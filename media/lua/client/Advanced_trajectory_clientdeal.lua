require "Advanced_trajectory_core"

local headShotDmgZomMultiplier = getSandboxOptions():getOptionByName("Advanced_trajectory.headShotDmgZomMultiplier"):getValue()
local bodyShotDmgZomMultiplier = getSandboxOptions():getOptionByName("Advanced_trajectory.bodyShotDmgZomMultiplier"):getValue()
local footShotDmgZomMultiplier = getSandboxOptions():getOptionByName("Advanced_trajectory.footShotDmgZomMultiplier"):getValue()


local function Advanced_trajectory_OnServerCommand(module, command, arguments)

    local Playershot = getPlayer()
    if not Playershot then return end
	if module == "ATY_shotplayer" then


        if (getSandboxOptions():getOptionByName("ATY_nonpvp_protect"):getValue() and NonPvpZone.getNonPvpZone(Playershot:getX(), Playershot:getY())) or (getSandboxOptions():getOptionByName("ATY_safezone_protect"):getValue() and SafeHouse.getSafeHouse(Playershot:getCurrentSquare())) then return end
        

        -- print(NonPvpZone.getNonPvpZone(getPlayer():getX(), getPlayer():getY()))
        -- print(SafeHouse.getSafeHouse(getPlayer():getCurrentSquare()))
        local damagepr = math.floor(arguments[1])
        print("damagepr: " .. damagepr)
        Playershot:Say("arguments[1]: " .. arguments[1])
        Playershot:Say("damagepr: " .. damagepr)


        local headShot = {
            BodyPartType.Head,			BodyPartType.Head,
            BodyPartType.Neck
        }
        local bodyShot = {
            BodyPartType.Torso_Upper,	BodyPartType.Torso_Lower,
            BodyPartType.Torso_Upper,	BodyPartType.Torso_Lower,
            BodyPartType.Torso_Upper,	BodyPartType.Torso_Lower,
            BodyPartType.Groin,
            BodyPartType.UpperArm_L,	BodyPartType.UpperArm_R,
            BodyPartType.ForeArm_L,		BodyPartType.ForeArm_R,
            BodyPartType.UpperLeg_L,	BodyPartType.UpperLeg_R,
            BodyPartType.UpperLeg_L,	BodyPartType.UpperLeg_R,
            BodyPartType.LowerLeg_L,	BodyPartType.LowerLeg_R
        }
        local terminalShot = {
            BodyPartType.Hand_L,		BodyPartType.Hand_R,
            BodyPartType.Foot_L,		BodyPartType.Foot_R
        }
        local shotpart = BodyPartType.Torso_Upper


        --[[
		-- takes a random bodypart type from the table and adds injury to it
		local hitCategory = ZombRand(10)  -- 10 possibilities

        -- takes a random bodypart type from the table and adds injury to it
		if hitCategory <= 6 then
			--selectedCategory = "bodyShot"
			shotpart = bodyShot[ZombRand(#bodyShot) + 1]
			if clitem then
                clitem:setCondition(clitem:getCondition()-1)
            end
		elseif hitCategory <= 9 then
			--selectedCategory = "headShot"
			shotpart = headShot[ZombRand(#headShot) + 1]
			if clitem then
                clitem:setCondition(clitem:getCondition()-1)
            end
		else
		   --selectedCategory = "terminalShot"
		   shotpart = terminalShot[ZombRand(#terminalShot) + 1]
		   if clitem then
                clitem:setCondition(clitem:getCondition()-1)
            end
		end
        --]]


        if damagepr == headShotDmgZomMultiplier then
            shotpart = headShot[ZombRand(#headShot)+1]
            local clitem = Playershot:getClothingItem_Head()
            if clitem then
                clitem:setCondition(clitem:getCondition()-1)
            end
        elseif damagepr == bodyShotDmgZomMultiplier then
            shotpart = bodyShot[ZombRand(#bodyShot)+1]

            local clitem = Playershot:getClothingItem_Torso()
            if clitem then
                clitem:setCondition(clitem:getCondition()-1)
            end
        elseif damagepr == footShotDmgZomMultiplier then
            shotpart = BodyPartType[ZombRand(#BodyPartType)+1]
            local clitem = Playershot:getClothingItem_Feet()
            if clitem then
                clitem:setCondition(clitem:getCondition()-1)
            end
        end


        local bodypart = Playershot:getBodyDamage():getBodyPart(shotpart)
        local defense1 = Playershot:getBodyPartClothingDefense(shotpart:index(),true,true)
        local defense2 = Playershot:getBodyPartClothingDefense(shotpart:index(),false,false)
        local defense3 = Playershot:getBodyPartClothingDefense(shotpart:index(),true,false)
        local alldefense = (defense1 + defense2*0.5 + defense3*0.5)/150

        -- print(alldefense)

        -- Playershot:getClothingItem_Legs()
        -- Playershot:getClothingItem_Torso()
        -- Playershot:getClothingItem_Back()
        
        if alldefense < 0.5 then
            if bodypart:haveBullet() then
                local deepWound = bodypart:isDeepWounded()
                local deepWoundTime = bodypart:getDeepWoundTime()
                local bleedTime = bodypart:getBleedingTime()
                --bodypart:setHaveBullet(false, 0)
                bodypart:setDeepWoundTime(deepWoundTime)
                bodypart:setDeepWounded(deepWound)
                bodypart:setBleedingTime(bleedTime)
            else
                bodypart:setHaveBullet(true, 0)
            end
            
        end

        if alldefense> 0.9 then
            alldefense = 0.9
        end
        

        Playershot:getBodyDamage():ReduceGeneralHealth(arguments[2]*damagepr*0.6*(1-alldefense))
  
    elseif module == "ATY_shotsfx" then
        if arguments[2] == Playershot:getOnlineID() then return end 
        table.insert(Advanced_trajectory.table,arguments[1])
    elseif module == "ATY_reducehealth" then
        
        
        Playershot:getBodyDamage():ReduceGeneralHealth(arguments[1])

    elseif module == "ATY_cshotzombie" then


        if Playershot:getOnlineID() == arguments[2] then return end
        local zombies = getCell():getZombieList()

        for i=1,zombies:size() do

            local zombiez = zombies:get(i-1)
            if zombiez:getOnlineID()==arguments[1] then

                -- if not string.find(tostring(zombiez:getCurrentState()), "Climb") and not string.find(tostring(zombiez:getCurrentState()), "Craw") then
                       
                --     zombiez:changeState(ZombieIdleState.instance())
                    
                -- end
                zombiez:setHitReaction("Shot")
            end
        end




    elseif module == "ATY_killzombie" then
        local zombies = getCell():getZombieList()

        for i=1,zombies:size() do

            local zombiez = zombies:get(i-1)
            if zombiez:getOnlineID()==arguments[1] then

                zombiez:Kill(zombiez)

            
            end
        end

    end
        
end



Events.OnServerCommand.Add(Advanced_trajectory_OnServerCommand)