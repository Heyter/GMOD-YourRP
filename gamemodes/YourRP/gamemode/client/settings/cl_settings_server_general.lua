//Copyright (C) 2017 Arno Zura ( https://www.gnu.org/licenses/gpl.txt )

//cl_settings_server_general.lua

local _advertname = "NULL"
local _restartTime = 0
function tabServerGeneral( sheet )
  local ply = LocalPlayer()

  local sv_generalPanel = vgui.Create( "DPanel", sheet )
  sheet:AddSheet( lang.general, sv_generalPanel, "icon16/server_database.png" )

  local sv_generalName = vgui.Create( "DTextEntry", sv_generalPanel )
  local sv_generalAdvert = vgui.Create( "DTextEntry", sv_generalPanel )

  local oldGamemodename = ""
  function sv_generalPanel:Paint()
    //draw.RoundedBox( 0, 0, 0, sv_generalPanel:GetWide(), sv_generalPanel:GetTall(), yrp.colors.panel )
    draw.SimpleText( lang.gamemodename .. ":", "SettingsNormal", ctrW( 300 - 10 ), ctrW( 5 + 25 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
    if oldGamemodename != sv_generalName:GetText() then
      draw.SimpleText( "you need to update Server!", "SettingsNormal", ctrW( 300 + 400 + 10 ), ctrW( 5 + 25 ), Color( 255, 0, 0, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )
    end
    draw.SimpleText( lang.advertname .. ":", "SettingsNormal", ctrW( 300 - 10 ), ctrW( 5 + 25 + 50 + 10 + 50 + 10 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )
  end

  sv_generalName:SetPos( ctrW( 300 ), ctrW( 5 ) )
  sv_generalName:SetSize( ctrW( 400 ), ctrW( 50 ) )
  sv_generalName:SetText( GAMEMODE.Name )

  net.Start("dbGetGeneral")
  net.SendToServer()

  net.Receive( "dbGetGeneral", function()
    local tmpTable = net.ReadTable()
    for k, v in pairs( tmpTable ) do
      if v.name == "gamemodename" then
        GAMEMODE.Name = v.value
        oldGamemodename = v.value
        if sv_generalName != nil then
          sv_generalName:SetText( GAMEMODE.Name )
        end
      elseif v.name == "advert" then
        _advertname = v.value
        if sv_generalAdvert != nil and _advertname != nil then
          sv_generalAdvert:SetText( tostring( _advertname ) )
        end
      end
    end
  end)

  sv_generalAdvert:SetPos( ctrW( 300 ), ctrW( 5 + 50 + 10 + 50 + 10 ) )
  sv_generalAdvert:SetSize( ctrW( 400 ), ctrW( 50 ) )
  sv_generalAdvert:SetText( _advertname )
  function sv_generalAdvert:OnChange()
    net.Start( "updateAdvert" )
      net.WriteString( sv_generalAdvert:GetText() )
    net.SendToServer()
  end

  local sv_generalRestartTime = vgui.Create( "DNumSlider", sv_generalPanel )
  sv_generalRestartTime:SetPos( ctrW( 10 ), ctrW( 5 + 50 + 10 + 50 + 10 + 50 + 10 ) )
  sv_generalRestartTime:SetSize( ctrW( 1800 ), ctrW( 50 ) )
  sv_generalRestartTime:SetText( lang.updatecountdown )
  sv_generalRestartTime:SetMin( 3 )
  sv_generalRestartTime:SetMax( 60 )
  sv_generalRestartTime:SetDecimals( 0 )
  net.Start( "selectGeneral" )
    net.WriteString( "restart_time" )
  net.SendToServer()
  net.Receive( "selectGeneral", function()
    local tmp = net.ReadString()
    if tmp == "restart_time" then
      if sv_generalRestartTime != nil then
        local _restartTime = tonumber( net.ReadString() )
        if _restartTime != nil then
          sv_generalRestartTime:SetValue( _restartTime )
        end
      end
    end
  end)
  function sv_generalRestartTime:OnValueChanged( value )
    net.Start( "updateGeneral" )
      net.WriteString( tostring( math.Round( value ) ) )
      net.WriteString( "restart_time" )
    net.SendToServer()
  end

  local sv_generalRestartServer = vgui.Create( "DButton", sv_generalPanel )
  sv_generalRestartServer:SetSize( ctrW( 400 ), ctrW( 50 ) )
  sv_generalRestartServer:SetPos( ctrW( 5 ), ctrW( 5 + 50 + 10 + 50 + 10 + 50 + 10 + 50 + 10 ) )
  sv_generalRestartServer:SetText( lang.updateserver )
  function sv_generalRestartServer:Paint()
    local color = Color( 255, 0, 0, 200 )
    if sv_generalRestartServer:IsHovered() then
      color = Color( 255, 255, 0, 200 )
    end
    draw.RoundedBox( ctrW( 10 ), 0, 0, sv_generalRestartServer:GetWide(), sv_generalRestartServer:GetTall(), color )
  end
  function sv_generalRestartServer:DoClick()
    if sv_generalName != nil then
      net.Start( "restartServer" )
        GAMEMODE.Name = sv_generalName:GetText()
        net.WriteString( GAMEMODE.Name )
        net.WriteInt( math.Round( sv_generalRestartTime:GetValue() ), 16 )
      net.SendToServer()
    end
    settingsWindow:Close()
  end

  local sv_generalRestartServerCancel = vgui.Create( "DButton", sv_generalPanel )
  sv_generalRestartServerCancel:SetSize( ctrW( 400 ), ctrW( 50 ) )
  sv_generalRestartServerCancel:SetPos( ctrW( 5 + 400 + 10 ), ctrW( 5 + 50 + 10 + 50 + 10 + 50 + 10 + 50 + 10 ) )
  sv_generalRestartServerCancel:SetText( lang.cancelupdateserver )
  function sv_generalRestartServerCancel:Paint()
    local color = Color( 0, 255, 0, 200 )
    if sv_generalRestartServerCancel:IsHovered() then
      color = Color( 255, 255, 0, 200 )
    end
    draw.RoundedBox( ctrW( 10 ), 0, 0, sv_generalRestartServerCancel:GetWide(), sv_generalRestartServerCancel:GetTall(), color )
  end
  function sv_generalRestartServerCancel:DoClick()
    net.Start( "cancelRestartServer" )
    net.SendToServer()
    settingsWindow:Close()
  end

  local sv_generalHardReset = vgui.Create( "DButton", sv_generalPanel )
  sv_generalHardReset:SetSize( ctrW( 400 ), ctrW( 50 ) )
  sv_generalHardReset:SetPos( ctrW( 5 ), ctrW( 5 + 50 + 10 + 50 + 10 + 50 + 10 + 50 + 10 + 50 + 10 ) )
  sv_generalHardReset:SetText( lang.hardresetdatabase )
  function sv_generalHardReset:Paint( pw, ph )
    local color = Color( 255, 0, 0, 200 )
    if sv_generalHardReset:IsHovered() then
      color = Color( 255, 255, 0, 200 )
    end
    draw.RoundedBox( ctrW( 10 ), 0, 0, pw, ph, color )
  end
  function sv_generalHardReset:DoClick()
    local _tmpFrame = createVGUI( "DFrame", nil, 630, 110, 0, 0 )
    _tmpFrame:Center()
    _tmpFrame:SetTitle( lang.areyousure )
    function _tmpFrame:Paint( pw, ph )
      local color = Color( 0, 0, 0, 200 )
      draw.RoundedBox( ctrW( 10 ), 0, 0, pw, ph, color )
    end

    local sv_generalHardResetSure = vgui.Create( "DButton", _tmpFrame )
    sv_generalHardResetSure:SetSize( ctrW( 300 ), ctrW( 50 ) )
    sv_generalHardResetSure:SetPos( ctrW( 10 ), ctrW( 50 ) )
    sv_generalHardResetSure:SetText( lang.yes .. ": DELETE DATABASE" )
    function sv_generalHardResetSure:DoClick()
      net.Start( "hardresetdatabase" )
      net.SendToServer()
      _tmpFrame:Close()
    end
    function sv_generalHardResetSure:Paint( pw, ph )
      local color = Color( 255, 0, 0, 200 )
      if sv_generalHardResetSure:IsHovered() then
        color = Color( 255, 255, 0, 200 )
      end
      draw.RoundedBox( ctrW( 10 ), 0, 0, pw, ph, color )
    end

    local sv_generalHardResetNot = vgui.Create( "DButton", _tmpFrame )
    sv_generalHardResetNot:SetSize( ctrW( 300 ), ctrW( 50 ) )
    sv_generalHardResetNot:SetPos( ctrW( 10 + 300 + 10 ), ctrW( 50 ) )
    sv_generalHardResetNot:SetText( lang.no .. ": do nothing" )
    function sv_generalHardResetNot:DoClick()
      _tmpFrame:Close()
    end
    function sv_generalHardResetNot:Paint( pw, ph )
      local color = Color( 0, 255, 0, 200 )
      if sv_generalHardResetNot:IsHovered() then
        color = Color( 255, 255, 0, 200 )
      end
      draw.RoundedBox( ctrW( 10 ), 0, 0, pw, ph, color )
    end

    settingsWindow:Close()
    _tmpFrame:MakePopup()
  end
end
