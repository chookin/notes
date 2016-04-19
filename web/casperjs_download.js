/**
 * Created by zhuyin on 12/18/14.
 */
// casperjs --proxy=proxy.cmcc:8080 casperjs_download.js --url="http://s.m.taobao.com/search.htm?q=%E5%AD%95%E5%A6%87%E5%A5%B6%E7%B2%89&spm=41.139785.167729.2" --out="tbGoods.json"
// casperjs --proxy=proxy.cmcc:8080 casperjs_download.js
// casperjs casperjs_download.js  --remote-debugger-port=9000

// http://casperjs.readthedocs.org/en/latest/cli.html
// http://casperjs.readthedocs.org/en/latest/debugging.html
// http://casperjs.readthedocs.org/en/latest/modules/casper.html

// An options object can be passed to the Casper constructor
var casper = require('casper').create({
    clientScripts: [ // These  scripts will be injected in remote DOM on every request
        // 'include/jquery.js'
    ],
    pageSettings: {
        loadImages: false,        // The WebPage instance used by Casper will
        loadPlugins: false         // use these settings
    },
    verbose: true,
    logLevel: "debug"
});

var url = casper.cli.get("url");
var out = casper.cli.get("out");
var useragent = casper.cli.get("userAgent");
if (url == null) {
    url = "http://www.le.com/ptv/vplay/25057280.html";
}
if (out == null) {
    out = "tbGoods";
}else{
    var ext = ".htm";
    var indexExt = out.indexOf(ext);
    if(indexExt == out.length - ext.length){
        out = out.substring(0, indexExt);
    }
}
if (useragent == null) {
    useragent = "Mozilla/5.0 (Linux; Android 4.4.2; M812C Build/KVT49L) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.59 Mobile Safari/537.36";
}
casper.echo('userAgent: ' + useragent);
casper.userAgent(useragent);

debugger;

casper.echo("Casper CLI passed options:");
require("utils").dump(casper.cli.options);


casper.start(url, function () {
    this.emit("page.loaded");
});

casper.run(function () {
    dumpPageContent(this);
    this.echo('Done of ' + url).exit(); // <--- don't forget me!
});

casper.on('page.loaded', function () {

});

function dumpPageContent(casper) {
    var html = casper.getPageContent();
    var filename = out + ".htm";
    casper.echo("dump page content to file " + filename);
    require('fs').write(filename, html, 'w');
}
