module View exposing (view)

-- import Listings

import Dict
import ElmEscapeHtml
import Html exposing (Html, button, div, dl, footer, form, header, input, span, text, em)
import Html.Attributes exposing (attribute, class, disabled, id, maxlength, name, placeholder, property, title, value)
import Html.Events exposing (on, onClick, onInput, onSubmit)
import Json.Decode
import Json.Encode
import Maybe.Extra
import Models exposing (Model, uniqueMessagesContainerId)
import Msgs exposing (Msg)
import Ports


view : Model -> Html Msg
view model =
    div []
        [ container model
        ]


data name val =
    Html.Attributes.attribute ("data-" ++ name) val


container model =
    div [ class "planga--chat-container" ]
        [ messages model
        , newMessageForm model
        ]


onScrollFetchScrollInfo =
    on "scroll" (Json.Decode.value |> Json.Decode.map (always (Msgs.ScrollMsg Msgs.ScrollTopChanged)))


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
    dl [ class "planga--chat-messages", id (Models.uniqueMessagesContainerId model), onScrollFetchScrollInfo ]
        messages_html


message current_user_name message =
        let
            is_current_user =
                case current_user_name |> Maybe.map (\val -> val == message.name) of
                    Just True ->
                        True
                    _ ->
                        False
            is_deleted = message.deleted_at /= Nothing

            message_class =
                "planga--chat-message"
                ++ (if is_current_user then " planga--chat-current-user-message" else "")
                    ++ (if is_deleted then " planga--chat-deleted-message" else "")
            message_content =
              if is_deleted then
                  span [title ("Original message: " ++ message.content)] [text "This message was deleted"]
              else
                  text (ElmEscapeHtml.unescape message.content)
        in
        div
            [ class message_class
            , data "message-sent-at" message.sent_at
            , data "message-uuid" message.uuid
            ]
            [
            div [class "planga--chat-message-options"]
                    [
                     span [onClick (Msgs.HideChatMessage message.uuid)] [text "×"]
                    ]
             , div [ class "planga--chat-message-sent-at-wrapper" ]
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
            , div [ class "planga--chat-message-content" ] [ message_content ]
            ]


newMessageForm model =
    let
        placeholder_value =
            model.current_user_name
                |> Maybe.map (\name -> name ++ ": Type your message here")
                |> Maybe.withDefault "Unable to connect to Planga Chat"

        is_disabled =
            Maybe.Extra.isNothing model.current_user_name
    in
    form [ class "planga--new-message-form", onSubmit (Msgs.SendMessage model.draft_message) ]
        [ div [ class "planga--new-message-field-wrapper" ]
            [ input
                [ maxlength 4096
                , placeholder placeholder_value
                , name "planga-new-message-field"
                , class "planga--new-message-field"
                , onInput Msgs.ChangeDraftMessage
                , value model.draft_message
                , disabled is_disabled
                ]
                []
            ]
        , button [ class "planga--new-message-submit-button" ]
            [ text "Send"
            ]
        ]
