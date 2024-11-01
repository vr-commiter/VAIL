local truegear = require "truegear"
local math = require("math")

local Pistol = {	
	"G17",
	"PL14",
	"MK23",
	"NXSHammer"	
}
local Rifle = {
	"MK418",
	"APC9Pro",
	"AK303N",
	"Vityaz",
	"UMP45",
	"GrotB",
	"Vector45",
	"AK12",
	"SCARH",
	"PM9",
}
local Shotgun = {
	"MR96",
	"M2Rifled",
	"G28Z",
	"STF12",
	"DEagle"
}

local isFirst = true
local hookIds = {}
local resetHook = true
local holsterType = ""
local isLeftHandItem = false
local isTwoHandGun = false
local leftHandItem = ""
local rightHandItem = ""
local canOutputAmmo = false
local canOutputItem = false

function SendMessage(context)
	if isDeath == true then
		return
	end
	if context then
		print(context .. "\n")
		return
	end
	print("nil\n")
end

-- 计算两个向量的点�?
function dotProduct(v1, v2)
    return v1.x * v2.x + v1.y * v2.y
end

-- 计算向量的模
function vectorMagnitude(v)
    return math.sqrt(v.x * v.x + v.y * v.y)
end

-- 计算向量之间的夹角（弧度�?
function angleBetweenVectors(v1, v2)
    local dot = dotProduct(v1, v2)
    local magV1 = vectorMagnitude(v1)
    local magV2 = vectorMagnitude(v2)

    -- 夹角的余弦�?
    local cosAngle = dot / (magV1 * magV2)

    -- 弧度转换为角�?
    local angleRad = math.acos(cosAngle)
    local angleDeg = math.deg(angleRad)

    return angleDeg
end

-- 计算两个向量的夹角，并以逆时�?60度输�?
function angleBetweenVectors360(v1, v2)
    local angle = angleBetweenVectors(v1, v2)

    -- 判断叉积的方向（顺时针或逆时针）
    local crossProduct = v1.x * v2.y - v1.y * v2.x
    if crossProduct < 0 then
        angle = 360 - angle
    end
    return angle
end


function vectorLength(v)
    return math.sqrt(v.x * v.x + v.y * v.y + v.z * v.z)
end

function PlayAngle(event,tmpAngle,tmpVertical)

	local rootObject = truegear.find_effect(event);

	local angle = (tmpAngle - 22.5 > 0) and (tmpAngle - 22.5) or (360 - tmpAngle)
	
    local horCount = math.floor(angle / 45) + 1
	local verCount = (tmpVertical > 0.1) and -4 or (tmpVertical < 0 and 8 or 0)


	for kk, track in pairs(rootObject.tracks) do
        if tostring(track.action_type) == "Shake" then
            for i = 1, #track.index do
                if verCount ~= 0 then
                    track.index[i] = track.index[i] + verCount
                end
                if horCount < 8 then
                    if track.index[i] < 50 then
                        local remainder = track.index[i] % 4
                        if horCount <= remainder then
                            track.index[i] = track.index[i] - horCount
                        elseif horCount <= (remainder + 4) then
                            local num1 = horCount - remainder
                            track.index[i] = track.index[i] - remainder + 99 + num1
                        else
                            track.index[i] = track.index[i] + 2
                        end
                    else
                        local remainder = 3 - (track.index[i] % 4)
                        if horCount <= remainder then
                            track.index[i] = track.index[i] + horCount
                        elseif horCount <= (remainder + 4) then
                            local num1 = horCount - remainder
                            track.index[i] = track.index[i] + remainder - 99 - num1
                        else
                            track.index[i] = track.index[i] - 2
                        end
                    end
                end
            end
            if track.index then
                local filteredIndex = {}
                for _, v in pairs(track.index) do
                    if not (v < 0 or (v > 19 and v < 100) or v > 119) then
                        table.insert(filteredIndex, v)
                    end
                end
                track.index = filteredIndex
            end
        elseif tostring(track.action_type) ==  "Electrical" then
            for i = 1, #track.index do
                if horCount <= 4 then
                    track.index[i] = 0
                else
                    track.index[i] = 100
                end
            end
            if horCount == 1 or horCount == 8 or horCount == 4 or horCount == 5 then
                track.index = {0, 100}
            end
        end
    end

	truegear.play_effect_by_content(rootObject)
