module View exposing (view)

-- import Listings

import Dict
import ElmEscapeHtml
import Html exposing (Html, button, div, dl, em, footer, form, header, input, span, text)
import Html.Attributes exposing (attribute, class, disabled, id, maxlength, name, placeholder, property, title, value)
import Html.Events exposing (on, onClick, onInput, onSubmit)
import Json.Decode
import Json.Encode
import Maybe.Extra
import Models exposing (Model, uniqueMessagesContainerId)
import Msgs exposing (Msg)
import Ports


view : Model Msg -> Html Msg
view model =
    div []
        [ container model
        ]


data name val =
    Html.Attributes.attribute ("data-" ++ name) val


onRightClick message =
    Html.Events.onWithOptions
        "contextmenu"
        { stopPropagation = True
        , preventDefault = True
        }
        (Json.Decode.succeed message)


container model =
    div [ class "planga--chat-container" ]
        [ messages model
        , newMessageForm model
        , moderationWindow model
        ]


onScrollFetchScrollInfo =
    on "scroll" (Json.Decode.value |> Json.Decode.map (always (Msgs.ScrollMsg Msgs.ScrollTopChanged)))


scrollHeight height =
    property "scrollTop" (Json.Encode.int height)

messages : Model Msg -> Html Msg
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


message : Maybe String -> Models.ChatMessage -> Html Msg
message current_user_name message =
    let
        is_current_user =
            case current_user_name |> Maybe.map (\val -> val == message.author_name) of
                Just True ->
                    True

                _ ->
                    False

        is_deleted =
            message.deleted_at /= Nothing

        message_class =
            "planga--chat-message"
                ++ (if is_current_user then
                        " planga--chat-current-user-message"

                    else
                        ""
                   )
                ++ (if is_deleted then
                        " planga--chat-deleted-message"

                    else
                        ""
                   )

        message_content =
            if is_deleted then
                span [ title ("Original message: " ++ message.content) ] [ text "This message was deleted" ]

            else
                text (ElmEscapeHtml.unescape message.content)
    in
    div
        [ class message_class
        , data "chat-message--sent-at" message.sent_at
        , data "chat-message--uuid" message.uuid
        , data "chat-message--author-role" message.author_role
        , data "chat-message--author-name" message.author_name
        , onRightClick (Msgs.OpenModerationWindow message)
        ]
        [ div [ class "planga--chat-message-options" ]
            [ span [ onClick (Msgs.HideChatMessage message.uuid) ] [ text "×" ]
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
            [ span [ class "planga--chat-author-name" ] [ text message.author_name ]
            , span [ class "planga--chat-message-separator" ] [ text ":   " ]
            ]
        , div [ class "planga--chat-message-content" ] [ message_content ]
        ]


newMessageForm : Model Msg -> Html Msg
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


moderationWindow : Model Msg -> Html Msg
moderationWindow model =
    let
        list_item ( key, value ) =
            [ Html.dt [] [ text key ], Html.dd [] [ text value ] ]

        info_list subject =
            [ ( "User:", subject.author_name )
            , ( "Message", subject.content )
            ]
                |> List.concatMap list_item
    in
    case model.moderation_window of
        Nothing ->
            text ""

        Just { subject } ->
            div []
                [ Html.h1 [] [ text "Moderation" ]
                , Html.dl [] (info_list subject)
                ]
