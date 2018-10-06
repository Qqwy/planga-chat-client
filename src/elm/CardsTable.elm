module CardsTable exposing (addToCartColumn, artColumn, castingCostColumn, config, priceColumn, toRowAttrs, view)

import Common.Euro
import Common.ViewHelpers
import Dict
import Html exposing (Attribute, Html, a, div, h1, img, input, p, text)
import Html.Attributes exposing (class, href, rel, src, style, target)
import Html.Events
import MagicTheGathering.Models exposing (Card)
import MagicTheGathering.View
import Msgs exposing (Msg(..))
import Routing
import Semantic
import ShoppingCart.View
import Table exposing (defaultCustomizations)


view { cards, cardsTableState, searchQuery, shoppingCart } =
    let
        filteredCards =
            cards
                |> Dict.values
                |> List.filter (.title >> String.toLower >> String.contains (searchQuery |> String.toLower))

        paginatedCards =
            filteredCards
                |> List.take 100

        -- Table.getSortedData config cardsTableState filteredCards
        --     |> List.take 1
    in
    div []
        [ Table.view (config shoppingCart) cardsTableState paginatedCards
        ]


config shoppingCart =
    Table.customConfig
        { toId = .id
        , toMsg = SetCardsTableState
        , columns =
            [ artColumn
            , titleColumn "Titel"
            , castingCostColumn
            , priceColumn "Prijs" .price
            , addToCartColumn shoppingCart
            ]
        , customizations =
            { defaultCustomizations
                | rowAttrs = toRowAttrs
                , tableAttrs = [ class "ui basic table" ]
            }
        }

titleColumn name =
    Table.veryCustomColumn
        { name = name
        , viewData =
        \card ->
        Table.HtmlDetails [] [
               Common.ViewHelpers.linkToInNewTab (Routing.cardDetailPath card.id) [] [text card.title]
              ]
            , sorter = Table.increasingOrDecreasingBy (.title)
        }

priceColumn name fieldSelector =
    let
        infinity =
            1 / 0
    in
    Table.veryCustomColumn
        { name = name
        , viewData =
            fieldSelector
                >> (\price ->
                        case price of
                            Just amount ->
                                Table.HtmlDetails [] [ text (Common.Euro.render amount) ]

                            Nothing ->
                                Table.HtmlDetails [] [ text "?" ]
                   )
        , sorter = Table.increasingOrDecreasingBy (fieldSelector >> Maybe.map Common.Euro.toFloat >> Maybe.withDefault infinity)
        }


artColumn =
    Table.veryCustomColumn
        { name = "Afbeelding"
        , viewData =
            \card ->
                Table.HtmlDetails
                    [
                    ]
                    [ Common.ViewHelpers.linkToInNewTab (Routing.cardDetailPath card.id) []
                        [ img
                            [ src card.artUrl, style [ ( "max-width", "100px" ) ] ]
                            []
                        ]
                    ]
        , sorter = Table.unsortable
        }


castingCostColumn =
    Table.veryCustomColumn
        { name = "Mana"
        , viewData = .castingCost >> (\cost -> Table.HtmlDetails [] [ MagicTheGathering.View.viewManaCost cost ])
        , sorter = Table.unsortable
        }


addToCartColumn shoppingCart =
    let
        renderCartButtonHtml card =
            if MagicTheGathering.Models.isCardBuyable card then
                [ Semantic.iconButton "cart" [ class "primary", Common.ViewHelpers.onClickWithoutPropagation (Msgs.CartMsg <| Msgs.IncrementCartContents card.id) ] ]

            else
                [ Semantic.iconButton "cart" [ class "disabled" ] ]
    in
    Table.veryCustomColumn
        { name = ""
        , viewData = ShoppingCart.View.addToCartButton shoppingCart >> (\html -> Table.HtmlDetails [ style [ ( "width", "100px" ), ( "text-align", "right" ) ] ] [ html ])
        , sorter = Table.unsortable
        }


toRowAttrs : Card -> List (Attribute Msg)
toRowAttrs card =
    [ -- Routing.linkTo (Routing.cardDetailPath card.id)
      -- Html.Events.onClick (Msgs.OpenInNewPage (Routing.cardDetailPath card.id))
      Html.Events.onMouseOver (PreviewCard card)
    , class "cards-table-row"
    ]
