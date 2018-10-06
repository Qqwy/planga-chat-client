module Semantic exposing (..)

import Html exposing (Html, div, text, footer, span)
import Html.Attributes exposing (class)

icon : String -> Html msg
icon iconName =
    Html.i [ class (iconName ++ " icon") ] []

header : List (Html.Attribute msg) -> List (Html msg) -> Html msg
header attrs html = div (attrs ++ [class "ui header"]) html

menu : List (Html.Attribute msg) -> List (Html msg) -> Html msg
menu attrs html = div (attrs ++ [class "ui menu"]) html

container : List (Html.Attribute msg) -> List (Html msg) -> Html msg
container attrs html = div (attrs ++ [class "ui container"]) html

headerList : List (Html.Attribute msg) -> List (String, Html msg) -> Html msg

headerList  attrs items =
    let
        items_html =
            items
                |> List.map (\(title, content) -> div [class "item"] [div [class "header"] [text title], content])
    in
        div (attrs ++ [class "ui list"]) items_html

button : List (Html.Attribute msg) -> List (Html msg) -> Html msg
button attrs html = div (attrs ++ [class "ui button"]) html

iconButton : String -> List (Html.Attribute msg) -> Html msg
iconButton iconName attrs = button (attrs ++ [class "icon"]) [icon iconName]

iconGroupButton iconNames buttonAttrs iconGroupAttrs =
    button (buttonAttrs ++ [class "icon"]) [Html.i (iconGroupAttrs ++ [class "icons"]) (iconNames |> List.map icon)]

labeledIconButton iconName attrs html = button (attrs ++ [class "labeled icon"]) ([icon iconName] ++ html)

label :  List (Html.Attribute msg) -> List (Html msg) -> Html msg
label attrs html = div (attrs ++ [class "ui label"]) html
