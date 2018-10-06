module MagicTheGathering.View exposing (..)

import MagicTheGathering.Models exposing (..)
import Html exposing (Html, div, text, ul, li, a, i, span, input, img, em)
import Html.Attributes exposing (href, class, placeholder, value, src)
import Html.Events exposing (onInput)


viewManaCost manaCost =
    span [] (manaCost |> Maybe.map (List.map viewMana) |> Maybe.withDefault [ text "??" ])


{-| Uses <https://andrewgioia.github.io/Mana/>, so include the correct font + CSS in your HTML wrapper!
-}
viewMana : Mana -> Html msg
viewMana mana =
    let
        className mana =
            case mana of
                GenericMana (GMNormal num) ->
                    toString num

                VariableGenericMana ->
                    "x"

                ColoredMana color ->
                    viewManaColorLetter color

                Phyrexian color ->
                    viewManaColorLetter color

                Hybrid color1 color2 ->
                    (className color1) ++ (className color2)
                other ->
                    -- TODO
                    toString other
    in
        i [ class ("ms ms-cost ms-" ++ className mana) ] []


viewManaColorLetter color =
    case color of
        Red ->
            "r"

        Blue ->
            "u"

        Black ->
            "b"

        White ->
            "w"

        Green ->
            "g"


viewCardType cardType =
    let
        icon className =
            i [ class ("ms ms-cost ms-" ++ className) ] []

        ( iconHtml, info ) =
            case cardType of
                Colored color ->
                    ( Just (icon (viewManaColorLetter color)), colorTranslation color )

                Colorless ->
                    ( Just (icon "c"), "Kleurloos" )
                cardType ->
                    ( Nothing, toString cardType )
    in
        span []
            [ iconHtml |> Maybe.withDefault (text "")
            , em [] [text ("(" ++ info ++ ")")]
            ]


colorTranslation color =
    case color of
        Red ->
            "Rood"

        Black ->
            "Zwart"

        White ->
            "Wit"

        Blue ->
            "Blauw"

        Green ->
            "Groen"
