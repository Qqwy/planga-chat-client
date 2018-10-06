module Routing exposing (..)

import Navigation
import Models exposing (Route(..))
import MagicTheGathering.Models exposing (CardId)
import UrlParser exposing ((</>))
import Html
import Html.Events
import Json.Decode
import Msgs


matchers : UrlParser.Parser (Route -> a) a
matchers =
    UrlParser.oneOf
        [UrlParser.map CardsRoute UrlParser.top
        , UrlParser.map CardDetailRoute (UrlParser.s "cards" </> UrlParser.string)
        , UrlParser.map CardsRoute (UrlParser.s "cards")
        , UrlParser.map ShoppingCartRoute (UrlParser.s "cart")
        ]

toPath : Route -> String
toPath route =
    case route of
        CardsRoute ->
            "/"
        CardDetailRoute card_id ->
            "/cards/" ++ card_id
        ShoppingCartRoute ->
            "/cart"
        NotFoundRoute ->
            "/404"

parseLocation : Navigation.Location -> Route
parseLocation location =
    case (UrlParser.parsePath matchers location) of
        Just route ->
            route
        Nothing ->
            NotFoundRoute

linkTo : String -> Html.Attribute Msgs.Msg
linkTo path = Html.Events.onWithOptions "click" { stopPropagation = True, preventDefault = True } (Json.Decode.succeed (Msgs.NavigateTo path))

cardsPath : String
cardsPath = toPath CardsRoute

cardDetailPath : CardId -> String
cardDetailPath card_id = toPath (CardDetailRoute card_id)

shoppingCartPath : String
shoppingCartPath = toPath ShoppingCartRoute
