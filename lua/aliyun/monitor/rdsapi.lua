local cjson , aliyunclient = require "cjson" ,require "aliyunclient"
local id = ngx.var.arg_instanceId
local result = { Id = id , Timestamp = os.time() }
local st , et = os.date("%Y-%m-%dT%H:%MZ",result.Timestamp-3600*8-300) , os.date("%Y-%m-%dT%H:%MZ",result.Timestamp-3600*8)

function handlemetric(rdstmpresult , key , metric1 , metric2)
	table.foreach(rdstmpresult.data.PerformanceKeys.PerformanceKey , function(k , value)
		if value.Key == key then 
			local tmp = value.Values.PerformanceValue[1].Value
			if metric2 then 
				result[metric1] = tonumber(string.sub(tmp,1,(string.find(tmp,'&',1,true)-1)))
				result[metric2] = tonumber(string.sub(tmp,(string.find(tmp,'&',1,true)+1)))
			else
				result[metric1] = tonumber(tmp)
			end
		end
	end)
end

function handleBasic(rdsdruresult , rdsddiaresult)
	result['DiskUsed'] = rdsdruresult.data.DiskUsed
	result['LogSize'] = rdsdruresult.data.LogSize
	result['DataSize'] = rdsdruresult.data.DataSize
	result['DBInstanceStorage'] = rdsddiaresult.data.Items.DBInstanceAttribute[1].DBInstanceStorage * 1024 * 1024 * 1024
	result['DiskFree'] = result.DBInstanceStorage - result.DiskUsed
	result['DiskUsedRatio'] = (result.DiskUsed / result.DBInstanceStorage) * 100
	result['Name'] = rdsddiaresult.data.Items.DBInstanceAttribute[1].DBInstanceDescription
	result['Team'] = string.sub(result.Name,1,(string.find(result.Name,'_',1,true)-1))
end

local trytimes , status = 0 , false
while ( (trytimes < 3) and (not status) ) do 
	local rdsrsuresult = aliyunclient.visitjson('rds' , 'DescribeResourceUsage' , '--DBInstanceId ' .. id)
	local rdsattrresult = aliyunclient.visitjson('rds' , 'DescribeDBInstanceAttribute' , '--DBInstanceId ' .. id)
	status = pcall(handleBasic , rdsrsuresult , rdsattrresult)
	trytimes = trytimes + 1 
end
trytimes , status = 0 , false
while ( (trytimes < 3) and (not status) ) do
	local keys = 'MySQL_IOPS,MySQL_Sessions,MySQL_MemCpuUsage,MySQL_NetworkTraffic,MySQL_QPSTPS'
	local rdsmetricresult = aliyunclient.visitjson('rds','DescribeDBInstancePerformance','--Key ' .. keys .. ' --DBInstanceId ' .. id .. ' --StartTime ' .. st .. ' --EndTime ' .
. et)
	status = pcall(function () 
		handlemetric(rdsmetricresult , 'MySQL_IOPS' , 'Iops')
		handlemetric(rdsmetricresult , 'MySQL_Sessions' , 'ActiveSession','TotalSession')
		handlemetric(rdsmetricresult , 'MySQL_MemCpuUsage' , 'Cpu','Memory')
		handlemetric(rdsmetricresult , 'MySQL_NetworkTraffic' , 'NetRecv','NetSend')
		handlemetric(rdsmetricresult , 'MySQL_QPSTPS' , 'Qps','Tps')
	end)
	trytimes = trytimes + 1 
end

--local rdsrsuresult = aliyunclient.visitjson('rds' , 'DescribeResourceUsage' , '--DBInstanceId ' .. id)
--local rdsattrresult = aliyunclient.visitjson('rds' , 'DescribeDBInstanceAttribute' , '--DBInstanceId ' .. id)
--handleBasic(rdsrsuresult , rdsattrresult)

--local keys = 'MySQL_IOPS,MySQL_Sessions,MySQL_MemCpuUsage,MySQL_NetworkTraffic,MySQL_QPSTPS'
--local rdsmetricresult = aliyunclient.visitjson('rds','DescribeDBInstancePerformance','--Key ' .. keys .. ' --DBInstanceId ' .. id .. ' --StartTime ' .. st .. ' --EndTime ' .. et)
--handlemetric(rdsmetricresult , 'MySQL_IOPS' , 'Iops')
--handlemetric(rdsmetricresult , 'MySQL_Sessions' , 'ActiveSession','TotalSession')
--handlemetric(rdsmetricresult , 'MySQL_MemCpuUsage' , 'Cpu','Memory')
--handlemetric(rdsmetricresult , 'MySQL_NetworkTraffic' , 'NetRecv','NetSend')
--handlemetric(rdsmetricresult , 'MySQL_QPSTPS' , 'Qps','Tps')

ngx.say(cjson.encode(result))

