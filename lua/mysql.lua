function rows (connection, sql_statement)
  local cursor = assert (connection:execute (sql_statement))
  return function ()
    return cursor:fetch()
  end
end

function row(connection,sql_statement)
  return assert(connection:execute (sql_statement))
end

local cjson = require "cjson"
local luasql = require "luasql.mysql"

local key = ngx.var.arg_key
local value = ngx.var.arg_value

env = assert(luasql.mysql())
conn = assert(env:connect("test","root","YUm32izp-","127.0.0.1",3306))

for k,v in rows(conn ,"select k,v from kv") do
    ngx.say(k..v.."\n")
end


local i = row(conn ,"insert into kv (k,v) values (3,5)")
ngx.say(i.."\n")

ngx.say(cjson.encode( { true, { foo = "bar" } ,{ "a", "b", "c"}}))
conn:close()
env:close()

