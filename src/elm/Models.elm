module Models exposing (Breadcrumb, Model, PageContent, Route(..), initialModel)

-- import Msgs exposing (Msg)

import Dict exposing (Dict)
import Html exposing (Html)
import MagicTheGathering.Models exposing (Card, CardId, SetId, initialCards)
import ShoppingCart exposing (ShoppingCart, ShippingOption(..))
import Table


type alias Model =
    { route : Route
    , cards : Dict String Card
    , cardsTableState : Table.State
    , searchQuery : String
    , previewedCard : Maybe Card
    , shoppingCart : ShoppingCart
    }


initialModel : Route -> Model
initialModel route =
    { route = route
    , cards = initialCards
    , cardsTableState = Table.initialSort "Name"
    , searchQuery = ""
    , previewedCard = Nothing
    , shoppingCart = { contents = Dict.empty, shippingOption = Nothing }
    }


type Route
    = CardsRoute
    | CardDetailRoute CardId
    | ShoppingCartRoute
    | NotFoundRoute


type alias PageContent msg =
    { title : Html msg
    , breadcrumbs : List Breadcrumb
    , content : Html msg
    }


type alias Breadcrumb =
    ( Route, String )
