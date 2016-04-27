local limit_req=require "resty.limit.req"
local cjson=require "cjson"
local tostring=tostring
local limit_cache = require "limit_cache"


local _M = {}
_M._VERSION = '1.0'
local mt = { __index = _M }

-------------------------------------------------------------------
--api_id:    number or string
--limit_number:   number, must more then 0
--limit_content:  string, which to show on 'data' field when limited 
-------------------------------------------------------------------
function _M.fire(self,api_id,limit_number,limit_content)
	if not api_id then
              ngx.log(ngx.ERR,"api_id is nil")
	      return
	end
	local number=limit_number
	local content=limit_content 
	-- number is nil, fetch redis and store lrucache for 1 min
	if not number then
		number,content=limit_cache:get(api_id)	
              	--ngx.log(ngx.ERR,"number:"..tostring(number)..",type:"..type(number)..",content:"..tostring(content))
	end
	if not number or type(number)~="string" then
              	ngx.log(ngx.ERR,"value of number must not nil, now:"..tostring(number))
		return
	end
	if not tonumber(number) or tonumber(number)<=0 then
              	ngx.log(ngx.ERR,"value of number must more than zero,now:"..tostring(number))
		return
	end

	local lim, err = limit_req.new("limit_req_store", tonumber(number), tonumber(number))
        if not lim then
              ngx.log(ngx.ERR,"failed to instantiate a resty.limit.req object: ", err)
              return ngx.exit(500)
        end
        local key=tostring(api_id) 
        local delay, err = lim:incoming(key, true)
        if not delay then
        	if err == "rejected" then
			if not content and tostring(content)~="" then
				local result={}
				result['status']=200
				result['info']="limited"
				result['data']=content
				ngx.say(cjson.encode(result))
				return ngx.exit(200)
			else
				return ngx.exit(503)
			end
                end
                ngx.log(ngx.ERR, "failed to limit req: ", err)
                --return ngx.exit(500)
        end
        if delay > 0 then
        	ngx.sleep(delay)
        end

end


return _M
