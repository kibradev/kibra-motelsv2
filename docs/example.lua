
Config.Motels = {
    --- TELEPORT MOTEL TABLE
    [1] = {
        Teleport = true, -- Mark *TRUE* if your hotel is Teleported. Otherwise mark *FALSE*.
        -----------------
        MotelName = "",
        Owner = "",
        SocietyMoney = 0,
        Blip = {BlipId = 475, Scale = 1.0, Color = 1}, -- Blip Settings
        MotelCenterCoord = vector3(958.29, -204.14, 73.11),  -- The coordinate of the motel's center point.
        RoomRentPrice = 0,
        SalePrice = 12000, -- The selling price of the motel.
        Reception = vector3(961.65, -193.82, 73.21),    -- The part where hotel rooms are purchased.
        MarkerColor = {r = 255, g = 255, b = 255, a = 255}, 
        EnterRoomCoord = vector4(-101.17, 1.71, 22.56, 256.05),
        Rooms = {
            [1] = {
                Owner = "",
                Password = "",
                Date = "",
                pData = {},
                ExitCoord = vector3(-101.32, 1.8, 22.56),
                DoorCoord = vector3(953.14, -196.58, 73.27), 
                StashCoord = vector3(-94.52, -0.6, 22.56),
                Wardrobe = vector3(-99.65, 1.6, 22.56),
                DoorLock = true,
                StashLock = true,
            },
        }
    }
}

----------------------------- MLO MOTEL TABLE ------------------------

Config.Motels = {
    --- TELEPORT MOTEL TABLE
    [1] = {
        Teleport = false, -- Mark *TRUE* if your hotel is Teleported. Otherwise mark *FALSE*.
        -----------------
        MotelName = "",
        Owner = "",
        Blip = {BlipId = 475, Scale = 1.0, Color = 2}, -- Blip Settings
        SocietyMoney = 0,
        MotelCenterCoord = vector3(323.87, -208.83, 54.09), -- The coordinate of the motel's center point.
        RoomRentPrice = 0,
        SalePrice = 12000, -- The selling price of the motel.
        AutoLock = true,
        DoorHash = -1156992775, -- If it's a Motel with an MLO, type the Hash of the Gate.
        Reception = vector3(324.79, -230.31, 54.22),  -- The part where hotel rooms are purchased.
        MarkerColor = {r = 255, g = 255, b = 255, a = 255},
        Rooms = {
            [1] = {
                Owner = "",
                Password = "",
                Date = "",
                pData = {},
                DoorCoord = vector3(307.32, -213.54, 54.22), 
                StashCoord = vector3(306.83, -208.62, 54.23), -- Stash Coord
                StashLock = true,
                Wardrobe = vector3(302.72, -206.84, 54.23) -- Clothe / Wardrobe
            },
        }
    }
}