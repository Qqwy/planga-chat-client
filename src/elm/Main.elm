port module Main exposing (init, main, subscriptions)

import Json.Decode
import Json.Encode
import Models exposing (Model, initialModel)
import Msgs exposing (Msg)
import Update
import View




init : String -> Navigation.Location -> ( Model, Cmd Msg )
init flags location =
    let
        currentRoute =
            Routing.parseLocation location

        model =
            initialModel currentRoute
    in
    ( model |> parseFlags flags, Cmd.none )


parseFlags : String -> Model -> Model
parseFlags flags model =
    let
        newShoppingCart =
            flags
                |> ShoppingCart.jsonDecodeString
    in
    { model | shoppingCart = newShoppingCart |> Result.withDefault model.shoppingCart }


subscriptions : Model -> Sub Msg
subscriptions model =
    ShoppingCart.onChange (Result.withDefault model.shoppingCart >> Msgs.LoadCartFromStorage)



main : Program String Model Msg
main =
    Navigation.programWithFlags Msgs.LocationChange
        { init = init
        , view = View.view
        , update = Update.update
        , subscriptions = subscriptions
        }


