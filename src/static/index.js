// pull in desired CSS/SASS files
require( './styles/main.scss' );



// inject bundled Elm app into div#main
var Elm = require( '../elm/Main' );

const wrapper_elem = document.getElementById( 'main' );
const app = Elm.Main.embed(wrapper_elem, "");

app.ports.fetchScrollPos.subscribe(function(event){
    sendScrollPosUpdate(event.target);
});

window.setTimeout(function(){
    let elem  = wrapper_elem.getElementsByClassName("planga--chat-messages")[0];
    console.log(elem);
    elem.scrollTop = 1000000;
    sendScrollPosUpdate(elem);
}, 900);

function sendScrollPosUpdate(target) {
    app.ports.scrollUpdate.send({
        scrollLeft:   target.scrollLeft,
        scrollTop:    target.scrollTop,
        scrollWidth:  target.scrollWidth,
        scrollHeight: target.scrollHeight
    });
}
