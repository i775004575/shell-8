local bit32 = require "bit32"

function byteToUint32(a,b,c,d)
        local _int = 0
	if a then
		_int = _int +  bit32.lshift(a, 24)
	end
	_int = _int + bit32.lshift(b, 16)
	_int = _int + bit32.lshift(c, 8)
	_int = _int + d
	if _int >= 0 then
        return _int
    else
        return _int + math.pow(2, 32)
    end
end

local ipdb = ngx.shared.ipdb
local indexBuffer = ''
local offset_len = 0
local ipBinaryFilePath = "/home/peiliping/dev/IP/ipdb.dat"
local file = io.open(ipBinaryFilePath)
local str = file:read(4)    
offset_len = byteToUint32(string.byte(str, 1), string.byte(str, 2),string.byte(str, 3),string.byte(str, 4))
indexBuffer = file:read(offset_len - 4)
file:seek("set", 4)
local indexPrefixBuf = file:read(1024);
local indexBuf = file:read(offset_len - 4 - 1024);
local index_offset = -1;
local index_length = -1;
local index = 1;
while index < string.len(indexBuf) do
    index_offset =  byteToUint32(0, string.byte(indexBuf, index+6),string.byte(indexBuf, index+5),string.byte(indexBuf, index+4))
    index_length = string.byte(indexBuf, index+7)
    index = index + 8
    file:seek("set", offset_len - 1024 + index_offset)
    ipdb:set(index_offset,file:read(index_length))
end
ipdb:set("indexBuffer",indexBuffer)
ipdb:set("offset_len",offset_len)
ngx.say("ok")

