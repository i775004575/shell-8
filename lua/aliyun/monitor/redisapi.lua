local cjson , aliyunclient = require "cjson" ,require "aliyunclient"
local id = ngx.var.arg_instanceId
local result = { Id = id , Timestamp = os.time() }

local redisresult = aliyunclient.visitjson('r-kvstore' , 'DescribeInstances' , '--InstanceIds ' .. id)
result['ConnectionDomain'] = redisresult.data.Instances.KVStoreInstance[1].ConnectionDomain
result['Name'] = redisresult.data.Instances.KVStoreInstance[1].InstanceName
result['Team'] = string.sub(result.Name,1,(string.find(result.Name,'_',1,true)-1))
result['Capacity'] = redisresult.data.Instances.KVStoreInstance[1].Capacity * 1024 * 1024

local redismonitorresult = aliyunclient.visitjson('r-kvstore' , 'DescribeMonitorValues' , '--InstanceIds ' .. id)
table.foreach(redismonitorresult.data.InstanceIds.KVStoreInstanceMonitor[1].MonitorKeys.KVStoreMonitorKey , function(k , value)
	local tmp_key = string.upper(string.sub(value.MonitorKey,1,1)) .. string.sub(value.MonitorKey,2)
	result[tmp_key]=tonumber(value.Value)
end)

local metric = { Append = true , Auth = true , Bitcount = true , Bitop = true , Blpop = true , Brpop = true , Brpoplpush = true , ConnCount = true , Dbsize = true , Decr = true , De
crby = true , Del = true , Discard = true , Dump = true , Echo = true , EvictedKeys = true , Exec = true , Exists = true , Expire = true , Expireat = true , ExpiredKeys = true , Exp
ires = true , FailedCount = true , Flushall = true , Flushdb = true , Get = true , Getbit = true , Getrange = true , Getset = true , Hdel = true , Hexists = true , Hget = true , Hge
tall = true , Hincrby = true , Hincrbyfloat = true , HitKeys = true , Hkeys = true , Hlen = true , Hmget = true , Hmset = true , Hscan = true , Hset = true , Hsetnx = true , Hvals =
 true , Incr = true , Incrby = true , Incrbyfloat = true , InFlow = true , Info = true , Keys = true , Lindex = true , Linsert = true , Llen = true , Lpop = true , Lpush = true , Lp
ushx = true , Lrange = true , Lrem = true , Lset = true , Ltrim = true , Mget = true , MissedKeys = true , Move = true , Mset = true , Msetnx = true , Multi = true , OutFlow = true 
, Persist = true , Pexpire = true , Pexpireat = true , Pfadd = true , Pfcount = true , Pfmerge = true , Psetex = true , Psubscribe = true , Pttl = true , Publish = true , Pubsub = t
rue , Punsubscribe = true , Quit = true , Randomkey = true , Rename = true , Renamenx = true , Restore = true , Rpop = true , Rpoplpush = true , Rpush = true , Rpushx = true , Sadd 
= true , Scan = true , Scard = true , Sdiff = true , Sdiffstore = true , Select = true , Set = true , Setbit = true , Setex = true , Setnx = true , Setrange = true , Sinter = true ,
 Sinterstore = true , Sismember = true , Smembers = true , Smove = true , Sort = true , Spop = true , Srandmember = true , Srem = true , Sscan = true , Strlen = true , Subscribe = t
rue , Sunion = true , Sunionstore = true , TotalQps = true , Ttl = true , Type = true , Unsubscribe = true , Unwatch = true , UsedMemory = true , UsedRss = true , Watch = true , Zad
d = true , Zcard = true , Zcount = true , Zincrby = true , Zinterstore = true , Zlexcount = true , Zrange = true , Zrangebylex = true , Zrangebyscore = true , Zrank = true , Zrem = 
true , Zremrangebylex = true , Zremrangebyrank = true , Zremrangebyscore = true , Zrevrange = true , Zrevrangebyscore = true , Zrevrank = true , Zscan = true , Zscore = true , Zunio
nstore = true }
table.foreach(metric,function(k,value)  if not result[k] then  result[k] = 0  end end)

result['MemoryFree'] = result.Capacity - result.UsedMemory
result['UsedRatio'] = ( result.UsedMemory / result.Capacity ) * 100

ngx.say(cjson.encode(result))
