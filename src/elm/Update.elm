module Update exposing (update)

import Dict
import Models exposing (Model)
import Msgs exposing (Msg)
import Ports
import Phoenix.Socket
import Debug


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msgs.NoOp ->
            (model, Cmd.none)
        Msgs.PhoenixMsg msg ->
            let
                ( phoenix_socket, phoenix_command ) = Phoenix.Socket.update msg model.phoenix_socket
            in
                Debug.log"TEST" <|
                ( { model | phoenix_socket = phoenix_socket }
                , Cmd.map Msgs.PhoenixMsg phoenix_command
                )
        Msgs.ShowJoinedMessage ->
            Debug.log "Joined!"
                (model, Cmd.none)
        Msgs.ShowLeftMessage ->
            Debug.log "Left!"
                (model, Cmd.none)
        Msgs.ShowErrorMessage ->
            Debug.log "Error!"
                (model, Cmd.none)
