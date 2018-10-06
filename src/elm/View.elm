module View exposing (notFoundView, renderBreadcrumbs, renderCurrentRoute, renderFooter, renderHeader, renderMenu, renderPage, renderPageContent, view)

-- import Listings

import Cards
import Common.ViewHelpers exposing (linkTo)
import Dict
import Html exposing (Html, div, footer, header, span, text)
import Html.Attributes exposing (class)
import Models exposing (Model, PageContent, Route)
import Msgs exposing (Msg)
import Routing
import Semantic
import ShoppingCart.View


view : Model -> Html Msg
view model =
    div [ class "page" ]
        [ header [] [ renderHeader model ]
        , div [ class "content" ] [ renderPageContent model ]
        , footer [] [ renderFooter ]
        ]


renderPageContent : Model -> Html Msg
renderPageContent model =
    Semantic.container []
        [ renderCurrentRoute model ]


renderHeader : Model -> Html Msg
renderHeader model =
    div []
        [ renderMenu model
        ]


renderMenu : Model -> Html Msg
renderMenu model =
    let
        menuLinkItem url attrs content =
            linkTo url (attrs ++ [ class "item" ]) content

        shoppingCartLabel =
            case model.shoppingCart.contents |> Dict.values |> List.sum of
                0 ->
                    Semantic.label [ class "circular" ] [ 0 |> toString |> text ]

                num ->
                    Semantic.label [ class "green circular" ] [ num |> toString |> text ]
    in
    Semantic.menu []
        [ menuLinkItem "/" [ class "header" ] [ text "Magic Mill" ]
        , menuLinkItem "/" [] [ text "Home" ]
        , div [ class "right menu" ]
            [ menuLinkItem Routing.shoppingCartPath
                []
                [ Semantic.icon "blue cart"
                , text "Winkelwagen"
                , shoppingCartLabel
                ]
            ]

        -- [ div [ class "ui simple dropdown item" ]
        --     [ text "Technical Info"
        --     , Semantic.icon "dropdown"
        --     , div [ class "menu" ]
        --         [ Semantic.header [] [ text "Technical details interesting for technical people" ]
        --         ]
        --     ]
        -- ]
        ]


renderFooter : Html Msg
renderFooter =
    div [] []


renderCurrentRoute : Model -> Html Msg
renderCurrentRoute model =
    renderPage model.route <|
        case model.route of
            Models.CardsRoute ->
                model
                    |> Cards.viewIndex

            -- model.cards
            --     |> Dict.values
            --     |> Cards.viewIndex
            Models.CardDetailRoute card_id ->
                let
                    maybePlayer =
                        Dict.get card_id model.cards
                in
                case maybePlayer of
                    Nothing ->
                        notFoundView

                    Just card ->
                        card
                            |> Cards.viewCardDetail

            Models.ShoppingCartRoute ->
                { content = ShoppingCart.View.view model
                , breadcrumbs = [(Models.ShoppingCartRoute, "Winkelwagen")]
                , title = text "Winkelwagen"
                }

            Models.NotFoundRoute ->
                notFoundView



-- page : String -> Html Msg -> Html Msg
-- page title content =
--     div [ class "pagewrapper" ]
--         [ div [ class "ui header" ] [ text title ]
--         , div [ class "ui center aligned container pagewrapper-inner" ] [ content ]
--         ]


renderPage : Route -> PageContent Msg -> Html Msg
renderPage current_route page_content =
    div [ class "pagewrapper" ]
        [ div [ class "ui breadcrumb" ] (renderBreadcrumbs current_route page_content.breadcrumbs)
        , div [ class "ui huge header" ] [ page_content.title ]
        , div [ class "ui center aligned pagewrapper-inner" ] [ page_content.content ]
        ]


renderBreadcrumbs : Route -> List Models.Breadcrumb -> List (Html Msg)
renderBreadcrumbs current_route breadcrumbs =
    let
        home =
            ( Models.CardsRoute, "Home" )
        breadcrumbHtml ( route, crumb_name ) =
            if route == current_route then
                div [ class "active section" ] [ text crumb_name ]

            else
                linkTo (Routing.toPath route) [ class "section" ] [ text crumb_name ]
    in
    (home :: breadcrumbs)
        |> List.map breadcrumbHtml
        |> List.intersperse (span [ class "divider" ] [ text "/" ])


notFoundView : PageContent msg
notFoundView =
    let
        title =
            text "Not Found"

        breadcrumbs =
            [ ( Models.CardsRoute, "Home" ) ]

        content =
            div []
                [ text "Error: Page not found. Please check the URL and try again"
                ]
    in
    { content = content
    , breadcrumbs = breadcrumbs
    , title = title
    }
