local cjson = require "cjson"
local bit32 = require "bit32"

local ipdb = ngx.shared.ipdb
local indexBuffer = ipdb:get("indexBuffer")
local offset_len = ipdb:get("offset_len")

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

function IpOffset(ipstr,indexBuffer,offset_len)
    local ip1,ip2,ip3,ip4 = string.match(ipstr, "(%d+).(%d+).(%d+).(%d+)")
    local ip_uint32 = byteToUint32(ip1, ip2, ip3, ip4)
    local tmp_offset = ip1 * 4 
    local start_len = byteToUint32(string.byte(indexBuffer, tmp_offset + 4), string.byte(indexBuffer, tmp_offset + 3), string.byte(indexBuffer, tmp_offset + 2), string.byte(indexBuffer, tmp_offset + 1))
    local max_comp_len = offset_len - 1028
    start = start_len * 8 + 1024 + 1
    local find_uint32 = 0
    local index_offset = -1
    local index_length = -1
    while start < max_comp_len do
        find_uint32 = byteToUint32(string.byte(indexBuffer, start), string.byte(indexBuffer, start+1),string.byte(indexBuffer, start+2),string.byte(indexBuffer, start+3))
        if ip_uint32 <= find_uint32  then
			index_offset = byteToUint32(0, string.byte(indexBuffer, start+6),string.byte(indexBuffer, start+5),string.byte(indexBuffer, start+4))
			index_length = string.byte(indexBuffer, start+7)
			break
	end
	start = start + 8
    end
    if index_offset == -1 or index_length == -1 then
	return nil
    end
    return index_offset
end

local pip = ngx.var.arg_ip
local gtmp = IpOffset(pip,indexBuffer,offset_len)
if gtmp == nil then 
  ngx.say(cjson.encode({country = "UNKNOWN COUNTRY", province = "UNKNOWN PROVINCE"}))
else
  local k = ipdb:get(gtmp)
  if k == nil then 
	ngx.say(cjson.encode({country = "UNKNOWN COUNTRY", province = "UNKNOWN PROVINCE"}))
  else	
	local res = {}
	res = Split(k,"\t")
	ngx.say(cjson.encode({country = res[1], province = res[2] }))
  end
end
