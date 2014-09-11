var page = new WebPage();
console.log('=====start=====');

page.open('http://www.v2ex.com', function(status) {
  if ( status === "success" ) {
	page.includeJs("http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js", function() {
        var t = page.evaluate(function() {
		var result = "" ;
                $(".item_title").each(function(){
			result = result + "\n" + $(this).text();
		});
                return result;
        });
	console.log(t);
        phantom.exit();
	});
  }
});