end



function RegisterHooks()

	if isFirst == true then
		isFirst = false
		local file = io.open("TrueGear.log", "w")
		if file then
			file:close()
		else
			print("无法打开文件")
		end
		
	end

	for k,v in pairs(hookIds) do
		UnregisterHook(k, v.id1, v.id2)
	end
		
	hookIds = {}

	local funcName = "/Script/VAIL.CFirearm:FireShot"
	local hook1, hook2 = RegisterHook(funcName, FireShot)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	-- local funcName = "/Script/VAIL.CFirearm:EjectMag"
	-- local hook1, hook2 = RegisterHook(funcName, EjectMag)
	-- hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	-- local funcName = "/Script/VAIL.CFirearm:OnMagWellBeginOverlap"
	-- local hook1, hook2 = RegisterHook(funcName, OnMagWellBeginOverlap)
	-- hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	-- local funcName = "/Script/VAIL.CFirearm:SetChamberState"
	-- local hook1, hook2 = RegisterHook(funcName, SetChamberState)
	-- hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/VAIL.CVRCharacter:OnDropLeft"
	local hook1, hook2 = RegisterHook(funcName, OnDropLeft)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/VAIL.CVRCharacter:OnDropRight"
	local hook1, hook2 = RegisterHook(funcName, OnDropRight)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/VAIL.CVRCharacter:OnGripLeft"
	local hook1, hook2 = RegisterHook(funcName, OnGripLeft)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/VAIL.CVRCharacter:OnGripRight"
	local hook1, hook2 = RegisterHook(funcName, OnGripRight)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/Shifted/Core/Player/BP_VRCharacter.BP_VRCharacter_C:OnDeath"
	local hook1, hook2 = RegisterHook(funcName, OnDeath)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/Shifted/Core/Player/BP_VRCharacter.BP_VRCharacter_C:ReceiveOnSpawn"
	local hook1, hook2 = RegisterHook(funcName, ReceiveOnSpawn)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/VAIL.CVRGripInterface:OnHolster"
	local hook1, hook2 = RegisterHook(funcName, OnHolster)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/VAIL.CVRGripInterface:OnUnholster"
	local hook1, hook2 = RegisterHook(funcName, OnUnholster)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }	

	local funcName = "/Script/VAIL.CVRCharacter:ClientNotifyHit"
	local hook1, hook2 = RegisterHook(funcName, ClientNotifyHit)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }		

	local funcName = "/Script/VAIL.CMeleeWeapon:OnHit"
	local hook1, hook2 = RegisterHook(funcName, MeleeHit)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }	
	

	local funcName = "/Script/VAIL.CVRCharacter:OnSecondaryGripRight"
	local hook1, hook2 = RegisterHook(funcName, OnSecondaryGripRight)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }				

	local funcName = "/Script/VAIL.CVRCharacter:OnSecondaryGripLeft"
	local hook1, hook2 = RegisterHook(funcName, OnSecondaryGripLeft)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }				

	local funcName = "/Script/VAIL.CVRCharacter:OnSecondaryDropRight"
	local hook1, hook2 = RegisterHook(funcName, OnSecondaryDropRight)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }				

	local funcName = "/Script/VAIL.CVRCharacter:OnSecondaryDropLeft"
	local hook1, hook2 = RegisterHook(funcName, OnSecondaryDropLeft)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }				

	local funcName = "/Script/VAIL.CImpactFrag:ServerActivate"
	local hook1, hook2 = RegisterHook(funcName, ServerActivate)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }					

	local funcName = "/Script/VAIL.CAmmoPouch:LeftHandGripped"
	local hook1, hook2 = RegisterHook(funcName, LeftHandGripped)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }				

	local funcName = "/Script/VAIL.CAmmoPouch:RightHandGripped"
	local hook1, hook2 = RegisterHook(funcName, RightHandGripped)	
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Script/VAIL.CAmmoPouch:ClientNotifyLoadingResult"
	local hook1, hook2 = RegisterHook(funcName, ClientNotifyLoadingResult)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

	local funcName = "/Game/VAIL/Devices/Frag/BP_Frag.BP_Frag_C:OnActivation"
	local hook1, hook2 = RegisterHook(funcName, OnActivation)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }
	
	local funcName = "/Script/VAIL.CRevolver:Server_OnFire"
	local hook1, hook2 = RegisterHook(funcName, Server_OnFire)
	hookIds[funcName] = { id1 = hook1; id2 = hook2 }

