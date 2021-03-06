// Generated by LiveScript 1.5.0
(function(){
  var request, domino, URL, getPrinter, print, ref$, url, sel, domain, opts, slice$ = [].slice;
  request = require('request');
  domino = require('domino');
  URL = require('url');
  getPrinter = require('./shared').getPrinter;
  print = getPrinter(slice$.call(process.argv, 2));
  ref$ = slice$.call(process.argv, -2), url = ref$[0], sel = ref$[1];
  domain = URL.parse(url).host;
  opts = {
    url: url,
    'User-Agent': 'Firefox'
  };
  request(opts, function(error, response, body){
    var win, nodes, i$, len$, node, results$ = [];
    if (error) {
      console.error(error);
      process.exit(1);
    }
    win = domino.createWindow(body);
    nodes = win.document.querySelectorAll(sel);
    for (i$ = 0, len$ = nodes.length; i$ < len$; ++i$) {
      node = nodes[i$];
      results$.push(print(node));
    }
    return results$;
  });
}).call(this);
