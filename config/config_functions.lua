-- Functions
Config.OpenMotelInventory = function(mid, rid)
    if Config.Inventory == "ox" then
        if exports.ox_inventory:openInventory('stash', "Motel_"..mid..'_'..rid) == false then
            TriggerServerEvent('ox:loadStashes')
            exports.ox_inventory:openInventory('stash', "Motel_"..mid..'_'..rid)
        end
    elseif Config.Inventory == "QBCore" then
        TriggerServerEvent("inventory:server:OpenInventory", "stash", "Motel_"..mid..'_'..rid)
        TriggerEvent("inventory:client:SetCurrentStash", "Motel_"..mid..'_'..rid)
    end
end

Config.Notify = function(textx, type)
    TriggerEvent('0r-core:notif', {text = textx})
end

Config.ServerNotify = function(src, textx)
    TriggerClientEvent('0r-core:notif', src, {text = textx})
end

Config.Show = function(button, text)
    exports["kibra-ui"]:Show(button, text)
end

Config.Hide = function()
    exports["kibra-ui"]:Hide()
end

Config.OpenWardrobe = function()
    if exports["0r-core"]:GetFramework() == "ESX" then
        ESX = exports['es_extended']:getSharedObject()
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'room',{
            title    = 'Clothes',
            align    = 'right',
            elements = {
                {label = 'Clothes', value = 'player_dressing'},
                {label = 'Delete Clothes', value = 'remove_cloth'}
            }
        }, function(data, menu)

            if data.current.value == 'player_dressing' then 
                menu.close()
                Framework.TriggerServerCallback('Kibra:Motels:V2:Server:GetPlayerClothes', function(dressing)
                    elements = {}

                    for i=1, #dressing, 1 do
                        table.insert(elements, {
                            label = dressing[i],
                            value = i
                        })
                    end

                    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'player_dressing',
                    {
                        title    = 'Clothes',
                        align    = 'right',
                        elements = elements
                    }, function(data2, menu2)

                        TriggerEvent('skinchanger:getSkin', function(skin)
                            ESX.TriggerServerCallback('Kibra:Motels:V2:Server:GetPlayerOutfits', function(clothes)
                                TriggerEvent('skinchanger:loadClothes', skin, clothes)
                                TriggerEvent('esx_skin:setLastSkin', skin)

                                TriggerEvent('skinchanger:getSkin', function(skin)
                                    TriggerServerEvent('esx_skin:save', skin)
                                end)
                            end, data2.current.value)
                        end)

                    end, function(data2, menu2)
                        menu2.close()
                    end)
                end)

            elseif data.current.value == 'remove_cloth' then
                menu.close()
                ESX.TriggerServerCallback('Kibra:Motels:V2:Server:GetPlayerClothes', function(dressing)
                    elements = {}

                    for i=1, #dressing, 1 do
                        table.insert(elements, {
                            label = dressing[i],
                            value = i
                        })
                    end

                    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'remove_cloth', {
                        title    = 'Delete Clothe',
                        align    = 'right',
                        elements = elements
                    }, function(data2, menu2)
                        menu2.close()
                        TriggerServerEvent('Kibra:Motels:V2:Server:DeleteOutfit', data2.current.value)
                        Config.Notify('Clothes Deleted!')
                    end, function(data2, menu2)
                        menu2.close()
                    end)
                end)
            end
        end, function(data, menu)
            menu.close()
        end)
    else
        TriggerEvent('qb-clothing:client:openOutfitMenu')
    end
end