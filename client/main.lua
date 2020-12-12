--- esx
ESX                           = nil
local PlayerData              = {}

Citizen.CreateThread(function ()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
        PlayerData = ESX.GetPlayerData()
    end
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

RegisterNetEvent('esx_criminalrecords:open')
AddEventHandler('esx_criminalrecords:open', function(closestPlayer)
    OpenCriminalRecords(closestPlayer)
end)

-----------------------------------------------------------
--== PUT THIS WHOLE CODE INTO POLICEJOB IN THE F6 MENU ==--
-----------------------------------------------------------

function OpenCriminalRecords(closestPlayer)
    ESX.TriggerServerCallback('esx_qalle_brottsregister:grab', function(crimes)

        local elements = {}

        table.insert(elements, {label = 'اضافه کردن سابقه جدید', value = 'crime'})
        table.insert(elements, {label = '----= سوابق =----', value = 'spacer'})

        for i=1, #crimes, 1 do
            table.insert(elements, {label = crimes[i].date .. ' - ' .. crimes[i].crime .. ' - توسط: ' .. crimes[i].author, value = crimes[i].crime, name = crimes[i].name})
        end


        ESX.UI.Menu.Open(
            'default', GetCurrentResourceName(), 'brottsregister',
            {
                title    = 'Criminalrecord',
                align = 	"right",
                elements = elements
            },
        function(data2, menu2)

            if data2.current.value == 'crime' then
                ESX.UI.Menu.Open(
                    'dialog', GetCurrentResourceName(), 'brottsregister_second',
                    {
                        title = 'سابقه'
                    },
                function(data3, menu3)
                    local crime = (data3.value)

                    if crime == tonumber(data3.value) then
                        exports.pNotify:SendNotification({text = "درخواست صحیح نیست.", type = "error", timeout = 4000})
                        menu3.close()               
                    else
                        menu2.close()
                        menu3.close()
                        TriggerServerEvent('esx_qalle_brottsregister:add', closestPlayer, crime)
                        exports.pNotify:SendNotification({text = "سابقه ثبت شد.", type = "success", timeout = 4000})
                        Citizen.Wait(100)
                        OpenCriminalRecords(closestPlayer)
                    end

                end,
            function(data3, menu3)
                menu3.close()
            end)
        else
            ESX.UI.Menu.Open(
                'default', GetCurrentResourceName(), 'remove_confirmation',
                    {
                    title    = 'آیا حذف شود؟',
                    align		= 'right',
                    elements = {
                        {label = 'بله', value = 'yes'},
                        {label = 'خیر', value = 'no'}
                    }
                },
            function(data3, menu3)

                if data3.current.value == 'yes' then
                    menu2.close()
                    menu3.close()
                    TriggerServerEvent('esx_qalle_brottsregister:remove', closestPlayer, data2.current.value)
                    exports.pNotify:SendNotification({text = "سابقه حذف شد.", type = "success", timeout = 4000})
                    Citizen.Wait(100)
                    OpenCriminalRecords(closestPlayer)
                else
                    menu3.close()
                end                         

                end,
            function(data3, menu3)
                menu3.close()
            end)                 
        end

        end,
        function(data2, menu2)
            menu2.close()
        end)

    end, closestPlayer)
end