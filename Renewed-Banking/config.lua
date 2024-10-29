lib.locale()
Config = {
    -- Framework automatically detected
    -- QB, QBX, and ESX preconfigured edit the framework.lua to add functionality to other frameworks
    renewedMultiJob = false, -- QBCORE ONLY! https://github.com/Renewed-Scripts/qb-phone  
    progressbar = 'rectangle', -- circle or rectangle (Anything other than circle will default to rectangle)
    currency = 'USD', -- USD, EUR, GBP ect.....
    atms = {
        `prop_atm_01`,
        `prop_atm_02`,
        `prop_atm_03`,
        `prop_fleeca_atm`
    },
    locations = {
        [1] = { -- Pacific Standard
            coords = vector3(256.89, 226.87, 106.28),
        },
        [2] = {
            coords = vector3(314.1, -279.05, 54.17),
        },
        [3] = {
            coords = vector3(149.64, -1040.64, 29.37),
        },
        [4] = {
            coords = vector3(-350.89, -49.92, 49.04),
        },
        [5] = {
            coords = vector3(-1212.45, -330.62, 37.78),
        },
        [6] = {
            coords = vector3(-2962.58, 482.78, 15.7),
        },
        [7] = {
            coords = vector3(1175.0, 2706.8, 38.09),
        },
        [8] = { -- paleto
            coords = vector3(-110.02, 6469.04, 31.63),
        }
    }
}
