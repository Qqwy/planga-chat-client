module Msgs exposing (CartMsg(..), Msg(..))

import MagicTheGathering.Models exposing (Card, CardId)
import Navigation exposing (Location)
import Table
import Storage
import ShoppingCart exposing (ShoppingCart)


type Msg
    = NoOp
    | NavigateTo String
    | LocationChange Location
    | SetCardsTableState Table.State
    | ChangeQuery String
    | PreviewCard Card
    | CartMsg CartMsg
    | PrintDebug String String
    -- | StorageWIPMsg (Storage.Msg Int Msg)
    | LoadCartFromStorage ShoppingCart
    | OpenInNewPage String


type CartMsg
    = RemoveFromCart CardId
    | IncrementCartContents CardId
    | DecrementCartContents CardId
    | SetCartContents CardId Int
