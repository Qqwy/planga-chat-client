// pull in desired CSS/SASS files
require( './styles/main.scss' );

class Planga {
    constructor(chat_container_elem, options) {
        var Elm = require( '../elm/Main' );

        this.notifications_enabled_message = options.notifications_enabled_message || "Chat Notifications are now enabled!";

        const wrapper_elem = document.getElementById(chat_container_elem);
        const app = Elm.Main.embed(wrapper_elem, options);

        app.ports.scrollToBottomPort.subscribe( _ => {
            window.requestAnimationFrame( () => {
                let elem  = wrapper_elem.getElementsByClassName("planga--chat-messages")[0];
                elem.scrollTop = elem.scrollHeight;
            });
        });

        app.ports.keepVScrollPosPort.subscribe( _ => {
            let elem  = wrapper_elem.getElementsByClassName("planga--chat-messages")[0];
            let scrollBottomPos = elem.scrollHeight - elem.scrollTop;
            window.requestAnimationFrame( () => {
                let elem  = wrapper_elem.getElementsByClassName("planga--chat-messages")[0];
                elem.scrollTop = elem.scrollHeight - scrollBottomPos;
            });

        });

        app.ports.sendBrowserNotification.subscribe(string => {
            console.log(string);
            this.sendNotification(string);
        });

        this.requestBrowserNotifications(applications_enabled_message);
    }

    requestBrowserNotifications(notifications_enabled_message){
        // Graceful degradation
        if("Notification" in window){
            // Only request permission if not granted before;
            // will make sure enabled_message is only shown when permission has been enabled.
            if(Notification.permission !== "granted") {
                Notification.requestPermission(permission => {
                    if(permission === "granted"){
                        new Notification(notifications_enabled_message);
                    }
                });
            }
        }
    }

    sendNotification (message) {
        if("Notification" in window){
            if(Notification.permission === 'granted') {
                new Notification(message);
            }
        }
    }

}

window.Planga = Planga;
