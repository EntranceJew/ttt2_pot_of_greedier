AddCSLuaFile()

ITEM.EquipMenuData = {
	type = "item_passive",
	name = "ttt2_item_ttt_potofgreedier",
	desc = "ttt2_item_ttt_potofgreedier_desc",
}

ITEM.material = "vgui/ttt/icon_item_ttt_potofgreedier"
ITEM.CanBuy = {ROLE_TRAITOR, ROLE_DETECTIVE}
ITEM.limited = false

if SERVER then
	function ITEM:Equip(buyer)
		-- print("artificial death", buyer)
		PotOfGreedier.GatchaPull(buyer, self)
		buyer:RemoveEquipmentItem("item_ttt_potofgreedier")
		-- or?
		-- buyer:StripWeapon(self:GetClass())
	end
else
	function ITEM:AddToSettingsMenu(parent)
		local form = vgui.CreateTTT2Form(parent, "header_equipment_additional")

		form:MakeHelp({
			label = "help_ttt2_item_ttt_potofgreedier"
		})
		form:MakeSlider({
			serverConvar = "ttt2_item_ttt_potofgreedier",
			label = "label_ttt2_item_ttt_potofgreedier",
			min = 0,
			max = 100,
			decimal = 0
		})
	end
end
