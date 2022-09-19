Framework.RegisterServerCallback('Kibra:Motels:V2:Server:GetPlayerClothes', function(source, cb)
	local xPlayer  = Framework.xPlayer(source)

	TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)
		local count  = store.count('dressing')
		local labels = {}

		for i=1, count, 1 do
			local entry = store.get('dressing', i)
			table.insert(labels, entry.label)
		end

		cb(labels)
	end)
end)

Framework.RegisterServerCallback('Kibra:Motels:V2:Server:GetPlayerOutfits', function(source, cb, num)
	local xPlayer = Framework.xPlayer(source)

	TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)
		local outfit = store.get('dressing', num)
		cb(outfit.skin)
	end)
end)

RegisterServerEvent('Kibra:Motels:V2:Server:DeleteOutfit', function(label)
    local xPlayer = Framework.xPlayer(source)
    TriggerEvent('esx_datastore:getDataStore', 'property', xPlayer.identifier, function(store)
        local dressing = store.get('dressing')
        if dressing == nil then
            dressing = {}
        end
        label = label
        table.remove(dressing, label)
        store.set('dressing', dressing)
    end)
end)