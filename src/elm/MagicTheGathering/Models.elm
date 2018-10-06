module MagicTheGathering.Models exposing (Card, CardId, CardType(..), CastingCost, Color(..), Mana(..), GenericManaAmount(..), Rarity(..), SetId, initialCards, isCardBuyable)

import Common.Euro exposing (Euro)
import Dict exposing (Dict)
import List.Extra


type alias CardId =
    String


type alias SetId =
    String


type Rarity
    = Common
    | Uncommon
    | Rare
    | Mythic


type Color
    = Red
    | White
    | Blue
    | Green
    | Black


type CardType
    = Colored Color
    | Colorless -- Do not confuse with the Generic Mana type!
    | Multicolor
    | Artifact
    | Country
    | Token


type GenericManaAmount
    = GMNormal Int
    | GMHalf
    | GMInfinity


type Mana
    = GenericMana GenericManaAmount
    | VariableGenericMana -- Shown as 'X' on a card.
    | ColoredMana Color
    | ColorlessMana
    | Snow
    | Phyrexian Color -- can be paid by life instead.
    | PhyrexianAnyColor -- can be paid by life instead.
    | Hybrid Mana Mana -- two possibilities.


{-| An empty list == an 'unpayable' mana cost.
-}
type alias CastingCost =
    List Mana


type alias Card =
    { id : CardId
    , title : String
    , description : String
    , set : SetId
    , rarity : Rarity
    , cardType : CardType
    , castingCost : Maybe CastingCost
    , price : Maybe Euro
    , amountAvailable : Int
    , artUrl : String
    }


initialCards : Dict String Card
initialCards =
    let
        card1 =
            { title = "Admiral's Order"
            , set = "1"
            , id = "1"
            , rarity = Rare
            , cardType = Colored Blue
            , castingCost = Just [ GenericMana (GMNormal 1), ColoredMana Blue, ColoredMana Blue ]
                         -- , castingCost = "{W}{B}{G}" |> MagicTheGathering.ManaParser.parse |> Result.toMaybe
            , description = "A super strong card"
            , price = Common.Euro.fromFloat 4.21
            , amountAvailable = 33
            , artUrl = "http://www.black-lotus.nl/mtg/lg/Rivals_of_Ixalan/Admiral_s_Order_tmp.jpg"
            }

        card2 =
            { title = "Agressive Urge"
            , set = "1"
            , id = "2"
            , rarity = Rare
            , cardType = Colored Green
            , castingCost = Just [ GenericMana (GMNormal 1), ColoredMana Green ]
            , description = "Yet Another Card"
            , price = Common.Euro.fromFloat 1.23

            -- , price = Common.Euro.fromFloat (1 / 0.0)
            , amountAvailable = 33
            , artUrl = "http://www.black-lotus.nl/mtg/lg/Rivals_of_Ixalan/Aggressive_Urge_tmp.jpg"
            }

        manycards =
            card2
                -- |> List.repeat 10000
                |> List.repeat 10
                |> List.Extra.zip (List.range 2 1000)
                |> List.map (\( index, card ) -> { card | id = toString index })

        cards =
            card1 :: manycards

        -- [
        -- ]
    in
    cards
        |> List.map (\elem -> ( elem.id, elem ))
        |> Dict.fromList


isCardBuyable card =
    case ( card.price, card.amountAvailable ) of
        ( Nothing, _ ) ->
            False

        ( _, 0 ) ->
            False

        ( Just _, _ ) ->
            True
