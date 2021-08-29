local modname = minetest.get_current_modname()
local S = minetest.get_translator(modname)
local mg_name = minetest.get_mapgen_setting("mg_name")
local superflat = mg_name == "flat" and minetest.get_mapgen_setting("mcl_superflat_classic") == "true"
local mountains = {
	"ExtremeHills", "ExtremeHills_beach", "ExtremeHills_ocean", "ExtremeHills_deep_ocean", "ExtremeHills_underground",
	"ExtremeHills+", "ExtremeHills+_ocean", "ExtremeHills+_deep_ocean", "ExtremeHills+_underground",
	"ExtremeHillsM", "ExtremeHillsM_ocean", "ExtremeHillsM_deep_ocean", "ExtremeHillsM_underground",
}
local layer_max = mcl_worlds.layer_to_y(16)
local layer_min = mcl_vars.mg_overworld_min

minetest.clear_registered_ores()

local function register_ore_variant(itemstring, desc, texture, overlay, drop, xp)
        minetest.register_node(modname .. ":" .. itemstring, {
                description = S(desc),
                tiles = { texture .. "^" .. overlay },
                is_ground_content = true,
                stack_max = 64,
                groups = { pickaxey = 1, building_block = 1, xp = xp, material_stone = 1 },
                drop = drop,
                sounds = mcl_sounds.node_sound_stone_defaults(),
                _mcl_blast_resistance = 6,
                _mcl_hardness = 1.5,
                _mcl_silk_touch_drop = true,
                _mcl_fortune_drop = mcl_core.fortune_drop_ore,
        })
end

local wherein = {
        { "Andesite", "mcl_core_andesite.png" },
        { "Diorite", "mcl_core_diorite.png" },
        { "Granite", "mcl_core_granite.png" },
        { "Tuff", "mcl_deepslate_tuff.png" },
}
local lapis = "mcl_dye:blue"
local redstone_drop = {
        items = {
                max_items = 1,
                { items = { "mesecons:redstone 4" }, rarity = 2 },
                { items = { "mesecons:redstone 5" } },
        },
}
local redstone_fortune = {
        discrete_uniform_distribution = true,
        items = { "mesecons:redstone" },
        min_count = 4,
        max_count = 5,
}
local redstone_timer = 68.28
local ores = {
        { "Iron", "mcl_raw_ores:raw_iron", 0 },
        { "Coal", "mcl_core:coal_lump", 1 },
        { "Lapis", {
                max_items = 1,
                items = {
                        { items = { lapis .. " 8" }, rarity = 5 },
                        { items = { lapis .. " 7" }, rarity = 5 },
                        { items = { lapis .. " 6" }, rarity = 5 },
                        { items = { lapis .. " 5" }, rarity = 5 },
                        { items = { lapis .. " 4" } },
                },
        }, 6 },
        { "Gold", "mcl_raw_ores:raw_gold", 0 },
        { "Emerald", "mcl_core:emerald", 6 },
        { "Redstone", redstone_drop, 7 },
        { "Redstone_lit", redstone_drop, 7 },
        { "Diamond", "mcl_core:diamond", 4 },
        { "Copper", "mcl_copper:raw_copper", 0 },

}

for _, w in pairs(wherein) do
        local item = w[1]:lower()
        local redstone = modname .. ":" .. item .. "_with_redstone"
        local function redstone_ore_activate(pos)
        	minetest.swap_node(pos, { name = redstone .. "_lit" })
        	local t = minetest.get_node_timer(pos)
        	t:start(redstone_timer)
        end
        local function redstone_ore_reactivate(pos)
        	local t = minetest.get_node_timer(pos)
        	t:start(redstone_timer)
        end
        for _, o in pairs(ores) do
                local desc, itemstring, overlay, texture = w[1] .. " " .. o[1] .. " Ore",
                item .. "_with_" .. o[1]:lower(),
                o[1]:lower() .. "_overlay.png",
                w[2] or "mcl_core_" .. item .. ".png"
                register_ore_variant(itemstring, desc, texture, overlay, o[2], o[3])
        end
        minetest.override_item(redstone, {
                _mcl_fortune_drop = redstone_fortune,
                sounds = mcl_sounds.node_sound_stone_defaults(),
	        on_punch = redstone_ore_activate,
	        on_walk_over = redstone_ore_activate,
        })
        minetest.override_item(redstone .. "_lit", {
                on_punch = redstone_ore_reactivate,
                on_walk_over = redstone_ore_reactivate,
                tiles = { w[2] .. "^" .. "redstone_overlay.png" },
                on_timer = function(pos, elapsed)
                        minetest.swap_node(pos, { name = redstone })
                end,
                light_source = 9,
                groups = { pickaxey = 1, not_in_creative_inventory = 1, material_stone = 1, xp = 7},
                _mcl_silk_touch_drop = { redstone },
                _mcl_fortune_drop = redstone_fortune,
        })
