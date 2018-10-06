port module Ports exposing (fetchScrollPos, persistToStorage, scrollUpdate)

import Json.Decode
import Json.Encode


port persistToStorage : Json.Encode.Value -> Cmd msg



port fetchScrollPos : Json.Encode.Value -> Cmd msg


port scrollUpdate : (Json.Decode.Value -> msg) -> Sub msg
