module Models exposing (Model, chatMessageDecoder, initialModel)

import Base64
import Dict exposing (Dict)
import Json.Decode as JD
import Msgs exposing (Msg)
import Phoenix.Socket


type alias UUID =
    String


type alias Model =
    { messages : Dict UUID ChatMessage
    , draft_message : String
    , phoenix_socket : Phoenix.Socket.Socket Msg
    , socket_location : String
    , channel_name : String
    , encrypted_options : String
    , public_api_id : String
    , current_user_name : Maybe String
    }


type alias ChatMessage =
    { uuid : String
    , name : String
    , content : String
    , sent_at : String
    }


chatMessageDecoder =
    JD.map4 ChatMessage
        (JD.field "uuid" JD.string)
        (JD.field "name" JD.string)
        (JD.field "content" JD.string)
        (JD.field "sent_at" JD.string)


channelName : String -> String -> String
channelName public_api_id encrypted_options =
    "encrypted_chat:" ++ Base64.encode public_api_id ++ "#" ++ Base64.encode encrypted_options


initialModel : String -> String -> String -> Model
initialModel public_api_id encrypted_options socket_location =
    { messages = Dict.empty
    , draft_message = ""
    , channel_name = channelName public_api_id encrypted_options
    , phoenix_socket = Phoenix.Socket.init socket_location
    , encrypted_options = encrypted_options
    , public_api_id = public_api_id
    , socket_location = socket_location
    , current_user_name = Nothing
    }
