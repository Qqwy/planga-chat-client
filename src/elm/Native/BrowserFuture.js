var _ResiliaDev$planga_chat_client$Native_BrowserFuture = function(){
    
// var _BrowserFuture_log = F2(function(tag, value)
//                             {
// 	                              console.log(tag + ': ' + JSON.stringify(value));
// 	                              return value;
//                             });

    function log(tag, value) {
        console.log(tag + ": " + JSON.stringify(value));
        return value;
    }

    return {
        log: F2(log)
    };

}();
