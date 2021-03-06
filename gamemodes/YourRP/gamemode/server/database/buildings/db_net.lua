//Copyright (C) 2017 Arno Zura ( https://www.gnu.org/licenses/gpl.txt )

//db_net.lua

util.AddNetworkString( "getBuildingInfo")
util.AddNetworkString( "getBuildings" )
util.AddNetworkString( "changeBuildingName" )
util.AddNetworkString( "changeBuildingID" )
util.AddNetworkString( "changeBuildingPrice" )

util.AddNetworkString( "getBuildingGroups")

util.AddNetworkString( "setBuildingOwnerGroup" )

util.AddNetworkString( "buyBuilding" )
util.AddNetworkString( "removeOwner" )
util.AddNetworkString( "sellBuilding" )

util.AddNetworkString( "createKey" )
util.AddNetworkString( "resetKey" )

util.AddNetworkString( "lockDoor" )

function canLock( ent, nr )
  local _tmpTable = dbSelect( "yrp_" .. string.lower( game.GetMap() ) .. "_doors", "keynr", "buildingID = " .. ent:GetNWInt( "buildingID" ) )
  if _tmpTable != nil then
    if _tmpTable[1] != nil then
      if _tmpTable[1].keynr == nr then
        return true
      else
        return false
      end
    end
  end
  return false
end

function unlockDoor( ent, nr )
  if canLock( ent, nr ) then
    ent:Fire( "Unlock" )
    return true
  end
  return false
end

function lockDoor( ent, nr )
  if canLock( ent, nr ) then
    ent:Fire( "Lock", "", 0 )
    return true
  end
  return false
end

function createKey( ent, id )
  local _tmp = id
  _tmp = _tmp .. math.Round( math.Rand( 100000, 999999 ), 0 )
  ent.keynr = _tmp
  dbUpdate( "yrp_" .. string.lower( game.GetMap() ) .. "_doors", "keynr = " .. _tmp, "buildingID = " .. id )
  return _tmp
end

function getNumber( ent, id )
  if ent.keynr == nil then
    ent.keynr = createKey( ent, id )
  end
  return ent.keynr
end

net.Receive( "resetKey", function( len, ply )
  local _door = net.ReadEntity()
  local _tmpBuildingID = net.ReadInt( 16 )

  createKey( _door, _tmpBuildingID )
end)

net.Receive( "createKey", function( len, ply )
  local _door = net.ReadEntity()
  local _tmpBuildingID = net.ReadInt( 16 )

  local _keynr = -1
  for k, v in pairs( ply:GetWeapons() ) do
    if v.ClassName == "yrp_key" then
      _keynr = getNumber( _door, _tmpBuildingID )
      local _oldkeynrs = dbSelect( "yrp_players", "keynrs", "SteamID = '" .. ply:SteamID() .. "'" )
      local _tmpTable = string.Explode( ",", _oldkeynrs[1].keynrs )
      if !table.HasValue( _tmpTable, _keynr ) then
        v:AddKeyNr( _keynr )

        local _newkeynrs = ""
        for l, w in pairs( _tmpTable ) do
          if w != "" then
            _newkeynrs = _newkeynrs .. w
            _newkeynrs = _newkeynrs .. ","
          end
        end
        _newkeynrs = _newkeynrs .. _keynr
        dbUpdate( "yrp_players", "keynrs = '" .. _newkeynrs .. "'", "SteamID = '" .. ply:SteamID() .. "'" )
      else
        printGM( "note", "Key already exists")
      end
      break
    end
  end
end)

net.Receive( "removeOwner", function( len, ply )
  local _tmpBuildingID = net.ReadInt( 16 )
  local _tmpTable = dbSelect( "yrp_" .. string.lower( game.GetMap() ) .. "_buildings", "*", "uniqueID = '" .. _tmpBuildingID .. "'" )

  dbUpdate( "yrp_" .. string.lower( game.GetMap() ) .. "_buildings", "ownerSteamID = '', groupID = -1", "uniqueID = '" .. _tmpBuildingID .. "'" )

  local _tmpDoors = ents.FindByClass( "prop_door_rotating" )
  for k, v in pairs( _tmpDoors ) do
    if tonumber( v:GetNWInt( "buildingID" ) ) == tonumber( _tmpBuildingID ) then
      v:SetNWString( "owner", "" )
      v:SetNWString( "ownerGroup", "" )
      createKey( v, _tmpBuildingID )
    end
  end
  local _tmpFDoors = ents.FindByClass( "func_door" )
  for k, v in pairs( _tmpFDoors ) do
    if tonumber( v:GetNWInt( "buildingID" ) ) == tonumber( _tmpBuildingID ) then
      v:SetNWString( "owner", "" )
      v:SetNWString( "ownerGroup", "" )
      createKey( v, _tmpBuildingID )
    end
  end
  local _tmpFRDoors = ents.FindByClass( "func_door_rotating" )
  for k, v in pairs( _tmpFRDoors ) do
    if tonumber( v:GetNWInt( "buildingID" ) ) == tonumber( _tmpBuildingID ) then
      v:SetNWString( "owner", "" )
      v:SetNWString( "ownerGroup", "" )
      createKey( v, _tmpBuildingID )
    end
  end
end)

