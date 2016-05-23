local cjson , aliyunclient ,ecsCache = require "cjson" ,require "aliyunclient" , ngx.shared.ecscache
local method = ngx.var.arg_method

function handleTeamList(regionList , ecsCache)
        local teamList = {}
        table.foreach(regionList , function(key,value)
                      local t_j = aliyunclient.visitjson('ecs' , 'DescribeTags' , '--Tag1Key Team --RegionId ' .. value)
                      table.foreach(t_j.data.Tags.Tag , function(k , val)
                              if val.TagKey == 'Team' then
                                teamList[val.TagValue] = teamList[val.TagValue] and (teamList[val.TagValue] + val.ResourceTypeCount.Instance) or val.ResourceTypeCount.Instance
                              end
                      end)        
        end)
	ecsCache:set('teamlist' , cjson.encode(teamList))
end

function handleECSList(regionList , ecsCache , pageNum , resultMapById)
	table.foreach(regionList , function(key,value)
		handleECSListPageN(value , ecsCache , pageNum , resultMapById)
	end)
end

function handleECSListPageN(region , ecsCache , pageNum , resultMapById)
	local t_j = aliyunclient.visitjson('ecs' , 'DescribeInstances' , '--PageSize 100 --RegionId ' .. region .. ' --PageNumber ' .. pageNum )
	table.foreach(t_j.data.Instances.Instance , function(k , val)
		resultMapById[val.InstanceId] = { instanceId = val.InstanceId , instanceName = val.InstanceName , zone = val.ZoneId , region = val.RegionId , createTime = val.Creati
onTime , expireTime = val.ExpiredTime , status = val.Status , innerIp = val.InnerIpAddress.IpAddress[1] , cpu = val.Cpu , memory = val.Memory , bandWidth = val.InternetMaxBandwidthO
ut , outerIp = val.PublicIpAddress.IpAddress[1] and val.PublicIpAddress.IpAddress[1] or '' , tags = val.Tags.Tag }
		table.foreach(val.Tags.Tag , function(tk,tv)
                        if tv.TagKey == 'Team' then
                                resultMapById[val.InstanceId]['team'] = tv.TagValue
                        end
                end)
	end)
	if (pageNum * t_j.data.PageSize) < t_j.data.TotalCount then
		handleECSListPageN(region , ecsCache , pageNum + 1 , resultMapById)
	end
end

function handleDisckList(regionList , ecsCache , pageNum , resultMapById)
	table.foreach(regionList , function(key,value)
                handleDiskListPageN(value , ecsCache , pageNum , resultMapById)
        end)	
end

function handleDiskListPageN(region , ecsCache , pageNum , resultMapById)
        local t_j = aliyunclient.visitjson('ecs' , 'DescribeDisks' , '--PageSize 100 --RegionId ' .. region .. ' --PageNumber ' .. pageNum )
        table.foreach(t_j.data.Disks.Disk , function(k , val)
		resultMapById[val.InstanceId].disks = (resultMapById[val.InstanceId].disks and resultMapById[val.InstanceId].disks or {})
		table.insert(resultMapById[val.InstanceId].disks , { type = val.Type , category = val.Category , size = val.Size })
        end)
        if (pageNum * t_j.data.PageSize) < t_j.data.TotalCount then
                handleDiskListPageN(region , ecsCache , pageNum + 1 , resultMapById)
        end
end

function handleResult(resultMapById , ecsCache)
	local resultMapByTeam , resultMapByIp = {} , {}
	table.foreach(resultMapById , function(key , value)
		if resultMapByTeam[value.team] == nil then 
			resultMapByTeam[value.team] = {}
		end
		table.insert(resultMapByTeam[value.team] , value)

		if resultMapByIp[value.innerIp] == nil then
			resultMapByIp[value.innerIp] = {}
		end
		table.insert(resultMapByIp[value.innerIp] , value)
	end)
	ecsCache:set('resultByTeam' , cjson.encode(resultMapByTeam))
	ecsCache:set('resultByIp' , cjson.encode(resultMapByIp))
end

if method == 'teamlist' then
	ngx.say(ecsCache:get('teamlist'))
	return
elseif method == 'ip' then
	local ip = ngx.var.arg_ip
	local t_j = cjson.decode(ecsCache:get('resultByIp'))
        if ip then
   	    ngx.say(cjson.encode(t_j[ip]))
        else
            ngx.say(cjson.encode(t_j))
        end
	return	
elseif method == 'team' then
	local teamname = ngx.var.arg_tn
	if teamname == nil then
		local t_j = cjson.decode(ecsCache:get('resultByTeam'))
		table.foreach(t_j , function (t_j_team,t_j_team_v) 
			table.foreach(t_j_team_v , function ( t_j_ins , t_j_ins_v )
				table.sort( t_j_ins_v.tags , function ( tgs1 , tgs2 )
					local orderMap = { Team = 1 , Phase = 2 , AppName = 3 , Role = 4 }
					return orderMap[tgs1.TagKey] < orderMap[tgs2.TagKey]
				end )
			end)
		end)
		ngx.say(cjson.encode(t_j))
	else
		local t_j = cjson.decode(ecsCache:get('resultByTeam'))
		ngx.say(cjson.encode(t_j[teamname]))
	end
	return
elseif method == 'reload' then
	local regionListJson , regionList = aliyunclient.visitjson('ecs' , 'DescribeRegions') , {}
	table.foreach(regionListJson.data.Regions.Region , function(k,val) table.insert(regionList,val.RegionId) end)
	handleTeamList(regionList , ecsCache)
	local resultMapById = {}
	handleECSList(regionList, ecsCache , 1 , resultMapById)
	handleDisckList(regionList, ecsCache , 1 , resultMapById)
	handleResult(resultMapById , ecsCache)
	return
elseif method == 'reboot' or method == 'stop' or method == 'start' then
	local check = ngx.var.remote_addr
	if check ~= 'xxx.xxx.xxx.xxx' then
		return 
	end
	local action = { reboot = 'RebootInstance' , stop = 'StopInstance' , start = 'StartInstance' }
	local ip = ngx.var.arg_ip
        local t_j = cjson.decode(ecsCache:get('resultByIp'))
	local id = t_j[ip][1].instanceId
	local r = aliyunclient.visitjsonadmin('ecs' , action[method] , '--InstanceId ' .. id)	
	ngx.say(cjson.encode(r))
	return
elseif method == 'refresh' then
	local ip = ngx.var.arg_ip
	local t_j = cjson.decode(ecsCache:get('resultByIp'))
        local id = t_j[ip][1].instanceId
	local r = aliyunclient.visitjson('ecs' , 'DescribeInstances' ,'--InstanceIds [\\"' .. id .. '\\"]' )
	t_j[ip][1].status = r.data.Instances.Instance[1].Status
        ecsCache:set('resultByIp' , cjson.encode(t_j))

	local t_k = cjson.decode(ecsCache:get('resultByTeam'))
	table.foreach(t_k[t_j[ip][1].team] , function(i , v)
		if v.instanceId == id then
			v.status = r.data.Instances.Instance[1].Status
		end
	end)
	ecsCache:set('resultByTeam' , cjson.encode(t_k))
	ngx.say(cjson.encode({ status = r.data.Instances.Instance[1].Status }))
	return 
end

