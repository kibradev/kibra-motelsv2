Config = {}

Config.Support = "discord.gg/0resmon" or "https://discord.gg/kv3Q44xYWd"

SETUP_DOCUMENT_AND_DOWNLOAD_MAPS_FILES = "https://kibra.gitbook.io/kibra-docs/resources/kibra-motels-v2"

Config.PoliceJob = "police"

Config.MotelKeyItem = "motelkey" -- Room key Item

Config.AutomaticPaymentInstruction = true  -- If you activate this feature, the player will not be charged. Room rental fee is deducted from the player's bank. However, if there is not enough money in the bank account, the lease agreement is terminated.

---------------------------------------------------- IMPORTANT --------------------------------------------------------------
Config.Inventory = "ox" -- or "QBCore" [qs-inventory - qb-inventory and Metadata Supported All Inventorys]

Config.BillingSystem = "esx_billing" -- or "gks-phone" or "okokBilling" or  "esx_billing" (only esx) or qb-phone (only qbcore)
---------------------------------------------------- IMPORTANT --------------------------------------------------------------

Config.UIFixCommand = "uifix" -- Closes all UI screens that remain open on your screen.

Config.BillingLabel = "Motel Room Bill" -- When the Motel room rent invoice is issued to the player, the text that will appear as the title of the invoice.

Config.BillingCheckTime = 1800 -- This is the time period that determines how long the player will pay a motel room rent. You can type in seconds.

Config.PoliceJob = "police"

Config.PoliceRaid = true -- He lets the cops raid motel rooms.

Config.OpenDoorKey = "e" -- Keys to be opened by Motel Owner and police

Config.DefaultRoomRental = 100 -- Room rental price of derelict motels.

Config.MaximumRoomRentalPrice = 1000 -- The maximum amount of rent the Hotel Owner can make.

Config.ShowRoomNo = "showroomno" -- Command that makes all room numbers visible from afar when near the motel.

Config.StashSlots = 50 -- The maximum slot that the player can put in the hotel room.

Config.StashMaxWeight = 5000 -- The maximum weight level of the player's motel room storage.

Config.MotelBlips = true   -- Makes motels appear on the map.

Config.MotelDefaultMoney = 1000 -- Initial money given to the business after the motel business is purchased.

Config.MotelBuyPayment = "bank" -- or cash

Config.MotelRoomRentPayment = "bank" -- or cash

Config.MotelRoomKeyDuplicatePayment = "cash" -- or bank

Config.MotelRoomKeyDuplicateFee = 100 -- Key extraction fee.

Config.MultiMotel = true -- Allows a player to have multiple hotel rooms.

Config.MotelSalePriceRatio = 2 -- The fee reimbursed when the motel owner sells the business.

Config.UIControls = {
    ReceptionOpenKey = "[E]",
    ExitOpenKey = "[E]",
    ExitText = "Exit",
    ReceptionText = "Reception",
    AdminMenuText = "Boss Menu",
    WardrobeOpenKey = "[E]",
    WardrobeText = "Wardrobe"

}

Config.Controls = {
    ReceptionOpenKey = 38,
    ExitRoomKey = 38
}