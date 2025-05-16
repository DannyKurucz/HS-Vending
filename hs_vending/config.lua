Config = {}
Config.VendingMachines = {
    [`prop_vend_coffe_01`] = { -- Prop name 
        label = "Coffee Machine", -- Label of machine
        animation = {
            dict = "mini@sprunk", --Dict
            name = "plyr_buy_drink_pt1", --name anim
            time = 5000 -- Time for animation
        },
        items = {
            { item = "coffee", label = "Coffee", price = 5, type = "item" }, -- You can add many items you want
            { item = "hot_chocolate", label = "Hot Chocolate", price = 7, type = "item" }
        },
        enableRobbery = true, -- Enable robbery for this vending machine
        robberyItemNeeded = "lockpick", -- require item - Lockpick or your mom :D
        robberyMoneyMin = 20, -- you can get min 20 dollars
        robberyMoneyMax = 80, -- to max 80 dollars its random 
        robberyCooldownMinutes = 5 -- CoolDown
    },
    [`prop_vend_soda_01`] = {
        label = "Soda Machine",
        animation = {
            dict = "mini@sprunk",
            name = "plyr_buy_drink_pt1",
            time = 5000
        },
        items = {
            { item = "cola", label = "Cola", price = 3, type = "item" },
            { item = "sprunk", label = "Sprunk", price = 3, type = "item" }
        },
        enableRobbery = true,
        robberyItemNeeded = "lockpick", 
        robberyMoneyMin = 20,
        robberyMoneyMax = 80,
        robberyCooldownMinutes = 5 
    },
    [`prop_vend_soda_02`] = {
        label = "Soda Machine",
        animation = {
            dict = "mini@sprunk",
            name = "plyr_buy_drink_pt1",
            time = 5000
        },
        items = {
            { item = "cola", label = "Cola", price = 3, type = "item" },
            { item = "sprunk", label = "Sprunk", price = 3, type = "item" }
        },
        enableRobbery = true,
        robberyItemNeeded = "lockpick", 
        robberyMoneyMin = 20,
        robberyMoneyMax = 80,
        robberyCooldownMinutes = 5 
    },
    [`prop_vend_snak_01`] = {
        label = "Snack Machine",
        animation = {
            dict = "mini@sprunk",
            name = "plyr_buy_drink_pt1",
            time = 5000
        },
        items = {
            { item = "burger", label = "Burger", price = 3, type = "item" },
        },
        enableRobbery = true,
        robberyItemNeeded = "lockpick", 
        robberyMoneyMin = 20,
        robberyMoneyMax = 80,
        robberyCooldownMinutes = 5 
    },
    [`prop_watercooler`] = {
        label = "Water Cooler",
        animation = {
            dict = "anim@amb@nightclub@mini@drinking@drinking_shots@ped_b@normal",
            name = "pickup",
            time = 3000
        },
        items = {
            { item = "water", label = "Water", price = 0, type = "item" },
        },
        enableRobbery = false,
        robberyItemNeeded = "lockpick", 
        robberyMoneyMin = 20,
        robberyMoneyMax = 80,
        robberyCooldownMinutes = 5 -- Cooldown in min
    }

    -- Add more vending machine models as needed
}

Config.Translations = {
    vendingMachineDefaultTitle = "Vending Machine", 
    errorTitle = "Error", 
    paymentCash = "cash",
    paymentBank = "bank",

    clientErrorConfigNotFound = "Error: Vending machine configuration not found.",
    clientErrorItemSelection = "Error selecting item.",
    clientInputDialogAmountTitle = "Enter Amount",
    clientInputDialogAmountLabel = "Quantity",
    clientInputDialogAmountDesc = "How many do you want to buy?",
    clientErrorInvalidAmount = "Invalid amount.",
    clientErrorMaxAmount = "You can buy a maximum of %s items at once.",
    clientInputDialogPaymentTitle = "Choose Payment Method",
    clientInputDialogPaymentLabel = "Payment Method",
    clientPaymentCashLabel = "Cash",
    clientPaymentBankLabel = "Bank Account",
    clientTargetUseLabel = "Use %s", 
    clientDescriptionlabel = "Price for one: %s$",
    clientTargetRobLabel = "Robbery %s", 

    robberyNeedsItem = "You need: %s to start the robbery.",
    robberyMinigameStarting = "You're trying to pick the lock...",
    robberyInProgress = "Robbery in progress...",

    serverErrorInvalidIdentifierType = "Vending machine error (invalid identifier type).",
    serverErrorInvalidItemName = "Item error (invalid name).",
    serverErrorInvalidPrice = "Item error (invalid price).",
    serverErrorInvalidAmount = "Invalid amount.", 
    serverErrorInvalidPaymentMethod = "Invalid payment method.",
    serverErrorMachineNotFoundServer = "Vending machine error (non-existent model on server).",
    serverErrorPriceMismatch = "Transaction error (price mismatch).",
    serverErrorItemNotFoundOrPrice = "Item not found in vending machine or price error.",
    serverPurchaseSuccess = "Purchased: %sx %s for $%s (%s)",
    serverErrorInventoryFull = "You do not have enough inventory space.",
    serverErrorInsufficientFunds = "Insufficient funds. Needed: $%s, You have: $%s (%s)",

    robberyNotAllowed = "This vending machine cannot be robbed.",
    robberyItemMissing = "You don't have %s to complete the action.",
    robberyOnCooldown = "This vending machine was recently robbed. Try again later.",
    robberyFailed = "Robbery failed.",
    robberySuccess = "You successfully robbed the vending machine and gained $%s.",
    robberySkillCheckTitle = "Lockpicking"
}