end

-- *******************************************************************

function Server_OnFire(self)
	if isTwoHandGun then
		SendMessage("--------------------------------")
		SendMessage("LeftHandPistolShoot")
		SendMessage("RightHandPistolShoot")
		truegear.play_effect_by_uuid("LeftHandPistolShoot")
		truegear.play_effect_by_uuid("RightHandPistolShoot")
	elseif self:get():GetFullName() == leftHandItem then
		SendMessage("--------------------------------")
		SendMessage("LeftHandPistolShoot")
		truegear.play_effect_by_uuid("LeftHandPistolShoot")
	else
		SendMessage("--------------------------------")
		SendMessage("RightHandPistolShoot")
		truegear.play_effect_by_uuid("RightHandPistolShoot")
	end
	SendMessage(self:get():GetFullName())

end


function ClientNotifyLoadingResult(self,TargetToLoad,LoadingResult)
	if LoadingResult:get() == 3 then
		SendMessage("--------------------------------")
	SendMessage("LeftHipSlotInputItem")
	truegear.play_effect_by_uuid("LeftHipSlotInputItem")
	end
	SendMessage(tostring(LoadingResult:get()))

end

function LeftHandGripped(self)
	local isLocalPlayer = self:get():GetPropertyValue("Owner"):IsLocalPlayer()
	if isLocalPlayer == false then
		return
	end
	if canOutputAmmo == false then
		return
	end
	canOutputAmmo = false
	SendMessage("--------------------------------")
	SendMessage("LeftHipSlotOutputItem")
	truegear.play_effect_by_uuid("LeftHipSlotOutputItem")
	SendMessage(self:get():GetFullName())
	SendMessage("Left")
	SendMessage("LeftHandItem :" .. leftHandItem)
	SendMessage("RightHandItem :" .. rightHandItem)

end

function RightHandGripped(self)
	local isLocalPlayer = self:get():GetPropertyValue("Owner"):IsLocalPlayer()
	if isLocalPlayer == false then
		return
	end
	if canOutputAmmo == false then
		return
	end
	canOutputAmmo = false
	SendMessage("--------------------------------")
	SendMessage("LeftHipSlotOutputItem")
	truegear.play_effect_by_uuid("LeftHipSlotOutputItem")
	SendMessage(self:get():GetFullName())
	SendMessage("Right")
	SendMessage("LeftHandItem :" .. leftHandItem)
	SendMessage("RightHandItem :" .. rightHandItem)
end




function OnActivation(self)	
	local isLocalPlayer = self:get():GetPropertyValue("Owner"):IsLocalPlayer()
	if isLocalPlayer == false then
		return
	end
	SendMessage("--------------------------------")
	if self:get():GetFullName() == leftHandItem then
		SendMessage("LeftHandPickupItem1")
		truegear.play_effect_by_uuid("LeftHandPickupItem")
	else
		SendMessage("RightHandPickupItem")
		truegear.play_effect_by_uuid("RightHandPickupItem")
	end	
