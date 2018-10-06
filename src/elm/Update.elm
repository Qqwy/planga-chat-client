module Update exposing (update, updateCart, updateLocationChange)

import Dict
import Models exposing (Model)
import Msgs exposing (CartMsg(..), Msg)
import Navigation
import Routing
import ShoppingCart exposing (ShoppingCart)
import Ports


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Msgs.NoOp ->
            (model, Cmd.none)
        Msgs.NavigateTo path ->
            ( model, Navigation.newUrl <| path )

        Msgs.LocationChange location ->
            updateLocationChange location model

        Msgs.SetCardsTableState newState ->
            ( { model | cardsTableState = newState }, Cmd.none )

        Msgs.ChangeQuery newQuery ->
            ( { model | searchQuery = newQuery }, Cmd.none )

        Msgs.PreviewCard newCard ->
            ( { model | previewedCard = Just newCard }, Cmd.none ) |> Debug.log "Card Preview"

        Msgs.PrintDebug name content ->
            let
                _ =
                    Debug.log ("Debugging: " ++ name ++ " ===> `" ++ content ++ "`") ()
            in
            ( model, Cmd.none )

        Msgs.LoadCartFromStorage shoppingCart ->
            ( { model | shoppingCart = shoppingCart }, Cmd.none )

        Msgs.CartMsg cartMsg ->
            let
                ( shoppingCart, cmd ) =
                    updateCart cartMsg model.shoppingCart
            in
            ( { model | shoppingCart = shoppingCart }, cmd )
        Msgs.OpenInNewPage location ->
            (model, Ports.openInNewPage location)


updateLocationChange : Navigation.Location -> Model -> ( Model, Cmd Msg )
updateLocationChange location model =
    let
        newRoute =
            Routing.parseLocation location
    in
    ( { model | route = newRoute }, Cmd.none )


updateCart : Msgs.CartMsg -> ShoppingCart -> ( ShoppingCart, Cmd msg )
updateCart cartMsg shoppingCart =
    let
        newContents =
            case cartMsg of
                IncrementCartContents cardId ->
                    Dict.update cardId
                        (\amount ->
                            case amount of
                                Nothing ->
                                    Just 1

                                Just amount ->
                                    Just (amount + 1)
                        )
                        shoppingCart.contents

                DecrementCartContents cardId ->
                    Dict.update cardId
                        (\amount ->
                            case amount of
                                Nothing ->
                                    Nothing

                                Just amount ->
                                    if amount <= 1 then
                                        Nothing

                                    else
                                        Just (amount - 1)
                        )
                        shoppingCart.contents

                RemoveFromCart cardId ->
                    Dict.remove cardId shoppingCart.contents

                SetCartContents cardId amount ->
                    case amount of
                        0 ->
                            Dict.remove cardId shoppingCart.contents
                        _ ->
                            Dict.insert cardId amount shoppingCart.contents

        newShoppingCart =
            { shoppingCart | contents = newContents }
    in
    ( newShoppingCart, ShoppingCart.persist newShoppingCart )
