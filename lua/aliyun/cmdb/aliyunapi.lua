local aliyunclient = require "aliyunclient"
local type , action , params = ngx.req.get_post_args()['type'] , ngx.req.get_post_args()['action'] , ngx.req.get_post_args()['params']
aliyunclient.visit(type , action , params)
