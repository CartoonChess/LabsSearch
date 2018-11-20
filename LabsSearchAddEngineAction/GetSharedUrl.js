/*
 * GetSharedUrl.js
 *
 * By setting the correct value in the app extension plist, this JavaScript code will be called
 * before the view is loaded.
 *
 * plist > NSExtensionAttributes : change to Dictionary type
 * - add NSExtensionActivationSupportsWebURLWithMaxCount : Int : 1
 * - add NSExtensionJavaScriptPreprocessingFile : String : [function name; ours is GetSharedUrl]
 *
 * In our case, we will fetch at least the URL and the page title.
 *
 * If things go well, we'll get the favicon, or possibly look for it by parsing the source code.
 *
 */


/*
 GetSharedUrl.prototype = {
 run: function(arguments) {
 arguments.completionFunction({
 "url": document.URL,
 "title": document.title,
 "html": document.documentElement.outerHTML
 );
 }
 };
 */

var GetSharedUrl = function() {};

GetSharedUrl.prototype = {
    run: function(arguments) {
        arguments.completionFunction({
            "url": document.URL,
            "title": document.title,
            "html": document.documentElement.outerHTML
         });
    }
};

var ExtensionPreprocessingJS = new GetSharedUrl;