end
function ServerActivate(self)
	local isLocalPlayer = self:get():GetPropertyValue("Owner"):IsLocalPlayer()
	if isLocalPlayer == false then
		return
	end
	SendMessage("--------------------------------")
	if self:get():GetFullName() == leftHandItem then
		SendMessage("LeftHandPickupItem2")
		truegear.play_effect_by_uuid("LeftHandPickupItem")
	else
		SendMessage("RightHandPickupItem")
		truegear.play_effect_by_uuid("RightHandPickupItem")
	end	
	SendMessage(self:get():GetFullName())
end


function OnSecondaryGripRight(self)
	local isLocalPlayer = self:get():IsLocalPlayer()
	if isLocalPlayer == false then
		return
	end
	isTwoHandGun = true
	SendMessage("--------------------------------")
	SendMessage("RightHandPickupItem")
	truegear.play_effect_by_uuid("RightHandPickupItem")
	SendMessage(self:get():GetFullName())
end

function OnSecondaryGripLeft(self)
	local isLocalPlayer = self:get():IsLocalPlayer()
	if isLocalPlayer == false then
		return
	end
	isTwoHandGun = true
	SendMessage("--------------------------------")
	SendMessage("LeftHandPickupItem3")
	truegear.play_effect_by_uuid("LeftHandPickupItem")
	SendMessage(self:get():GetFullName())
end

function OnSecondaryDropRight(self)
	local isLocalPlayer = self:get():IsLocalPlayer()
	if isLocalPlayer == false then
		return
	end
	isTwoHandGun = false
	SendMessage("--------------------------------")
	SendMessage("OnSecondaryDropRight")
	SendMessage(self:get():GetFullName())
end

function OnSecondaryDropLeft(self)
	local isLocalPlayer = self:get():IsLocalPlayer()
	if isLocalPlayer == false then
		return
	end
	isTwoHandGun = false
	SendMessage("--------------------------------")
	SendMessage("OnSecondaryDropLeft")
	SendMessage(self:get():GetFullName())
end





function ClientNotifyHit(self,HitDirection)
	local isLocalPlayer = self:get():IsLocalPlayer()
	if isLocalPlayer == false then
		return
	end
	SendMessage("--------------------------------")
	SendMessage("ClientNotifyHit")
	SendMessage(self:get():GetFullName())
	SendMessage(HitDirection:get():GetFullName())
	SendMessage("HitX :" .. tostring(HitDirection:get()["X"]))
	SendMessage("HitY :" .. tostring(HitDirection:get()["Y"]))
	SendMessage("OrginX :" .. tostring(self:get():GetVRForwardVector()["X"]))
	SendMessage("OrginY :" .. tostring(self:get():GetVRForwardVector()["Y"]))
	local point = {x = HitDirection:get()["X"],y = HitDirection:get()["Y"]}
	local orgin = {x = -self:get():GetVRForwardVector()["X"],y = -self:get():GetVRForwardVector()["Y"]}
	local angle = angleBetweenVectors360(point,orgin)
	SendMessage("DefaultDamage," .. angle .. ",0")
	PlayAngle("DefaultDamage",angle,0)
end

function ReceiveOnSpawn(self)
	local isLocalPlayer = self:get():IsLocalPlayer()
	if isLocalPlayer == false then
		return
	end
	SendMessage("--------------------------------")
	SendMessage("ReceiveOnSpawn")
	SendMessage(self:get():GetFullName())
	holsterType = ""
	leftHandItem = ""
	rightHandItem = ""
	isTwoHandGun = false
end

