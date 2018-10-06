module Models exposing (Model, initialModel)

import Dict exposing (Dict)
import Html exposing (Html)


type alias Model = {
        messages: List ChatMessage
    }

type alias ChatMessage = String


initialModel : Model
initialModel =
    {
        messages= []
    }
