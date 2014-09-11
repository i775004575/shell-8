var page = new WebPage();

page.open('http://www.v2ex.com/?tab=all', function(status) {
  if ( status === "success" ) {
	page.includeJs("http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js", function() {
        var t = page.evaluate(function() {
		var result = "" ;
                $(".item_title").each(function(){
			result = result + $(this).text() ;
			result = result + "\t" + "http://www.v2ex.com" +$(this).find("a").attr("href") + "\n";
		});
                return result;
        });
	console.log(t);
        phantom.exit();
	});
  }
});