function MeleeHit(self,SelfActor,OtherActor,NormalImpulse)
	local isLocalPlayer = self:get():GetPropertyValue("Owner"):IsLocalPlayer()
	if isLocalPlayer == false then
		return
	end
	local vector = {x = NormalImpulse:get()["X"], y = NormalImpulse:get()["Y"], z = NormalImpulse:get()["Z"]}
	local vectorLength = vectorLength(vector)
	if vectorLength < 100 then
		return
	end
	if self:get():GetFullName() == leftHandItem then
		SendMessage("--------------------------------")
		SendMessage("LeftHandMeleeHit")
		truegear.play_effect_by_uuid("LeftHandMeleeHit")
	else
		SendMessage("--------------------------------")
		SendMessage("RightHandMeleeHit")
		truegear.play_effect_by_uuid("RightHandMeleeHit")
	end
	
	SendMessage(self:get():GetFullName())
	SendMessage(SelfActor:get():GetFullName())
	
	SendMessage(NormalImpulse:get()["X"])
	SendMessage(NormalImpulse:get()["Y"])
	SendMessage(NormalImpulse:get()["Z"])
	SendMessage("Power :" .. vectorLength)
end

function OnHolster(self,Character)	
	-- local isLocalPlayer = Character:get():IsLocalPlayer()
	-- if isLocalPlayer == false then
	-- 	return
	-- end
	if holsterType == "" then
		return
	end


	if holsterType == 2 then
		SendMessage("--------------------------------")
		SendMessage("RightHipSlotInputItem")
		truegear.play_effect_by_uuid("RightHipSlotInputItem")
	elseif holsterType == 6 then
		if isLeftHandItem then
			SendMessage("--------------------------------")
			SendMessage("RightHandSlotInputItem")
			truegear.play_effect_by_uuid("RightHandSlotInputItem")
		else
			SendMessage("--------------------------------")
			SendMessage("LeftHandSlotInputItem")
			truegear.play_effect_by_uuid("LeftHandSlotInputItem")
		end
	elseif holsterType == 8 then
		SendMessage("--------------------------------")
		SendMessage("LeftChestSlotInputItem")
		truegear.play_effect_by_uuid("LeftChestSlotInputItem")
	else
		SendMessage("--------------------------------")
		SendMessage("ChestSlotInputItem")
		truegear.play_effect_by_uuid("ChestSlotInputItem")
	end
	holsterType = ""
	-- SendMessage(self:get():GetFullName())
	-- SendMessage(Character:get():GetFullName())
end

function OnUnholster(self,Character)
	-- local isLocalPlayer = Character:get():IsLocalPlayer()
	-- if isLocalPlayer == false then
	-- 	return
	-- end
	if canOutputItem == false then
		return
	end
	if holsterType == "" then
		return
	end
	canOutputItem = false
	if holsterType == 2 then
		SendMessage("--------------------------------")
		SendMessage("RightHipSlotOutputItem")
		truegear.play_effect_by_uuid("RightHipSlotOutputItem")
	elseif holsterType == 6 then
		if isLeftHandItem then
			SendMessage("--------------------------------")
			SendMessage("RightHandSlotOutputItem")
			truegear.play_effect_by_uuid("RightHandSlotOutputItem")
		else
			SendMessage("--------------------------------")
			SendMessage("LeftHandSlotOutputItem")
			truegear.play_effect_by_uuid("LeftHandSlotOutputItem")
		end
	elseif holsterType == 8 then
		SendMessage("--------------------------------")
		SendMessage("LeftChestSlotOutputItem")
		truegear.play_effect_by_uuid("LeftChestSlotOutputItem")
	else
		SendMessage("--------------------------------")
		SendMessage("ChestSlotOutputItem")
		truegear.play_effect_by_uuid("ChestSlotOutputItem")
	end
	holsterType = ""
	-- SendMessage(self:get():GetFullName())
	-- SendMessage(Character:get():GetFullName())
end


