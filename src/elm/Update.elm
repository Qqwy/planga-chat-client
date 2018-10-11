module Update exposing (update)

import Debug
import Dict
import Dom.Scroll
import Json.Decode as JD
import Json.Encode as JE
import Models exposing (Model)
import Msgs exposing (Msg)
import Phoenix.Push
import Phoenix.Socket
import Ports
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
            Debug.log "TEST" <|
                ( { model | phoenix_socket = phoenix_socket }
                , Cmd.map Msgs.PhoenixMsg phoenix_command
                )

        Msgs.ShowJoinedMessage value ->
            Debug.log ("Joined!" ++ toString value) <|
                case JD.decodeValue (JD.field "current_user_name" JD.string) value of
                    Ok current_user_name ->
                        ( { model | current_user_name = Just current_user_name }
                        , Cmd.none
                        )

                    Err err ->
                        ( model, Cmd.none )

        Msgs.ShowLeftMessage ->
            Debug.log "Left!"
                ( model, Cmd.none )

        Msgs.ShowErrorMessage ->
            Debug.log "Error!"
                ( model, Cmd.none )

        Msgs.SendMessage message ->
            Debug.log "Sending Message!" <|
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

        Msgs.ReceiveMessage message_json ->
            Debug.log "Receiving message!" <|
                case JD.decodeValue Models.chatMessageDecoder message_json of
                    Ok chatMessage ->
                        let
                            updated_messages =
                                Dict.insert chatMessage.uuid chatMessage model.messages

                            oldest_timestamp =
                                model.oldest_timestamp
                                    |> minimumMaybe (Just chatMessage.sent_at)
                        in
                        ( { model | messages = updated_messages, oldest_timestamp = oldest_timestamp }
                        , Ports.scrollToBottom
                        )

                    Err error ->
                        ( model, Cmd.none )

        Msgs.MessagesSoFar messages_json ->
            let
                messagesDecoder =
                    JD.field "messages" (JD.list Models.chatMessageDecoder)
            in
            Debug.log ("Receiving old messages!" ++ toString messages_json) <|
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

                            new_scroll_height =
                                model.scroll_info.scrollHeight - model.scroll_info.scrollTop

                            oldest_timestamp =
                                model.oldest_timestamp
                                    |> minimumMaybe (List.minimum (List.map .sent_at chat_messages))
                        in
                        ( { model
                            | messages = updated_messages
                            , fetching_messages = False
                            , overridden_scroll_height = new_scroll_height
                            , oldest_timestamp = oldest_timestamp
                          }
                        , Dom.Scroll.toBottom "planga--chat-messages" |> Task.attempt (toString >> Msgs.Debug)
                        )

                    Err error ->
                        ( model, Dom.Scroll.toBottom "planga--chat-messages" |> Task.attempt (toString >> Msgs.Debug) )

        Msgs.ChangeDraftMessage new_draft_message ->
            ( { model | draft_message = new_draft_message }, Cmd.none )

        Msgs.ScrollUpdate event ->
            let
                command =
                    Dom.Scroll.y "planga--chat-messages"
                        |> Task.attempt Msgs.ScrollHeightCalculated
            in
            ( model, command )

        Msgs.ScrollHeightCalculated val ->
            -- TODO: Debounce
            case val of
                Err _ ->
                    ( model, Cmd.none )

                Ok scrollTop ->
                    if scrollTop < 50 && model.fetching_messages == False then
                        fetchOldMessages model

                    else
                        Debug.log "Doing nothing, not high enough scrolled" <|
                            ( model, Cmd.none )

        Msgs.FetchingMessagesFailed _ ->
            ( { model | fetching_messages = False }, Cmd.none )


fetchOldMessages model =
    case model.oldest_timestamp of
        Nothing ->
            ( model, Cmd.none )

        Just oldest_timestamp ->
            Debug.log "Sending Message!" <|
                let
                    constructed_message =
                        JE.object
                            [ ( "sent_before", JE.string oldest_timestamp )
                            ]

                    push_data =
                        Phoenix.Push.init "load_old_messages" model.channel_name
                            |> Phoenix.Push.withPayload constructed_message
                            |> Phoenix.Push.onError Msgs.FetchingMessagesFailed

                    ( phoenix_socket, phoenix_command ) =
                        Phoenix.Socket.push push_data model.phoenix_socket
                in
                ( { model | phoenix_socket = phoenix_socket, fetching_messages = True }
                , Cmd.batch
                    [ Cmd.map Msgs.PhoenixMsg phoenix_command
                    , Ports.keepVScrollPos
                    ]
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
