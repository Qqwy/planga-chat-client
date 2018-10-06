module Storage exposing (Config, onChange, persist)

import Json.Decode
import Json.Encode



-- import Porter


type alias Config val msg =
    { serialize : val -> String
    , deserialize : String -> Result String val
    , outgoingPort : Json.Encode.Value -> Cmd msg
    , incomingPort : (Json.Decode.Value -> msg) -> Sub msg
    }


persist : Config val msg -> val -> Cmd msg
persist { serialize, outgoingPort } value =
    value |> serialize |> Json.Encode.string |> outgoingPort


onChange : Config val msg -> (Result String val -> msg) -> Sub msg
onChange { deserialize, incomingPort } msgFun =
    incomingPort
        (Json.Decode.decodeValue Json.Decode.string
            >> Result.andThen deserialize
            >> msgFun
        )



-- port outgoing : Json.Encode.Value -> Cmd msg
-- port incoming : (Json.Decode.Value -> msg) -> Sub msg
-- encodeStorageRequest : Int -> String
-- encodeStorageRequest val =
--     Json.Encode.encode 0 (Json.Encode.int val)
-- decodeStorageResponse : String -> Result String Int
-- decodeStorageResponse str =
--     Json.Decode.decodeString Json.Decode.int str
-- type alias Msg val msg =
--     Porter.Msg val (Result String val) msg
-- type alias Config val msg =
--     { outgoingPort : Json.Encode.Value -> Cmd msg
--     , incomingPort : (Json.Decode.Value -> Msg val msg) -> Sub (Msg val msg)
--     , serializeToStorage : val -> String
--     , deserializeFromStorage : String -> Result String val
--     , storageMsg : Msg val msg -> msg
--     , storageKey : String
--     }
-- -- type MyMessageType
-- --     = Foo (Msg Int MyMessageType)
-- porterConfig : Config val msg -> Porter.Config val (Result String val) msg
-- porterConfig config =
--     { outgoingPort = config.outgoingPort
--     , incomingPort = config.incomingPort
--     , porterMsg = config.storageMsg
--     , decodeResponse = Json.Decode.string |> Json.Decode.map config.deserializeFromStorage
--     , encodeRequest = config.serializeToStorage >> Json.Encode.string
--     }
-- store : Config val msg -> val -> Cmd msg
-- store config val =
--     val |> config.serializeToStorage |> Json.Encode.string |> config.outgoingPort
-- -- load : Config val msg -> (res -> msg) -> Cmd msg
-- -- load config msgFun =
-- --     Porter.request "load"
-- --         |> Porter.send msgFun (porterConfig config)
