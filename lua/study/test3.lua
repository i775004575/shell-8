local f = io.open("/home/peiliping/dev/gitwork/self/shell/lua/study/data","r")

local c = f:read("*all")

print(c)

f:close()
