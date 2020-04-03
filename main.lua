require 'utils'

_G.data = {}

local all_recipes = {}

function data:extend( p_recipe_list )
	all_recipes = table.union(all_recipes, p_recipe_list)
end

require 'recipe.ammo'
require 'recipe.capsule'
require 'recipe.demo-furnace-recipe'
require 'recipe.demo-recipe'
require 'recipe.demo-turret'
require 'recipe.equipment'
require 'recipe.fluid-recipe'
require 'recipe.inserter'
require 'recipe.module'
require 'recipe.recipe'
require 'recipe.turret'

local recipe_map = {}

local items = {}

for _, _recipe in ipairs(all_recipes) do
	local recipe = _recipe
	if _recipe.normal then
		recipe = _recipe.normal
	end

	if recipe.result then
		table.insert(items, recipe.result)
		recipe_map[recipe.result] = recipe
	elseif recipe.results then
		for _, v in ipairs(recipe.results) do
			table.insert(items, v.name or v[1])
			recipe_map[v.name or v[1]] = recipe
		end
	else
		assert(false, "xxx")
	end
end

-- print(table.tostring((table.filter(table.groupBy(items, function ( v )
-- 	return v
-- end), function ( v )
-- 	return #v > 1
-- end))))

items = table.unique(items)

local locale = require 'locale'

-- print(table.tostring(table.map(function ( v )
-- 	return locale(v) .. ' ' .. v
-- end, items)))

local final_items = {
	'copper-plate',
	'iron-plate',
	'stone-brick',
	'steel-plate',
	'petroleum-gas',
	'water',
	'coal',
	'stone-brick',
	'stone',
	'heavy-oil',
	'heavy-oil',
	'light-oil',
	'sulfuric-acid',

	-- 'advanced-circuit',
}

local products = {
	'iron-gear-wheel',
	'electronic-circuit',
	'automation-science-pack',
	'chemical-science-pack',
	'logistic-science-pack',
	'military-science-pack',
	'production-science-pack',
	'utility-science-pack',
}


local function resolve( ... )

	local resolved = {}

	local queue = table.simpleClone(products)

	while #queue > 0 do

		local top = queue[1]
		table.remove(queue, 1)

		if resolved[top] then

		elseif table.includes(final_items, top) then
			resolved[top] = true
		else
			resolved[top] = true
			local recipe = recipe_map[top]
			-- print('top', top)

			for _, v in ipairs(recipe.ingredients) do
				table.insert(queue, v.name or v[1])
			end
		end
	end

	
	local edges = {}
	for item, _ in pairs(resolved) do
		if not table.includes(final_items, item) then
			for _, v in ipairs((recipe_map[item] or {}).ingredients) do
				table.insert(edges, {v.name or v[1], item})
			end
		end
	end

	edges = table.map(function ( v )
		return string.format("%s -> %s", locale(v[1]), locale(v[2]))
	end, edges)

	edges = table.concat(edges, '\n')
	-- print('edges', edges)

	return 'digraph g {\n' .. edges .. '\n}\n'

end

print(resolve())

