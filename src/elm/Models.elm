module Models exposing (Model, initialModel)

import Dict exposing (Dict)
import Html exposing (Html)
import Msgs exposing (Msg)
import Phoenix.Socket
import Base64


type alias Model =
    { messages : List ChatMessage
    , phoenix_socket : Phoenix.Socket.Socket Msg
    , socket_location : String
    , channel_name : String
    , encrypted_options : String
    , public_api_id : String
    }


type alias ChatMessage =
    String


channelName : String -> String -> String
channelName public_api_id encrypted_options =
    "encrypted_chat:" ++ (Base64.encode public_api_id) ++ "#" ++ (Base64.encode encrypted_options)

initialModel : String -> String -> String -> Model
initialModel public_api_id encrypted_options socket_location =
    { messages = []
    , channel_name = (channelName public_api_id encrypted_options)
    , phoenix_socket = Phoenix.Socket.init socket_location
    , encrypted_options = encrypted_options
    , public_api_id = public_api_id
    , socket_location = socket_location
    }
