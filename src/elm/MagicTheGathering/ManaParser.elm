module MagicTheGathering.ManaParser exposing (ManaText(..), manaBodyParser, manaCostParser, parse, parseManaBody, parseManaCost, parser)

import MagicTheGathering.Models exposing (Color(..), GenericManaAmount(..), Mana(..))
import Parser exposing ((|.), (|=), Parser)


{-| A ManaText can either be a mana symbol or a normal piece of text.

Use `List ManaText` to represent a blurb that might contain mana symbols.

-}
type ManaText
    = NormalText String
    | ManaText Mana -- TODO: Change to actual mana representation


{-| A Mana Cost can only exist of a list of `{X}`-tokens.
-}
manaCostParser : Parser (List Mana)
manaCostParser =
    Parser.repeat Parser.zeroOrMore manaParser


{-| Convenience function that intermediately invokes `manaCostParser`.
-}
parseManaCost : String -> Result Parser.Error (List Mana)
parseManaCost =
    Parser.run (manaCostParser |. Parser.end)


{-| Convenience function that intermediately invokes `parser`.
-}
parse : String -> Result Parser.Error (List ManaText)
parse =
    Parser.run (parser |. Parser.end)


{-| Parses a string into a `ManaText`, which intermittently might contain MTG-symbols.
-}
parser : Parser (List ManaText)
parser =
    let
        either =
            Parser.oneOf [ Parser.map ManaText manaParser, nonManaParser ]
    in
    Parser.repeat Parser.zeroOrMore either


manaParser : Parser Mana
manaParser =
    Parser.delayedCommit (Parser.symbol "{") <|
        Parser.succeed identity
            |= manaBodyParser
            |. Parser.symbol "}"


{-| Grabs all normal text until the next opening '{'
-}
nonManaParser : Parser ManaText
nonManaParser =
    Parser.keep Parser.oneOrMore (\c -> c /= '{')
        |> Parser.map NormalText


{-| Convenience function that intermediately invokes `manaBodyParser`.
-}
manaBodyParser : Parser Mana
manaBodyParser =
    let
        constantParser ( name, representation ) =
            Parser.symbol name |> Parser.map (\() -> representation)

        genericManaParsers =
            List.range 0 20
                |> List.map
                    (\x ->
                        ( toString x, GenericMana (GMNormal x) )
                    )

        parsePossibilities =
            -- genericManaParsers
            [ ( "X", VariableGenericMana )

            -- TODO: Y and Z
            , ( "0", GenericMana (GMNormal 0) )
            , ( "½", GenericMana GMHalf )
            , ( "∞", GenericMana GMInfinity )
            , ( "W/U", Hybrid (ColoredMana White) (ColoredMana Blue) )
            , ( "W/B", Hybrid (ColoredMana White) (ColoredMana Blue) )
            , ( "B/R", Hybrid (ColoredMana White) (ColoredMana Blue) )
            , ( "B/G", Hybrid (ColoredMana White) (ColoredMana Blue) )
            , ( "U/B", Hybrid (ColoredMana White) (ColoredMana Blue) )
            , ( "U/R", Hybrid (ColoredMana White) (ColoredMana Blue) )
            , ( "R/G", Hybrid (ColoredMana White) (ColoredMana Blue) )
            , ( "R/W", Hybrid (ColoredMana White) (ColoredMana Blue) )
            , ( "G/W", Hybrid (ColoredMana White) (ColoredMana Blue) )
            , ( "R/U", Hybrid (ColoredMana White) (ColoredMana Blue) )
            , ( "2/W", Hybrid (ColoredMana White) (ColoredMana Blue) )
            , ( "2/U", Hybrid (ColoredMana White) (ColoredMana Blue) )
            , ( "2/B", Hybrid (ColoredMana White) (ColoredMana Blue) )
            , ( "2/R", Hybrid (ColoredMana White) (ColoredMana Blue) )
            , ( "2/G", Hybrid (ColoredMana White) (ColoredMana Blue) )
            , ( "P", PhyrexianAnyColor )
            , ( "W/P", Phyrexian White )
            , ( "U/P", Phyrexian Blue )
            , ( "B/P", Phyrexian Black )
            , ( "R/P", Phyrexian Red )
            , ( "G/P", Phyrexian Green )

            -- TODO half-white, half-red
            , ( "W", ColoredMana White )
            , ( "U", ColoredMana Blue )
            , ( "B", ColoredMana Black )
            , ( "R", ColoredMana Red )
            , ( "G", ColoredMana Green )
            , ( "C", ColorlessMana )
            , ( "S", Snow )
            ]
    in
    parsePossibilities
        |> List.map constantParser
        |> (++) [ Parser.int |> Parser.map (\x -> GenericMana (GMNormal x)) ]
        |> Parser.oneOf


{-| Convenience function that intermediately invokes `manaBodyParser`.
-}
parseManaBody =
    Parser.run (manaBodyParser |. Parser.end)
