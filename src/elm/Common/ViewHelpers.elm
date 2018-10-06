module Common.ViewHelpers exposing (euroPrice, linkTo, linkToInNewTab, onClickWithoutPropagation)

import Html exposing (Html, a, div, li, span, text, ul)
import Html.Attributes exposing (class, href, rel, target)
import Html.Events
import Json.Decode
import Routing


linkTo path attributes content =
    a ([ href path, Routing.linkTo path ] ++ attributes) content


linkToInNewTab path attributes content =
    a ([ href path, target "_blank", rel "noopener noreferrer" ] ++ attributes) content


euroPrice amount =
    span []
        [ span [ class "euro-price--sign" ] [ text "€" ]
        , span [ class "euro-price--amount" ] [ text (toString amount) ]
        ]


onClickWithoutPropagation msg =
    Html.Events.onWithOptions "click" { stopPropagation = True, preventDefault = True } (Json.Decode.succeed msg)
