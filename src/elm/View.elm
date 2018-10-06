module View exposing (view)

-- import Listings

import Html exposing (Html, div, footer, header, span, text)
import Html.Attributes exposing (class)
import Models exposing (Model)
import Msgs exposing (Msg)


view : Model -> Html Msg
view model =
    div [] [text "This is where the magic happens!"]


