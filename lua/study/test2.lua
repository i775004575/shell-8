printResult = ""
function printt(...)
	for i,v in ipairs(arg) do
		print(i)
		print(v)
		printResult = printResult .. tostring(v) .. "\t"
	end
	printResult = printResult .. "\n"
end

printt("hello","word")
print(printResult)
