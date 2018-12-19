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
import Time


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


checkbox attributes contents =
    Html.label []
        (Html.input ([ Html.Attributes.type_ "checkbox" ] ++ attributes) []
            :: contents
        )


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

        is_moderator =
            Models.isModerator model

        messages_html =
            message_list
                |> List.map (message model.current_user_name is_moderator)
    in
    dl [ class "planga--chat-messages", id (Models.uniqueMessagesContainerId model), onScrollFetchScrollInfo ]
        messages_html


message : Maybe String -> Bool -> Models.ChatMessage -> Html Msg
message current_user_name is_moderator message =
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

        options_button =
            div [ class "planga--chat-message-options" ]
                [ span [ onClick (Msgs.OpenModerationWindow message) ] [ text "⚙" ]
                ]
    in
    if is_deleted && not is_moderator then
        text ""

    else
        div
            [ class message_class
            , data "chat-message--sent-at" message.sent_at
            , data "chat-message--uuid" message.uuid
            , data "chat-message--author-role" message.author_role
            , data "chat-message--author-name" message.author_name
            , onRightClick (Msgs.OpenModerationWindow message)
            ]
            [ options_button
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
        ban_status =
            model.conversation_user_info
                |> Maybe.map (Models.banStatus model.current_time)
                |> Maybe.withDefault Models.NotBanned

        is_banned =
            ban_status /= Models.NotBanned

        placeholder_value =
            case ( model.conversation_user_info, model.current_user_name ) of
                ( Just conversation_user_info, Just current_user_name ) ->
                    case ban_status of
                        Models.BannedUntil time ->
                            { disabled = True, placeholder = "Banned for " ++ toString (time - model.current_time) ++ " more milliseconds" }

                        Models.NotBanned ->
                            { disabled = False, placeholder = current_user_name ++ ": Type your message here" }

                ( _, _ ) ->
                    { disabled = True, placeholder = "Not connected to Planga Chat" }

        -- if Maybe.Extra.isNothing model.conversation_user_info
        -- then
        --     "Unable to connect to Planga Chat"
        -- else
        --     model.current_user_name
        --         |> Maybe.map (\name -> name ++ ": Type your message here")
        --         |> Maybe.withDefault "Unable to connect to Planga Chat"
        -- is_banned =
        --     model.conversation_user_info
        --         |> Maybe.withDefault {banned_until = Nothing}
        --         |> Maybe.map (\{banned_until} -> banned_until |> Maybe.withDefault 0 |> (>) model.current_time)
        -- is_disabled =
        --     Maybe.Extra.isNothing model.current_user_name || Maybe.Extra.isNothing model.conversation_user_info || is_banned
    in
    form [ class "planga--new-message-form", onSubmit (Msgs.SendMessage model.draft_message) ]
        [ div [ class "planga--new-message-field-wrapper" ]
            [ input
                [ maxlength 4096
                , placeholder placeholder_value.placeholder
                , name "planga-new-message-field"
                , class "planga--new-message-field"
                , onInput Msgs.ChangeDraftMessage
                , value model.draft_message
                , disabled placeholder_value.disabled
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
            [ ( "User", subject.author_name )
            , ( "Message", subject.content )
            , ( "Status"
              , if subject.deleted_at == Nothing then
                    "Visible"

                else
                    "Hidden"
              )
            ]
                |> List.concatMap list_item
    in
    case model.moderation_window of
        Nothing ->
            text ""

        Just { subject } ->
            div [ class "planga--moderation-window" ]
                [ div
                    [ class "planga--moderation-window-content" ]
                    [ Html.h1 [] [ text "Moderation" ]
                    , Html.div [ onClick Msgs.CloseModerationWindow ] [ text "Close" ]
                    , Html.dl [] (info_list subject)
                    , Html.div []
                        [ Html.h2 [] [ text "Message Actions" ]

                        -- , checkbox [] [ text "Delete Message" ]
                        -- , checkbox [] [ text "Ban user for" ]
                        -- , Html.ul []
                        --     [ Html.li [] [ text "5 minutes" ]
                        --     , Html.li [] [ text "15 minutes" ]
                        --     , Html.li [] [ text "1 hour" ]
                        --     , Html.li [] [ text "1 day" ]
                        --     , Html.li [] [ text "permanently" ]
                        --     ]
                        , button [ onClick (Msgs.HideChatMessage subject.uuid) ] [ text "hide this message" ]
                        , button [ onClick (Msgs.ShowChatMessage subject.uuid) ] [ text "show this message" ]
                        , Html.h2 [] [ text "Ban User" ]
                        , button [ onClick (Msgs.BanUser subject.author_uuid 1) ] [ text "1 minute" ]
                        , button [ onClick (Msgs.BanUser subject.author_uuid 5) ] [ text "5 minues" ]
                        , button [ onClick (Msgs.BanUser subject.author_uuid 15) ] [ text "15 minutes" ]
                        , button [ onClick (Msgs.BanUser subject.author_uuid (1 * 60)) ] [ text "1 hour" ]
                        , button [ onClick (Msgs.BanUser subject.author_uuid (1 * 60 * 24)) ] [ text "1 day" ]
                        , button [ onClick (Msgs.BanUser subject.author_uuid (1 * 60 * 24 * 256 * 1000)) ] [ text "indefinitely" ]
                        , button [ onClick (Msgs.UnbanUser subject.author_uuid) ] [ text "unban" ]
                        ]
                    ]
                ]
