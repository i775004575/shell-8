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

local f = io.open("data.log","r")
local linenum = 0
local sr = {}
for i in f:lines() do
	linenum = linenum + 1
	sr[linenum] = Split(i," ")
end
f:close()
local limit = linenum - 3

local i1,i2,i3,j1,j2,j3,k,count,tmp1,t

cl = os.clock()

for i1 = 0,9 do
	for i2 = 0,9 do
		for i3 = 0,9 do
			for j1 = 0,9 do
				for j2 = 0,9 do
					for j3 = 0,9 do
						for k = 0,9 do
							count = 0
							for t = 1,linenum do
								tmp1 = ((sr[t][1]^i1) * j1 + (sr[t][2]^i2) * j2 + (sr[t][3]^i3) * j3 + k ) / 10
								tmp1 = math.floor(tmp1) % 10
								if tmp1 % 3 == sr[t][5] % 3 then
									count = count + 1 
								end
							end
							if count > limit then 
								for t = 1,linenum do
									tmp1 = ((sr[t][1]^i1) * j1 + (sr[t][2]^i2) * j2 + (sr[t][3]^i3) * j3 + k ) / 10
									tmp1 = math.floor(tmp1) % 10
									if tmp1 % 3 == sr[t][5] % 3 then
										print(i1..i2..i3..j1..j2..j3..k.." "..t)
									end								
								end
							end
						end
					end
				end
			end
		end
	end
end
print(os.clock()-cl)
