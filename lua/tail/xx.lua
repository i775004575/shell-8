local cjson = require "cjson"

function sleep(n)
    os.execute("sleep " .. n)
end

function handle(event)
    for a , b , c , d , e , f ,g , h , i , j , k , l in string.gmatch(event , '([%d.]+) ([%d.:]+) ([%d.]+) ([%d.-]+) %[(.+)%] "([%a]+) (.+)" ([%d]+) ([%d]+) ([%d]+) "(.+)" "(.+)"') do
        local json = cjson.encode({ a = a , b = b , c = c , d = d , e = e , f = f , g = g , h = h , i = i , j = j , k = k , i = i })
        print(json)
    end
end

local file = io.open("/oneapm/log/nginx/bi-dc_20160811.log", "r")
local pos , BUFFERSIZE = file:seek("end") , 2^13
local left = ""

while(true) 
do 
    local t_pos , content = file:seek("end")  , ""
    if t_pos == pos then
        sleep(1)
    else
        file:seek("set" , pos -1 )
        if t_pos - pos <= BUFFERSIZE then
            content = file:read(t_pos - pos)
            pos = t_pos
        end
        if t_pos - pos > BUFFERSIZE then
            content = file:read(BUFFERSIZE)
            pos = pos + BUFFERSIZE
        end
        content = left .. content          
        left = ""
        for line in content:gmatch('[^\n]+') do
            if left ~= "" then
                handle(left)
            end
            left = line
        end
        if string.byte(content , -1) == 10 then
            handle(left)
            left = ""
        end
    end
end
file:close()