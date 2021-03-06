port module Ports exposing (fetchScrollPos, keepVScrollPos, persistToStorage, scrollToBottom, scrollUpdate, unlockVScrollPos, sendBrowserNotification)

import Json.Decode
import Json.Encode


port persistToStorage : Json.Encode.Value -> Cmd msg


port fetchScrollPos : Json.Encode.Value -> Cmd msg


port scrollUpdate : (Json.Decode.Value -> msg) -> Sub msg


port scrollToBottomPort : () -> Cmd msg


scrollToBottom : Cmd msg
scrollToBottom =
    scrollToBottomPort ()


port keepVScrollPosPort : () -> Cmd msg


keepVScrollPos : Cmd msg
keepVScrollPos =
    keepVScrollPosPort ()


port unlockVScrollPosPort : () -> Cmd msg


unlockVScrollPos : Cmd msg
unlockVScrollPos =
    unlockVScrollPosPort ()

port sendBrowserNotification : String -> Cmd msg