function FireShot(self)
	local isRightHand = self:get():GetPropertyValue("bIsHeldByRightController")
	local gunType = GunCheck(self:get():GetFullName())
	if isTwoHandGun == true then
		if gunType == "Rifle" then
			SendMessage("--------------------------------")
			SendMessage("LeftHandRifleShoot")
			SendMessage("RightHandRifleShoot")
			truegear.play_effect_by_uuid("LeftHandRifleShoot")
			truegear.play_effect_by_uuid("RightHandRifleShoot")
		elseif gunType == "Shotgun" then
			SendMessage("--------------------------------")
			SendMessage("LeftHandShotgunShoot")
			SendMessage("RightHandShotgunShoot")
			truegear.play_effect_by_uuid("LeftHandShotgunShoot")
			truegear.play_effect_by_uuid("RightHandShotgunShoot")
		else
			SendMessage("--------------------------------")
			SendMessage("LeftHandPistolShoot")
			SendMessage("RightHandPistolShoot")
			truegear.play_effect_by_uuid("LeftHandPistolShoot")
			truegear.play_effect_by_uuid("RightHandPistolShoot")
		end
	elseif isRightHand then
		if gunType == "Rifle" then
			SendMessage("--------------------------------")
			SendMessage("RightHandRifleShoot")
			truegear.play_effect_by_uuid("RightHandRifleShoot")
		elseif gunType == "Shotgun" then
			SendMessage("--------------------------------")
			SendMessage("RightHandShotgunShoot")
			truegear.play_effect_by_uuid("RightHandShotgunShoot")
		else
			SendMessage("--------------------------------")
			SendMessage("RightHandPistolShoot")
			truegear.play_effect_by_uuid("RightHandPistolShoot")
		end
	else
		if gunType == "Rifle" then
			SendMessage("--------------------------------")
			SendMessage("LeftHandRifleShoot")
			truegear.play_effect_by_uuid("LeftHandRifleShoot")
		elseif gunType == "Shotgun" then
			SendMessage("--------------------------------")
			SendMessage("LeftHandShotgunShoot")
			truegear.play_effect_by_uuid("LeftHandShotgunShoot")
		else
			SendMessage("--------------------------------")
			SendMessage("LeftHandPistolShoot")
			truegear.play_effect_by_uuid("LeftHandPistolShoot")
		end
	end	
	SendMessage(self:get():GetFullName())
end

function GunCheck(ObjectName)
	for k, v in pairs(Rifle) do
		if string.find(ObjectName,v) then
			return "Rifle"
		end
	end
	for k, v in pairs(Shotgun) do
		if string.find(ObjectName,v) then
			return "Shotgun"
		end
	end
	return "Pistol"
end

function EjectMag(self)
	SendMessage("--------------------------------")
	SendMessage("EjectMag")
	SendMessage(tostring(self:get():GetPropertyValue("bIsHeldByRightController")))
end

function OnMagWellBeginOverlap(self)
	SendMessage("--------------------------------")
	SendMessage("OnMagWellBeginOverlap****************")
	SendMessage(tostring(self:get():GetPropertyValue("bIsHeldByRightController")))
end

function SetChamberState(self,NewChamberState)
	local chamberState = NewChamberState:get()
	if chamberState ~= 147 then
		return
	end
	SendMessage("--------------------------------")
	SendMessage("SetChamberState")
	SendMessage(tostring(self:get():GetPropertyValue("bIsHeldByRightController")))
	SendMessage(tostring(NewChamberState:get()))
end

function OnDropLeft(self,GripInformation)
	local isLocalPlayer = self:get():IsLocalPlayer()
	if isLocalPlayer == false then
		return
	end
	holsterType = GripInformation:get()["GrippedObject"]:GetPropertyValue("HolsterType")
	isLeftHandItem = true
	leftHandItem = ""
	
	SendMessage("--------------------------------")
	SendMessage("OnDropLeft")
	SendMessage(GripInformation:get():GetFullName())
	SendMessage(GripInformation:get()["GrippedObject"]:GetFullName())	
	SendMessage(holsterType)	
end

