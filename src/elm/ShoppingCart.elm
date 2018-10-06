module ShoppingCart exposing (ShippingOption(..), ShoppingCart, empty, jsonDecodeString, jsonDecoder, jsonEncodeString, jsonEncoder, onChange, persist, storageConfig, cartPrice)

import Dict exposing (Dict)
import Json.Decode
import Json.Encode
import MagicTheGathering.Models exposing (CardId)
import Ports
import Storage
import Maybe.Extra
import Common.Euro


type ShippingOption
    = UnknownShippingCost


type alias ShoppingCart =
    { contents : Dict CardId Int
    , shippingOption : Maybe ShippingOption
    }


empty : ShoppingCart
empty =
    { contents = Dict.empty, shippingOption = Nothing }


jsonEncoder : ShoppingCart -> Json.Encode.Value
jsonEncoder { contents, shippingOption } =
    Json.Encode.object
        [ ( "contents", Json.Encode.object (contents |> Dict.map (\_ a -> a |> Json.Encode.int) |> Dict.toList) )
        , ( "shippingOption", Json.Encode.null )
        ]


jsonDecoder : Json.Decode.Decoder ShoppingCart
jsonDecoder =
    Json.Decode.map2 ShoppingCart
        (Json.Decode.field "contents" (Json.Decode.dict Json.Decode.int))
        (Json.Decode.field "shippingOption" (Json.Decode.maybe (Json.Decode.succeed UnknownShippingCost)))


jsonDecodeString =
    Json.Decode.decodeString jsonDecoder


jsonEncodeString cart =
    Json.Encode.encode 0 (jsonEncoder cart)


storageConfig : Storage.Config ShoppingCart msg
storageConfig =
    { outgoingPort = Ports.persistToStorage
    , incomingPort = Ports.storageUpdate
    , serialize = jsonEncodeString
    , deserialize = jsonDecodeString
    }


persist : ShoppingCart -> Cmd msg
persist cart =
    Storage.persist storageConfig cart


onChange msgFun =
    Storage.onChange storageConfig msgFun


cartPrice shoppingCart cards =
    let
        cardPriceSum cardId amount =
            cards
                |> Dict.get cardId
                |> Maybe.andThen .price
                |> Maybe.map (\price -> Common.Euro.mulInt price amount)
    in
    shoppingCart.contents
        |> Dict.map cardPriceSum
        |> Dict.values
        |> Maybe.Extra.values
        |> List.foldr Common.Euro.add Common.Euro.zero
