ESX = exports["es_extended"]:getSharedObject()
local VendingMachineRobberyCooldowns = {} 

RegisterServerEvent('vending:buyItem')
AddEventHandler('vending:buyItem', function(propModelKey_from_client, itemName_from_client, price_from_client, count_from_client, paymentMethod_from_client)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local T = Config.Translations 

    if not xPlayer then return end
    if not Config or not Config.VendingMachines or not T then 
        print("[vending_server] ERROR: Config, Config.VendingMachines or Config.Translations not loaded on server!")
        return 
    end

    local notifyTitle = Config.VendingMachines[propModelKey_from_client] and Config.VendingMachines[propModelKey_from_client].label or T.vendingMachineDefaultTitle

    if type(propModelKey_from_client) ~= 'string' and type(propModelKey_from_client) ~= 'number' then
        TriggerClientEvent('ox_lib:notify', src, { title = notifyTitle, description = T.serverErrorInvalidIdentifierType, type = 'error' })
        return
    end
    if type(itemName_from_client) ~= 'string' then
        TriggerClientEvent('ox_lib:notify', src, { title = notifyTitle, description = T.serverErrorInvalidItemName, type = 'error' })
        return
    end
    if type(price_from_client) ~= 'number' or price_from_client < 0 then
        TriggerClientEvent('ox_lib:notify', src, { title = notifyTitle, description = T.serverErrorInvalidPrice, type = 'error' })
        return
    end
    if type(count_from_client) ~= 'number' or count_from_client <= 0 or count_from_client > 100 then
        TriggerClientEvent('ox_lib:notify', src, { title = notifyTitle, description = T.serverErrorInvalidAmount, type = 'error' })
        return
    end
    count_from_client = math.floor(count_from_client)
    if paymentMethod_from_client ~= "cash" and paymentMethod_from_client ~= "bank" then
        TriggerClientEvent('ox_lib:notify', src, { title = notifyTitle, description = T.serverErrorInvalidPaymentMethod, type = 'error' })
        return
    end

    local serverVendingConfig = Config.VendingMachines[propModelKey_from_client] 
    if not serverVendingConfig then
        TriggerClientEvent('ox_lib:notify', src, { title = T.errorTitle, description = T.serverErrorMachineNotFoundServer, type = 'error' })
        return
    end
    notifyTitle = serverVendingConfig.label or T.vendingMachineDefaultTitle

    local serverItemData = nil 
    for _, config_item_entry in pairs(serverVendingConfig.items) do
        if config_item_entry.item == itemName_from_client then
            if config_item_entry.price == price_from_client then
                serverItemData = config_item_entry 
                break 
            else
                TriggerClientEvent('ox_lib:notify', src, { title = notifyTitle, description = T.serverErrorPriceMismatch, type = 'error' })
                return 
            end
        end
    end

    if not serverItemData then
        TriggerClientEvent('ox_lib:notify', src, { title = notifyTitle, description = T.serverErrorItemNotFoundOrPrice, type = 'error' })
        return
    end

    local actualItemName = serverItemData.item
    local actualItemPrice = serverItemData.price
    local totalPrice = actualItemPrice * count_from_client
    local hasEnoughMoney = false
    local currentBalance = 0

    if paymentMethod_from_client == "cash" then
        currentBalance = xPlayer.getMoney()
        if currentBalance >= totalPrice then
            hasEnoughMoney = true
            xPlayer.removeMoney(totalPrice)
        end
    elseif paymentMethod_from_client == "bank" then
        local bankAccount = xPlayer.getAccount('bank')
        if bankAccount and bankAccount.money >= totalPrice then
            currentBalance = bankAccount.money
            hasEnoughMoney = true
            xPlayer.removeAccountMoney('bank', totalPrice)
        else
            currentBalance = (bankAccount and bankAccount.money or 0)
        end
    end

    if hasEnoughMoney then
        if xPlayer.canCarryItem(actualItemName, count_from_client) then
            xPlayer.addInventoryItem(actualItemName, count_from_client)
            local paymentMethodText = paymentMethod_from_client == "cash" and T.paymentCash or T.paymentBank
            TriggerClientEvent('ox_lib:notify', src, {
                title = notifyTitle,
                description = string.format(T.serverPurchaseSuccess, count_from_client, ESX.GetItemLabel(actualItemName) or actualItemName, totalPrice, paymentMethodText),
                type = 'success'
            })
        else
            TriggerClientEvent('ox_lib:notify', src, {
                title = notifyTitle,
                description = T.serverErrorInventoryFull,
                type = 'error'
            })
            if paymentMethod_from_client == "cash" then xPlayer.addMoney(totalPrice) else xPlayer.addAccountMoney('bank', totalPrice) end
        end
    else
        local paymentMethodText = paymentMethod_from_client == "cash" and T.paymentCash or T.paymentBank
        TriggerClientEvent('ox_lib:notify', src, {
            title = notifyTitle,
            description = string.format(T.serverErrorInsufficientFunds, totalPrice, currentBalance, paymentMethodText),
            type = 'error'
        })
    end
end)