net.Receive( "sellBuilding", function( len, ply )
  local _tmpBuildingID = net.ReadInt( 16 )
  local _tmpTable = dbSelect( "yrp_" .. string.lower( game.GetMap() ) .. "_buildings", "*", "uniqueID = '" .. _tmpBuildingID .. "'" )

  dbUpdate( "yrp_" .. string.lower( game.GetMap() ) .. "_buildings", "ownerSteamID = '', groupID = -1", "uniqueID = '" .. _tmpBuildingID .. "'" )
  local _tmpDoors = ents.FindByClass( "prop_door_rotating" )

  for k, v in pairs( _tmpDoors ) do
    if tonumber( v:GetNWInt( "buildingID" ) ) == tonumber( _tmpBuildingID ) then
      v:SetNWString( "owner", "" )
      v:SetNWString( "ownerGroup", "" )
      createKey( v, _tmpBuildingID )
      v:Fire("Unlock")
      dbUpdate( "yrp_" .. string.lower( game.GetMap() ) .. "_doors", "keynr = -1", "buildingID = " .. tonumber( v:GetNWInt( "buildingID" ) ) )
    end
  end

  local _tmpFDoors = ents.FindByClass( "func_door" )

  for k, v in pairs( _tmpFDoors ) do
    if tonumber( v:GetNWInt( "buildingID" ) ) == tonumber( _tmpBuildingID ) then
      v:SetNWString( "owner", "" )
      v:SetNWString( "ownerGroup", "" )
      createKey( v, _tmpBuildingID )
      v:Fire("Unlock")
      dbUpdate( "yrp_" .. string.lower( game.GetMap() ) .. "_doors", "keynr = -1", "buildingID = " .. tonumber( v:GetNWInt( "buildingID" ) ) )
    end
  end

  local _tmpFRDoors = ents.FindByClass( "func_door_rotating" )

  for k, v in pairs( _tmpFRDoors ) do
    if tonumber( v:GetNWInt( "buildingID" ) ) == tonumber( _tmpBuildingID ) then
      v:SetNWString( "owner", "" )
      v:SetNWString( "ownerGroup", "" )
      createKey( v, _tmpBuildingID )
      v:Fire("Unlock")
      dbUpdate( "yrp_" .. string.lower( game.GetMap() ) .. "_doors", "keynr = -1", "buildingID = " .. tonumber( v:GetNWInt( "buildingID" ) ) )
    end
  end

  ply:addMoney( ( _tmpTable[1].price / 2 ) )
end)

net.Receive( "buyBuilding", function( len, ply )
  local _tmpBuildingID = net.ReadInt( 16 )
  local _tmpTable = dbSelect( "yrp_" .. string.lower( game.GetMap() ) .. "_buildings", "*", "uniqueID = '" .. _tmpBuildingID .. "'" )

  if ply:canAfford( _tmpTable[1].price ) and _tmpTable[1].ownerSteamID == "" and tonumber( _tmpTable[1].groupID ) == -1 then
    ply:addMoney( - ( _tmpTable[1].price ) )
    dbUpdate( "yrp_" .. string.lower( game.GetMap() ) .. "_buildings", "ownerSteamID = '" .. ply:SteamID() .. "'", "uniqueID = '" .. _tmpBuildingID .. "'" )
    local _tmpDoors = ents.FindByClass( "prop_door_rotating" )
    local _tmpPlys = dbSelect( "yrp_players", "nameSur, nameFirst", "steamID = '" .. ply:SteamID() .. "'" )
    for k, v in pairs( _tmpDoors ) do
      if tonumber( v:GetNWInt( "buildingID" ) ) == tonumber( _tmpBuildingID ) then
        v:SetNWString( "owner", _tmpPlys[1].nameSur .. ", " .. _tmpPlys[1].nameFirst )
      end
    end
    local _tmpFDoors = ents.FindByClass( "func_door" )
    for k, v in pairs( _tmpFDoors ) do
      if tonumber( v:GetNWInt( "buildingID" ) ) == tonumber( _tmpBuildingID ) then
        v:SetNWString( "owner", _tmpPlys[1].nameSur .. ", " .. _tmpPlys[1].nameFirst )
      end
    end
    local _tmpFRDoors = ents.FindByClass( "func_door_rotating" )
    for k, v in pairs( _tmpFRDoors ) do
      if tonumber( v:GetNWInt( "buildingID" ) ) == tonumber( _tmpBuildingID ) then
        v:SetNWString( "owner", _tmpPlys[1].nameSur .. ", " .. _tmpPlys[1].nameFirst )
      end
    end

    printGM( "user", ply:Nick() .. " has buyed a door")
  else
    printGM( "user", ply:Nick() .. " has not enough money to buy door")
  end
end)

