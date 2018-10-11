module Models exposing (Model, chatMessageDecoder, initialModel, ScrollInfo, scrollInfoDecoder)

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
    , scroll_info : ScrollInfo
    , overridden_scroll_height : Int
    , fetching_messages : Bool
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


type alias ScrollInfo =
    { scrollLeft : Int
    , scrollTop : Int
    , scrollWidth : Int
    , scrollHeight : Int
    }


scrollInfoDecoder =
    JD.map4 ScrollInfo
        (JD.field "scrollLeft" JD.int)
        (JD.field "scrollTop" JD.int)
        (JD.field "scrollWidth" JD.int)
        (JD.field "scrollHeight" JD.int)


initialScrollInfo =
    ScrollInfo 0 0 0 0


channelName : String -> String -> String
channelName public_api_id encrypted_options =
    "encrypted_chat:" ++ Base64.encode public_api_id ++ "#" ++ Base64.encode encrypted_options


initialModel : String -> String -> String -> Model
initialModel public_api_id encrypted_options socket_location =
    { messages = Dict.empty
    , oldest_timestamp  = Nothing
    , draft_message = ""
    , channel_name = channelName public_api_id encrypted_options
    , phoenix_socket = Phoenix.Socket.init socket_location
    , encrypted_options = encrypted_options
    , public_api_id = public_api_id
    , socket_location = socket_location
    , current_user_name = Nothing
    , scroll_info = initialScrollInfo
    , overridden_scroll_height = 1000000
    , fetching_messages = False
    }
