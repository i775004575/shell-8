local luasql = require "luasql.mysql"
env = assert(luasql.mysql())
conn = assert(env:connect("test","root","YUm32izp-","127.0.0.1",3306))

function rows (connection, sql_statement)
  local cursor = assert (connection:execute (sql_statement))
  return function ()
    return cursor:fetch()
  end
end

for k,v in rows(conn ,"SELECT * from kv") do
    print(string.format("%s  %s",k,v))
end

conn:close()
env:close()