function OnDropRight(self,GripInformation)
	local isLocalPlayer = self:get():IsLocalPlayer()
	if isLocalPlayer == false then
		return
	end
	
	holsterType = GripInformation:get()["GrippedObject"]:GetPropertyValue("HolsterType")
	isLeftHandItem = false
	rightHandItem = ""
	
	SendMessage("--------------------------------")
	SendMessage("OnDropRight")
	SendMessage(GripInformation:get():GetFullName())
	SendMessage(GripInformation:get()["GrippedObject"]:GetFullName())
	SendMessage(holsterType)	
end

function OnGripLeft(self,GripInformation)
	local isLocalPlayer = self:get():IsLocalPlayer()
	if isLocalPlayer == false then
		return
	end
	
	holsterType = GripInformation:get()["GrippedObject"]:GetPropertyValue("HolsterType")
	isLeftHandItem = true
	leftHandItem = GripInformation:get()["GrippedObject"]:GetFullName()
	if string.find(GripInformation:get()["GrippedObject"]:GetFullName(),"Magazine") then
		canOutputAmmo = true
	end
	canOutputItem = true
	SendMessage("--------------------------------")
	SendMessage("LeftHandPickupItem4")
	truegear.play_effect_by_uuid("LeftHandPickupItem")
	SendMessage(GripInformation:get()["GrippedBoneName"]:ToString())
	SendMessage(GripInformation:get()["SlotName"]:ToString())
	SendMessage(GripInformation:get()["GrippedObject"]:GetFullName())
	SendMessage(holsterType)	
end

function OnGripRight(self,GripInformation)
	local isLocalPlayer = self:get():IsLocalPlayer()
	if isLocalPlayer == false then
		return
	end
	
	holsterType = GripInformation:get()["GrippedObject"]:GetPropertyValue("HolsterType")
	isLeftHandItem = false
	rightHandItem = GripInformation:get()["GrippedObject"]:GetFullName()
	if string.find(GripInformation:get()["GrippedObject"]:GetFullName(),"Magazine") then
		canOutputAmmo = true
	end
	canOutputItem = true
	SendMessage("--------------------------------")
	SendMessage("RightHandPickupItem")
	truegear.play_effect_by_uuid("RightHandPickupItem")
	SendMessage(GripInformation:get()["GrippedBoneName"]:ToString())
	SendMessage(GripInformation:get()["SlotName"]:ToString())
	SendMessage(GripInformation:get()["GrippedObject"]:GetFullName())
	SendMessage(holsterType)	
end

function OnDeath(self)
	local isLocalPlayer = self:get():IsLocalPlayer()
	if isLocalPlayer == false then
		return
	end
	SendMessage("--------------------------------")
	SendMessage("PlayerDeath")
	truegear.play_effect_by_uuid("PlayerDeath")
	holsterType = ""
	leftHandItem = ""
	rightHandItem = ""
	isTwoHandGun = false
end



-- function HeartBeat()
-- 	if type(health) ~= "number" or type(maxHealth) ~= "number" then
-- 		return
-- 	end
-- 	if health < maxHealth / 3 then
-- 		SendMessage("--------------------------------")
-- 		SendMessage("HeartBeat")
-- 		truegear.play_effect_by_uuid("HeartBeat")
-- 	end
-- end

truegear.seek_by_uuid("DefaultDamage")
truegear.init("801550", "VAIL")

function CheckPlayerSpawned()
	RegisterHook("/Script/Engine.PlayerController:ClientRestart", function()
		if resetHook then
			local ran, errorMsg = pcall(RegisterHooks)
			if ran then
				SendMessage("--------------------------------")
				SendMessage("HeartBeat")
				truegear.play_effect_by_uuid("HeartBeat")
				resetHook = false
			else
				print(errorMsg)				
			end
		end		
	end)
end

-- function CheckPlayerSpawned()
-- 	RegisterHooks()
-- end

SendMessage("TrueGear Mod is Loaded");
CheckPlayerSpawned()

-- LoopAsync(1000, HeartBeat)