net.Receive( "setBuildingOwnerGroup", function( len, ply )
  local _tmpBuildingID = net.ReadInt( 16 )
  local _tmpGroupID = net.ReadInt( 16 )

  dbUpdate( "yrp_" .. string.lower( game.GetMap() ) .. "_buildings", "groupID = " .. _tmpGroupID, "uniqueID = " .. _tmpBuildingID )

  local _tmpGroupName = dbSelect( "yrp_groups", "groupID", "uniqueID = " .. _tmpGroupID )
  local _tmpDoors = ents.FindByClass( "prop_door_rotating" )
  for k, v in pairs( _tmpDoors ) do
    if tonumber( v:GetNWInt( "buildingID" ) ) == tonumber( _tmpBuildingID ) then
      v:SetNWString( "ownerGroup", _tmpGroupName[1].groupID )
    end
  end
  local _tmpFDoors = ents.FindByClass( "func_door" )
  for k, v in pairs( _tmpFDoors ) do
    if tonumber( v:GetNWInt( "buildingID" ) ) == tonumber( _tmpBuildingID ) then
      v:SetNWString( "ownerGroup", _tmpGroupName[1].groupID )
    end
  end
  local _tmpFRDoors = ents.FindByClass( "func_door_rotating" )
  for k, v in pairs( _tmpFRDoors ) do
    if tonumber( v:GetNWInt( "buildingID" ) ) == tonumber( _tmpBuildingID ) then
      v:SetNWString( "ownerGroup", _tmpGroupName[1].groupID )
    end
  end
end)

net.Receive( "getBuildingGroups", function( len, ply )
  local _tmpTable = dbSelect( "yrp_groups", "*", nil )

  net.Start( "getBuildingGroups" )
    net.WriteTable( _tmpTable )
  net.Send( ply )
end)

net.Receive( "changeBuildingPrice", function( len, ply )
  local _tmpBuildingID = net.ReadInt( 16 )
  local _tmpNewPrice = net.ReadInt( 16 )

  dbUpdate( "yrp_" .. string.lower( game.GetMap() ) .. "_buildings", "price = " .. _tmpNewPrice , "uniqueID = " .. _tmpBuildingID )
end)


function hasDoors( id )
  local _allDoors = dbSelect( "yrp_" .. string.lower( game.GetMap() ) .. "_doors", "*", nil )
  for k, v in pairs( _allDoors ) do
    if tonumber( v.buildingID ) == tonumber( id ) then
      return true
    end
  end
  return false
end

function lookForEmptyBuildings()
  local _allBuildings = dbSelect( "yrp_" .. string.lower( game.GetMap() ) .. "_buildings", "*", nil )

  for k, v in pairs( _allBuildings ) do
    if !hasDoors( v.uniqueID ) then
      dbDeleteFrom( "yrp_" .. string.lower( game.GetMap() ) .. "_buildings", "uniqueID = " .. tonumber( v.uniqueID ) )
    end
  end
end

net.Receive( "changeBuildingID", function( len, ply )
  local _tmpDoor = net.ReadEntity()
  local _tmpBuildingID = net.ReadInt( 16 )

  _tmpDoor:SetNWInt( "buildingID", tonumber( _tmpBuildingID ) )
  dbUpdate( "yrp_" .. string.lower( game.GetMap() ) .. "_doors", "buildingID = " .. tonumber( _tmpBuildingID ) , "uniqueID = " .. _tmpDoor:GetNWInt( "uniqueID" ) )

  lookForEmptyBuildings()
end)

net.Receive( "changeBuildingName", function( len, ply )
  local _tmpBuildingID = net.ReadInt( 16 )
  local _tmpNewName = net.ReadString()
  if _tmpBuildingID != nil then
    printGM( "note", "renamed Building: " .. _tmpNewName )
    dbUpdate( "yrp_" .. string.lower( game.GetMap() ) .. "_buildings", "name = '" .. _tmpNewName .. "'" , "uniqueID = " .. _tmpBuildingID )
  else
    printGM( "note", "changeBuildingName failed" )
  end
end)

net.Receive( "getBuildings", function( len, ply )
  local _tmpTable = dbSelect( "yrp_" .. string.lower( game.GetMap() ) .. "_buildings", "*", nil )
  net.Start( "getBuildings" )
    net.WriteTable( _tmpTable )
  net.Send( ply )
end)

net.Receive( "getBuildingInfo", function( len, ply )
  local _tmpDoorID = net.ReadInt( 16 )
  local _tmpBuildingID = net.ReadInt( 16 )
  if _tmpBuildingID != nil then

    local _tmpTable = dbSelect( "yrp_" .. string.lower( game.GetMap() ) .. "_buildings", "*", "uniqueID = '" .. _tmpBuildingID .. "'" )
    if _tmpTable != nil then
      if allowedToUseDoor( _tmpBuildingID, ply ) then
        net.Start( "getBuildingInfo" )
          net.WriteBool( true )
          net.WriteInt( _tmpDoorID, 16 )
          net.WriteInt( _tmpBuildingID, 16 )
          net.WriteTable( _tmpTable )
        net.Send( ply )
      end
    else
      net.Start( "getBuildingInfo" )
        net.WriteBool( false )
      net.Send( ply )
    end
  end
end)
