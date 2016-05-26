local redis = require "resty.redis"
local tostring=tostring
local gw_config = require "gw_config"

local _M = {}           
_M._VERSION = '1.0' 
local mt = { __index = _M }
local _ip=gw_config.redis.host
local _port=gw_config.redis.port


function _M.hget(self,key,field)
	local red = redis:new()
        red:set_timeout(1000)
--        ngx.log(ngx.ERR,"redis,ip:"..tostring(_ip)..",port:"..tostring(_port))
        local ok, err = red:connect(_ip,_port)
        if not ok then
                ngx.log(ngx.ERR,"failed to connect redis,ip:"..tostring(_ip)..",port:"..tostring(_port))
        	return
        end
	local res, err = red:hget(key,field)
	if not res then
		ngx.log(ngx.ERR,"hget:",err)
		return
	end
	return res
end

function _M.hset(self,key,field,value)
        local red = redis:new()
        red:set_timeout(1000)
        local ok, err = red:connect(_ip,_port)
        if not ok then
                ngx.log(ngx.ERR,"failed to connect redis ")
                return
        end
        local res, err = red:hset(key,field,value)
        if not res then
                ngx.log(ngx.ERR,"hset:",err)
                return
        end
        return res
end

function _M.hincrby(self,key,field,value)
        local red = redis:new()
        red:set_timeout(1000)
        local ok, err = red:connect(_ip,_port)
        if not ok then
                ngx.log(ngx.ERR,"failed to connect redis ")
                return
        end
        local res, err = red:hincrby(key,field,value)
        if not res then
                ngx.log(ngx.ERR,"hincrby:",err)
                return
        end
        return res
end


return _M
