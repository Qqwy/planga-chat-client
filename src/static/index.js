// pull in desired CSS/SASS files
require( './styles/main.scss' );
// var $ = jQuery = require( '../../node_modules/jquery/dist/jquery.js' );           // <--- remove if jQuery not needed
// require( '../../node_modules/semantic-ui-css/semantic.min.js' );   // <--- remove if Semantic UI JS-capabilities are not needed

// inject bundled Elm app into div#main
var Elm = require( '../elm/Main' );
const storageKey = "MagicMillElmStorage";

const app = Elm.Main.embed(document.getElementById( 'main' ), loadStorage() );

console.log(app);

app.ports.persistToStorage.subscribe(
    function(data){
        window.localStorage.setItem(storageKey, data);
    });

function loadStorage(){
    return window.localStorage.getItem(storageKey) || "";
}

function updateStorage(){
    app.ports.storageUpdate.send(loadStorage());
}

addEventListener('storage', updateStorage, false);

app.ports.openInNewPage.subscribe(function(location){
    window.open(location, '_blank');
});
