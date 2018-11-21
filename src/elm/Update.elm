module Update exposing (update)

import Debug
import Dict
import Dom.Scroll
import Json.Decode as JD
import Json.Encode as JE
import Maybe.Extra
import Models exposing (Model, uniqueMessagesContainerId)
import Msgs exposing (Msg)
import Phoenix.Push
import Phoenix.Socket
import Ports
import Scroll
import Task


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msgs.NoOp ->
            ( model, Cmd.none )

        Msgs.Debug string ->
            let
                _ =
                    Debug.log "Debug" string
            in
            ( model, Cmd.none )

        Msgs.PhoenixMsg msg ->
            let
                ( phoenix_socket, phoenix_command ) =
                    Phoenix.Socket.update msg model.phoenix_socket
            in
            ( { model | phoenix_socket = phoenix_socket }
            , Cmd.map Msgs.PhoenixMsg phoenix_command
            )

        Msgs.ShowJoinedMessage value ->
            case JD.decodeValue (JD.field "current_user_name" JD.string) value of
                Ok current_user_name ->
                    ( { model | current_user_name = Just current_user_name }
                    , Cmd.none
                    )

                Err err ->
                    ( model, Cmd.none )

        Msgs.ShowLeftMessage ->
            ( model, Cmd.none )

        Msgs.ShowErrorMessage ->
            ( model, Cmd.none )

        Msgs.SendMessage message ->
            let
                constructed_message =
                    JE.object
                        [ ( "message", JE.string message )
                        ]

                push_data =
                    Phoenix.Push.init "new_message" model.channel_name
                        |> Phoenix.Push.withPayload constructed_message

                ( phoenix_socket, phoenix_command ) =
                    Phoenix.Socket.push push_data model.phoenix_socket
            in
            ( { model | phoenix_socket = phoenix_socket, draft_message = "" }, Cmd.map Msgs.PhoenixMsg phoenix_command )

        -- TODO Desktop notifications!
        Msgs.ReceiveMessage message_json ->
            case JD.decodeValue Models.chatMessageDecoder message_json of
                Err error ->
                    ( model, Cmd.none )

                Ok chatMessage ->
                    let
                        updated_messages =
                            Dict.insert chatMessage.uuid chatMessage model.messages

                        oldest_timestamp =
                            model.oldest_timestamp
                                |> minimumMaybe (Just chatMessage.sent_at)
                    in
                    ( { model | messages = updated_messages, oldest_timestamp = oldest_timestamp }
                    , Cmd.batch [Ports.scrollToBottom, Ports.sendBrowserNotification (chatMessage.name ++ ": " ++ chatMessage.content)]
                    )

        Msgs.ChangedChatMessage message_json ->
            case JD.decodeValue Models.chatMessageDecoder message_json of
                Err error ->
                    ( model, Cmd.none )

                Ok chatMessage ->
                    let
                        updated_messages =
                            Dict.insert chatMessage.uuid chatMessage model.messages
                    in
                    ( { model | messages = updated_messages }
                    , Cmd.none
                    )

        Msgs.MessagesSoFar messages_json ->
            let
                messagesDecoder =
                    JD.field "messages" (JD.list Models.chatMessageDecoder)

                fix_scroll_pos =
                    case model.fetching_messages_scroll_pos of
                        Nothing ->
                            Cmd.none

                        Just scroll_pos ->
                            Ports.keepVScrollPos

                -- Scroll.toBottomY (uniqueMessagesContainerId model) scroll_pos
                --     |> Task.attempt (always (Msgs.ScrollMsg Msgs.UnlockScrollHeight))
            in
            case JD.decodeValue messagesDecoder messages_json of
                Ok chat_messages ->
                    let
                        new_messages =
                            chat_messages
                                |> List.map (\message -> ( message.uuid, message ))
                                |> Dict.fromList

                        updated_messages =
                            model.messages
                                |> Dict.union new_messages

                        oldest_timestamp =
                            model.oldest_timestamp
                                |> minimumMaybe (List.minimum (List.map .sent_at chat_messages))
                    in
                    if List.length chat_messages == 0 then
                        ( model, Cmd.none )

                    else
                        ( { model
                            | messages = updated_messages
                            , oldest_timestamp = oldest_timestamp
                            , fetching_messages_scroll_pos = Nothing
                          }
                        , fix_scroll_pos
                        )

                Err error ->
                    ( model, fix_scroll_pos )

        Msgs.ChangeDraftMessage new_draft_message ->
            ( { model | draft_message = new_draft_message }, Cmd.none )

        Msgs.ScrollMsg scroll_msg ->
            updateScrollMsg model scroll_msg

        Msgs.HideChatMessage message_uuid ->
            let
                constructed_message =
                    JE.object
                        [ ( "message_uuid", JE.string message_uuid )
                        ]

                push_data =
                    Phoenix.Push.init "hide_message" model.channel_name
                        |> Phoenix.Push.withPayload constructed_message

                ( phoenix_socket, phoenix_command ) =
                    Phoenix.Socket.push push_data model.phoenix_socket
            in
            ( { model | phoenix_socket = phoenix_socket, draft_message = "" }, Cmd.map Msgs.PhoenixMsg phoenix_command )


updateScrollMsg : Model -> Msgs.ScrollMsg -> ( Model, Cmd Msgs.Msg )
updateScrollMsg model scroll_msg =
    case scroll_msg of
        Msgs.ScrollTopChanged ->
            let
                fetch_scroll_pos =
                    Task.map2 (\top bottom -> ( top, bottom ))
                        (Scroll.y (Models.uniqueMessagesContainerId model))
                        (Scroll.bottomY (Models.uniqueMessagesContainerId model))
                        |> Task.attempt Msgs.ScrollHeightCalculated
            in
            ( model, Cmd.map Msgs.ScrollMsg fetch_scroll_pos )

        Msgs.ScrollHeightCalculated val ->
            case val of
                Err _ ->
                    ( model, Cmd.none )

                Ok ( scroll_top, scroll_bottom ) ->
                    if scroll_top < 200 && Maybe.Extra.isNothing model.fetching_messages_scroll_pos then
                        fetchOldMessages model scroll_bottom

                    else
                        ( model, Cmd.none )

        -- DEPRECATED
        Msgs.UnlockScrollHeight ->
            ( { model | fetching_messages_scroll_pos = Nothing }, Cmd.none )


fetchOldMessages : Model -> Float -> ( Model, Cmd Msgs.Msg )
fetchOldMessages model scroll_bottom =
    case model.oldest_timestamp of
        Nothing ->
            ( model, Cmd.none )

        Just oldest_timestamp ->
            let
                payload =
                    JE.object
                        [ ( "sent_before", JE.string oldest_timestamp )
                        ]

                push_data =
                    Phoenix.Push.init "load_old_messages" model.channel_name
                        |> Phoenix.Push.withPayload payload
                        |> Phoenix.Push.onError (always (Msgs.ScrollMsg Msgs.UnlockScrollHeight))

                ( phoenix_socket, phoenix_command ) =
                    Phoenix.Socket.push push_data model.phoenix_socket
            in
            ( { model
                | phoenix_socket = phoenix_socket
                , fetching_messages_scroll_pos = Just scroll_bottom
              }
            , Cmd.map Msgs.PhoenixMsg phoenix_command
            )


minimumMaybe : Maybe String -> Maybe String -> Maybe String
minimumMaybe x y =
    case ( x, y ) of
        ( Nothing, y ) ->
            y

        ( x, Nothing ) ->
            x

        ( Just x, Just y ) ->
            Just (min x y)
