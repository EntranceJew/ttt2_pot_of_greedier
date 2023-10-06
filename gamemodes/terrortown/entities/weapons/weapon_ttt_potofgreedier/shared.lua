---@diagnostic disable: duplicate-set-field
AddCSLuaFile()

SWEP.HoldType = "grenade"

if CLIENT then
	SWEP.PrintName = "weapon_ttt_potofgreedier_name"
	SWEP.Slot = 6

	SWEP.ViewModelFOV = 90
	SWEP.EquipMenuData = {
		type = "item_weapon",
		name = "weapon_ttt_potofgreedier_name",
		desc = "weapon_ttt_potofgreedier_desc"
   }
   SWEP.Icon = "vgui/ttt/icon_weapon_ttt_potofgreedier"
end

SWEP.Base = "weapon_tttbase"
SWEP.ViewModel = "models/weapons/v_crowbar.mdl"
SWEP.WorldModel = "models/prawnmodels/yugioh!md/mates/potofgreed.mdl"
SWEP.DrawCrosshair = false
SWEP.Primary.ClipSize = 1
SWEP.Primary.DefaultClip = 1
SWEP.Primary.Automatic = true
SWEP.Primary.Ammo = "9mmRound"
SWEP.Primary.Delay = 1.0
SWEP.Secondary.ClipSize = 1
SWEP.Secondary.DefaultClip = 1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 1.0

-- This is special equipment
SWEP.Kind = WEAPON_EXTRA
SWEP.CanBuy = {ROLE_TRAITOR, ROLE_DETECTIVE}
SWEP.LimitedStock = false
SWEP.WeaponID = AMMO_CUBE
SWEP.AllowDrop = true
SWEP.NoSights = true

if CLIENT then
	function SWEP:Initialize()
		self:AddTTT2HUDHelp("ttt2_potofgreedier_help_primary")
	end
end

function SWEP:PrimaryAttack()
	if not self:CanPrimaryAttack() then
		return
	end

---@diagnostic disable-next-line: undefined-field
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:CreatePot()
	self:TakePrimaryAmmo(1)

	if SERVER then
		self:Remove()
	end
end

-- function SWEP:DrawWorldModel()
--     return false
-- end

function SWEP:CreatePot()
	if SERVER then
		PotOfGreedier.SpawnPot( self:GetOwner() )
	end
end

function SWEP:SecondaryAttack()
	if not self:CanSecondaryAttack() then
		return
	end
	self:SetNextSecondaryFire( CurTime() + self.Secondary.Delay)
	if not IsFirstTimePredicted() then
		return
	end
end

function SWEP:OnRemove()
	local ply = self:GetOwner()
	if CLIENT and IsValid(ply) and ply == LocalPlayer() and ply:Alive() then
		RunConsoleCommand("lastinv")
	end
end


if CLIENT then
	---
	-- @ignore
	function SWEP:AddToSettingsMenu(parent)
		local forms = {
			-- general = vgui.CreateTTT2Form(parent, "header_equipment_additional")
		}

		for _, def in pairs(PotOfGreedier.ToCVAR.weapon) do
			if not forms[def.menu] then
				forms[def.menu] = vgui.CreateTTT2Form(parent, "ttt2_potofgreedier_heading_" .. def.menu)
			end
			local form = forms[def.menu]

			form:MakeHelp({
				label = "help_ttt2_sv_pog_weapon_" .. def.name,
			})
			form[def.typ](form, {
				serverConvar = "sv_pog_weapon_" .. def.name,
				label = "label_ttt2_sv_pog_weapon_" .. def.name,
				min = def.min or 0,
				max = def.max or 100,
				decimal = def.decimal or 0,
				default = def.default,
			})
		end
	end
end
