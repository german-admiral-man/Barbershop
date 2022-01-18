ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('barbershop:payForService', function(src, cb, data)
    if (data.amount > 0) then
        local xPlayer = ESX.GetPlayerFromId(src)

        if (xPlayer.getMoney() >= data.amount) then
            xPlayer.removeMoney(data.amount)
            cb(true)
        else
            xPlayer.showNotification('Du hast nicht genug Geld!')
            cb(false)
        end
    end
end)