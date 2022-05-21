Config = {}

Config.Cops = 1

Config.Door1 = 11
Config.Door2 = 12
Config.Door3 = 13

-- Thermite Minigame Settings
Config.ThermiteBlocks = 18
Config.ThermiteAttempts = 3
Config.ThermiteShow = 5
Config.ThermiteTime = 45

-- laptop mingame settings anything more than 6 blocks will look ugly
Config.LaptopTime = 8
Config.LaptopBlocks = 6
Config.LaptopRepeat = 5

Config.MarkedBagMin = 1
Config.MarkedBagMax = 5
Config.MarkedMin = 25000
Config.MarkedMax = 50000

Config.Time = 30 -- time in seconds for the bomb to explode 

Config.Explosion = {
    [1] = {
        x = 891.89,
        y = -2284.89,
        z = 32.44,
        h = 75.46,
        hit = false
    }   
}


Config.Trolleys = {
    [1] = {
        coords = vector3(888.44, -2287.37, 31.44), 
        h =  5.92,
        hit = false
    },
    [2] = {
        coords = vector3(885.67, -2286.2, 31.44), 
        h =  349.89,
        hit = false
    },
    [3] = {
        coords = vector3(883.89, -2282.42, 31.44), 
        h = 164.06,
        hit = false
    },
    [4] = {
        coords = vector3(881.89, -2284.64, 31.44), 
        h = 324.95,
        hit = false
    }
}

-- Guards 
Config['guards'] = {
    ['npcguards'] = {
        { coords = vector3(891.8, -2275.47, 32.44), heading = 81.91, model = 's_m_m_prisguard_01'},
        { coords = vector3(892.86, -2278.36, 32.44), heading = 81.91, model = 's_m_m_prisguard_01'},
        { coords = vector3(895.18, -2279.62, 32.44), heading = 81.91, model = 's_m_m_prisguard_01'},
        { coords = vector3(895.95, -2281.63, 32.44), heading = 81.91, model = 's_m_m_prisguard_01'},
        { coords = vector3(894.38, -2283.13, 32.44), heading = 10.64, model = 's_m_m_prisguard_01'},
        { coords = vector3(891.0, -2293.46, 32.44), heading = 346.05, model = 's_m_m_prisguard_01'},
        { coords = vector3(879.18, -2296.97, 32.44), heading = 346.05, model = 's_m_m_prisguard_01'},
        { coords = vector3(870.02, -2296.56, 32.44), heading = 275.60, model = 's_m_m_prisguard_01'},
        { coords = vector3(871.96, -2291.06, 32.44), heading = 275.60, model = 's_m_m_prisguard_01'},
        { coords = vector3(869.15, -2292.16, 32.44), heading = 275.60, model = 's_m_m_prisguard_01'},
    },
}