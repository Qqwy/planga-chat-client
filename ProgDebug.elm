module ProgDebug exposing (opt_debug)

opt_debug : Bool -> String -> a -> a
opt_debug show str data = if show then Debug.log str data else data
