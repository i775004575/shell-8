local cjson , aliyunclient = require "cjson" ,require "aliyunclient"
local type , action , metric , dims , other = ngx.req.get_post_args()['type'] ,ngx.req.get_post_args()['action'] , ngx.req.get_post_args()['metric'] , ngx.req.get_post_args()['dims'
] , ngx.req.get_post_args()['other']
dims  = '\'' .. ngx.unescape_uri(dims) .. '\''
other = (other and other or '')
other = ngx.unescape_uri(other)
local params = '--Project acs_' .. type .. ' --Metric ' .. metric .. ' --Dimensions ' .. dims .. ' ' .. other
--ngx.say(params)
aliyunclient.visit('cms' , action , params)

