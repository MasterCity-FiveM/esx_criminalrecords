ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_qalle_brottsregister:add')
AddEventHandler('esx_qalle_brottsregister:add', function(id, reason)
	ESX.RunCustomFunction("anti_ddos", source, 'esx_qalle_brottsregister:add', {id = id, reason = reason})
	local xPlayer = ESX.GetPlayerFromId(source)
	local tPlayer = ESX.GetPlayerFromId(id)
	
	if not xPlayer or not tPlayer or xPlayer.job.name ~= 'police' then
		return
	end
	
	local SourceName = GetPlayerName(source)
	
	local identifier = tPlayer.identifier
	local date = os.date("%Y-%m-%d")
	MySQL.Async.fetchAll(
		'SELECT firstname, lastname FROM users WHERE identifier = @identifier',{['@identifier'] = identifier},
		function(result)
			if result[1] ~= nil then
				MySQL.Async.execute('INSERT INTO qalle_brottsregister (identifier, firstname, lastname, dateofcrime, crime, author) VALUES (@identifier, @firstname, @lastname, @dateofcrime, @crime, @author)',
					{
					['@identifier']   = identifier,
					['@firstname']    = result[1].firstname,
					['@lastname']     = result[1].lastname,
					['@dateofcrime']  = date,
					['@crime']        = reason,
					['@author']        = SourceName,
					}
				)
		end
	end)
end)

function getIdentity(source)
  local identifier = GetPlayerIdentifiers(source)[1]
  local result = MySQL.Sync.fetchAll("SELECT * FROM users WHERE identifier = @identifier", {['@identifier'] = identifier})
  if result[1] ~= nil then
    local identity = result[1]

    return {
      identifier = identity['identifier'],
      firstname = identity['firstname'],
      lastname = identity['lastname'],
      dateofbirth = identity['dateofbirth'],
      sex = identity['sex'],
      height = identity['height']
    }
  else
    return nil
  end
end

--gets brottsregister
ESX.RegisterServerCallback('esx_qalle_brottsregister:grab', function(source, cb, target)
	ESX.RunCustomFunction("anti_ddos", source, 'esx_qalle_brottsregister:grab', {target = target})
	local xPlayer = ESX.GetPlayerFromId(source)
	local tPlayer = ESX.GetPlayerFromId(target)
		
	if not xPlayer or not tPlayer or xPlayer.job.name ~= 'police' then
		cb({})
		return
	end
	
	local identifier = tPlayer.identifier
	local name = getIdentity(target)
	MySQL.Async.fetchAll("SELECT identifier, firstname, lastname, dateofcrime, crime, author FROM `qalle_brottsregister` WHERE `identifier` = @identifier LIMIT 10",
	{
		['@identifier'] = identifier
	},
		function(result)
			if identifier ~= nil then
			local crime = {}

				for i=1, #result, 1 do
				table.insert(crime, {
				crime = result[i].crime,
				author = result[i].author,
				name = result[i].firstname .. ' - ' .. result[i].lastname,
				date = result[i].dateofcrime,
			})
			end
			cb(crime)
		end
	end)
end)

RegisterServerEvent('esx_qalle_brottsregister:remove')
AddEventHandler('esx_qalle_brottsregister:remove', function(id, crime)
	ESX.RunCustomFunction("anti_ddos", source, 'esx_qalle_brottsregister:remove', {id = id, crime = crime})
	local xPlayer = ESX.GetPlayerFromId(source)
	local tPlayer = ESX.GetPlayerFromId(id)
		
	if not xPlayer or not tPlayer or xPlayer.job.name ~= 'police' then
		return
	end
	
	local identifier = tPlayer.identifier
	MySQL.Async.fetchAll(
		'SELECT firstname FROM users WHERE identifier = @identifier',{['@identifier'] = identifier},
	function(result)
		if (result[1] ~= nil) then
			MySQL.Async.execute('DELETE FROM qalle_brottsregister WHERE identifier = @identifier AND crime = @crime',
				{
					['@identifier']    = identifier,
					['@crime']     = crime
				}
			)
		end
	end)
end)
