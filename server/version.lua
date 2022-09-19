local resource  = GetInvokingResource() or GetCurrentResourceName()
local script    = GetResourceMetadata(resource, 'scriptname', 0)
local version   = GetResourceMetadata(resource, 'version', 0)
local newversion

SetTimeout(1000, function()
    checkversion()
end)

function checkversion()
    PerformHttpRequest('http://213.238.172.182/index.php?sc='..script, function(errorCode, resultData, resultHeaders)
        if resultData ~= nil then
            newversion = resultData:gsub("\r", "")
            newversion = newversion:gsub("\n", "")
            newversion = string.sub(newversion, 4)
        
            if newversion == "nodata" then return end

            if newversion == "error" or newversion == "dontfind" then
                CreateThread(function()
                    while true do
                        print('^3This script could not be found. Please restore the script name or fxmanifest information.')
                        Wait(20 * 1000)
                    end
                end)
            else 
                if version == newversion then
                    print('^3You are using the latest version of the script. [Script: ^1'..script.. '^0 ^3Script version: ^1v'..version.. "^3]")
                else
                    CreateThread(function()
                        while true do
                            print('^3There is a new version of the script you are using. ^3You can get the new version via Kibra#9999 or discord.gg/0resmon discord. [Script: ^1'..script..'^3 Version: ^1v'..version.. "^3 New version: ^1v"..newversion.. "^3]")
                            Wait(60 * 1000)
                        end
                    end)
                end
            end
        else
            print('^3Don\'t control this script version. Have a problem. Try again now..')
            Wait(5000)
            checkversion()
        end
    end)
end