end

-- copy from mcl_mapgen_core

local specialstones = { "mcl_core:diorite", "mcl_core:andesite", "mcl_core:granite" }
for s=1, #specialstones do
	local node = specialstones[s]
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = { "mcl_core:stone" },
		clust_scarcity = 15*15*15,
		clust_num_ores = 33,
		clust_size     = 5,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_vars.mg_overworld_max,
		noise_params = {
			offset  = 0,
			scale   = 1,
			spread  = { x = 250, y = 250, z = 250 },
			seed    = 12345,
			octaves = 3,
			persist = 0.6,
			lacunarity = 2,
			flags = "defaults",
		}
	})
	minetest.register_ore({
		ore_type       = "blob",
		ore            = node,
		wherein        = { "mcl_core:stone" },
		clust_scarcity = 10*10*10,
		clust_num_ores = 58,
		clust_size     = 7,
		y_min          = mcl_vars.mg_overworld_min,
		y_max          = mcl_vars.mg_overworld_max,
		noise_params = {
			offset  = 0,
			scale   = 1,
			spread  = { x = 250 , y = 250, z = 250 },
			seed    = 12345,
			octaves = 3,
			persist = 0.6,
			lacunarity = 2,
			flags = "defaults",
		}
	})
end

minetest.register_ore({
	ore_type       = "blob",
	ore            = "mcl_core:dirt",
	wherein        = { "mcl_core:stone", "mcl_core:diorite", "mcl_core:andesite", "mcl_core:granite" },
	clust_scarcity = 15*15*15,
	clust_num_ores = 33,
	clust_size     = 4,
	y_min          = mcl_vars.mg_overworld_min,
	y_max          = mcl_vars.mg_overworld_max,
	noise_params = {
		offset  = 0,
		scale   = 1,
		spread  = { x = 250, y = 250, z = 250 },
		seed    = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

minetest.register_ore({
	ore_type       = "blob",
	ore            = "mcl_core:gravel",
	wherein        =  { "mcl_core:stone", "mcl_core:diorite", "mcl_core:andesite", "mcl_core:granite" },
	clust_scarcity = 14*14*14,
	clust_num_ores = 33,
	clust_size     = 5,
	y_min          = mcl_vars.mg_overworld_min,
	y_max          = mcl_worlds.layer_to_y(111),
	noise_params = {
		offset  = 0,
		scale   = 1,
		spread  = { x = 250, y = 250, z = 250 },
		seed    = 12345,
		octaves = 3,
		persist = 0.6,
		lacunarity = 2,
		flags = "defaults",
	}
})

-- copy from mcl_deepslate

minetest.register_ore({
        ore_type       = "blob",
        ore            = "mcl_deepslate:deepslate",
        wherein        = { "mcl_core:stone" },
        clust_scarcity = 200,
        clust_num_ores = 100,
        clust_size     = 10,
        y_min          = layer_min,
        y_max          = layer_max,
        noise_params = {
            offset  = 0,
            scale   = 1,
            spread  = { x = 250 , y = 250, z = 250 },
            seed    = 12345,
            octaves = 3,
            persist = 0.6,
            lacunarity = 2,
            flags = "defaults",
        }
})
    
minetest.register_ore({
        ore_type       = "blob",
        ore            = "mcl_deepslate:tuff",
        wherein        = { "mcl_core:stone", "mcl_core:diorite", "mcl_core:andesite", "mcl_core:granite", "mcl_deepslate:deepslate" },
        clust_scarcity = 10*10*10,
        clust_num_ores = 58,
        clust_size     = 7,
        y_min          = layer_min,
    	y_max          = layer_max,
        noise_params = {
                offset  = 0,
                scale   = 1,
                spread  = { x = 250, y = 250, z = 250 },
                seed    = 12345,
                octaves = 3,
                persist = 0.6,
                lacunarity = 2,
                flags = "defaults",
        }
})

local function register_ore(ore, wherein, scarcity, num, size, min, max)
	minetest.register_ore({
		ore_type       = "scatter",
		ore            = ore,
		wherein        = wherein,
		clust_scarcity = scarcity,
		clust_num_ores = num,
		clust_size     = size,
		y_min          = min,
		y_max          = max,
	})
end

if not superflat then
	local lava = "mcl_core:lava_source"
	local water = "mcl_core:water_source"
	local liquid_ores = {
		{ water, 9000, mcl_worlds.layer_to_y(5), mcl_worlds.layer_to_y(128) },
		{ lava, 2000, mcl_worlds.layer_to_y(1), mcl_worlds.layer_to_y(10) },
		{ lava, 9000, mcl_worlds.layer_to_y(11), mcl_worlds.layer_to_y(31) },
		{ lava, 32000, mcl_worlds.layer_to_y(32), mcl_worlds.layer_to_y(47) },
		{ lava, 72000, mcl_worlds.layer_to_y(48), mcl_worlds.layer_to_y(61) },
		{ lava, 96000, mcl_worlds.layer_to_y(62), mcl_worlds.layer_to_y(127) },
	}
	for _, l in pairs(liquid_ores) do
		register_ore(l[1], { "mcl_core:stone", "mcl_core:andesite", "mcl_core:diorite", "mcl_core:granite", "mcl_core:dirt" }, l[2], 1, 1, l[3], l[4])
	end
	register_ore(water, "mcl_deepslate:deepslate", 9000, 1, 1, mcl_worlds.layer_to_y(5), layer_max)
	register_ore(lava, "mcl_deepslate:deepslate", 2000, 1, 1, mcl_worlds.layer_to_y(1), mcl_worlds.layer_to_y(10))
	register_ore(lava, "mcl_deepslate:deepslate", 9000, 1, 1, mcl_worlds.layer_to_y(11), layer_max)
end

minetest.register_ore({
        ore_type       = "scatter",
        ore            = "mcl_deepslate:infested_deepslate",
        wherein        = "mcl_deepslate:deepslate",
        clust_scarcity = 26 * 26 * 26,
        clust_num_ores = 3,
        clust_size     = 2,
        y_min          = layer_min,
        y_max          = layer_max,
        biomes         = mountains,
})


if minetest.settings:get_bool("mcl_generate_ores", true) then
        local function register_ore_mg(ore, scarcity, num, size, y_min, y_max, biomes)
                biomes = biomes or ""
                minetest.register_ore({
                        ore_type       = "scatter",
                        ore            = ore,
                        wherein        = { "mcl_deepslate:deepslate" },
                        clust_scarcity = scarcity,
                        clust_num_ores = num,
                        clust_size     = size,
                        y_min          = y_min,
                        y_max          = y_max,
                        biomes	       = biomes,
                })
        end
        local ore_mapgen = {
                { "coal", 1575, 5, 3, layer_min, layer_max },
                { "coal", 1530, 8, 3, layer_min, layer_max },
                { "coal", 1500, 12, 3, layer_min, layer_max },
                { "iron", 830, 5, 3, layer_min, layer_max },
                { "gold", 4775, 5, 3, layer_min, layer_max },
                { "gold", 6560, 7, 3, layer_min, layer_max },
                { "diamond", 10000, 4, 3, layer_min, mcl_worlds.layer_to_y(12) },
                { "diamond", 5000, 2, 3, layer_min, mcl_worlds.layer_to_y(12) },
                { "diamond", 10000, 8, 3, layer_min, mcl_worlds.layer_to_y(12) },
                { "diamond", 20000, 1, 1, mcl_worlds.layer_to_y(13), mcl_worlds.layer_to_y(15) },
                { "diamond", 20000, 2, 2, mcl_worlds.layer_to_y(13), mcl_worlds.layer_to_y(15) },
                { "redstone", 500, 4, 3, layer_min, mcl_worlds.layer_to_y(13) },
                { "redstone", 800, 7, 4, layer_min, mcl_worlds.layer_to_y(13) },
                { "redstone", 1000, 4, 3, mcl_worlds.layer_to_y(13), mcl_worlds.layer_to_y(15) },
                { "redstone", 1600, 7, 4, mcl_worlds.layer_to_y(13), mcl_worlds.layer_to_y(15) },
                { "lapis", 10000, 7, 4, mcl_worlds.layer_to_y(14), layer_max },
                { "lapis", 12000, 6, 3, mcl_worlds.layer_to_y(10), mcl_worlds.layer_to_y(13) },
                { "lapis", 14000, 5, 3, mcl_worlds.layer_to_y(6), mcl_worlds.layer_to_y(9) },
                { "lapis", 16000, 4, 3, mcl_worlds.layer_to_y(2), mcl_worlds.layer_to_y(5) },
                { "lapis", 18000, 3, 2, mcl_worlds.layer_to_y(0), mcl_worlds.layer_to_y(2) },
        }
        for _, o in pairs(ore_mapgen) do
                register_ore_mg("mcl_deepslate:deepslate_with_"..o[1], o[2], o[3], o[4], o[5], o[6])
        end
        if minetest.get_mapgen_setting("mg_name") == "v6" then
                register_ore_mg("mcl_deepslate:deepslate_with_emerald", 14340, 1, 1, layer_min, layer_max)
        else
                register_ore_mg("mcl_deepslate:deepslate_with_emerald", 16384, 1, 1, mcl_worlds.layer_to_y(4), layer_max, mountains)
        end
        register_ore_mg("mcl_deepslate:deepslate_with_copper", 830, 5, 3, layer_min, layer_max)
            
end


local reg_ores = {
	["mcl_deepslate:tuff"] = {
		"mcl_more_ore_variants:tuff_with_copper",
		"mcl_more_ore_variants:tuff_with_diamond",
		"mcl_more_ore_variants:tuff_with_gold",
		"mcl_more_ore_variants:tuff_with_coal",
		"mcl_more_ore_variants:tuff_with_iron",
		"mcl_more_ore_variants:tuff_with_lapis",
		"mcl_more_ore_variants:tuff_with_redstone",
		"mcl_more_ore_variants:tuff_with_emerald",
	},
	["mcl_core:andesite"] = {
		"mcl_more_ore_variants:andesite_with_copper",
		"mcl_more_ore_variants:andesite_with_diamond",
		"mcl_more_ore_variants:andesite_with_gold",
		"mcl_more_ore_variants:andesite_with_coal",
		"mcl_more_ore_variants:andesite_with_iron",
		"mcl_more_ore_variants:andesite_with_lapis",
		"mcl_more_ore_variants:andesite_with_redstone",
		"mcl_more_ore_variants:andesite_with_emerald",
	},
	["mcl_core:diorite"] = {
		"mcl_more_ore_variants:diorite_with_copper",
		"mcl_more_ore_variants:diorite_with_diamond",
		"mcl_more_ore_variants:diorite_with_gold",
		"mcl_more_ore_variants:diorite_with_coal",
		"mcl_more_ore_variants:diorite_with_iron",
		"mcl_more_ore_variants:diorite_with_lapis",
		"mcl_more_ore_variants:diorite_with_redstone",
		"mcl_more_ore_variants:diorite_with_emerald",
	},
	["mcl_core:granite"] = {
		"mcl_more_ore_variants:granite_with_copper",
		"mcl_more_ore_variants:granite_with_diamond",
		"mcl_more_ore_variants:granite_with_gold",
		"mcl_more_ore_variants:granite_with_coal",
		"mcl_more_ore_variants:granite_with_iron",
		"mcl_more_ore_variants:granite_with_lapis",
		"mcl_more_ore_variants:granite_with_redstone",
		"mcl_more_ore_variants:granite_with_emerald",
	},
	["mcl_core:stone"] = {
		"mcl_copper:stone_with_copper",
		"mcl_core:stone_with_diamond",
		"mcl_core:stone_with_gold",
		"mcl_core:stone_with_coal",
		"mcl_core:stone_with_iron",
		"mcl_core:stone_with_lapis",
		"mcl_core:stone_with_redstone",
		"mcl_core:stone_with_emerald",
	},
}

if minetest.settings:get_bool("mcl_generate_ores", true) then
	for w, ores in pairs(reg_ores) do
		local stonelike = { w }
		local copper, diamond, gold, coal, iron, lapis, redstone, emerald = 
		ores[1], ores[2], ores[3], ores[4], ores[5],ores[6], ores[7], ores[8]

		local function override_ore(ore, scarcity, num, size, min, max)
			minetest.register_ore({
				ore_type       = "scatter",
				ore            = ore,
				wherein        = stonelike,
				clust_scarcity = scarcity,
				clust_num_ores = num,
				clust_size     = size,
				y_min          = min,
				y_max          = max,
			})
		end
		if mg_name == "v6" then
			override_ore(emerald, 14340, 1, 1, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(29))
			override_ore(emerald, 21510, 1, 1, mcl_worlds.layer_to_y(30), mcl_worlds.layer_to_y(32))
		end
		local overrides = {
			{ coal, 525 * 3, 5, 3, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(50) },
			{ coal, 510 * 3, 8, 3, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(50) },
			{ coal, 500 * 3, 12, 3, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(50) },
			{ coal, 550 * 3, 4, 2, mcl_worlds.layer_to_y(51), mcl_worlds.layer_to_y(80) },
			{ coal, 525 * 3, 6, 3, mcl_worlds.layer_to_y(51), mcl_worlds.layer_to_y(80) },
			{ coal, 500 * 3, 8, 3, mcl_worlds.layer_to_y(51), mcl_worlds.layer_to_y(80) },
			{ coal, 600 * 3, 3, 2, mcl_worlds.layer_to_y(81), mcl_worlds.layer_to_y(128) },
			{ coal, 550 * 3, 4, 3, mcl_worlds.layer_to_y(81), mcl_worlds.layer_to_y(128) },
			{ coal, 500 * 3, 5, 3, mcl_worlds.layer_to_y(81), mcl_worlds.layer_to_y(128) },
			{ iron, 830, 5, 3, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(39) },
			{ iron, 1660, 4, 2, mcl_worlds.layer_to_y(40), mcl_worlds.layer_to_y(63) },
			{ copper, 830, 5, 3, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(39) },
			{ copper, 1660, 4, 2, mcl_worlds.layer_to_y(40), mcl_worlds.layer_to_y(63) },
			{ gold, 4775, 5, 3, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(30) },
			{ gold, 6560, 7, 3, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(30) },
			{ gold, 13000, 4, 2, mcl_worlds.layer_to_y(31), mcl_worlds.layer_to_y(33) },
			{ diamond, 10000, 4, 3, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(12) },
			{ diamond, 5000, 2, 2, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(12) },
			{ diamond, 10000, 8, 3, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(12) },
			{ diamond, 20000, 1, 1, mcl_worlds.layer_to_y(13), mcl_worlds.layer_to_y(15) },
			{ diamond, 20000, 2, 2, mcl_worlds.layer_to_y(13), mcl_worlds.layer_to_y(15) },
			{ redstone, 500, 4, 3, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(13) },
			{ redstone, 800, 7, 4, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(13) },
			{ redstone, 1000, 4, 3, mcl_worlds.layer_to_y(13), mcl_worlds.layer_to_y(15) },
			{ redstone, 1600, 7, 4, mcl_worlds.layer_to_y(13), mcl_worlds.layer_to_y(15) },
			{ lapis, 10000, 7, 4, mcl_worlds.layer_to_y(14), mcl_worlds.layer_to_y(16) },
			{ lapis, 12000, 6, 3, mcl_worlds.layer_to_y(10), mcl_worlds.layer_to_y(13) },
			{ lapis, 14000, 5, 3, mcl_worlds.layer_to_y(6), mcl_worlds.layer_to_y(9) },
			{ lapis, 16000, 4, 3, mcl_worlds.layer_to_y(2), mcl_worlds.layer_to_y(5) },
			{ lapis, 18000, 3, 2, mcl_worlds.layer_to_y(0), mcl_worlds.layer_to_y(2) },
			{ lapis, 12000, 6, 3, mcl_worlds.layer_to_y(17), mcl_worlds.layer_to_y(20) },
			{ lapis, 14000, 5, 3, mcl_worlds.layer_to_y(21), mcl_worlds.layer_to_y(24) },
			{ lapis, 16000, 4, 3, mcl_worlds.layer_to_y(25), mcl_worlds.layer_to_y(28) },
			{ lapis, 18000, 3, 2, mcl_worlds.layer_to_y(29), mcl_worlds.layer_to_y(32) },
			{ lapis, 32000, 1, 1, mcl_worlds.layer_to_y(31), mcl_worlds.layer_to_y(32) },
			{ coal, 830, 5, 3, mcl_vars.mg_overworld_min, mcl_worlds.layer_to_y(39) },
			{ coal, 1660, 4, 2, mcl_worlds.layer_to_y(40), mcl_worlds.layer_to_y(63) },
		}
		for _, o in pairs(overrides) do
			override_ore(o[1], o[2], o[3], o[4], o[5], o[6])
		end
	end

end
