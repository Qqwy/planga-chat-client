module Msgs exposing (Msg(..), ScrollMsg(..))
import Phoenix.Socket
import Json.Decode as JD
import Dom
import Models exposing (ChatMessage, UUID)
import Time

type alias DurationMinutes = Int

type ScrollMsg
    = ScrollTopChanged
    | ScrollHeightCalculated (Result Dom.Error (Float, Float))
    | UnlockScrollHeight

type Msg
    = NoOp
    | Debug String
    | Tick Time.Time
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | ShowJoinedMessage JD.Value
    | ShowErrorMessage
    | ShowLeftMessage
    | SendMessage String
    | ReceiveMessage JD.Value
    | MessagesSoFar JD.Value
    | ChangeDraftMessage String
    | ScrollMsg ScrollMsg
    | HideChatMessage UUID
    | BanUser UUID DurationMinutes
    | ChangedChatMessage JD.Value
    | ChangedYourConversationUserInfo JD.Value
    | ChangedConversationUserInfo JD.Value
    | OpenModerationWindow ChatMessage
    | CloseModerationWindow
