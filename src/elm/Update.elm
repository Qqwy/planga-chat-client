module Update exposing (update)

import Dict
import Models exposing (Model)
import Msgs exposing (Msg)
import Ports
import Phoenix.Socket
import Phoenix.Push
import Debug
import Json.Encode as JE
import Json.Decode as JD


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msgs.NoOp ->
            (model, Cmd.none)
        Msgs.Debug string ->
            let
                _ = Debug.log "Debug" string
            in
                (model, Cmd.none)
        Msgs.PhoenixMsg msg ->
            let
                ( phoenix_socket, phoenix_command ) = Phoenix.Socket.update msg model.phoenix_socket
            in
                Debug.log"TEST" <|
                ( { model | phoenix_socket = phoenix_socket }
                , Cmd.map Msgs.PhoenixMsg phoenix_command
                )
        Msgs.ShowJoinedMessage value ->
            Debug.log ("Joined!" ++ toString value) <|
              case JD.decodeValue (JD.field "current_user_name" JD.string) value of
                  Ok current_user_name ->
                      ({model | current_user_name = Just current_user_name},
                      Cmd.none)
                  Err err ->
                      (model, Cmd.none)
        Msgs.ShowLeftMessage ->
            Debug.log "Left!"
                (model, Cmd.none)
        Msgs.ShowErrorMessage ->
            Debug.log "Error!"
                (model, Cmd.none)
        Msgs.SendMessage message ->
            Debug.log "Sending Message!" <|
                let
                    constructed_message =
                        JE.object [
                             ("message", JE.string message)
                            ]
                    push_data =
                        Phoenix.Push.init "new_message" model.channel_name
                            |> Phoenix.Push.withPayload constructed_message
                    ( phoenix_socket, phoenix_command ) =
                        Phoenix.Socket.push push_data model.phoenix_socket
                in
                    ({model | phoenix_socket = phoenix_socket, draft_message = ""}, Cmd.map Msgs.PhoenixMsg phoenix_command)
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
                          ( { model | messages = updated_messages, oldest_timestamp = oldest_timestamp}
                          , Ports.scrollToBottom
                          )
                  Err error ->
                      ( model, Cmd.none )

        Msgs.MessagesSoFar messages_json ->
            let
                messagesDecoder =
                    (JD.field "messages" (JD.list Models.chatMessageDecoder) )
            in
              Debug.log ("Receiving old messages!" ++ toString messages_json) <|
                case JD.decodeValue messagesDecoder messages_json of
                    Ok chat_messages ->
                        let
                          new_messages =
                              chat_messages
                                  |> List.map (\message -> (message.uuid, message))
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
                            (
                             { model | messages = updated_messages,
                                   overridden_scroll_height = new_scroll_height
                             , oldest_timestamp = oldest_timestamp
                             }
                            , Ports.keepVScrollPos
                            )
                    Err error ->
                        (model, Cmd.none)

        Msgs.ChangeDraftMessage new_draft_message ->
            ({model | draft_message = new_draft_message}, Cmd.none)
        Msgs.ScrollUpdate event ->
            (model, Ports.fetchScrollPos event)
        Msgs.ScrollHeightCalculated val ->
            case JD.decodeValue Models.scrollInfoDecoder val of
                Err _ ->
                    (model, Cmd.none)
                Ok scroll_info ->
                    if scroll_info.scrollTop < 50 then
                        fetchOldMessages model
                    else
                        ({model | scroll_info = scroll_info}, Cmd.none)

fetchOldMessages model =
    case model.oldest_timestamp of
        Nothing ->
            (model, Cmd.none)
        Just oldest_timestamp -> 
          Debug.log "Sending Message!" <|
              let
                  constructed_message =
                      JE.object [
                          ("sent_before", JE.string oldest_timestamp)
                          ]
                  push_data =
                      Phoenix.Push.init "load_old_messages" model.channel_name
                          |> Phoenix.Push.withPayload constructed_message
                  ( phoenix_socket, phoenix_command ) =
                      Phoenix.Socket.push push_data model.phoenix_socket
              in
                  ({model | phoenix_socket = phoenix_socket}, Cmd.map Msgs.PhoenixMsg phoenix_command)


minimumMaybe : Maybe String -> Maybe String -> Maybe String
minimumMaybe x y =
    case (x, y) of
        (Nothing, y) ->
            y
        (x, Nothing) ->
            x
        (Just x, Just y) ->
            Just (min x y)
