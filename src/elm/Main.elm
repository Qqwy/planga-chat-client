port module Main exposing (init, main, subscriptions)

import Html
import Models exposing (Model, initialModel)
import Msgs exposing (Msg)
import Phoenix.Socket
import Phoenix.Channel
import Update
import View
import Json.Encode as JE


init : String -> ( Model, Cmd Msg )
init flags =
    let
        model =
            initialModel "http://localhost:4000/socket/websocket"
    in
        model
            |> parseFlags flags

userParams : JE.Value
userParams =
    JE.object [ ( "user_id", JE.string "123" ) ]

setupConnection : Model -> (Model, Cmd Msg)
setupConnection model =
    let
        channel =
            Phoenix.Channel.init "rooms:lobby"
                |> Phoenix.Channel.withPayload userParams
                |> Phoenix.Channel.onJoin (always (Msgs.ShowJoinedMessage))
                |> Phoenix.Channel.onError (always (Msgs.ShowErrorMessage))
                |> Phoenix.Channel.onClose (always (Msgs.ShowLeftMessage))
        (phoenix_socket, phoenix_cmd) =
            Phoenix.Socket.join channel model.phoenix_socket
    in
        ({model | phoenix_socket = phoenix_socket}, Cmd.map Msgs.PhoenixMsg phoenix_cmd)
        -- (model, Cmd.none)

parseFlags : String -> Model -> (Model, Cmd Msg)
parseFlags flags model =
    model
        |> setupConnection


subscriptions : Model -> Sub Msg
subscriptions model =
    Phoenix.Socket.listen model.phoenix_socket Msgs.PhoenixMsg


main : Program String Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = View.view
        , update = Update.update
        , subscriptions = subscriptions
        }
