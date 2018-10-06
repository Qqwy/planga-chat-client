module View exposing (view)

-- import Listings

import Dict
import Html exposing (Html, button, div, dl, footer, header, input, span, text, form)
import Html.Attributes exposing (attribute, class, maxlength, name, placeholder, title, value, property)
import Html.Events exposing (onClick, onInput, onSubmit, on)
import Models exposing (Model)
import Msgs exposing (Msg)
import Json.Decode
import Json.Encode
import Ports


view : Model -> Html Msg
view model =
    div []
        [ text "This is where the magic happens!"
        , button [ onClick (Msgs.SendMessage "This is a message") ] [ text "Send!" ]
        , text ("Username: " ++ toString model.current_user_name)
        , text "Messages: "

        -- , div [] [ text (toString model.messages) ]
        , container model
        ]

data name val =
    Html.Attributes.attribute ("data-" ++ name) val


container model =
    div [ class "planga--chat-container" ]
        [ messages model
        , newMessageForm model
        ]

onScrollFetchScrollInfo =
    on "scroll" (Json.Decode.value |> Json.Decode.map Msgs.ScrollUpdate)

onLoadFetchScrollInfo =
    on "load" (Json.Decode.value |> Json.Decode.map Msgs.ScrollUpdate)

scrollHeight height =
    property "scrollTop" (Json.Encode.int height)

messages model =
    let
        message_list =
            model.messages
                |> Dict.values
                |> List.sortBy .sent_at

        messages_html =
            message_list
                |> List.map (message model.current_user_name)
    in
    dl [ class "planga--chat-messages", onScrollFetchScrollInfo, onLoadFetchScrollInfo, scrollHeight model.overridden_scroll_height]
        messages_html


message current_user_name message =
    let
        message_class =
            case current_user_name |> Maybe.map (\val -> val == message.name) of
                Just True ->
                    "planga--chat-message planga--chat-current-user-message"
                _ ->
                    "planga--chat-message"
    in

      div
          [ class message_class
          , data "message-sent-at" message.sent_at
          , data "message-uuid" message.uuid
          ]
          [ div [ class "planga--chat-message-sent-at-wrapper" ]
              [ span
                  [ class "planga--chat-message-sent-at"
                  , title message.sent_at
                  ]
                  [ text message.sent_at
                  ]
              ]
          , div [ class "planga--chat-author-wrapper" ]
              [ span [ class "planga--chat-author-name" ] [ text message.name ]
              , span [ class "planga--chat-message-separator" ] [ text ":   " ]
              ]
          , div [ class "planga--chat-message-content" ] [ text message.content ]
          ]


newMessageForm model =
    let
        placeholder_value =
            model.current_user_name
            |> Maybe.map (\name -> name ++ ": Type your message here")
            |> Maybe.withDefault "Unable to connect to Planga Chat"
    in
      form [ class "planga--new-message-form" , onSubmit (Msgs.SendMessage model.draft_message)]
          [ div [ class "planga--new-message-field-wrapper" ]
              [ input [ maxlength 4096, placeholder placeholder_value, name "planga-new-message-field", class "planga--new-message-field", onInput Msgs.ChangeDraftMessage, value model.draft_message ] []
              ]
          , button [ class "planga--new-message-submit-button", onClick (Msgs.SendMessage model.draft_message)]
              [ text "Send"
              ]
          ]
