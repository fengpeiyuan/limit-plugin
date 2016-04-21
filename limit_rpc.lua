local redis = require "resty.redis"
local tostring=tostring

local _M = {}           
_M._VERSION = '1.0' 
local mt = { __index = _M }
local _ip="127.0.0.1"
local _port="6380"

function _M.init(self,ip,port)
	_ip=ip
	_port=port
	return 
end

function _M.hget(self,key,field)
	local red = redis:new()
        red:set_timeout(1000)
        local ok, err = red:connect(_ip,_port)
        if not ok then
                ngx.log(ngx.ERR,"failed to connect redis ")
        	return
        end
	local res, err = red:hget(key,field)
	if not res then
		ngx.log(ngx.ERR,"hget:",err)
		return
	end
	return res
end


return _M
