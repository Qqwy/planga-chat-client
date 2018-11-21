// pull in desired CSS/SASS files
require( './styles/main.scss' );


let absolute_protocolless_path = (location) => {
    return location.charAt(0) === "/" && location.charAt(1) === "/";
};

let relative_path = (location) => {
    return location.charAt(0) === "/" && location.charAt(1) !== "/";
};

let absolute_protocol_path = (location) => {
    return location.charAt(0) !== "/";
};

let on_localhost = (location) => {
    let location_str = absolute_protocolless_path(location) ? ("http:" + location) : location;
    let location_url = new URL(location_str);
    return location_url.hostname === "localhost";
};

/**
   Only when both the application that renders this snippet,
   as well as the Planga Chat application that socket_location refers to,
   are hosted on 'localhost', do we allow to use a non-SSL connection.

   (This is for ease of development.)
*/
let normalizeSocketLocation = (socket_location) => {
    if(absolute_protocol_path(socket_location)) {
        return socket_location;
    }
    if(absolute_protocolless_path(socket_location)){
        if(on_localhost(window.location.toString()) && on_localhost(socket_location)){
            return "ws:" + socket_location;
        }
        return "wss:" + socket_location;
    }
    // Relative paths
    return "wss://" + location.host + socket_location;
};


class Planga {
    constructor(chat_container_elem, options) {
        var Elm = require( '../elm/Main' );

            options.socket_location = normalizeSocketLocation(options.socket_location|| "https://chat.planga.io/socket");
        this.notifications_enabled_message = options.notifications_enabled_message || "Chat Notifications are now enabled!";

        const app = Elm.Main.embed(chat_container_elem, options);

        app.ports.scrollToBottomPort.subscribe( _ => {
            window.requestAnimationFrame( () => {
                let elem  = chat_container_elem.getElementsByClassName("planga--chat-messages")[0];
                elem.scrollTop = elem.scrollHeight;
            });
        });

        app.ports.keepVScrollPosPort.subscribe( _ => {
            let elem  = chat_container_elem.getElementsByClassName("planga--chat-messages")[0];
            let scrollBottomPos = elem.scrollHeight - elem.scrollTop;
            window.requestAnimationFrame( () => {
                let elem  = chat_container_elem.getElementsByClassName("planga--chat-messages")[0];
                elem.scrollTop = elem.scrollHeight - scrollBottomPos;
            });

        });

        app.ports.sendBrowserNotification.subscribe(string => {
            this.sendNotification(string);
        });

        this.requestBrowserNotifications(this.notifications_enabled_message);
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
