module Cards exposing (viewCardDetail, viewIndex)

import CardsTable
import Common.Euro
import Common.ViewHelpers exposing (linkTo)
import Html exposing (Html, a, div, i, img, input, li, span, text, ul)
import Html.Attributes exposing (class, href, placeholder, src, value)
import Html.Events exposing (onInput)
import MagicTheGathering.Models exposing (CastingCost, Color(..), Mana(..))
import MagicTheGathering.View
import Models exposing (Model, PageContent, Route(..))
import Msgs exposing (Msg(..))
import Routing
import Semantic


cardsBreadcrumbs : List ( Route, String )
cardsBreadcrumbs =
    [ ( CardsRoute, "Cards" ) ]


cardBreadcrumbs card =
    cardsBreadcrumbs ++ [ ( CardDetailRoute card.id, card.title ) ]


viewIndex model =
    let
        title =
            text "All Cards"

        content =
            div [ class "ui divided grid" ]
                [ div
                    [ class "ui row" ]
                    [ div [ class "ui twelve wide column" ]
                        [ div [ class "ui big icon input fluid" ]
                            [ input [ placeholder "Zoek kaart op naam", onInput ChangeQuery, value model.searchQuery ] []
                            , Semantic.icon "search"
                            ]
                        , div [ class "ui feed" ]
                            [ CardsTable.view model
                            ]
                        ]
                    , div [ class "ui four wide column" ]
                        [ div [ class "" ] [ viewCardPreview model ]
                        ]
                    ]
                ]

        -- (List.map listingElem cards)
    in
    { content = content
    , breadcrumbs = cardsBreadcrumbs
    , title = title
    }


viewCardDetail card =
    let
        title =
            text ("Card: " ++ card.title)

        content =
            div [] [ text "TODO" ]
    in
    { content = content
    , breadcrumbs = cardBreadcrumbs card
    , title = title
    }


viewCardPreview { previewedCard } =
    case previewedCard of
        Nothing ->
            text "Nothing"

        Just card ->
            let
                priceStr =
                    case card.price of
                        Nothing ->
                            "?"

                        Just euro ->
                            Common.Euro.render euro

                cartButtonAttributes =
                    if MagicTheGathering.Models.isCardBuyable card then
                        [ class "primary"
                        , Common.ViewHelpers.onClickWithoutPropagation (Msgs.CartMsg (Msgs.IncrementCartContents card.id))
                        ]

                    else
                        [ class "disabled" ]
            in
            div []
                [ Semantic.header [] [ text card.title ]
                , div [ class "ui image" ] [ img [ src card.artUrl ] [] ]
                , Semantic.headerList []
                    [ ( "Set", text (toString card.set) )
                    , ( "Manakosten", MagicTheGathering.View.viewManaCost card.castingCost )
                    , ( "Kaarttype", MagicTheGathering.View.viewCardType card.cardType )
                    , ( "Omschrijving", text card.description )
                    , ( "Prijs", text priceStr )
                    ]
                , Semantic.labeledIconButton "cart"
                    cartButtonAttributes
                    [ text "Aan winkelwagen toevoegen"
                    ]
                ]
