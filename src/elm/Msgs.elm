module Msgs exposing (Msg(..))
import Phoenix.Socket
import Json.Decode as JD
import Scroll

type Msg
    = NoOp
    | Debug JD.Value
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | ShowJoinedMessage JD.Value
    | ShowErrorMessage
    | ShowLeftMessage
    | SendMessage String
    | ReceiveMessage JD.Value
    | MessagesSoFar JD.Value
    | ChangeDraftMessage String
    | ScrollUpdate JD.Value
    | ScrollHeightCalculated JD.Value

