local cjson , shell = require "cjson" , require "resty.shell"

local aliyunclient = {}

function aliyunclient.visitjson(type , action , params)
	if not type then 
  		type , action , params = 'help' , nil , nil
	end
	if not action then 
 		action , params = 'help' , nil
	end
	if not params then 
		params = '' 
	end
	if string.find(action,'^Describe') or string.find(action,'^Query') or string.find(action,'^help') then 
		local status, out, err = shell.execute('export HOME="/home/nginx" && aliyuncli ' .. type .. ' ' .. action .. ' ' .. params)
		return { status = status , data = cjson.decode(out) , msg = err }
	else
		return { status = false , data = {} , msg = 'No Permission' }
	end
end

function aliyunclient.visitjsonadmin(type , action , params)
        if not type then
                type , action , params = 'help' , nil , nil
        end
	if not action then
                action , params = 'help' , nil
        end
	if not params then
                params = ''
        end
        local status, out, err = shell.execute('export HOME="/home/nginx" && aliyuncli ' .. type .. ' ' .. action .. ' ' .. params)
        return { status = status , data = cjson.decode(out) , msg = err }
end

function aliyunclient.visit(type , action , params)
        if not type then
                type , action , params = 'help' , nil , nil
        end
	if not action then
                action , params = 'help' , nil
        end
	if not params then
                params = ''
        end
	if string.find(action,'^Describe') or string.find(action,'^Query') or string.find(action,'^help') then
                local status, out, err = shell.execute('export HOME="/home/nginx" && aliyuncli ' .. type .. ' ' .. action .. ' ' .. params)
                -- ngx.say('status:' .. status )
		-- ngx.say('error:'  .. (err and err or '') )
		-- ngx.say('data:\n' .. out)
                ngx.say(out)
        else
		ngx.say('status:false')
            	ngx.say('error:No Permission')
        end
end

return aliyunclient

