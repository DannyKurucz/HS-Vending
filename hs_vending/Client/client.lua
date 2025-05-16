ESX = exports['es_extended']:getSharedObject()
local T = Config.Translations -- Zkratka pro překlady na klientovi

local function playVendingAnim(configKey, targetEntity)
    local animConfig = Config.VendingMachines[configKey] and Config.VendingMachines[configKey].animation
    if not animConfig then return end
    local playerPed = PlayerPedId()
    if targetEntity and DoesEntityExist(targetEntity) then
        local playerCoords, targetCoords = GetEntityCoords(playerPed), GetEntityCoords(targetEntity)
        SetEntityHeading(playerPed, GetHeadingFromVector_2d(targetCoords.x - playerCoords.x, targetCoords.y - playerCoords.y))
        Wait(150)
    end
    FreezeEntityPosition(playerPed, true)
    RequestAnimDict(animConfig.dict)
    while not HasAnimDictLoaded(animConfig.dict) do Wait(10) end
    TaskPlayAnim(playerPed, animConfig.dict, animConfig.name, 8.0, -8.0, animConfig.time or 3000, 49, 0, false, false, false)
    Wait(animConfig.time or 3000)
    ClearPedTasks(playerPed)
    FreezeEntityPosition(playerPed, false)
end

local function playRobberyAnim(configKey, targetEntity)
    local playerPed = PlayerPedId()
    if targetEntity and DoesEntityExist(targetEntity) then
        local playerCoords, targetCoords = GetEntityCoords(playerPed), GetEntityCoords(targetEntity)
        SetEntityHeading(playerPed, GetHeadingFromVector_2d(targetCoords.x - playerCoords.x, targetCoords.y - playerCoords.y))
        Wait(150)
    end
    RequestAnimDict("missheistfbi3b_ig8_2")
    while not HasAnimDictLoaded("missheistfbi3b_ig8_2") do Wait(10) end
    TaskPlayAnim(playerPed, "missheistfbi3b_ig8_2", "lift_up_cop", 8.0, -8.0, 2000, 0, 0, false, false, false)
end


local function createVendingMenu(configKey, targetEntity)
    local vendingConfig = Config.VendingMachines[configKey]
    if not vendingConfig then ESX.ShowNotification(T.clientErrorConfigNotFound); return end

    local options = {}
    for _, itemEntry in ipairs(vendingConfig.items) do
        table.insert(options, {
            title = itemEntry.label,
            description = (T.clientDescriptionlabel):format(itemEntry.price),
            icon = "shopping-cart",
            args = { itemKey = itemEntry.item, itemPrice = itemEntry.price },
            onSelect = function(args_data)
                local selectedItemKey = args_data.itemKey 
                local selectedItemPrice = args_data.itemPrice
                if not selectedItemKey then ESX.ShowNotification(T.clientErrorItemSelection); return end

                local inputAmount = lib.inputDialog(T.clientInputDialogAmountTitle, {
                    { type = 'number', label = T.clientInputDialogAmountLabel, description = T.clientInputDialogAmountDesc, default = 1, min = 1, max = 100 }
                })
                if inputAmount and inputAmount[1] then
                    local count = math.floor(tonumber(inputAmount[1]))
                    if count <= 0 then ESX.ShowNotification(T.clientErrorInvalidAmount); return end
                    if count > 100 then ESX.ShowNotification(string.format(T.clientErrorMaxAmount, 100)); return end
                    
                    local paymentDialog = lib.inputDialog(T.clientInputDialogPaymentTitle, {
                        { type = 'select', label = T.clientInputDialogPaymentLabel, options = {
                            { label = T.clientPaymentCashLabel, value = 'cash' },
                            { label = T.clientPaymentBankLabel, value = 'bank' }
                        }}
                    })
                    if paymentDialog and paymentDialog[1] then
                        TriggerServerEvent('vending:buyItem', configKey, selectedItemKey, selectedItemPrice, count, paymentDialog[1])
                        playVendingAnim(configKey, targetEntity)
                    end
                end
            end
        })
    end
    lib.registerContext({ id = 'vending_menu_' .. tostring(configKey), title = vendingConfig.label, options = options })
    lib.showContext('vending_menu_' .. tostring(configKey))
end

CreateThread(function()
    if not Config or not Config.VendingMachines or not Config.Translations then return end

    for configTableKey, vendingData in pairs(Config.VendingMachines) do
        local modelHashForOxTarget
        local isValidKeyForTarget = true
        if type(configTableKey) == "string" then
            modelHashForOxTarget = GetHashKey(configTableKey)
        elseif type(configTableKey) == "number" then
            modelHashForOxTarget = configTableKey 
        else
            isValidKeyForTarget = false
        end

        if isValidKeyForTarget then
            local targetOptions = {
                {
                    name = 'buy_from_vending_' .. tostring(configTableKey), 
                    label = string.format(T.clientTargetUseLabel, vendingData.label),
                    icon = 'fa-solid fa-cart-shopping',
                    onSelect = function(data_ox_target)
                        if not Config.VendingMachines[configTableKey] then
                            ESX.ShowNotification(T.clientErrorConfigNotFound .. " (Admin)")
                            return
                        end
                        local targetEntity = (data_ox_target and type(data_ox_target) == "table") and data_ox_target.entity or nil
                        createVendingMenu(configTableKey, targetEntity) 
                    end,
                    distance = 2.0
                }
            }

            if vendingData.enableRobbery then
                table.insert(targetOptions, {
                    name = 'rob_vending_' .. tostring(configTableKey),
                    label = string.format(T.clientTargetRobLabel, vendingData.label),
                    icon = 'fa-solid fa-mask', 
                    onSelect = function(data_ox_target)
                        local targetEntity = (data_ox_target and type(data_ox_target) == "table") and data_ox_target.entity or nil
                        playRobberyAnim(configTableKey, targetEntity) 

                        TriggerServerEvent('vending:attemptRobbery', configTableKey)
                    end,
                    distance = 2.0
                })
            end
            exports.ox_target:addModel(modelHashForOxTarget, targetOptions)
        end
    end
end)

RegisterNetEvent('vending:startRobberyMinigame', function(configKey)
    local vendingConfig = Config.VendingMachines[configKey]
    if not vendingConfig then return end

    local success = lib.skillCheck({'easy', 'easy', 'medium'}, {'e', 'r', 't'})
    
    TriggerServerEvent('vending:robberyMinigameResult', configKey, success)
end)