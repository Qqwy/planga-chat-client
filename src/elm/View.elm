module View exposing (view)

-- import Listings

import Html exposing (Html, button, div, footer, header, span, text)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Models exposing (Model)
import Msgs exposing (Msg)


view : Model -> Html Msg
view model =
    div []
        [ text "This is where the magic happens!"
        , button [ onClick (Msgs.SendMessage "This is a message") ] [ text "Send!" ]
        , text ("Username: " ++ (toString model.current_user_name))
        , text "Messages: "
        , div [] [ text (toString model.messages) ]
        ]
