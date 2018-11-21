port module Main exposing (init, main, subscriptions)

import Html
import Json.Encode as JE
import Json.Decode as JD
import Models exposing (Model, initialModel, Options)
import Msgs exposing (Msg)
import Phoenix.Channel
import Phoenix.Socket
import Scroll
import Update
import View
import Ports
import Dom.Scroll
import Task


init : JD.Value -> ( Model, Cmd Msg )
init flags =
    let
        options = case JD.decodeValue Models.optionsDecoder flags of
                      Ok res -> res |> Debug.log "Options parsed!"
                      Err error -> Debug.crash ("Could not start Planga application:" ++ (toString error))
        -- public_api_id =
        --     "foobar"

        -- encrypted_options =
        --     "eyJhbGciOiJBMTI4R0NNS1ciLCJlbmMiOiJBMTI4R0NNIiwiaXYiOiJ4VVgyM0NreGFoaFZxU1pnIiwidGFnIjoiREVIYldpV3p0Zy1NYjJFcU5UMHBPQSJ9.KMHBCIOzNHzbV-tFMS0_dg.qWj7Hloah1mhEbAk.zmijotwRq9lK9VcbRGWdY2BOjCLHjNAKaDf0wsRH7Rs8moMnVmnZYk8gQnBv1i-mtbj_NwPcBawG4XddpU9dgIMowSYN7XGCXBhf24za274w43sJyRlVgac.ZlNeDKNjXdHEftHaXh7KRA"

        -- socket_location =
        --     "ws://localhost:4000/socket/websocket"

        model =
            initialModel options.public_api_id options.encrypted_options (options.socket_location ++ "/websocket")

        -- initialModel "ws://phoenixchat.herokuapp.com/ws"
    in
    model
        |> setupConnection
        -- |> parseFlags flags

-- parseFlags : JD.Value -> Options
-- parseFlags flags = 

-- userParams : String -> String -> JE.Value
-- userParams public_api_id encrypted_options =
--     -- JE.object [ ( "user_id", JE.string "123" ) ]
--     JE.object
--         [ ( "encrypted_chat", JE.string <| public_api_id ++ "#" ++ encrypted_options )
--         ]


-- flags =
--     JE.object
--         [ ( "public_api_id", JE.string "foobar" )
--         , ( "encrypted_options", JE.string "eyJhbGciOiJBMTI4R0NNS1ciLCJlbmMiOiJBMTI4R0NNIiwiaXYiOiJ4VVgyM0NreGFoaFZxU1pnIiwidGFnIjoiREVIYldpV3p0Zy1NYjJFcU5UMHBPQSJ9.KMHBCIOzNHzbV-tFMS0_dg.qWj7Hloah1mhEbAk.zmijotwRq9lK9VcbRGWdY2BOjCLHjNAKaDf0wsRH7Rs8moMnVmnZYk8gQnBv1i-mtbj_NwPcBawG4XddpU9dgIMowSYN7XGCXBhf24za274w43sJyRlVgac.ZlNeDKNjXdHEftHaXh7KRA" )
--         , ( "socket_location", JE.string "//localhost:4000/socket" )
--         ]


setupConnection : Model -> ( Model, Cmd Msg )
setupConnection model =
    let
        channel =
            Phoenix.Channel.init model.channel_name
                |> Phoenix.Channel.withPayload (JE.object [])
                |> Phoenix.Channel.onJoin Msgs.ShowJoinedMessage
                |> Phoenix.Channel.onError (always Msgs.ShowErrorMessage)
                |> Phoenix.Channel.onJoinError (always Msgs.ShowErrorMessage)
                |> Phoenix.Channel.onClose (always Msgs.ShowLeftMessage)

        ( phoenix_socket, phoenix_cmd ) =
            model.phoenix_socket
                |> Phoenix.Socket.withDebug
                |> Phoenix.Socket.on "new_remote_message" model.channel_name Msgs.ReceiveMessage
                |> Phoenix.Socket.on "changed_message" model.channel_name Msgs.ChangedChatMessage
                |> Phoenix.Socket.on "messages_so_far" model.channel_name Msgs.MessagesSoFar
                |> Phoenix.Socket.join channel
    in
    ( { model | phoenix_socket = phoenix_socket },
          Cmd.batch [
               Cmd.map Msgs.PhoenixMsg phoenix_cmd
              , Dom.Scroll.toBottom "planga--chat-messages" |> Task.attempt (toString >> Msgs.Debug)
              ]
              )




-- parseFlags : JD.Value -> Model -> ( Model, Cmd Msg )
-- parseFlags flags model =
--     let
--         options =
--             flags
--                 |> JD.decodeValue options_decoder
--                 |> Debug.log "Options decoding!"
--         options_decoder =
--             JD.field "socket_location" JD.string
--     in
--         model
--         |> setupConnection


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Phoenix.Socket.listen model.phoenix_socket Msgs.PhoenixMsg
        -- , Ports.scrollUpdate Msgs.ScrollHeightCalculated
        ]


main : Program JD.Value Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = View.view
        , update = Update.update
        , subscriptions = subscriptions
        }
