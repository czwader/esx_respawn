local isDead = false
local timeout = false
local spawned = true
local respawnPoints = {
	vector4(-1343.6,729.0,185.72,205.44),
	vector4(501.68,5604.52,797.92,354.72),
	vector4(94.36,6964.76,11.2,0.48),
	vector4(659.88,453.32,144.64,344.8),
	vector4(-1376.24,311.56,64.08,16.68),
	vector4(-1474.2,160.68,55.68,129.8),
	vector4(-57.88,-351.36,42.32,253.04),
	vector4(322.16,-624.64,29.28,242.48),
	vector4(-1839.6,-1254.24,8.6,228.2),
	vector4(1980.52,3816.92,32.28,302.08),
	vector4(3316.2,5172.76,18.44,238.0),
	vector4(104.0,6320.2,31.4,114.24),
	vector4(-286.08,6312.96,31.6,131.72),
	vector4(-607.52,6365.72,3.76,240.6),
	vector4(-689.28,5786.96,17.32,155.96),
	vector4(-738.56,5595.0,41.64,83.52),
	vector4(-953.92,4843.16,313.6,57.0),
	vector4(-839.72,4182.52,215.28,45.68),
	vector4(-524.0,4194.44,193.72,241.2),
	vector4(-326.72,2821.24,58.4,52.6),
	vector4(-439.2,1586.28,357.88,245.76),
	vector4(-468.76,1524.24,391.04,182.84),
	vector4(-735.8,785.68,213.2,108.84),
	vector4(-1537.32,-264.88,48.28,98.12),
	vector4(-1330.32,59.48,53.56,269.2),
	vector4(-542.36,-208.72,37.64,205.56),
	vector4(-269.04,-754.36,53.24,114.8),
	vector4(-376.84,-1891.04,29.96,21.28),
	vector4(484.84,-1095.04,43.08,88.92),
	vector4(415.44,-1328.8,46.04,227.52),
	vector4(355.12,-1693.84,48.32,318.72),
	vector4(-175.8,-1273.28,32.6,90.0),
	vector4(-569.28,-1712.4,23.28,238.76),
	vector4(-464.96,-2302.2,63.0,232.0),
	vector4(-453.24,-2424.0,6.0,227.76),
	vector4(87.68,810.24,211.12,228.04),
}

CreateThread(function()
	AddTextEntry("death_system:spawn", "Stiskni  ~INPUT_CONTEXT~ <font face='Fire Sans'>pro spawn.</font>")
end)

AddEventHandler('esx:onPlayerDeath', function(data)
	isDead = true
	spawned = false
	SetTimeout(5000, function()
		isDead = false	
	end)
	StartScreenEffect("DeathFailOut", 0, 0)
	PlaySoundFrontend(-1, "Bed", "WastedSounds", 1)
	ShakeGameplayCam("DEATH_FAIL_IN_EFFECT_SHAKE", 1.0)
	local scaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")
	while not HasScaleformMovieLoaded(scaleform) do
		Citizen.Wait(0)
	end
	PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
	BeginTextComponent("STRING")
	AddTextComponentString("~r~wasted")
	EndTextComponent()
	PopScaleformMovieFunctionVoid()
	PlaySoundFrontend(-1, "TextHit", "WastedSounds", 1)
	while isDead do
		DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
		Citizen.Wait(0)
	end
	DoScreenFadeOut(1000)
	Wait(1000)
	respawn()
	TriggerServerEvent('esx:onPlayerSpawn')
	TriggerEvent('esx:onPlayerSpawn')
	
	
end)



function getClosestVector(player, vectors)
	local coords = GetEntityCoords(player)
	local closestVector = nil
	local closestDistance = nil
	for key, vectorCoords in pairs(vectors) do
		local distance = GetDistanceBetweenCoords(coords, vectorCoords.x, vectorCoords.y, vectorCoords.z, true)
		if closestDistance == nil or distance < closestDistance then
			closestVector = vectorCoords
			closestDistance = distance
		end
	end
	return closestVector
end



function respawn()
	StopScreenEffect("DeathFailOut")
	DoScreenFadeIn(1000)
	local ped = PlayerPedId()
	SetEntityVisible(ped, false)
	SetEntityInvincible(ped, true)
	FreezeEntityPosition(ped, true)
	local respawnCoords = getClosestVector(ped, respawnPoints)
	NetworkResurrectLocalPlayer(respawnCoords.x, respawnCoords.y, respawnCoords.z, respawnCoords.w, true, false)

	ClearPedBloodDamage(ped)
	ClearPedSecondaryTask(ped)	
	while not spawned do 
		Wait(0)
		SetEntityCoordsNoOffset(ped, respawnCoords.x, respawnCoords.y, respawnCoords.z+2, false, false, false, true)
		DisplayHelpTextThisFrame("death_system:spawn")
		if IsControlJustPressed(0, 38) then 
			local ped = PlayerPedId()
			SetEntityVisible(ped, true)
			FreezeEntityPosition(ped, false)
			SetEntityInvincible(ped, false)
			spawned = true
		end
	end
	
	
end