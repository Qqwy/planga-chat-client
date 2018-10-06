port module Main exposing (init, main, subscriptions)

import Json.Decode
import Json.Encode
import Models exposing (Model, initialModel)
import Msgs exposing (Msg)
import Navigation
import Routing
import ShoppingCart exposing (ShoppingCart)
import Storage
import Update
import View



-- encodeStorageRequest : Int -> String
-- encodeStorageRequest val =
--     Json.Encode.encode 0 (Json.Encode.int val)


decodeStorageResponse : String -> Result String Int
decodeStorageResponse str =
    Json.Decode.decodeString Json.Decode.int str


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



-- Storage.onChange ShoppingCart.storageConfig (toString >> Msgs.PrintDebug "Storage Debug")
-- incoming (toString >> Msgs.PrintDebug "DEBUG")


main : Program String Model Msg
main =
    Navigation.programWithFlags Msgs.LocationChange
        { init = init
        , view = View.view
        , update = Update.update
        , subscriptions = subscriptions
        }



-- initialStorageConfig : Storage.Config Int Msg
-- initialStorageConfig =
--     { outgoingPort = outgoing
--     , incomingPort = incoming
--     , serializeToStorage = toString
--     , deserializeFromStorage = String.toInt
--     , storageMsg = Msgs.StorageWIPMsg
--     , storageKey = "MagicMillStorage"
--     }
