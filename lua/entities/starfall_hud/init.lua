AddCSLuaFile('cl_init.lua')
AddCSLuaFile('shared.lua')
include('shared.lua')

util.AddNetworkString( "starfall_hud_set_enabled" )

local vehiclelinks = setmetatable({}, {__mode="k"})

function ENT:Initialize ()
	self.BaseClass.Initialize( self )
	self:PhysicsInit( SOLID_VPHYSICS )
	self:SetMoveType( MOVETYPE_VPHYSICS )
	self:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE )
end

function ENT:SetHudEnabled( ply, mode )
	net.Start( "starfall_hud_set_enabled" )
		net.WriteEntity( self )
		net.WriteInt( mode, 8 )
	net.Send( ply )
	
	if mode == 1 then
		ply.sfhudenabled = true
	elseif mode == -1 then
		ply.sfhudenabled = not ply.sfhudenabled
	else
		ply.sfhudenabled = nil
	end
	if not ply.sfhudenabled then
		ply:SetViewEntity()
	end
end

function ENT:OnRemove()
	net.Start( "starfall_hud_set_enabled" )
		net.WriteEntity( self )
		net.WriteInt( 0, 8 )
	net.Broadcast()
end

function ENT:Use( ply )
	self:SetHudEnabled( ply, -1 )
end

function ENT:LinkEnt ( ent, ply )
	self.link = ent
	net.Start("starfall_processor_link")
		net.WriteEntity(self)
		net.WriteEntity(ent)
	if ply then net.Send(ply) else net.Broadcast() end
end

function ENT:LinkVehicle( ent )
	if ent then
		vehiclelinks[ent] = self
	else
		--Clear links
		for k,v in pairs( vehiclelinks ) do
			if self == v then
				vehiclelinks[k] = nil
			end
		end
	end
end

hook.Add("PlayerEnteredVehicle","Starfall_HUD_PlayerEnteredVehicle",function( ply, vehicle )
	for k,v in pairs( vehiclelinks ) do
		if vehicle == k and v:IsValid() then
			vehicle:CallOnRemove("remove_sf_hud"..v:EntIndex(), function()
				if not IsValid( v ) then return end
				v:SetHudEnabled( ply, 0 )
			end)
			v:SetHudEnabled( ply, 1 )
		end
	end
end)

hook.Add("PlayerLeaveVehicle","Starfall_HUD_PlayerLeaveVehicle",function( ply, vehicle )
	for k,v in pairs( vehiclelinks ) do
		if vehicle == k and v:IsValid() then
			v:SetHudEnabled( ply, 0 )
		end
	end
end)

function ENT:PreEntityCopy ()
	if self.EntityMods then self.EntityMods.SFLink = nil end
	local info = {}
	if IsValid(self.link) then
		info.link = self.link:EntIndex()
	end
	local linkedvehicles = {}
	for k, v in pairs( vehiclelinks ) do
		if v == self and k:IsValid() then
			linkedvehicles[#linkedvehicles + 1] = k:EntIndex()
		end
	end
	if #linkedvehicles > 0 then
		info.linkedvehicles = linkedvehicles
	end
	if info.link or info.linkedvehicles then
		duplicator.StoreEntityModifier( self, "SFLink", info )
	end
end

function ENT:PostEntityPaste ( ply, ent, CreatedEntities )
	if ent.EntityMods and ent.EntityMods.SFLink then
		local info = ent.EntityMods.SFLink
		if info.link then
			local e = CreatedEntities[ info.link ]
			if IsValid( e ) then
				self:LinkEnt( e )
			end
		end
		
		if info.linkedvehicles then
			for k, v in pairs(info.linkedvehicles) do
				local e = CreatedEntities[ v ]
				if IsValid( e ) then
					self:LinkVehicle( e )
				end
			end
		end
	end
end
