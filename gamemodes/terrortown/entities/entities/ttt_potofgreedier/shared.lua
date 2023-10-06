AddCSLuaFile()

ENT.Type = "anim"

ENT.NextUse = 0
ENT.Role = ROLE_NONE
local prompt

function ENT:Initialize()
	self:SetModel("models/prawnmodels/yugioh!md/mates/potofgreed.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_NONE)

	if SERVER then
		self:NextThink(CurTime() + 1.5)

	end
end

-- ENT.PropmtColor = Color( 10, 90,140,100)
-- ENT.TextColor = Color(255,255,255,255)

-- function ENT:Draw()
-- 	if IsValid(self) then
-- 		prompt = LANG.GetParamTranslation("ttt2_potofgreedier_prompt", {usekey = Key("+use", "USE")})
-- 		self:DrawModel()
-- 		local pos = self:GetPos() + Vector(0, 0, 30)
-- 		local ang = Angle(0, LocalPlayer():GetAngles().y - 90, 90)
-- 		surface.SetFont("ChatFont")
-- 		local width, height = surface.GetTextSize(prompt)

-- 		cam.Start3D2D(pos, ang, 0.3)
-- 			draw.RoundedBox( 5, -width / 2 , -5, width, height, self.PropmtColor)
-- 			draw.SimpleText(prompt, "ChatFont", 0, 5, self.TextColor, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)
-- 		cam.End3D2D()
-- 	end
-- end

--[[
---@TODO: break?
function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
	self:SetHealth(self:Health() - dmginfo:GetDamage())

	if self:Health() > 0 then return end

	self:Remove()

	local effect = EffectData()
	effect:SetOrigin(self:GetPos())

	util.Effect("cball_explode", effect)
	sound.Play(zapsound, self:GetPos())

	if IsValid(self:GetOwner()) then
		LANG.Msg(self:GetOwner(), "decoy_broken")
	end
end
]]

function ENT:Use(ply)
	if (self.NextUse < CurTime()) then
		if not IsFirstTimePredicted() then
			return
		end

		self.NextUse = CurTime() + 2

		local succ = PotOfGreedier.GatchaPull(ply, self)
		if succ then
			self:UseSuccess(ply)
			self:Remove()
		else
			self:UseFailure(ply)
		end
	end
end

function ENT:UseFailure(ply)
	LANG.Msg(ply, "ttt2_potofgreedier_error", nil, MSG_MSTACK_WARN)
	self:EmitSound("buttons/button9.wav", 75, 150)
end

function ENT:UseSuccess(ply)
	local effect = EffectData()
	local pos = self:GetPos()
	effect:SetOrigin(pos + Vector(0,0, 10))
	effect:SetStart(pos + Vector(0,0, 10))

	util.Effect("cball_explode", effect, true, true )

	-- sound.Play("ambient/levels/labs/electric_explosion3.wav", pos)
	if SERVER then
		PotOfGreedier.SpewShards(self)
		PotOfGreedier.PlaySound(self, "activate"  .. (self.Fluke and "_fluke" or ""))
	end
	-- sound.Play(string.format("ttt2_potofgreedier/activate/activate_%02d.wav", math.random(1,PotOfGreedier.ToVAR.pot_max_activate_sounds)), pos)
end

if CLIENT then
	local TryT = LANG.TryTranslation
	local ParT = LANG.GetParamTranslation

	hook.Add("TTTRenderEntityInfo", "HUDDrawTargetIDPotOfGreedier", function(tData)
		local client = LocalPlayer()
		local ent = tData:GetEntity()

		if not IsValid(client) or not client:IsTerror() or not client:Alive()
		or not IsValid(ent) or tData:GetEntityDistance() > 100 or ent:GetClass() ~= "ttt_potofgreedier" then
			return
		end

		-- enable targetID rendering
		tData:EnableText()
		tData:EnableOutline()
		tData:SetOutlineColor(client:GetRoleColor())

		tData:SetTitle(TryT("weapon_ttt_potofgreedier_name"))
		tData:SetSubtitle(ParT("weapon_ttt_potofgreedier_target_activate", {usekey = Key("+use", "USE")}))
		tData:SetKeyBinding("+use")
		tData:AddDescriptionLine(TryT("weapon_ttt_potofgreedier_desc"))
	end)
end