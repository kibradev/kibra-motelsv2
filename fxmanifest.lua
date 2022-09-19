fx_version "adamant"

game "gta5"

author "Kibra"

version "1.1.4"

scriptname "kibra-motelsv2"

description "Creator by Kibra for 0Resmon"

client_scripts {"client/client.lua"}

server_scripts {'@oxmysql/lib/MySQL.lua', 'server/server.lua','server/wardrobe.lua', 'server/billing.lua', 'server/version.lua'}

shared_scripts {
    "config/config_main.lua", 
    "config/config_functions.lua",
    "config/config_motels.lua",
    "config/config_lang.lua"
}

ui_page "web/index.html"

escrow_ignore {
    "config/config_main.lua",
    "config/config_lang.lua",
    "config/config_main.lua",
    "config/config_functions.lua",
    "server/billing.lua",
    "wardrobe.lua",
    "docs/example.lua"
}

dependency '0r-core'

files {
    "web/index.html",
    "web/main.css",
    "web/stars.png",
    "web/main.js"
}

lua54 "yes"