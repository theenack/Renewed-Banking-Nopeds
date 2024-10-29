local isVisible = false
local progressBar = Config.progressbar == 'circle' and lib.progressCircle or lib.progressBar
PlayerPed = cache.ped

lib.onCache('ped', function(newPed)
	PlayerPed = newPed
end)

local function nuiHandler(val)
    isVisible = val
    SetNuiFocus(val, val)
end

local function openBankUI(isAtm)
    SendNUIMessage({action = 'setLoading', status = true})
    nuiHandler(true)
    lib.callback('renewed-banking:server:initalizeBanking', false, function(accounts)
        if not accounts then
            nuiHandler(false)
            lib.notify({title = locale('bank_name'), description = locale('loading_failed'), type = 'error'})
            return
        end
        SetTimeout(1000, function()
            SendNUIMessage({
                action = 'setVisible',
                status = isVisible,
                accounts = accounts,
                loading = false,
                atm = isAtm
            })
        end)
    end)
end

RegisterNetEvent('Renewed-Banking:client:openBankUI', function(data)
    local txt = data.atm and locale('open_atm') or locale('open_bank')
    TaskStartScenarioInPlace(PlayerPed, 'PROP_HUMAN_ATM', 0, true)
    if progressBar({
        label = txt,
        duration = math.random(3000,5000),
        position = 'bottom',
        useWhileDead = false,
        allowCuffed = false,
        allowFalling = false,
        canCancel = true,
        disable = {
            car = true,
            move = true,
            combat = true,
            mouse = false,
        }
    }) then
        openBankUI(data.atm)
        Wait(500)
        ClearPedTasksImmediately(PlayerPed)
    else
        ClearPedTasksImmediately(PlayerPed)
        lib.notify({title = locale('bank_name'), description = locale('canceled'), type = 'error'})
    end
end)

RegisterNUICallback('closeInterface', function(_, cb)
    nuiHandler(false)
    cb('ok')
end)

RegisterCommand('closeBankUI', function() nuiHandler(false) end, false)

local bankActions = {'deposit', 'withdraw', 'transfer'}
CreateThread(function ()
    for k=1, #bankActions do
        RegisterNUICallback(bankActions[k], function(data, cb)
            local newTransaction = lib.callback.await('Renewed-Banking:server:'..bankActions[k], false, data)
            cb(newTransaction)
        end)
    end
    
    -- Add target for ATMs
    exports.ox_target:addModel(Config.atms, {{
        name = 'renewed_banking_openui',
        event = 'Renewed-Banking:client:openBankUI',
        icon = 'fas fa-money-check',
        label = locale('view_bank'),
        atm = true,
        canInteract = function(_, distance)
            return distance < 2.5
        end
    }})

    -- Add target for specific bank locations
    for k, bank in pairs(Config.locations) do
        exports.ox_target:addBoxZone({
            coords = vector3(bank.coords.x, bank.coords.y, bank.coords.z),
            size = vec3(3.0, 3.0, 3.0),
            rotation = bank.rotation or 0,
            debug = false,
            options = {{
                name = 'renewed_banking_openui',
                event = 'Renewed-Banking:client:openBankUI',
                icon = 'fas fa-money-check',
                label = locale('view_bank'),
                atm = false,
                canInteract = function(_, distance)
                    return distance < 0.5
                end
            },{
                name = 'renewed_banking_accountmng',
                event = 'Renewed-Banking:client:accountManagmentMenu',
                icon = 'fas fa-money-check',
                label = locale('manage_bank'),
                atm = false,
                canInteract = function(_, distance)
                    return distance < 0.5
                end
            }},
            distance = 2.0
        })
         -- Add blips for each bank location
        local blip = AddBlipForCoord(bank.coords.x, bank.coords.y, bank.coords.z)
        SetBlipSprite(blip, 108)  -- Icon for bank (ATM = 277)
        SetBlipDisplay(blip, 4)   -- Show on both the minimap and map
        SetBlipScale(blip, 0.8)   -- Scale of the blip
        SetBlipColour(blip, 2)    -- Green color for banks
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString("Bank")
        EndTextCommandSetBlipName(blip)
    end
end)

-- Removed ped creation logic and replaced with location targets above

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end
    exports.ox_target:removeModel(Config.atms, {'renewed_banking_openui'})
    -- Remove bank location targets if needed
    for k, bank in pairs(Config.locations) do
        exports.ox_target:removeBoxZone('renewed_banking_openui')
    end
end)

RegisterNetEvent('Renewed-Banking:client:sendNotification', function(msg)
    if not msg then return end
    SendNUIMessage({
        action = 'notify',
        status = msg,
    })
end)

RegisterNetEvent('Renewed-Banking:client:viewAccountsMenu', function()
    TriggerServerEvent('Renewed-Banking:server:getPlayerAccounts')
end)
