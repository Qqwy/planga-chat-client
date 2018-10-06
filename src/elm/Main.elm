port module Main exposing (init, main, subscriptions)

import Models exposing (Model, initialModel)
import Msgs exposing (Msg)
import Update
import View
import Html



init : String -> ( Model, Cmd Msg )
init flags =
    let
        model =
            initialModel
    in
    ( model |> parseFlags flags, Cmd.none )


parseFlags : String -> Model -> Model
parseFlags flags model =
        model


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



main : Program String Model Msg
main =
    Html.programWithFlags
        { init = init
        , view = View.view
        , update = Update.update
        , subscriptions = subscriptions
        }


