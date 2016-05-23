local cjson , mysql = require "cjson" , require "resty.mysql"
local db , databaseBlackList , tableBlackList =  mysql:new() , { information_schema = true , mysql = true , performance_schema = true , quartzdata = true } , { increment_trx = true 
}
local ds , context = cjson.decode(ngx.req.get_post_args()['ds']) , cjson.decode(ngx.req.get_post_args()['ct'])  -- ds : {username , password , host , team}  ct: {printformat , cache
result , mergehistory , onlyreadcache, caldelta}
local checkResult  , resultCache = { successResult = {} , failResult = {} } , ngx.shared.resultcache 

function getPriKeySql(dbname , tbname) 
	return "SELECT column_name FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_SCHEMA='" .. dbname .. "' AND TABLE_NAME='" .. tbname .. "' AND COLUMN_KEY='PRI' AND EXTRA='auto_incre
ment'" 
end
function getMaxPriKeyValSql(dbname , tbname , colname) 
	return 'SELECT max(' ..colname .. ') as val FROM ' .. dbname ..'.' .. tbname 
end
function buildResultKey(ds , dbname , tbname) 	
	return ds.team .. ',' .. dbname .. ',' .. ds.host .. ',' .. tbname 
end 
function handle(db , sql , colname , blackList) 
	local res = {} ; 
	table.foreach(db:query(sql) , function(i , row) 
		if not blackList  or not blackList[row[colname]] then 
			table.insert(res,row[colname]) 
		end 
	end) 
	return res 
end
function printAndSaveResult(ds , context , resultCache , checkResult)
	if context.onlyreadcache and resultCache:get(ds.host) then 
		checkResult = cjson.decode(resultCache:get(ds.host))
	else
		if context.mergehistory and resultCache:get(ds.host) then 
			local lastCheckResult = cjson.decode(resultCache:get(ds.host))
			table.foreach(checkResult.successResult , function(key , value) 
				value['lastvalue']=(lastCheckResult.successResult[key] and lastCheckResult.successResult[key].value or -1) 
				if context.caldelta then	
					value['delta']=(value.lastvalue > 0 and  value.value - value.lastvalue or 0 )
				end
			end )
		end
		if context.cacheresult then resultCache:set(ds.host , cjson.encode(checkResult)) end
	end
	if context.printformat == 'json' then 
		 ngx.say(cjson.encode(checkResult))
	else
		table.foreach(checkResult.successResult , function(key , value) 
			if context.caldelta then
				ngx.say(key .. ',' .. 'success,' .. value.timestamp .. ',' .. value.value .. ',' .. value.lastvalue .. ',' .. value.delta)  
			else
				ngx.say(key .. ',' .. 'success,' .. value.timestamp .. ',' .. value.value .. ',' .. value.lastvalue)  
			end
		end ) 
		table.foreach(checkResult.failResult , function(key , value) ngx.say(key .. ',' .. 'failed,' .. value.timestamp .. ',' .. value.reason)  end )
	end 
end

if context.onlyreadcache then 
	printAndSaveResult(ds , context , resultCache , checkResult)
else
	db:set_timeout(1000) ; db:connect{ host = ds.host , user = ds.username , password = ds.password }
	local dbList = handle(db , 'show databases' , 'Database' , databaseBlackList)
	table.foreach(dbList , function(i,dbname)
		db:query('use ' .. dbname) ; local tableList = handle(db , 'show tables' ,'Tables_in_' .. dbname , tableBlackList)
		table.foreach(tableList , function(i , tbname)
			local colList , resultKey = handle(db , getPriKeySql(dbname , tbname) , 'column_name') , buildResultKey(ds , dbname , tbname)
			if table.getn(colList) == 1 then 
				local valList = handle(db , getMaxPriKeyValSql(dbname , tbname , colList[1]) ,'val')
				if tonumber(valList[1]) then 
					checkResult.successResult[resultKey] = { value = tonumber(valList[1]) , lastvalue = -1 , timestamp = os.time() }
				else
					checkResult.failResult[resultKey] = { reason = 'Empty Table' , timestamp = os.time() }
				end
			else
				checkResult.failResult[resultKey] = { reason = 'Not Found Right Primary Key' , timestamp = os.time() }
			end 
		end)
	end)
	db:close() ; printAndSaveResult(ds , context , resultCache , checkResult)
end

