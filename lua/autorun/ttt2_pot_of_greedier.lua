AddCSLuaFile()
PotOfGreedier = PotOfGreedier or {}
PotOfGreedier.Proto = PotOfGreedier.Proto or {}

--#region convars
local flags = {FCVAR_NOTIFY, FCVAR_ARCHIVE, FCVAR_REPLICATED}
local tovar = {
	debug = false,
	pot_mass = 200,
	pot_throw_velocity = 100,
	pot_init_pos = 32,
	-- pot_max_tries = 8,
	-- pot_conflict_policy = 2,
	pot_max_deploy_sounds = 26,
	pot_max_deploy_fluke_sounds = 6,
	pot_max_activate_sounds = 29,
	pot_max_activate_fluke_sounds = 3,

	shard_mass = 100,
	shard_throw_velocity = 400,
	shard_throw_lift_velocity = 400,
	shard_init_pos = 10,
	shard_spawn_range = 20,


	-- ttt2_pot_of_greedier_ignore_not_buyable,
	-- ttt2_pot_of_greedier_max_credits,
	-- ttt2_pot_of_greedier_items_to_give,
	-- ttt2_pot_of_greedier_conflict_policy,
}
local realvars = {
	weapon = {
		-- pot
		{
			name = "items_to_give",
			menu = "pot",
			default = 2,
			min = 0,
			max = 10,
			typ = "MakeSlider",
			label = "Items To Give",
			help = "How many items should be given to the user upon activation.",
		},
		-- {
		-- 	name = "credits_max_cost",
		-- 	menu = "pot",
		-- 	default = 2,
		-- 	min = 0,
		-- 	max = 10,
		-- 	typ = "MakeSlider",
		-- 	label = "Max Credits",
		-- 	help = "How expensive of an item should Pot of Greed create?",
		-- },
		{
			name = "credits_use_balance",
			menu = "pot",
			default = 0,
			min = 0,
			max = 1,
			typ = "MakeCheckBox",
			label = "Credits Use Balance",
			help = "Spend actual credits when the Pot of Greed makes purchases.",
		},
		{
			name = "allow_waste",
			menu = "pot",
			default = 0,
			min = 0,
			max = 1,
			typ = "MakeCheckBox",
			label = "Allow Waste",
			help = "Pot of Greed may attempt to deliver items that are already owned, or that there is no room in a player's inventory for.",
		},

		-- fluke
		{
			name = "fluke_bonus",
			menu = "fluke",
			default = 1,
			min = 0,
			max = 10,
			typ = "MakeSlider",
			label = "Fluke Bonus",
			help = "The number of additional items to reward if a 'fluke' occurs.",
		},
		{
			name = "fluke_chance",
			menu = "fluke",
			default = 3,
			min = 0,
			max = 100,
			typ = "MakeSlider",
			label = "Fluke Chance",
			help = "The likelyhood of a 'fluke' occuring, rewarding additional items.",
		},

		-- shard
		{
			name = "shard_global_distribute",
			menu = "shard",
			default = 1,
			min = 0,
			max = 1,
			typ = "MakeCheckBox",
			label = "Shards: Global Distribute",
			help = "If enabled, Shards of Greed will appear wherever an item spawn is, rather than emitting from Pot of Greed or killed players.",
		},
		{
			name = "shard_quantity",
			menu = "shard",
			default = 3,
			min = 0,
			max = 16,
			typ = "MakeSlider",
			label = "Shards: Quantity",
			help = "How many shards are spawned by activating a Pot of Greed.",
		},
		{
			name = "shard_collect_total",
			menu = "shard",
			default = 3,
			min = 0,
			max = 16,
			typ = "MakeSlider",
			label = "Shards: Collect Total",
			help = "How many shards you must collect to assemble a new Pot of Greed.",
		},
	},
	item = {

	}
}
PotOfGreedier.ToCVAR = realvars
PotOfGreedier.ToVAR = tovar
PotOfGreedier.CVARS = PotOfGreedier.CVARS or {}

