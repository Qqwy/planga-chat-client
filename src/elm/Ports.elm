port module Ports exposing (fetchScrollPos, persistToStorage, scrollUpdate, scrollToBottom, keepVScrollPos)

import Json.Decode
import Json.Encode


port persistToStorage : Json.Encode.Value -> Cmd msg



port fetchScrollPos : Json.Encode.Value -> Cmd msg


port scrollUpdate : (Json.Decode.Value -> msg) -> Sub msg

port scrollToBottomPort : () -> Cmd msg

scrollToBottom : Cmd msg
scrollToBottom = scrollToBottomPort ()

port keepVScrollPosPort : () -> Cmd msg

keepVScrollPos : Cmd msg
keepVScrollPos = keepVScrollPosPort ()
