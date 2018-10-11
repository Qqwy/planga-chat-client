module Msgs exposing (Msg(..))
import Phoenix.Socket
import Json.Decode as JD
import Scroll
import Dom

type Msg
    = NoOp
    | Debug String
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | ShowJoinedMessage JD.Value
    | ShowErrorMessage
    | ShowLeftMessage
    | SendMessage String
    | ReceiveMessage JD.Value
    | MessagesSoFar JD.Value
    | ChangeDraftMessage String
    | ScrollUpdate JD.Value
    | ScrollHeightCalculated (Result Dom.Error Float)
    | FetchingMessagesFailed JD.Value