PotOfGreedier.CreateConVars = function()
	for _, def in pairs(PotOfGreedier.ToCVAR.weapon) do
		PotOfGreedier.CVARS["weapon_" .. def.name] = CreateConVar(
			"sv_pog_weapon_" .. def.name,
			tostring(def.default),
			flags,
			def.label
		)
	end
end

PotOfGreedier.CreateLang = function()
	local x = [[
local L = LANG.GetLanguageTableReference("en")

L["ttt2_weapon_ttt_potofgreedier"] = "Pot of Greedier"
L["ttt2_weapon_ttt_potofgreedier_desc"] = "An item that deploys a Pot of Greed, which allows you to acquire items from the role that dropped it!"

L["ttt2_potofgreedier_heading_pot"] = "Pot Settings"
L["ttt2_potofgreedier_heading_fluke"] = "Fluke Settings"
L["ttt2_potofgreedier_heading_shard"] = "Shard Settings"

L["ttt2_potofgreedier_prompt"] = "Press {usekey} to receive your Item!"
L["ttt2_potofgreedier_error"] = "Sorry, please try again."

]]

	for cvar, def in pairs(realvars.weapon) do
		x = x .. [[L["label_ttt2_sv_pog_weapon_]] .. cvar .. [["] = "]] .. def.label .. "\"\n"
		x = x .. [[L["help_ttt2_sv_pog_weapon_]] .. cvar .. [["] = "]] .. def.help .. "\"\n"
	end
	print(x)
end

--	Conflict policy: determines what to do when an item received takes the same slot as an item is already in the inventory.
--	So far, the conflict policy for items of slot number >6 is 0 unless specified otherwise.
--	The ideal is to buy the pot of greed first if you want it, so you don't lose items!
--		0 - do nothing. The new item is lost.
--		1 - override the current item. The user may still lose items if several items taking the same slot are obtained.
--		2 - override the current item, and prevent next given items from overriding this new item.
--		3 - avoid needing to override the current item by preventing the pot from giving the same kind (not recommended).
-- 	Changing this ConVar might be a way to balance the item if it is judged too weak or too strong:
--	Using either 0 or 1 may result in players sometimes getting less items from the pot of greed;
--	however, this can result in a frustrating outcome for players and severly penalize them over "bad RNG".
--	On the other hand, using 3 enables users to manipulate what items they will not get.

--#endregion convars

if SERVER then --resource
	resource.AddFile("materials/vgui/ttt/icon_hud_effect_shardofgreedier.png")

	resource.AddFile("materials/vgui/ttt/icon_item_ttt_potofgreedier.vtf")
	resource.AddFile("materials/vgui/ttt/icon_item_ttt_potofgreedier.vmt")
	resource.AddFile("materials/vgui/ttt/icon_weapon_ttt_potofgreedier.vtf")
	resource.AddFile("materials/vgui/ttt/icon_weapon_ttt_potofgreedier.vmt")

	resource.AddFile("models/prawnmodels/yugioh!md/mates/potofgreed.dx80.vtx")
	resource.AddFile("models/prawnmodels/yugioh!md/mates/potofgreed.dx90.vtx")
	resource.AddFile("models/prawnmodels/yugioh!md/mates/potofgreed.mdl")
	resource.AddFile("models/prawnmodels/yugioh!md/mates/potofgreed.phy")
	resource.AddFile("models/prawnmodels/yugioh!md/mates/potofgreed.sw.vtx")
	resource.AddFile("models/prawnmodels/yugioh!md/mates/potofgreed.vvd")

	resource.AddFile("models/prawnmodels/yugioh!md/mates/shardofgreed.dx80.vtx")
	resource.AddFile("models/prawnmodels/yugioh!md/mates/shardofgreed.dx90.vtx")
	resource.AddFile("models/prawnmodels/yugioh!md/mates/shardofgreed.mdl")
	resource.AddFile("models/prawnmodels/yugioh!md/mates/shardofgreed.phy")
	resource.AddFile("models/prawnmodels/yugioh!md/mates/shardofgreed.sw.vtx")
	resource.AddFile("models/prawnmodels/yugioh!md/mates/shardofgreed.vvd")

	resource.AddFile("models/prawnmodels/yugioh!md/mates/shardofgreed/m09775_tex.vmf")
	resource.AddFile("models/prawnmodels/yugioh!md/mates/shardofgreed/m09775_tex.vtf")
	resource.AddFile("models/prawnmodels/yugioh!md/mates/shardofgreed/m09775_normal_tex.vtf")
	resource.AddFile("models/prawnmodels/yugioh!md/mates/shardofgreed/m09775_specular_tex.vtf")

	resource.AddFile("models/prawnmodels/yugioh!md/mates/potofgreed/m04844_02_normal_tex.vtf")
	resource.AddFile("models/prawnmodels/yugioh!md/mates/potofgreed/m04844_02_specular_tex.vtf")
	resource.AddFile("models/prawnmodels/yugioh!md/mates/potofgreed/m04844_02_tex.vmt")
	resource.AddFile("models/prawnmodels/yugioh!md/mates/potofgreed/m04844_02_tex.vtf")
	resource.AddFile("models/prawnmodels/yugioh!md/mates/potofgreed/m04844_normal_tex.vtf")
	resource.AddFile("models/prawnmodels/yugioh!md/mates/potofgreed/m04844_specular_tex.vtf")
	resource.AddFile("models/prawnmodels/yugioh!md/mates/potofgreed/m04844_tex.vmt")
	resource.AddFile("models/prawnmodels/yugioh!md/mates/potofgreed/m04844_tex.vtf")

	for i = 1, tovar.pot_max_deploy_sounds, 1 do
		resource.AddFile(string.format("sound/ttt2_potofgreedier/deploy/deploy_%02d.wav", i))
	end
	for i = 1, tovar.pot_max_deploy_fluke_sounds, 1 do
		resource.AddFile(string.format("sound/ttt2_potofgreedier/deploy_fluke/deploy_fluke_%02d.wav", i))
	end
	for i = 1, tovar.pot_max_activate_sounds, 1 do
		resource.AddFile(string.format("sound/ttt2_potofgreedier/activate/activate_%02d.wav", i))
	end
	for i = 1, tovar.pot_max_activate_fluke_sounds, 1 do
		resource.AddFile(string.format("sound/ttt2_potofgreedier/activate_fluke/activate_fluke_%02d.wav", i))
	end
end

---@class ModeData
---@field filter_inventory_kind_strict boolean
-- -@field filter_inventory_kind boolean
-- -@field filter_kinds_like number
---@field filter_credits boolean
---@field filter_owned boolean
---@field filter_buyable boolean
---@field filter_ids string[]
PotOfGreedier.Proto.ModeData = {
	filter_inventory_kind_strict = true,
	-- filter_inventory_kind = false,
	-- filter_kinds_like = -1,
	filter_credits = true,
	filter_owned = true,
	filter_buyable = true,
	filter_ids = {"weapon_ttt_potofgreedier"},
}

---@class BuyArgs
---@field ply Player
---@field fluke boolean
---@field role number|ROLE
---@field inventory Weapon[]
---@field credits_budget number
---@field is_purchase boolean
---@field modes ModeData
PotOfGreedier.Proto.BuyArgs = {
	ply = nil,
	fluke = false,
	-- role = ROLE_DETECTIVE,
	inventory = {},
	credits_budget = math.huge,
	is_purchase = false,
	modes = table.Copy(PotOfGreedier.Proto.ModeData),
}

hook.Add("Initialize", "PotOfGreedier_SharedInitialize", function()
	if not TTT2 then return end
	PotOfGreedier.CreateConVars()

	if SERVER then
		util.AddNetworkString("PotOfGreedier_ClientSpend")

		net.Receive("PotOfGreedier_ClientSpend", PotOfGreedier.SpendAvailableCredits)

		hook.Add("TTT2PostPlayerDeath", "PotOfGreedier_TTT2PostPlayerDeath", function(victim, inflictor, attacker)
			PotOfGreedier.SpewShards(victim)
		end)
	end

	if CLIENT then
		STATUS:RegisterStatus("ttt_shardofgreed", {
			hud = Material("vgui/ttt/icon_hud_effect_shardofgreedier.png"),
			type = "default",
			DrawInfo = function(slf)
				return string.format("%d/%d", LocalPlayer():GetNW2Var("ttt_shardofgreed_count", 0), PotOfGreedier.CVARS.weapon_shard_collect_total:GetInt())
			end
		})
	end
end)

---comment
---@param buyargs any
---@param equipmentTable any
---@param modes ModeData
---@return table
PotOfGreedier.FilterAllModes = function(buyargs, equipmentTable)
	local newEquipmentTable = {}
	for _, equipment in RandomPairs(equipmentTable) do
		local isItem =  items.IsItem(equipment)
		-- local hydrated = isItem and items.Get(equipment) or weapons.Get(equipment)
		local class = WEPS.GetClass(equipment)
		if buyargs.modes.filter_inventory_kind_strict and (not isItem and not InventorySlotFree(buyargs.ply, equipment.Kind)) then
			if tovar.debug then print("filtering out", class, equipment, "inventory kind limit") end
			continue
		end
		-- if modes.filter_kinds_like ~= nil and equipment.kind == modes.filter_kinds_like then
		-- 	continue
		-- end
		if buyargs.modes.filter_credits and (equipment.credits or 1) > buyargs.credits_budget then
			if tovar.debug then print("filtering out", class, equipment, "credit cost") end
			continue
		end
		if buyargs.modes.filter_owned and ((items.IsItem(class) and buyargs.ply:HasEquipmentItem(class)) or buyargs.ply:HasWeapon(class)) then
			if tovar.debug then print("filtering out", class, equipment, "owned") end
			continue
		end
		if buyargs.modes.filter_buyable then
			-- local eib = not EquipmentIsBuyable(equipment, buyargs.ply)
			local eib = false
			local coe = not hook.Run("TTTCanOrderEquipment", buyargs.ply, class, isItem)
			local coe2 = hook.Run("TTT2CanOrderEquipment", buyargs.ply, class, isItem, equipment.credits or 1) == false
			if tovar.debug then print("eib", eib, "coe", coe, "coe2", coe2) end
			if eib or coe or coe2 then
				if tovar.debug then print("filtering out", class, equipment, "not buyable") end
				continue
			end
		end
		if buyargs.modes.filter_ids and table.HasValue(buyargs.modes.filter_ids, class) then
			if tovar.debug then print("filtering out", class, equipment, "blacklisted item name") end
			continue
		end

		if tovar.debug then print("filter in", equipment.kind, class) end
		table.insert(newEquipmentTable, equipment)
	end
	-- if tovar.debug then PrintTable(newEquipmentTable) end
	return newEquipmentTable
end


---comment
---@param buyargs BuyArgs
---@return boolean
PotOfGreedier.PurchaseStrategy = function(buyargs)
	if not IsValid(buyargs.ply) then
		if tovar.debug then print("no purchase, invalid player", buyargs.ply) end
		return false
	end

	-- print("PotOfGreedier: PurchaseStrategy")
	-- PrintTable(buyargs)

	local equipmentTable
	-- if CLIENT then
		-- equipmentTable = GetEquipmentForRole(buyargs.ply, buyargs.role, false)
	-- else
	equipmentTable = PotOfGreedier.GetEquipmentServerSided(buyargs.ply, buyargs.role, false)
	if tovar.debug then print("equipment count pre-filter", #equipmentTable) end
	-- end
	equipmentTable = PotOfGreedier.FilterAllModes(buyargs, equipmentTable)
	if tovar.debug then print("equipment count post-filter", #equipmentTable) end

	local total = PotOfGreedier.CVARS.weapon_items_to_give:GetInt()
	if buyargs.fluke then
		total = total + PotOfGreedier.CVARS.weapon_fluke_bonus:GetInt()
	end
	for i = 1, total do
		if #equipmentTable ~= 0 then
			local itemIndex = math.random(1, #equipmentTable)
			local item = equipmentTable[itemIndex]
			local class = WEPS.GetClass(item)
			if tovar.debug then print("attempting to give", itemIndex, class, item.kind) end

			-- if tovar.pot_conflict_policy == 1 or tovar.pot_conflict_policy == 2 or tovar.pot_conflict_policy == 3 then
			-- 	StripOldWeapon(buyargs.ply, item.kind)
			-- end

			-- if tovar.pot_conflict_policy == 0 then --"do nothing" case...
			-- if tovar.pot_conflict_policy == 1 then --"override" case...
			-- if tovar.pot_conflict_policy == 2 then --"override" case w/ table update...
			-- if tovar.pot_conflict_policy == 3 then --"avoid override" case w/ skipping same-type...

			if buyargs.is_purchase then
				buyargs.ply:SubtractCredits(item.credits or 1)
				buyargs.ply:AddBought(class)
			end

			PotOfGreedier.GiveEquipment(buyargs.ply, class)
			table.remove(equipmentTable, itemIndex)
			equipmentTable = PotOfGreedier.FilterAllModes(buyargs, equipmentTable)
			buyargs = PotOfGreedier.GetBuyArgs(buyargs)
		else
			if tovar.debug then print("no purchase, equipment table blanked") end
			return false
		end
	end
	return true
end

PotOfGreedier.RandomAngle = function()
	local angle = math.random() * (math.pi * 2)
	return Vector(math.cos(angle), math.sin(angle))
end

PotOfGreedier.GetEquipmentServerSided = function(ply, subrole, noModification)
	local fallbackTable = GetShopFallbackTable(subrole)
	-- PrintTable(fallbackTable)

	if not noModification then
		fallbackTable = GetModifiedEquipment(ply, fallbackTable)
		-- PrintTable(fallbackTable)
	end

	if fallbackTable then
		return fallbackTable
	end

	local fallback = GetShopFallback(subrole)
	-- PrintTable(fallback)

	Equipment = Equipment or {}

	-- need to build equipment cache?
	if not Equipment[fallback] then
		local tbl = {}
		local v

		-- find buyable items to load info from
		local itms = items.GetList()

		for i = 1, #itms do
			v = itms[i]

			if v and not v.Doublicated and v.CanBuy and v.CanBuy[fallback] then
				local base = GetEquipmentBase(v)
				if base then
					tbl[#tbl + 1] = base
				end
			end
		end

		-- find buyable weapons to load info from
		local weps = weapons.GetList()

		for i = 1, #weps do
			v = weps[i]

			if v and not v.Doublicated and v.CanBuy and v.CanBuy[fallback] then
				local base = GetEquipmentBase(v)
				if base then
					tbl[#tbl + 1] = base
				end
			end
		end

		-- mark custom items
		for k = 1, #tbl do
			v = tbl[k]

			if not v or not v.id then continue end

			v.custom = not table.HasValue(DefaultEquipment[fallback], v.id)
		end

		Equipment[fallback] = tbl
	end

	return not noModification and GetModifiedEquipment(ply, Equipment[fallback]) or Equipment[fallback]
end

PotOfGreedier.GiveEquipmentWeaponCallback = function(ply, cls, wep)
	if isfunction(wep.WasBought) then
		wep:WasBought(ply)
	end
	ply:AddBought(WEPS.GetClass(wep))
end

---comment
---@param ply Player
---@param class string
PotOfGreedier.GiveEquipment = function(ply, class)
	if tovar.debug then print("pot of greedier:", ply, "got a", class) end
	local isItem = items.IsItem(class) -- and items.GetStored(class)
	if isItem then
		local item = ply:GiveEquipmentItem(class)
		if item then
			if isfunction(item.Bought) then
				item:Bought(ply)
			end
			ply:AddBought(class)
		end
	else
		ply:GiveEquipmentWeapon(class, PotOfGreedier.GiveEquipmentWeaponCallback)
	end
end

---comment
---@param plyOrBuyargs Player|BuyArgs
---@param ent? Entity
---@return BuyArgs
PotOfGreedier.GetBuyArgs = function(plyOrBuyargs, ent)
	---@as BuyArgs
	local buyargs
	if plyOrBuyargs.IsPlayer and plyOrBuyargs:IsPlayer() then
		buyargs = table.Copy(PotOfGreedier.Proto.BuyArgs) --[[@as BuyArgs]]
		buyargs.ply = plyOrBuyargs --[[@as Player]]
		if ent and ent.GetClass and ent:GetClass() == "ttt_potofgreedier" then
			buyargs.fluke = ent:GetFluke()
			buyargs.role = ent:GetRole()
		else
			-- print("some other entity was here?", ent)
			buyargs.role = buyargs.ply:GetSubRole()
		end
	else
		buyargs = plyOrBuyargs --[[@as BuyArgs]]
	end

	if PotOfGreedier.CVARS.weapon_allow_waste:GetBool() then
		buyargs.modes.filter_inventory_kind_strict = false
	end

	if PotOfGreedier.CVARS.weapon_credits_use_balance:GetBool() then
		buyargs.is_purchase = true
	end

	if buyargs.is_purchase then
		buyargs.credits_budget = buyargs.ply:GetCredits()
	end

	-- both case:
	buyargs.inventory = buyargs.ply:GetWeapons()

	return buyargs --[[@as BuyArgs]]
end

---comment
---@param ply Player
---@param ent Entity
---@return boolean|nil
PotOfGreedier.GatchaPull = function(ply, ent)
	-- old style
	-- return PotOfGreedier.PickAndGiveRandomEquipFromTable(swep, ply)

	local buyargs = PotOfGreedier.GetBuyArgs(ply, ent)
	-- PrintTable(buyargs)
	return PotOfGreedier.PurchaseStrategy(buyargs)
end

PotOfGreedier.SpendAvailableCredits = function(len, ply)
	if ply:IsShopper() and ply:GetCredits() > 0 then
		local buyargs = table.Copy(PotOfGreedier.Proto.BuyArgs)
		buyargs.ply = ply
		buyargs.role = ply:GetSubRole()
		buyargs.is_purchase = true
		buyargs.credits_budget = buyargs.ply:GetCredits()
		buyargs = PotOfGreedier.GetBuyArgs(buyargs)
		-- print("SpendClientCredits")
		-- PrintTable(buyargs)
		return PotOfGreedier.PurchaseStrategy(buyargs)
	end
end

if CLIENT then
	concommand.Add('cl_pog_spend_credits', function(ply)
		net.Start("PotOfGreedier_ClientSpend")
		net.SendToServer()
	end)
end

PotOfGreedier.RollFlukeChance = function()
	local chance = GetConVar("sv_pog_weapon_fluke_chance"):GetInt()
	return chance ~= 0 and chance > math.random(0, 100)
end

---comment
---@param ply Player
PotOfGreedier.SpawnPot = function(ply)
	local pot = ents.Create("ttt_potofgreedier")
	if ply:IsShopper() then
		pot:SetRole( ply:GetSubRole() )
	else
		pot:SetRole( ROLE_DETECTIVE )
	end

	if IsValid(pot) and IsValid(ply) then
		local vsrc = ply:GetShootPos()
		local vang = ply:GetAimVector()
		local vvel = ply:GetVelocity()
		local vthrow = vvel + vang * tovar.pot_throw_velocity
		pot:SetPos(vsrc + vang * tovar.pot_init_pos)
		pot:Spawn()

		local phys = pot:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(vthrow)
			phys:SetMass(tovar.pot_mass)
		end

		pot:SetFluke( PotOfGreedier.RollFlukeChance() )
		PotOfGreedier.PlaySound(ply, "deploy" .. (pot:GetFluke() and "_fluke" or ""))
	end
end

PotOfGreedier.PlaySound = function(ent, sound_name)
	local snd = math.random(1,PotOfGreedier.ToVAR["pot_max_" .. sound_name .. "_sounds"])
	local file_name = string.format("ttt2_potofgreedier/" .. sound_name .. "/" .. sound_name .. "_%02d.wav", snd)
	ent:EmitSound(file_name)
end

--#region Shards
---comment
---@param ply Player
PotOfGreedier.SpawnShard = function(pot)
	local shard = ents.Create("ttt_shard_of_greed")
	shard.Role = pot and pot.Role

	if IsValid(shard) then
		local vsrc = pot:GetPos() + (PotOfGreedier.RandomAngle() * tovar.shard_spawn_range)
		local vang = PotOfGreedier.RandomAngle()
		local vvel = pot:GetVelocity()
		local vlift = Vector(1, 1, tovar.shard_throw_lift_velocity)
		local vthrow = vvel + ( vang * tovar.shard_throw_velocity ) + vlift
		shard:SetPos(vsrc + vang * tovar.shard_init_pos)
		shard:Spawn()

		local phys = shard:GetPhysicsObject()
		if IsValid(phys) then
			phys:SetVelocity(vthrow)
			phys:SetMass(tovar.shard_mass)
		end
	end
end

PotOfGreedier.CollectShard = function(ply, ent)
	local new_val = ply:GetNW2Var("ttt_shardofgreed_count", 0)
	if new_val == 0 then
		STATUS:AddStatus(ply, "ttt_shardofgreed")
	end
	new_val = new_val + 1
	local total = PotOfGreedier.CVARS.weapon_shard_collect_total:GetInt()
	if new_val >= total then
		new_val = new_val - total

		local effect = EffectData()
		local pos = ply:GetPos()
		effect:SetOrigin(pos + Vector(0,0, 10))
		effect:SetStart(pos + Vector(0,0, 10))

		util.Effect("cball_explode", effect, true, true )
		sound.Play("ambient/levels/labs/electric_explosion3.wav", pos)

		ply:GiveEquipmentWeapon("weapon_ttt_potofgreedier")
	end
	ply:SetNW2Var("ttt_shardofgreed_count", new_val)
	if new_val == 0 then
		STATUS:RemoveStatus(ply, "ttt_shardofgreed")
	end
end

PotOfGreedier.SpewShards = function(ent)
	local quantity = PotOfGreedier.CVARS.weapon_shard_quantity:GetInt()
	local is_global = PotOfGreedier.CVARS.weapon_shard_global_distribute:GetBool()

	if ent:IsPlayer() then
		quantity = ent:GetNW2Var("ttt_shardofgreed_count", 0)
		ent:SetNW2Var("ttt_shardofgreed_count", 0)
		is_global = false
	end
	if is_global then
		PotOfGreedier.DistributeShards(quantity)
	else
		for i = 1, quantity do
			PotOfGreedier.SpawnShard( ent )
		end
	end
end

PotOfGreedier.DistributeShards = function(quantity)
	-- limit by defined max and found items
	local spawns = ents.FindByClass("item_*")
	local total_spawns = #spawns
	local amount = math.min(total_spawns, quantity)

	-- make sure more than 0 shards can be spawned
	if amount == 0 or amount < quantity then return false end

	for i = 1, quantity do
		local index = math.random(#spawns)
		local spwn = spawns[index]

		--print("spice girls", spwn, quantity, index)
		PotOfGreedier.SpawnShard(spwn)
		table.remove(spawns, index)
	end
end
--#endregion Shards