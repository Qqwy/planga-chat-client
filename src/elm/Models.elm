module Models exposing (Model, initialModel)

import Dict exposing (Dict)
import Html exposing (Html)
import Msgs exposing (Msg)
import Phoenix.Socket


type alias Model =
    { messages : List ChatMessage
    , phoenix_socket : Phoenix.Socket.Socket Msg
    }


type alias ChatMessage =
    String


initialModel : String -> Model
initialModel server_location =
    { messages = []
    , phoenix_socket = Phoenix.Socket.init server_location
    }
