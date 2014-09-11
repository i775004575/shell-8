var page = new WebPage();
var url = phantom.args[0] ;
page.onError = function(msg, trace) {};
page.open(url,function(status) {
  if ( status === "success" ) {
	var r = page.evaluate(function() {
	return document.getElementsByTagName("html")[0].outerText;
	});
	console.log(r);
  }else{
	console.log("Failed!!");
  }
  phantom.exit();
});
