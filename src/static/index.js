// pull in desired CSS/SASS files
require( './styles/main.scss' );

class Planga {
    constructor(chat_container_elem, options) {
        var Elm = require( '../elm/Main' );

        const wrapper_elem = document.getElementById(chat_container_elem);// document.getElementById( 'main' );
        const app = Elm.Main.embed(wrapper_elem, options);

        app.ports.scrollToBottomPort.subscribe(function(_){
            window.requestAnimationFrame(function(){
                let elem  = wrapper_elem.getElementsByClassName("planga--chat-messages")[0];
                elem.scrollTop = elem.scrollHeight;
            });
        });

        app.ports.keepVScrollPosPort.subscribe(function(_){
            console.log("TEST PORT");
            let elem  = wrapper_elem.getElementsByClassName("planga--chat-messages")[0];
            let scrollBottomPos = elem.scrollHeight - elem.scrollTop;
            console.log(elem, elem.scrollTop, scrollBottomPos);
            window.requestAnimationFrame(function(){
                let elem  = wrapper_elem.getElementsByClassName("planga--chat-messages")[0];
                elem.scrollTop = elem.scrollHeight - scrollBottomPos;

                console.log(elem, elem.scrollTop);
            });

        });
    }
}

window.Planga = Planga;
