ENT.Type            = "anim"
ENT.Base            = "base_gmodentity"

ENT.PrintName       = "Starfall"
ENT.Author          = "Colonel Thirty Two"
ENT.Contact         = "initrd.gz@gmail.com"
ENT.Purpose         = ""
ENT.Instructions    = ""

ENT.Spawnable       = false
ENT.AdminSpawnable  = false

function ENT:runScriptHook ( hook, ... )
	if self.instance and not self.instance.error then
		local ok, rt, tb = self.instance:runScriptHook( hook, ... )
		if not ok then self:Error( rt, tb )
		else return rt end
	end
end

function ENT:runScriptHookForResult ( hook, ... )
	if self.instance and not self.instance.error then
		local ok, rt, tb = self.instance:runScriptHookForResult( hook, ... )
		if not ok then self:Error( rt, tb )
		else return rt end
	end
end

function ENT:Error ( msg, traceback )
	if type( msg ) == "table" then
		if msg.message then
			local line= msg.line
			local file = msg.file

			msg = ( file and ( file .. ":" ) or "" ) .. ( line and ( line .. ": " ) or "" ) .. msg.message
		end
	end
	msg = tostring( msg )

	if SERVER then
		self:UpdateState( "Inactive (Error)" )
		self:SetColor( Color( 255, 0, 0, 255 ) )
		self:SetDTString( 0, traceback or msg )
	end
	
	SF.AddNotify( self.owner, msg, NOTIFY_ERROR, 7, NOTIFYSOUND_ERROR1 )
	if self.instance then
		self.instance:deinitialize()
		self.instance = nil
	end

	if traceback then
		if SERVER then
			SF.Print( self.owner, traceback )
		else
			print( traceback )
		end
	end

	return msg
end

function ENT:OnRemove ()
	if not self.instance then return end

	self:runScriptHook( "Removed" )
	
	self.instance:deinitialize()
	self.instance = nil
end