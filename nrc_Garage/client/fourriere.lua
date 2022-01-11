ESX = nil 
local isMenuOpen = false

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local menu_fouriere = RageUI.CreateMenu(nil, "FOURIERE")
menu_fouriere.Closed = function()
    isMenuOpen = false
end

pound = {
    poundlist = {}
}

local function openPound()
    if not isMenuOpen then
        isMenuOpen = true
        RageUI.Visible(menu_fouriere, true)
        CreateThread(function()
            while isMenuOpen do
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
                                        isMenuOpen = false
                                    end
                                end)
                            end
                        })
                    end


                end)
            Wait(0)      
            end
        end)
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
            end

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
        end
    Wait(0)
    end
end)