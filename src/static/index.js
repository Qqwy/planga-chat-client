// pull in desired CSS/SASS files
require( './styles/main.scss' );



// inject bundled Elm app into div#main
var Elm = require( '../elm/Main' );

const wrapper_elem = document.getElementById( 'main' );
const app = Elm.Main.embed(wrapper_elem, "");

app.ports.fetchScrollPos.subscribe(function(event){
    sendScrollPosUpdate(event.target);
});

app.ports.scrollToBottomPort.subscribe(function(_){
    window.setTimeout(function(){
        let elem  = wrapper_elem.getElementsByClassName("planga--chat-messages")[0];
        elem.scrollTop = 1000000;
    }, 100);
});

var vScrollStickInterval;

app.ports.keepVScrollPosPort.subscribe(function(_){
    if(vScrollStickInterval !== null) {
        return;
    }
    let elem  = wrapper_elem.getElementsByClassName("planga--chat-messages")[0];
    let pos = elem.scrollHeight - elem.scrollTop;
    console.log(elem, pos);
    vScrollStickInterval = window.setInterval(function(){
        let elem  = wrapper_elem.getElementsByClassName("planga--chat-messages")[0];
        console.log("SCROLL FIX", elem, pos);
        elem.scrollTop = elem.scrollHeight - pos;
    }, 100);
});
app.ports.unlockVScrollPosPort.subscribe(function(_){
    window.clearInterval(vScrollStickInterval);
});

window.setTimeout(function(){
    let elem  = wrapper_elem.getElementsByClassName("planga--chat-messages")[0];
    console.log(elem);
    elem.scrollTop = 1000000;
    sendScrollPosUpdate(elem);
}, 1000);

function sendScrollPosUpdate(target) {
    app.ports.scrollUpdate.send({
        scrollLeft:   target.scrollLeft,
        scrollTop:    target.scrollTop,
        scrollWidth:  target.scrollWidth,
        scrollHeight: target.scrollHeight
    });
}
