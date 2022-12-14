ESX = nil 

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Garage 

ESX.RegisterServerCallback("nrc:vehiclelist", function(source, cb)
    local ownedCars =  {}
    local xPlayer = ESX.GetPlayerFromId(source)
	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND `stored` = @stored', {
		['@owner'] = xPlayer.identifier,
		['@Type'] = 'car',
		['@stored'] = true
	}, function(data)
		for k, v in pairs(data) do
			local vehicle = json.decode(v.vehicle)
			table.insert(ownedCars, {vehicle = vehicle, stored = v.stored, plate = v.plate})
		end
		cb(ownedCars)
	end)
end)

RegisterServerEvent("nrc:breakveh")
AddEventHandler("nrc:breakveh", function(plate, state)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)

	MySQL.Async.execute('UPDATE owned_vehicles SET `stored` = @stored WHERE plate = @plate', {
		['@stored'] = state,
		['@plate'] = plate
	}, function(rowsChanged)
		if rowsChanged == 0 then
			print(('esx_advancedgarage: %s exploited the garage!'):format(xPlayer.identifier))
		end
	end)
end)

ESX.RegisterServerCallback('nrc:returnveh', function (source, cb, Propsvehicle)
	local ownedCars = {}
	local vehplate = Propsvehicle.plate:match("^%s*(.-)%s*$")
	local vehiclemodel = Propsvehicle.model
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND @plate = plate', {
		['@owner'] = xPlayer.identifier,
		['@plate'] = Propsvehicle.plate
	}, function (result)
		if result[1] ~= nil then
			local originalvehprops = json.decode(result[1].vehicle)
			if originalvehprops.model == vehiclemodel then
				MySQL.Async.execute('UPDATE owned_vehicles SET vehicle = @vehicle WHERE owner = @owner AND plate = @plate', {
					['@owner'] = xPlayer.identifier,
					['@vehicle'] = json.encode(Propsvehicle),
					['@plate'] = Propsvehicle.plate
				}, function (rowsChanged)
					if rowsChanged == 0 then
						print(('nrc_garage : tente de ranger un véhicule non à lui '):format(xPlayer.identifier))
					end
					cb(true)
				end)
			else
				cb(false)
			end
		else
			cb(false)
		end
	end)
end)

-- Fourière 

ESX.RegisterServerCallback("nrc:vehiclelistPound", function(source, cb)
	local ownedCars = {}
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND `stored` = @stored", {
		["@owner"] = xPlayer.identifier,
		["@Type"] = "car",
		["@stored"] = false
	}, function(data)
		for k, v in pairs(data) do
			local veh = json.decode(v.vehicle)
			table.insert(ownedCars, {vehicle = veh, stored = v.stored, plate = v.plate})
		end
		cb(ownedCars)
	end)
end)

ESX.RegisterServerCallback("nrc:BuyPound", function(source, cb)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	
	if xPlayer.getMoney() >= Config.poundprice then
		xPlayer.removeMoney(Config.poundprice)
		TriggerClientEvent('esx:showAdvancedNotification', _src, 'Banque', 'Conseiller', "Vous avez payer ~g~"..Config.poundprice.."$~s~ pour récuperer votre véhicule", 'CHAR_BANK_MAZE', 1)
		cb(true)
	else 
		TriggerClientEvent('esx:showNotification', _src, "~r~Vous n'avez pas suffisament d'argent ~s~!")
		cb(false)
	end
end)