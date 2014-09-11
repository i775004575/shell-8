var Main , page;
var urlbase = "http://www.neitui.me/neitui/type=all&page=" , tail = ".html";
var max = 1 , current = 1 ;

Main = function(urlbase,max,tail,current,callback){
  page = new WebPage();
  url = urlbase + current + tail ;
  if(current>max){
	return callback();
  }
  next=function(){
	page.close();
	current++;
	Main(urlbase,max,tail,current,callback);
  }
  page.open(url,function(status){
	if ( status === "success" ) {
        	page.includeJs("http://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js", function() {
		        var t = page.evaluate(function() {
                	var result = "" ;
	                $(".jobtitle").each(function(){
        	                result = result + "\n" + $(this).text();
				result = result + "\t" + "http://www.neitui.me" + $(this).find("a").attr("href");
				var tmpid=$("div").index(this)-1;
				result = result + "\t" + $("div").get(tmpid).innerText;
                	});
                	return result;
		});
        	console.log(t);
		next();
		});
	}
  });
}

Main(urlbase,max,tail,current,function(){return phantom.exit();});
