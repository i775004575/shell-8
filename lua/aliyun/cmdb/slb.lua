local cjson , aliyunclient ,cache , ecsCache = require "cjson" ,require "aliyunclient" , ngx.shared.slbcache , ngx.shared.ecscache
local method , result = ngx.var.arg_method , {}

function handle(result)
	local ecslist = cjson.decode(ecsCache:get('resultByIp'))
	local resultjson = aliyunclient.visitjson('slb' , 'DescribeLoadBalancers')
	table.foreach(resultjson.data.LoadBalancers.LoadBalancer , function(key , val)
		local attr = aliyunclient.visitjson('slb' , 'DescribeLoadBalancerAttribute' , ' --LoadBalancerId ' .. val.LoadBalancerId )
		val.InternetChargeType = attr.data.InternetChargeType
		val.ListenerPorts = attr.data.ListenerPorts.ListenerPort
		val.BackendServers = attr.data.BackendServers.BackendServer
		table.foreach(val.BackendServers , function(k , v)
			local id = v.ServerId
			table.foreach(ecslist , function (ip , value)
				if value[1].instanceId == id then 
					v.ip = ip
					return
				end
			end)
		end)
		table.insert(result , val)
	end)
end

if method == 'reload' then
	handle(result)
	ngx.say(cjson.encode(result))
	cache:set('slb',cjson.encode(result))
elseif method == 'list' then
	local json = cache:get('slb')
	ngx.say(json)
end

