module Msgs exposing (Msg(..))
import Phoenix.Socket

type Msg
    = NoOp
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | ShowJoinedMessage
    | ShowErrorMessage
    | ShowLeftMessage
    | SendMessage String

