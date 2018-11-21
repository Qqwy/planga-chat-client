module Models exposing (Model, Options, chatMessageDecoder, initialModel, optionsDecoder, uniqueMessagesContainerId)

import Base64
import Dict exposing (Dict)
import Json.Decode as JD
import Msgs exposing (Msg)
import Phoenix.Socket


type alias UUID =
    String


type alias Model =
    { messages : Dict UUID ChatMessage
    , oldest_timestamp : Maybe String
    , draft_message : String
    , phoenix_socket : Phoenix.Socket.Socket Msg
    , socket_location : String
    , channel_name : String
    , encrypted_options : String
    , public_api_id : String
    , current_user_name : Maybe String
    , fetching_messages_scroll_pos : Maybe Float
    }


type alias ChatMessage =
    { uuid : String
    , name : String
    , content : String
    , sent_at : String
    , deleted_at : Maybe String
    }


type alias Options =
    { public_api_id : String
    , encrypted_options : String
    , socket_location : String
    , debug : Bool
    }


optionsDecoder : JD.Decoder Options
optionsDecoder =
    JD.map4 Options
        (JD.field "public_api_id" JD.string)
        (JD.field "encrypted_options" JD.string)
        (JD.field "socket_location" JD.string)
        (JD.oneOf [ JD.field "debug" JD.bool, JD.succeed False ])


chatMessageDecoder : JD.Decoder ChatMessage
chatMessageDecoder =
    JD.map5 ChatMessage
        (JD.field "uuid" JD.string)
        (JD.field "name" JD.string)
        (JD.field "content" JD.string)
        (JD.field "sent_at" JD.string)
        (JD.field "deleted_at" (JD.nullable JD.string))


channelName : String -> String -> String
channelName public_api_id encrypted_options =
    "encrypted_chat:" ++ Base64.encode public_api_id ++ "#" ++ Base64.encode encrypted_options


initialModel : String -> String -> String -> Model
initialModel public_api_id encrypted_options socket_location =
    { messages = Dict.empty
    , oldest_timestamp = Nothing
    , draft_message = ""
    , channel_name = channelName public_api_id encrypted_options
    , phoenix_socket = Phoenix.Socket.init socket_location
    , encrypted_options = encrypted_options
    , public_api_id = public_api_id
    , socket_location = socket_location
    , current_user_name = Nothing
    , fetching_messages_scroll_pos = Just 0
    }


uniqueMessagesContainerId model =
    "planga--chat-messages/" ++ model.encrypted_options
