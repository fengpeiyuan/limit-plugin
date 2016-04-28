local tostring=tostring
local limit_rpc=require "limit_rpc"
local lrucache=require "resty.lrucache"

local _M = {}
_M._VERSION = '1.0'
local mt = { __index = _M }

local lru=lrucache.new(2000)
if not lru then
    return error("failed to create the cache: " .. (err or "unknown"))
end


function _M.get(self,key)
	local number_content=lru:get(tostring(key))
	local number
	local content 
	if not number_content then
		number=limit_rpc:hget("limit",tostring(key))
		content=limit_rpc:hget("limit",tostring(key).."_content")
		ngx.log(ngx.ERR,"fetch from redis::number:"..tostring(number)..",type:"..type(number)..",content:"..tostring(content)..",type:"..type(content))
		if type(number)~="string" or type(content)~="string" then
			ngx.log(ngx.ERR,"Get number and content from redis return nil")
			lru:set(tostring(key),"nil:nil",10)
			return nil,nil
		end
		local value=number..":"..content
		lru:set(tostring(key),value, 10)
	else
		local from, to, err = ngx.re.find(number_content, ":", "jo")	
		number=string.sub(number_content,1,from-1)
		content=string.sub(number_content,from+1,string.len(number_content))
		if "nil"==tostring(number) and "nil"==tostring(content) then
			return nil,nil
		end
		--ngx.log(ngx.ERR,"fetch from lrucache:number:"..tostring(number)..",type:"..type(number)..",content:"..tostring(content)..",type:"..type(content))
	end
	
    	return number,content 
end

return _M
