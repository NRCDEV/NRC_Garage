ESX = nil 
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

Garage = {
    vehiclelist = {}
}

-- Menu du garage
local function opengarage()
    local garage_menu = RageUI.CreateMenu(nil, "Garage")
    RageUI.Visible(garage_menu, true)
    while garage_menu do
        Wait(0)   
        RageUI.IsVisible(garage_menu, function()
            RageUI.Separator("~g~↓~s~    Liste de véhicule(s)    ~g~↓")
            RageUI.Separator("__________________")
            for i = 1, #Garage.vehiclelist, 1 do
                local hash = Garage.vehiclelist[i].vehicle.model
                local model = Garage.vehiclelist[i].vehicle
                local nomvehicle = GetDisplayNameFromVehicleModel(hash)
                local text = GetLabelText(nomvehicle)
                local plaque = Garage.vehiclelist[i].plate 

                RageUI.Button(text.." | ~b~"..plaque, nil, {}, true, {
                    onSelected = function()
                        SpawnVehicle(model, plaque)
                        RageUI.CloseAll()
                    end
                })
            end
        end)  
        if not RageUI.Visible(garage_menu) then 
            garage_menu = RMenu:DeleteType('garage_menu', true)
        end  
    end
end

-- Ouverture du menu
CreateThread(function()
    while true do
        local internal = 250 
        
        for k, v in pairs(Config.sortie) do
            local plyCoords = GetEntityCoords(PlayerPedId(), false)
            local pos = Config.sortie
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, pos[k].x, pos[k].y, pos[k].z)

            if dist <= 15 then
                interval = 0
                DrawMarker(36, pos[k].x, pos[k].y, pos[k].z, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 1.5, 1.5, 1.5, 47, 232, 64, 255, false, true, p19, true)
                if dist <= 2 then
                    interval = 0
                    ESX.ShowHelpNotification("Appuyer sur [~g~E~s~] pour accéder au garage")
                    if IsControlJustPressed(1, 51) then
                        ESX.TriggerServerCallback("nrc:vehiclelist", function(ownedCars)
                            Garage.vehiclelist = ownedCars
                        end)
                        opengarage()
                    end
                end
            else 
                Wait(internal)
            end
        end

        for k, v in pairs(Config.rentrer) do
            local plyCoords = GetEntityCoords(PlayerPedId(), false)
            local pos = Config.rentrer
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, pos[k].x, pos[k].y, pos[k].z)

            if dist <= 15 then
                interval = 0
                DrawMarker(36, pos[k].x, pos[k].y, pos[k].z, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 1.5, 1.5, 1.5, 190, 0, 0, 255, false, true, p19, true)
                if dist <= 2 then
                    interval = 0
                    ESX.ShowHelpNotification("Appuyer sur [~r~E~s~] pour ranger votre véhicule")
                    if IsControlJustPressed(1, 51) then
                        ReturnVeh()
                    end
                end
            else 
                Wait(internal)
            end
        end
    Wait(0)
    end
end)

-- Spawn du véhicule 

function SpawnVehicle(vehicle, plate)
    x,y,z = table.unpack(GetEntityCoords(PlayerPedId(),true))

	ESX.Game.SpawnVehicle(vehicle.model, {
		x = x,
		y = y,
		z = z 
	}, GetEntityHeading(PlayerPedId()), function(callback_vehicle)
		ESX.Game.SetVehicleProperties(callback_vehicle, vehicle)
		SetVehRadioStation(callback_vehicle, "OFF")
		SetVehicleFixed(callback_vehicle)
		SetVehicleDeformationFixed(callback_vehicle)
		SetVehicleUndriveable(callback_vehicle, false)
		SetVehicleEngineOn(callback_vehicle, true, true)
		SetVehicleBodyHealth(callback_vehicle, 1000)
		TaskWarpPedIntoVehicle(PlayerPedId(), callback_vehicle, -1)
	end)
    TriggerServerEvent("nrc:breakveh", plate, false)
end

-- Rentrer le véhicule

function ReturnVeh()
    local playerPed = PlayerPedId()
    if IsPedInAnyVehicle(playerPed, false) then 
        local playerPed = PlayerPedId()
        local pos = GetEntityCoords(playerPed)
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local Propsvehicle = ESX.Game.GetVehicleProperties(vehicle)
        local current = GetPlayersLastVehicle(PlayerPedId(), true)
        local engineH = GetVehicleEngineHealth(current)
        local plate = Propsvehicle.plate

        ESX.TriggerServerCallback("nrc:returnveh", function(valid)
            if valid then 
                BreakReturnVehicle(vehicle, Propsvehicle)
            else
                ESX.ShowNotification("Tu ne peux pas garer ce véhicule")
            end
        end, Propsvehicle)
    else 
        ESX.ShowNotification("Il n'y a pas de véhicule à ranger dans le garage")
    end
end

function BreakReturnVehicle(vehicle, Propsvehicle)
	ESX.Game.DeleteVehicle(vehicle)
	TriggerServerEvent('nrc:breakveh', Propsvehicle.plate, true)
	ESX.ShowNotification("Tu viens de ranger ton ~r~véhicule ~s~!")
end

CreateThread(function ()
    for k, v in pairs(Config.rentrer) do 
        local blip = AddBlipForCoord(v.x, v.y, v.z)

        SetBlipSprite(blip, 50)
        SetBlipScale (blip, 0.8)
        SetBlipColour(blip, 38)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName('Garage')
        EndTextCommandSetBlipName(blip)
    end

    for k, v in pairs(Config.pound) do 
        local blip = AddBlipForCoord(v.x, v.y, v.z)

        SetBlipSprite(blip, 67)
        SetBlipScale (blip, 0.9)
        SetBlipColour(blip, 47)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName('Fourrière')
        EndTextCommandSetBlipName(blip)
    end
end)
