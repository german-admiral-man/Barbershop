ESX = nil

Citizen.CreateThread(function() 
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

local hasAlreadyEnteredMarker, lastZone, currentAction, currentActionMsg, hasPaid

local lastSkin, cam, isCameraActive
local firstSpawn, zoomOffset, camOffset, heading, skinLoaded = true, 0.0, 0.0, 90.0, false

AddEventHandler('barbershop:hasEnteredMarker', function(zone)
	currentAction = 'shop_menu'
	currentActionMsg = _U('press_access')
end)

AddEventHandler('barbershop:hasExitedMarker', function(zone)
	currentAction = nil

	if not hasPaid then
		ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
			TriggerEvent('skinchanger:loadSkin', skin)
		end)
	end
end)

-- Create Blips
Citizen.CreateThread(function()
	for k,v in ipairs(Config.Shops) do
		local blip = AddBlipForCoord(v)

		SetBlipSprite (blip, 71)
		SetBlipColour (blip, 51)
		SetBlipAsShortRange(blip, true)

		BeginTextCommandSetBlipName('STRING')
		AddTextComponentSubstringPlayerName(_U('barber_blip'))
		EndTextCommandSetBlipName(blip)
	end
end)

-- Enter / Exit marker events and draw marker
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		local playerCoords, isInMarker, currentZone, letSleep = GetEntityCoords(PlayerPedId()), nil, nil, true

		for k,v in ipairs(Config.Shops) do
			local distance = #(playerCoords - v)

			if distance < Config.DrawDistance then
				letSleep = false
				DrawMarker(Config.MarkerType, v, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.MarkerSize, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, nil, nil, false)

				if distance < 1.5 then
					isInMarker, currentZone = true, k
				end
			end
		end

		if (isInMarker and not hasAlreadyEnteredMarker) or (isInMarker and lastZone ~= currentZone) then
			hasAlreadyEnteredMarker, lastZone = true, currentZone
			TriggerEvent('barbershop:hasEnteredMarker', currentZone)
		end

		if not isInMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			TriggerEvent('barbershop:hasExitedMarker', lastZone)
		end

		if letSleep then
			Citizen.Wait(500)
		end
	end
end)

-- Key controls
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if currentAction then
			ESX.ShowHelpNotification(currentActionMsg)

			if IsControlJustReleased(0, 38) then
				if currentAction == 'shop_menu' then
					OpenUI()
				end

				currentAction = nil
			end
		else
			Citizen.Wait(500)
		end
	end
end)

function CreateSkinCam()
    if not DoesCamExist(cam) then
        cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    end

    local playerPed = PlayerPedId()
	local coords    = GetEntityCoords(playerPed)

    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)

    isCameraActive = true
    SetCamCoord(cam, coords.x, coords.y + 1, coords.z + 0.5)
    SetCamRot(cam, 0.0, 0.0, 180.0, true)
	-- PointCamAtCoord(cam, coords.x + coords.x, coords.y - coords.y, coords.z + 1)
    SetEntityHeading(playerPed, 0.0)
end

function DeleteSkinCam()
    isCameraActive = false
    SetCamActive(cam, false)
    RenderScriptCams(false, true, 500, true, true)
    cam = nil
end

-- NUI
function OpenUI()
	if not isMenuActive then
		ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
			local playerPed = PlayerPedId()
			hasPaid = false
			isMenuActive = true
			SetNuiFocus(true, true)
			
			local success, overlayValue, colourType, firstColour, secondColour, overlayOpacity = GetPedHeadOverlayData(PlayerPedId(), 1)
			SendNUIMessage({type = 'openUI',
				skin = skin,

				currentHair = GetPedDrawableVariation(playerPed, 2),
				currentHairColor = GetPedTextureVariation(playerPed, 2),
				totalHairs = GetNumberOfPedDrawableVariations(playerPed, 2),
				hairColors = GetNumberOfPedTextureVariations(playerPed, 2, GetPedDrawableVariation(playerPed, 2)) - 1,

				currentBeard = GetPedHeadOverlayValue(playerPed, 1),
				currentBeardColor = firstColour,
				totalBeards = GetPedHeadOverlayNum(1) - 1,
				-- beardColors = GetNumberOfPedDrawableVariations(playerData, 1)
				beardColors = GetNumberOfPedTextureVariations(playerPed, 1, GetPedHeadOverlayValue(playerPed, 1))
			})
			SendNUIMessage({type = 'updateData',
				currentHair = GetPedDrawableVariation(playerPed, 2),
				currentHairColor = GetPedTextureVariation(playerPed, 2),
				totalHairs = GetNumberOfPedDrawableVariations(playerPed, 2),
				hairColors = GetNumberOfPedTextureVariations(playerPed, 2, GetPedDrawableVariation(playerPed, 2)) - 1,

				currentBeard = GetPedHeadOverlayValue(playerPed, 1),
				currentBeardColor = firstColour,
				totalBeards = GetPedHeadOverlayNum(1) - 1,
				-- beardColors = GetNumberOfPedDrawableVariations(playerData, 1)
				beardColors = GetNumberOfPedTextureVariations(playerPed, 1, GetPedHeadOverlayValue(playerPed, 1))
			})
			TriggerEvent('skinchanger:loadSkin', skin)
			CreateSkinCam()
		end)
	end
end

RegisterNUICallback('changeDrawable', function(data)
	local playerPed = PlayerPedId()
	if (data.beard) then
		SetPedHeadOverlay(playerPed, 1, data.drawable, 1.0)
		SetPedHeadOverlayColor(playerPed, 1, 1, data.texture, data.texture)
		SendNUIMessage({type = 'updateData', 
			currentBeard = data.drawable,
			currentBeardColor = data.texture,
			totalBeards = GetPedHeadOverlayNum(1) - 1,
			beardColors = GetNumberOfPedTextureVariations(playerPed, 1, data.drawable)
		})
	else
		SetPedComponentVariation(playerPed, 2, data.drawable, data.texture, 0)
		SendNUIMessage({type = 'updateData', 
			currentHair = data.drawable,
			currentHairColor = data.texture,
			totalHairs = GetNumberOfPedDrawableVariations(playerPed, 2),
			hairColors = GetNumberOfPedTextureVariations(playerPed, 2, data.drawable) - 1
		})
	end
end)

RegisterNUICallback('goToPayment', function(data)
	if (data.amount > 0) then
		ESX.TriggerServerCallback('barbershop:payForService', function(success)
			if success then
				hasPaid = true
				isMenuActive = false
				SetNuiFocus(false, false)
				SendNUIMessage({type = 'closePayUI'})
				DeleteSkinCam()
				TriggerEvent('skinchanger:getSkin', function(skin) 
					skin.hair_1 = data.hair
					skin.hair_color_1 = data.hairColor
					skin.beard_1 = data.beard
					skin.beard_2 = 10
					skin.beard_3 = data.beardColor
					TriggerServerEvent('esx_skin:save', skin)
				end)
			else
				escape()
			end
		end, data)
	end
end)

RegisterNUICallback('escape', function()
	escape()
end)

AddEventHandler('onResourceStop', function (resourceName)
	if (GetCurrentResourceName() ~= resourceName) then
		return
	end
	escape()
end)

AddEventHandler('onResourceStart', function (resourceName)
	if(GetCurrentResourceName() ~= resourceName) then
		return
	end
	escape()
end)

function escape()
	if isMenuActive then
		ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
			TriggerEvent('skinchanger:loadSkin', skin)
		end)
		isMenuActive = false
		SetNuiFocus(false, false)
		SendNUIMessage({type = 'closeUI'})
		DeleteSkinCam()
	end
end