module Msgs exposing (Msg(..), ScrollMsg(..))
import Phoenix.Socket
import Json.Decode as JD
import Scroll
import Dom

type ScrollMsg
    = ScrollTopChanged
    | ScrollHeightCalculated (Result Dom.Error (Float, Float))
    | UnlockScrollHeight

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
    | ScrollMsg ScrollMsg
    | HideChatMessage String
    | ChangedChatMessage JD.Value
    | ChangedConversationUserInfo JD.Value
