Framework = nil
TriggerEvent('0r-core:getSharedObject', function(obj) Framework = obj end)

RegisterNetEvent('Kibra:Motels:V2:Server:CheckMotel', function(pid)
    local src = source
    local Player = Framework.xPlayer(source)
    if Player then
        local PlayerMotels = MySQL.Sync.fetchAll('SELECT * FROM `kibra-motels` WHERE owner = ?', {Player.identifier})
        if #PlayerMotels > 0 then
            for k,v in pairs(PlayerMotels) do
                local Motel, Room = MotelIdFind(v.roomid)
                if v.invoiceseen == 0 then
                    AddBilling(Player.source, Motel, v.roomid)
                    Config.ServerNotify(src, Config.Lang["NewMotelBill"])
                end
            end
        end
    end
end)

RegisterNetEvent('Kibra:Motels:V2:Server:AddSocietyMoney', function(societyX, money)
    local src = source 
    local id, r = MotelIdFind(societyX)
    MySQL.Async.execute('UPDATE `kibra-motels` SET invoiceseen = ? WHERE roomid = ?',{0, societyX})
    MySQL.Async.execute('UPDATE `kibra-motels-business` SET money = ? WHERE id = ?',{Config.Motels[id].SocietyMoney+money, id})
	Config.Motels[id].SocietyMoney = Config.Motels[id].SocietyMoney+money
	TriggerClientEvent('Kibra:Motels:V2:Client:UpdateMotels', src, Config.Motels)
end)

function AddBilling(Player, Motel, RoomId)
    local Player = Framework.xPlayer(Player)
    local RData = MySQL.Sync.fetchAll('SELECT * FROM `kibra-motels-business` WHERE id = ?', {Motel})
    MySQL.Async.execute('UPDATE `kibra-motels` SET invoiceseen = ? WHERE id = ?',{1, Motel})
    if Config.BillingSystem == "gks-phone"  then
        MySQL.Async.execute('INSERT INTO gksphone_invoices (citizenid, amount, society, sender, sendercitizenid, label) VALUES (@citizenid, @amount, @society, @sender, @sendercitizenid, @label)', {
            ['@citizenid'] = Player.identifier,
            ['@amount'] = Config.Motels[Motel].BillingFee,
            ['@society'] = "MOTEL",
            ['@sender'] = Config.Motels[Motel].MotelName,
            ['@sendercitizenid'] = RoomId,
            ['@label'] = Config.BillingLabel
        })
    elseif Config.BillingSystem == "qb-phone" then
        MySQL.Async.execute('INSERT INTO phone_invoices (citizenid, amount, society, sender, sendercitizenid) VALUES (@citizenid, @amount, @society, @sender, @sendercitizenid)', {
            ['@citizenid'] = Player.identifier,
            ['@amount'] = Config.Motels[Motel].BillingFee,
            ['@society'] = "MOTEL",
            ['@sender'] = Config.Motels[Motel].MotelName,
            ['@sendercitizenid'] = RoomId,
        })
        TriggerClientEvent('qb-phone:RefreshPhone', Player)
    elseif Config.BillingSystem == "esx_billing" then
        MySQL.Async.execute('INSERT INTO billing (identifier, sender, target_type, target, label, amount) VALUES (@identifier, @sender, @target_type, @target, @label, @amount)', {
            ["@identifier"] = Player.identifier,
            ["@sender"] = Config.Motels[Motel].MotelName,
            ["@target_type"] = "MOTEL",
            ["@target"] = RoomId,
            ["@label"] = Config.BillingLabel,
            ["@amount"] = Config.Motels[Motel].BillingFee
        })
    elseif Config.BillingSystem == "okokBilling" then
        MySQL.Async.insert('INSERT INTO okokBilling (receiver_identifier, receiver_name, author_identifier, author_name, society, society_name, item, invoice_value, status, notes, sent_date, limit_pay_date) VALUES (@receiver_identifier, @receiver_name, @author_identifier, @author_name, @society, @society_name, @item, @invoice_value, @status, @notes, CURRENT_TIMESTAMP(), DATE_ADD(CURRENT_TIMESTAMP(), INTERVAL @limit_pay_date DAY))', {
			['@receiver_identifier'] = Player.identifier,
			['@receiver_name'] = Player.getName(),
			['@author_identifier'] = RoomId,
			['@author_name'] = RData[1].motel,
			['@society'] = "MOTEL",
			['@society_name'] = RData[1].motel,
			['@item'] = "cash",
			['@invoice_value'] = Config.Motels[Motel].BillingFee,
			['@status'] = "unpaid",
			['@notes'] = Config.BillingLabel,
			['@limit_pay_date'] = 'N/A'
        })
        TriggerEvent('MotelBillNotify', Player)
    end
end

Framework.RegisterServerCallback('Kibra:Motels:V2:Server:CheckPlayerFatura', function(source, cb)
    local Player = Framework.xPlayer(source)
    if Config.BillingSystem == "gks-phone" then
        local mDataX = MySQL.Sync.fetchAll('SELECT * FROM gksphone_invoices WHERE citizenid = ?', {Player.identifier})
        if #mDataX > 0 then
            if mDataX[1].society == "MOTEL" then
                cb(false)
            else
                cb(true)
            end
        else
            cb(true)
        end
    elseif Config.BillingSystem == "esx_billing" then
        local mDataV = MySQL.Sync.fetchAll('SELECT * FROM billing WHERE identifier = ?', {Player.identifier})
        if #mDataV > 0 then
            if mDataV[1].target_type == "MOTEL" then
                cb(false)
            else
                cb(true)
            end
        else
            cb(true)
        end
    elseif Config.BillingSystem == "qb-phone" then
        local mDataV = MySQL.Sync.fetchAll('SELECT * FROM phone_invoices WHERE citizenid = ?', {Player.identifier})
        if #mDataV > 0 then
            if mDataV[1].society == "MOTEL" then
                cb(false)
            else
                cb(true)
            end
        else
            cb(true)
        end
    elseif Config.BillingSystem == "okokBilling" then
        local mDataR = MySQL.Sync.fetchAll('SELECT * FROM okokBilling WHERE receiver_identifier = ?', {Player.identifier})
        if #mDataR > 0 then
            if mDataR[1].society == "MOTEL" then
                cb(false)
            else
                cb(true)
            end
        else
            cb(true)
        end
    end
end)