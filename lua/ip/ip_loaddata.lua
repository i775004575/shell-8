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

function Split(str, delim, maxNb)   
    if string.find(str, delim) == nil then  
        return { str }  
    end  
    if maxNb == nil or maxNb < 1 then  
        maxNb = 0    -- No limit   
    end  
    local result = {}  
    local pat = "(.-)" .. delim .. "()"   
    local nb = 0  
    local lastPos   
    for part, pos in string.gfind(str, pat) do  
        nb = nb + 1  
        result[nb] = part   
        lastPos = pos   
        if nb == maxNb then break end  
    end  
    if nb ~= maxNb then  
        result[nb + 1] = string.sub(str, lastPos)   
    end  
    return result   
end

local ipdb = ngx.shared.ipdb
local dataconfig = ngx.shared.dataconfig
local regionvsid = ngx.shared.regiondb
local countryvsid = ngx.shared.countrydb


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
dataconfig:set("indexBuffer",indexBuffer)
dataconfig:set("offset_len",offset_len)

local f = io.open("/home/peiliping/dev/IP/provinceid")
local sr = {}
for i in f:lines() do
    sr = Split(i,"\t")
    regionvsid:set(sr[1],sr[2])
end

local f2 = io.open("/home/peiliping/dev/IP/countryid")
local sr2 = {}
for i in f2:lines() do
    sr2 = Split(i,"\t")
    countryvsid:set(sr2[1],sr2[2])
    ngx.say(sr2[1] .. "" .. sr2[2])
end

ngx.say("ok")