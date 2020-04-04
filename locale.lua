require 'utils'

local file = io.open('base.cfg')
local data = file:read('*all')
file:close()

local lines = data:split('\n')

local dict = {}

for _, line in ipairs(lines) do
	local result = line:split('=')
	if result[1] and result[2] then
		result[2] = string.gsub(result[2], '%(', '（')
		result[2] = string.gsub(result[2], '%)', '）')
		result[2] = string.gsub(result[2], ' ', '')
		result[2] = string.gsub(result[2], '-', '')
		dict[result[1]] = result[2]
	end
end

-- print(table.tostring(dict))

return function ( key )
	return dict[key] or 'nil'
end
