module Future.String exposing (toInt)

{-| Resolves a bug in Elm 0.18 that is fixed in 0.19 with parsing a string to integer.

Specifically, the 0.18 version of `String.toInt` breaks on the input "-", which is improperly converted to `Ok NaN`.
-}


toInt : String -> Result String Int
toInt string =
    if string == "-" then
        Err "Cannot convert \"-\" to an integer!"

    else
        String.toInt string
