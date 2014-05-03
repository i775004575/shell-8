
##BASIC FUNCTION

function ltrim(s) { sub(/^[ \t\r\n]+/, "", s); return s }
function rtrim(s) { sub(/[ \t\r\n]+$/, "", s); return s }
function trim(s)  { return rtrim(ltrim(s)); }

##DEFINE YOURSELF
function test(s)  { return "test -----"s; }

function f_action(name,psstr)
{ 
	if(name=="trim"){return trim(psstr);}
	if(name=="test"){return test(psstr);}
}
