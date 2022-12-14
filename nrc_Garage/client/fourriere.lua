ESX = nil 
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

pound = {
    poundlist = {}
}

local function openPound()
    local menu_fouriere = RageUI.CreateMenu(nil, "FOURIERE")
    RageUI.Visible(menu_fouriere, true)

    while menu_fouriere do
        RageUI.IsVisible(menu_fouriere, function()
            RageUI.Separator("~g~↓~s~    Liste de véhicule(s)    ~g~↓")
            RageUI.Separator("__________________")
            for i = 1, #pound.poundlist, 1 do
                local hash = pound.poundlist[i].vehicle.model
                local model = pound.poundlist[i].vehicle
                local nomveh = GetDisplayNameFromVehicleModel(hash)
                local nomvehtexte = GetLabelText(nomveh)
                local plaque = pound.poundlist[i].plate

                RageUI.Button(nomveh.." | ~o~"..plaque, nil, {}, true, {
                    onSelected = function()
                        ESX.TriggerServerCallback("nrc:BuyPound", function(callback_pound)
                            if callback_pound then 
                                SpawnVehicle(model, plaque)
                                RageUI.CloseAll()

                            end
                        end)
                    end
                })
            end
        end)
        if not RageUI.Visible(menu_fouriere) then 
            menu_fouriere = RMenu:DeleteType('menu_fouriere', true)
        end  
    Wait(0)      
    end
end

CreateThread(function()
    while true do
        local internal = 250 
        
        for k, v in pairs(Config.pound) do
            local plyCoords = GetEntityCoords(GetPlayerPed(-1), false)
            local pos = Config.pound
            local dist = Vdist(plyCoords.x, plyCoords.y, plyCoords.z, pos[k].x, pos[k].y, pos[k].z)

            if dist <= 10 then
                interval = 0
                DrawMarker(39, pos[k].x, pos[k].y, pos[k].z, 0.0, 0.0, 0.0, 0.0,0.0,0.0, 0.5, 0.5, 0.5, 255, 138, 27, 255, false, true, p19, true)
                if dist <= 2 then
                    interval = 0
                    ESX.ShowHelpNotification("Appuyer sur [~o~E~s~] pour accéder à la fourrière")
                    if IsControlJustPressed(1, 51) then
                        ESX.TriggerServerCallback("nrc:vehiclelistPound", function(ownedCars)
                            pound.poundlist = ownedCars
                        end)
                        openPound()
                    end
                end
            else 
                Wait(internal)
            end
        end
    Wait(0)
    end
end)