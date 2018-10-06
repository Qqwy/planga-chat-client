module Common.Euro exposing (Euro, fromCents, fromFloat, unsafeFromFloat, fromString, render, toCents, toFloat, mul, mulInt, add, zero)

import Decimal exposing (Decimal)

{-| Internally, uses an arbitrary-precision BigDecimal to store monetary values.

However, once turning them back into strings, the output is truncated to two decimal places.
 -}
type Euro
    = Euro Decimal


fromCents : Int -> Euro
fromCents cents =
    Euro (Decimal.fromIntWithExponent -2 cents)


toCents : Euro -> Int
toCents (Euro decimal) =
    decimal
    |> Decimal.mul (Decimal.fromInt 100)
    |> Decimal.round 0
    |> Decimal.toFloat
    |> round


fromFloat : Float -> Maybe Euro
fromFloat float =
    float
        |> Decimal.fromFloat
        |> Maybe.map Euro

{-| Only ever use this function for easy creation of hard-coded constants!
Using them in other places will result in run-time crashes.

Use the normal 'fromFloat' instead.

 -}
unsafeFromFloat : Float -> Euro
unsafeFromFloat float =
    case fromFloat float of
        Just res -> res
        Nothing -> Debug.crash "unsafeFromFloat called with improper float (like NaN or Infinity)!"

toFloat : Euro -> Float
toFloat (Euro amount) =
    amount
        |> Decimal.round 2
        |> Decimal.toFloat

fromString : String -> Maybe Euro
fromString str =
    str
        |> Decimal.fromString
        |> Maybe.map Euro

render : Euro -> String
render (Euro amount) =
    let
        fullEurosStr =  amount
                        |> Decimal.round 0
                        |> Decimal.toString
        centsStr = (toString <| Decimal.getDigit -1 amount) ++ (toString <| Decimal.getDigit -2 amount)
    in
        "€ " ++ fullEurosStr ++ "," ++ centsStr

mul : Euro -> Decimal -> Euro
mul (Euro amount) multiplier =
    amount
        |> Decimal.mul multiplier
        |> Euro

mulInt : Euro -> Int -> Euro
mulInt euro multiplier = mul euro (Decimal.fromInt multiplier)

add : Euro -> Euro -> Euro
add (Euro lhs) (Euro rhs) = Euro <| Decimal.add lhs rhs

sub : Euro -> Euro -> Euro
sub (Euro lhs) (Euro rhs) = Euro <| Decimal.sub lhs rhs

zero : Euro
zero = Euro (Decimal.zero)
