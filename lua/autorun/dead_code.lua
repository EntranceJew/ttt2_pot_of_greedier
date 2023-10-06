POG = POG or {}


---comment
---@param buyargs BuyArgs
---@return table
POG.GenerateEquipTable = function(buyargs)
	local equips = {}
	local out = table.Add(weapons.GetList(), items.GetList())
	for _, v in RandomPairs(out) do
		-- if table.HasValue(v.CanBuy, buyargs.role) then
		table.insert(equips, WEPS.GetClass(v))
		-- end
	end

	return equips
end

---comment
---@param ply Player
---@param ent Entity
---@return boolean
POG.PickAndGiveRandomEquipFromTable = function(ply, ent)
	local try = 0
	local buyargs = POG.GetBuyArgs(ply, ent)
	-- buyargs.role = ent.Role or buyargs.role
	-- buyargs.fluke = ent.Fluke or false
	local class
	local isItem
	local items_picked = {}
	while try < tovar.pot_max_tries do
		try = try + 1
		local equips = POG.GenerateEquipTable(buyargs)
		if #equips > 0 then
			class = equips[math.random(1, #equips)]
		end

		if not class then continue end
		isItem = items.IsItem(class)
		local equip = isItem and items.GetStored(class) or weapons.GetStored(class)
		if not equip then continue end

		if isItem and ply:HasBought(class) or not isItem and not ply:CanCarryWeapon(equip) then
			continue
		else
			table.insert(items_picked, class)
		end
	end
	if try >= tovar.pot_max_tries then
		return false
	end

	for _, item_picked in ipairs(items_picked) do
		POG.GiveEquipment(ply, item_picked)
	end

	return true
end

---comment
---@param buyer Player
---@return boolean
POG.PurchaseStrategy = function(buyer)
	if not IsValid(buyer) then return false end
	local buyargs = POG.GetBuyArgs(buyer, nil)
	local equipmentTable = POG.GenerateEquipTable(buyargs)
	equipmentTable = POG.FilterAllModes(buyargs, equipmentTable)

	for i = 1, GetConVar("sv_pog_weapon_") do
		if #equipmentTable ~= 0 then
			local itemIndex = math.random(1, #equipmentTable)
			local item = equipmentTable[itemIndex]

			if tovar.pot_conflict_policy == 1 or tovar.pot_conflict_policy == 2 or tovar.pot_conflict_policy == 3 then
				--StripOldWeapons
				for _, inventoryItem in pairs(buyargs.inventory) do
					if inventoryItem.kind == item.kind then
						buyer:StripWeapon(inventoryItem:GetClass())
					end
				end
			end

			-- if tovar.pot_conflict_policy == 0 then --"do nothing" case...
			-- if tovar.pot_conflict_policy == 1 then --"override" case...
			-- if tovar.pot_conflict_policy == 2 then --"override" case w/ table update...
			-- if tovar.pot_conflict_policy == 3 then --"avoid override" case w/ skipping same-type...

			POG.GiveEquipment(buyer, item)
			table.remove(equipmentTable, itemIndex)

			-- if (tovar.pot_conflict_policy == 2 or tovar.pot_conflict_policy == 3) and item.kind < 7 then
			-- 	equipmentTable = POG.FilterAllModes(buyargs, equipmentTable, {
			-- 		filter_kinds_like = item.kind,
			-- 	})
			-- end
		else
			return false
		end
	end
	return true
end