RegisterServerEvent('vending:attemptRobbery')
AddEventHandler('vending:attemptRobbery', function(configKey)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local T = Config.Translations

    if not xPlayer then return end
    local vendingConfig = Config.VendingMachines[configKey]
    local notifyTitle = vendingConfig and vendingConfig.label or T.vendingMachineDefaultTitle

    if not vendingConfig then
        TriggerClientEvent('ox_lib:notify', src, { title = T.errorTitle, description = T.serverErrorMachineNotFoundServer, type = 'error' })
        return
    end

    if not vendingConfig.enableRobbery then
        TriggerClientEvent('ox_lib:notify', src, { title = notifyTitle, description = T.robberyNotAllowed, type = 'error' })
        return
    end

    local currentTime = os.time()
    local cooldownEnd = VendingMachineRobberyCooldowns[configKey] or 0
    if currentTime < cooldownEnd then
        TriggerClientEvent('ox_lib:notify', src, { title = notifyTitle, description = T.robberyOnCooldown, type = 'warning' })
        return
    end

    -- Server-side kontrola a odebrání itemu
    if vendingConfig.robberyItemNeeded then
        local itemCount = xPlayer.getInventoryItem(vendingConfig.robberyItemNeeded)
        if not itemCount or itemCount.count <= 0 then
            TriggerClientEvent('ox_lib:notify', src, { title = notifyTitle, description = string.format(T.robberyItemMissing, ESX.GetItemLabel(vendingConfig.robberyItemNeeded) or vendingConfig.robberyItemNeeded), type = 'error' })
            return 
        end
        xPlayer.removeInventoryItem(vendingConfig.robberyItemNeeded, 1)
    end
    
    TriggerClientEvent('vending:startRobberyMinigame', src, configKey)
end)

RegisterServerEvent('vending:robberyMinigameResult')
AddEventHandler('vending:robberyMinigameResult', function(configKey, success)
    local src = source
    local xPlayer = ESX.GetPlayerFromId(src)
    local T = Config.Translations

    if not xPlayer then return end
    local vendingConfig = Config.VendingMachines[configKey]
    local notifyTitle = vendingConfig and vendingConfig.label or T.vendingMachineDefaultTitle

    if not vendingConfig then
        TriggerClientEvent('ox_lib:notify', src, { title = T.errorTitle, description = T.serverErrorMachineNotFoundServer, type = 'error' })
        return
    end

    if success then
        local moneyGained = math.random(vendingConfig.robberyMoneyMin or 10, vendingConfig.robberyMoneyMax or 50)
        xPlayer.addMoney(moneyGained)
        
        local cooldownDurationSeconds = (vendingConfig.robberyCooldownMinutes or 5) * 60
        VendingMachineRobberyCooldowns[configKey] = os.time() + cooldownDurationSeconds

        TriggerClientEvent('ox_lib:notify', src, { title = notifyTitle, description = string.format(T.robberySuccess, moneyGained), type = 'success' })
    else
        TriggerClientEvent('ox_lib:notify', src, { title = notifyTitle, description = T.robberyFailed, type = 'error' })

    end
end)
