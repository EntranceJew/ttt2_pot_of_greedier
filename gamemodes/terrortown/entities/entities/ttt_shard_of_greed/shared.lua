AddCSLuaFile()
if SERVER then
	-- resource.AddWorkshop("1577101565")
	-- resource.AddFile("materials/vgui/ttt/icon_suitcase.vmt")
end

ENT.Type = "anim"

ENT.Solidified = false
ENT.SpawnTime = 0
ENT.NextUse = 0
ENT.Role = ROLE_NONE
function ENT:Initialize()
	self:SetModel("models/prawnmodels/yugioh!md/mates/shardofgreed.mdl")
	self:SetMoveType(MOVETYPE_VPHYSICS)
	self:PhysicsInit(SOLID_VPHYSICS)
	self:SetSolid(SOLID_BBOX)
	self:SetCollisionGroup(COLLISION_GROUP_DEBRIS)

	if SERVER then
		self:NextThink(CurTime() + 1.5)
		self.NextUse = CurTime() + 2
		self.SpawnTime = CurTime() + 2

		self.Trail = util.SpriteTrail( self, 0, Color( 240, 189, 248 ), false, 15, 1, 4, 1 / ( 15 + 1 ) * 0.5, "trails/plasma" )
	end
end

function ENT:Think()
	if (not self.Solidified and CurTime() > self.SpawnTime) then
		self:SetCollisionGroup(COLLISION_GROUP_NONE)
		self.Solidified = true
	end
end


function ENT:Use(ply)
	if (self.NextUse < CurTime()) then
		if not IsFirstTimePredicted() then
			return
		end

		self.NextUse = CurTime() + 2

		if SERVER then
			PotOfGreedier.CollectShard(ply, self)
		end

		self:Remove()
	end
end


if CLIENT then
	local TryT = LANG.TryTranslation
	local ParT = LANG.GetParamTranslation

	hook.Add("TTTRenderEntityInfo", "HUDDrawTargetIDShardOfGreed", function(tData)
		local client = LocalPlayer()
		local ent = tData:GetEntity()

		if not IsValid(client) or not client:IsTerror() or not client:Alive()
		or not IsValid(ent) or tData:GetEntityDistance() > 100 or ent:GetClass() ~= "ttt_shard_of_greed" then
			return
		end

		-- enable targetID rendering
		tData:EnableText()
		tData:EnableOutline()
		tData:SetOutlineColor(client:GetRoleColor())

		tData:SetTitle(TryT("ent_shardofgreedier_name"))
		tData:SetSubtitle(ParT("ent_shardofgreedier_target_activate", {usekey = Key("+use", "USE")}))
		tData:SetKeyBinding("+use")

		local total = PotOfGreedier.CVARS.weapon_shard_collect_total:GetInt()
		local has = client:GetNW2Var("ttt_shardofgreed_count", 0)
		if has > total or total == 0 then
			tData:AddDescriptionLine(TryT("ent_shardofgreedier_desc_noreason"))
		else
			tData:AddDescriptionLine(ParT("ent_shardofgreedier_desc_reassemble", {shards = total - has }))
		end
	end)
end