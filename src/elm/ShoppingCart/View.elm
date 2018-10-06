module ShoppingCart.View exposing (view, addToCartButton)

import ShoppingCart
import Common.ViewHelpers
import Dict
import Future.String
import Html exposing (Attribute, Html, div, h1, img, input, p, text)
import Html.Attributes exposing (class, src, style, value, disabled)
import Html.Events
import MagicTheGathering.Models
import Maybe.Extra
import Msgs
import Semantic
import Models exposing (Model)
import Common.Euro

view : Model -> Html Msgs.Msg
view {shoppingCart, cards} =
    div [] [text (toString shoppingCart), text (Common.Euro.render (ShoppingCart.cartPrice shoppingCart cards))]

addToCartButton shoppingCart card =
    let
        isCardInShoppingCart =
            Dict.member card.id shoppingCart.contents

        cardAmount =
            Dict.get card.id shoppingCart.contents
    in
    -- case ( MagicTheGathering.Models.isCardBuyable card, isCardInShoppingCart ) of
      case MagicTheGathering.Models.isCardBuyable card of
        -- ( False, _ ) ->
          False ->
              Semantic.iconButton "cart" [ class "disabled" ]

        -- ( True, False ) ->
        --     Semantic.iconGroupButton ["cart"]
        --         [ class "primary"
        --         , Common.ViewHelpers.onClickWithoutPropagation (Msgs.CartMsg (Msgs.IncrementCartContents card.id))
        --         ] [class "large"]

        -- ( True, True ) ->
          True ->
            let
                inputHandler str =
                    str
                        |> Future.String.toInt
                        |> Debug.log "toInt"
                        |> Result.toMaybe
                        |> Debug.log "toMaybe"
                        -- Only allow positive numbers
                        |> Maybe.Extra.filter (\x -> x >= 0)
                        |> Debug.log "filter"
                        |> (\res ->
                                -- If no valid input was entered, fall back on previous input
                                Maybe.Extra.or res cardAmount
                                    |> Debug.log "or"
                                    -- If for some reason the card was not yet in the cart, use 1 as default.
                                    |> Maybe.withDefault 1
                                    |> Debug.log "withDefault"
                           )
            in
            div []
                [ --Semantic.icon "tiny red delete"
                  div [ class "ui small transparent input" ]
                    [ Semantic.iconButton "minus"
                        ([ class "left attached basic large buy-field"
                        , Common.ViewHelpers.onClickWithoutPropagation (Msgs.CartMsg (Msgs.DecrementCartContents card.id))
                        ] ++ if not isCardInShoppingCart then [class "disabled hidden-field", disabled True] else [])
                    , input
                        ([ style [ ( "width", "30px" ), ( "text-align", "center" ) ]
                         , class "buy-field"
                        , Html.Events.onInput (inputHandler >> (\amount -> Msgs.CartMsg (Msgs.SetCartContents card.id amount)))
                        , value (cardAmount |> Maybe.withDefault 0 |> toString)
                        , Common.ViewHelpers.onClickWithoutPropagation (Msgs.NoOp)
                        ]
                        ++ if not isCardInShoppingCart then [class "disabled hidden-field", disabled True] else [])
                        []
                    -- , Semantic.iconButton "plus"
                    --     [ class "primary right attached"
                    --     , Common.ViewHelpers.onClickWithoutPropagation (Msgs.CartMsg (Msgs.IncrementCartContents card.id))
                    --     ]

                    , Semantic.iconGroupButton [ "cart", "top right corner grey plus"]
                        [ class "primary right attached"
                        , Common.ViewHelpers.onClickWithoutPropagation (Msgs.CartMsg (Msgs.IncrementCartContents card.id))
                        ] [class "large"]
                    ]
                ]
