
http{
	...
	lua_shared_dict limit_req_store 10m;
	...

}

local limit= require "limit"
limit:fire(api_version["id"],api_version["limit_number"],tostring(api_version["limit_content"]))
