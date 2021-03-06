//Copyright (C) 2017 Arno Zura ( https://www.gnu.org/licenses/gpl.txt )

//cl_settings_client_hud.lua

function createDerma( art, parent, w, h, x, y )
  tmpDerma = vgui.Create( art, parent )
  tmpDerma:SetSize( ctrW(w), ctrW(h) )
  tmpDerma:SetPos( ctrW(x), ctrW(y) )
  return tmpDerma
end

function changeHudElement( parent, tmpx, tmpy, tmpw, tmph, tmpt, textPre )
  local ply = LocalPlayer()
  local frame = createDerma( "DFrame", parent, cl_db[tmpw], cl_db[tmph], cl_db[tmpx], cl_db[tmpy] )
  frame:SetTitle( "" )
  frame:ShowCloseButton( false )
  frame:SetSizable( true )
  frame:SetMinHeight( ctrW( 40 ) )
  frame:SetMinWidth( ctrW( 200 ) )

  function frame:Paint( pw, ph )
    draw.RoundedBox( 0, 0, 0, pw, ph, Color( 0, 0, 0, 120 ) )
    draw.RoundedBox( 0, 0, 0, pw, ctrH( 50 ), Color( 0, 0, 255, 200 ) )

    draw.RoundedBox( 0, pw - ctrW( 20 ), ph - ctrH( 20 ), ctrW( 20 ), ctrH( 20 ), Color( 0, 255, 0, 200 ) )

    drawText( textPre, "HudBars", pw, ph, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    if frame:IsHovered() then

      local tw, th = frame:GetSize()
      if tw != ctrW( cl_db[tmpw] ) or th != ctrW( cl_db[tmph] ) then
        cl_db[tmpw] = (tw*ctrF( ScrH() )) - (tw*ctrF( ScrH() ))%ctrW( 40 )
        cl_db[tmph] = (th*ctrF( ScrH() )) - (th*ctrF( ScrH() ))%ctrH( 40 )
        frame:SetSize( ctrW( cl_db[tmpw] ), ctrW( cl_db[tmph] ) )
        updateDBHud( tmpw, cl_db[tmpw] )
        updateDBHud( tmph, cl_db[tmph] )
      end

      local x, y = frame:GetPos()
      if x != ctrW( cl_db[tmpx] ) or y != ctrW( cl_db[tmpy] ) then
        local w, h = frame:GetSize()
        local outside = false
        if x+w > ScrW() then
          frame:SetPos( ScrW()-w, y )
          outside = true
        elseif y+h > ScrH() then
          frame:SetPos( x, ScrH()-h )
          outside = true
        elseif x < 0 then
          frame:SetPos( 0, y )
          outside = true
        elseif y < 0 then
          frame:SetPos( x, 0 )
          outside = true
        end
        if !outside then
          cl_db[tmpx] = ( x*ctrF( ScrH() ) ) - ( ( x*ctrF( ScrH() ) )%ctrW( 40 ) )
          cl_db[tmpy] = ( y*ctrF( ScrH() ) ) - ( ( y*ctrF( ScrH() ) )%ctrH( 40 ) )

          frame:SetPos( ctrW( cl_db[tmpx] ), ctrW( cl_db[tmpy] ) )
          updateDBHud( tmpx, cl_db[tmpx] )
          updateDBHud( tmpy, cl_db[tmpy] )
        end
      end
    end
  end

  local tmpToggle = createDerma( "DCheckBox", frame, 30, 30, 10, 10 )
  local tmpToggleChecked = -1
  if tonumber( cl_db[tmpt] ) == 0 then
    tmpToggleChecked = false
  elseif tonumber( cl_db[tmpt] ) == 1 then
    tmpToggleChecked = true
  end
  tmpToggle:SetChecked( tmpToggleChecked )
  function tmpToggle:OnChange( bVal )
  	if ( bVal ) then
      cl_db[tmpt] = 1
  		updateDBHud( tmpt, cl_db[tmpt] )
  	else
      cl_db[tmpt] = 0
  		updateDBHud( tmpt, cl_db[tmpt] )
  	end
  end
end

function tabClientHud( sheet )
  local ply = LocalPlayer()

  local cl_hudPanel = vgui.Create( "DPanel", sheet )
  sheet:AddSheet( lang.hud, cl_hudPanel, "icon16/photo.png" )
  function cl_hudPanel:Paint( w, h )
    //draw.RoundedBox( 0, 0, 0, sv_generalPanel:GetWide(), sv_generalPanel:GetTall(), yrp.colors.panel )
  end

  local changeHudButton = createDerma( "DButton", cl_hudPanel, 470, 50, 0, 0 )
  changeHudButton:SetText( lang.changehud )
  function changeHudButton:DoClick()
    settingsWindow:Close()

    local changeHudWindow = createDerma( "DFrame", nil, ScrW() * ctrF( ScrH() ), ScrH() * ctrF( ScrH() ), 0, 0 )
    changeHudWindow:SetDraggable( false )
    changeHudWindow:SetTitle( "" )
    changeHudWindow:ShowCloseButton( false )
    function changeHudWindow:Paint( w, h )
      local gridSize = ctrW( 20 )
      draw.RoundedBox( 0, 0, 0, ScrW(), ScrH(), Color( 0, 0, 0, 120 ) )
      for i=1, ScrW()/gridSize do
        if i%(ScrW()/gridSize/2) == 0 then
          draw.RoundedBox( 0, (i*gridSize)-ctrW( 2 ), 0, ctrW( 4 ), ScrH(), Color( 255, 255, 0, 60 ) )
        elseif i%10 == 1 then
            draw.RoundedBox( 0, (i*gridSize)-ctrW( 2 ), 0, ctrW( 4 ), ScrH(), Color( 0, 0, 255, 50 ) )
        else
          draw.RoundedBox( 0, (i*gridSize)-ctrW( 2 ), 0, ctrW( 4 ), ScrH(), Color( 255, 255, 255, 20 ) )
        end
      end

      for i=1, ScrH()/gridSize do
        if i%(ScrH()/gridSize/2) == 0 then
          draw.RoundedBox( 0, 0, (i*gridSize)-2, ScrW(), ctrW( 4 ), Color( 255, 255, 0, 60 ) )
        elseif i%10 == 9 then
          draw.RoundedBox( 0, 0, (i*gridSize)-2, ScrW(), ctrW( 4 ), Color( 0, 0, 255, 50 ) )
        else
          draw.RoundedBox( 0, 0, (i*gridSize)-2, ScrW(), ctrW( 4 ), Color( 255, 255, 255, 20 ) )
        end
      end
    end

    local changeHudWindowCloseButton = createDerma( "DButton", changeHudWindow, ScrW() * ctrF( ScrH() ), ScrH() * ctrF( ScrH() ), 0, 0 )
    changeHudWindowCloseButton:SetText( "" )
    function changeHudWindowCloseButton:DoClick()
      changeHudWindow:Close()
    end
    function changeHudWindowCloseButton:Paint( pw, ph )
      draw.SimpleText( lang.helpclose, "HudBars", pw/2, ph/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

      draw.SimpleText( lang.helpmove, "HudBars", pw/2, ph/2+20, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
      draw.SimpleText( lang.helpresize, "HudBars", pw/2, ph/2+40, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
    end

    changeHudElement( changeHudWindow, "mmx", "mmy", "mmw", "mmh", "mmt", lang.minimap )
    changeHudElement( changeHudWindow, "hpx", "hpy", "hpw", "hph", "hpt", lang.health )
    changeHudElement( changeHudWindow, "arx", "ary", "arw", "arh", "art", lang.armor )
    changeHudElement( changeHudWindow, "wnx", "wny", "wnw", "wnh", "wnt", lang.wname )
    changeHudElement( changeHudWindow, "wpx", "wpy", "wpw", "wph", "wpt", lang.wprimary )
    changeHudElement( changeHudWindow, "wsx", "wsy", "wsw", "wsh", "wst", lang.wsecondary )
    changeHudElement( changeHudWindow, "rix", "riy", "riw", "rih", "rit", lang.role )
    changeHudElement( changeHudWindow, "ttx", "tty", "ttw", "tth", "ttt", lang.tooltip )
    changeHudElement( changeHudWindow, "mox", "moy", "mow", "moh", "mot", lang.money )

    changeHudWindow:MakePopup()
  end

  function testIf( question, atrue, afalse )
    if question == 1 then
      return atrue
    else
      return afalse
    end
  end

  local toggleHud = createVGUI( "DButton", cl_hudPanel, 470, 50, 0, 50 + 10 )
  toggleHud:SetText( lang.togglehud .. " (" .. testIf( GetConVar( "yrp_cl_hud" ):GetInt(), lang.on, lang.off ) .. ")" )
  function toggleHud:DoClick()
    if GetConVar( "yrp_cl_hud" ):GetInt() == 1 then
      GetConVar( "yrp_cl_hud" ):SetInt( 0 )
    elseif GetConVar( "yrp_cl_hud" ):GetInt() == 0 then
      GetConVar( "yrp_cl_hud" ):SetInt( 1 )
    end
    toggleHud:SetText( lang.togglehud .. " (" .. testIf( GetConVar( "yrp_cl_hud" ):GetInt(), lang.on, lang.off ) .. ")" )
  end

  local resetHudButton = createDerma( "DColorButton", cl_hudPanel, 470, 50, 470 + 10, 50 + 10 )
  resetHudButton:SetText( "" )
  function resetHudButton:Paint( pw, ph )
    if resetHudButton:IsHovered() then
      draw.RoundedBox( 0, 0,0, pw, ph, Color( 255, 255, 0 ) )
    else
      draw.RoundedBox( 0, 0,0, pw, ph, Color( 255, 0, 0 ) )
    end

    draw.SimpleText( lang.resethud, "SettingsNormal", pw/2, ph/2, Color( 255, 255, 255, 255 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
  end
  function resetHudButton:DoClick()
    local _window = createVGUI( "DFrame", nil, 430, 50 + 10 + 50 + 10, 0, 0 )
    _window:Center()
    _window:SetTitle( lang.areyousure )

    local _yesButton = createVGUI( "DButton", _window, 200, 50, 10, 60 )
    _yesButton:SetText( lang.yes )
    function _yesButton:DoClick()
      resetHud()
      _window:Close()
    end

    local _noButton = createVGUI( "DButton", _window, 200, 50, 10 + 200 + 10, 60 )
    _noButton:SetText( lang.no )
    function _noButton:DoClick()
      _window:Close()
    end

    _window:MakePopup()
  end

  local _colorBackgroundPanel = createVGUI( "DPanel", cl_hudPanel, 470, 510, 0, 50+10+50+10 )
  function _colorBackgroundPanel:Paint( pw, ph )
    draw.RoundedBox( 0, 0, 0, pw, ph, Color( 255, 255, 255 ) )

    draw.SimpleText( lang.hudbackground, "SettingsNormal", ctrW( 10 ), ctrW( 10 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
  end

  local _colorBackground = createVGUI( "DColorMixer", _colorBackgroundPanel, 450, 450, 10, 50 )
  _colorBackground:SetPalette( true )
  _colorBackground:SetAlphaBar( true )
  _colorBackground:SetWangs( true )
  if cl_db["colbgr"] != nil then
    _colorBackground:SetColor( Color( cl_db["colbgr"], cl_db["colbgg"], cl_db["colbgb"], cl_db["colbga"] ) )	--Set the default color
  end
  function _colorBackground:ValueChanged( newColor )
    updateDBHud( "colbgr", newColor.r )
    updateDBHud( "colbgg", newColor.g )
    updateDBHud( "colbgb", newColor.b )
    updateDBHud( "colbga", newColor.a )
  end

  local _colorBorderPanel = createVGUI( "DPanel", cl_hudPanel, 470, 510, 470+10, 50+10+50+10 )
  function _colorBorderPanel:Paint( pw, ph )
    draw.RoundedBox( 0, 0, 0, pw, ph, Color( 255, 255, 255 ) )

    draw.SimpleText( lang.hudborder, "SettingsNormal", ctrW( 10 ), ctrW( 10 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
  end

  local _colorBorder = createVGUI( "DColorMixer", _colorBorderPanel, 450, 450, 10, 50 )
  _colorBorder:SetPalette( true )
  _colorBorder:SetAlphaBar( true )
  _colorBorder:SetWangs( true )
  _colorBorder:SetColor( Color( cl_db["colbrr"], cl_db["colbrg"], cl_db["colbrb"], cl_db["colbra"] ) )	--Set the default color
  function _colorBorder:ValueChanged( newColor )
    updateDBHud( "colbrr", newColor.r )
    updateDBHud( "colbrg", newColor.g )
    updateDBHud( "colbrb", newColor.b )
    updateDBHud( "colbra", newColor.a )
  end

  local _colorCrosshairPanel = createVGUI( "DPanel", cl_hudPanel, 470, 510, 0, 50+10+50+10+510+10 )
  function _colorCrosshairPanel:Paint( pw, ph )
    draw.RoundedBox( 0, 0, 0, pw, ph, Color( 255, 255, 255 ) )

    draw.SimpleText( lang.crosshair, "SettingsNormal", ctrW( 10 ), ctrW( 10 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
  end

  local _colorCrosshair = createVGUI( "DColorMixer", _colorCrosshairPanel, 450, 450, 10, 50 )
  _colorCrosshair:SetPalette( true )
  _colorCrosshair:SetAlphaBar( true )
  _colorCrosshair:SetWangs( true )
  _colorCrosshair:SetColor( Color( cl_db["colchr"], cl_db["colchg"], cl_db["colchb"], cl_db["colcha"] ) )	--Set the default color
  function _colorCrosshair:ValueChanged( newColor )
    updateDBHud( "colchr", newColor.r )
    updateDBHud( "colchg", newColor.g )
    updateDBHud( "colchb", newColor.b )
    updateDBHud( "colcha", newColor.a )
  end

  local _colorCrosshairBorderPanel = createVGUI( "DPanel", cl_hudPanel, 470, 510, 470+10, 50+10+50+10+510+10 )
  function _colorCrosshairBorderPanel:Paint( pw, ph )
    draw.RoundedBox( 0, 0, 0, pw, ph, Color( 255, 255, 255 ) )

    draw.SimpleText( lang.crosshairborder, "SettingsNormal", ctrW( 10 ), ctrW( 10 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
  end

  local _colorCrosshairBorder = createVGUI( "DColorMixer", _colorCrosshairBorderPanel, 450, 450, 10, 50 )
  _colorCrosshairBorder:SetPalette( true )
  _colorCrosshairBorder:SetAlphaBar( true )
  _colorCrosshairBorder:SetWangs( true )
  _colorCrosshairBorder:SetColor( Color( cl_db["colchbrr"], cl_db["colchbrg"], cl_db["colchbrb"], cl_db["colchbra"] ) )	--Set the default color
  function _colorCrosshairBorder:ValueChanged( newColor )
    updateDBHud( "colchbrr", newColor.r )
    updateDBHud( "colchbrg", newColor.g )
    updateDBHud( "colchbrb", newColor.b )
    updateDBHud( "colchbra", newColor.a )
  end

  local _settingCrosshairPanel = createVGUI( "DPanel", cl_hudPanel, 470, 510, 470+10+470+10, 50+10+50+10+510+10 )
  function _settingCrosshairPanel:Paint( pw, ph )
    draw.RoundedBox( 0, 0, 0, pw, ph, Color( 255, 255, 255 ) )

    draw.SimpleText( lang.crosshairsettings, "SettingsNormal", ctrW( 10 ), ctrW( 10 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

    draw.SimpleText( lang.length .. ":", "SettingsNormal", ctrW( 10 ), ctrW( 60 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
    draw.SimpleText( lang.gap .. ":", "SettingsNormal", ctrW( 10 ), ctrW( 150 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
    draw.SimpleText( lang.thickness .. ":", "SettingsNormal", ctrW( 10 ), ctrW( 240 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
    draw.SimpleText( lang.border .. ":", "SettingsNormal", ctrW( 10 ), ctrW( 330 ), Color( 255, 255, 255, 255 ), TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )
  end

  local _settingCrosshairLength = createVGUI( "DNumberWang", _settingCrosshairPanel, 450, 50, 10, 90 )
  _settingCrosshairLength:SetValue( cl_db["chl"] )
  function _settingCrosshairLength:OnValueChanged( val )
    updateDBHud( "chl", val )
  end

  local _settingCrosshairGap = createVGUI( "DNumberWang", _settingCrosshairPanel, 450, 50, 10, 90+90 )
  _settingCrosshairGap:SetValue( cl_db["chg"] )
  function _settingCrosshairGap:OnValueChanged( val )
    updateDBHud( "chg", val )
  end

  local _settingCrosshairThickness = createVGUI( "DNumberWang", _settingCrosshairPanel, 450, 50, 10, 90+180 )
  _settingCrosshairThickness:SetValue( cl_db["chh"] )
  function _settingCrosshairThickness:OnValueChanged( val )
    updateDBHud( "chh", val )
  end

  local _settingCrosshairBorder = createVGUI( "DNumberWang", _settingCrosshairPanel, 450, 50, 10, 90+270 )
  _settingCrosshairBorder:SetValue( cl_db["chbr"] )
  function _settingCrosshairBorder:OnValueChanged( val )
    updateDBHud( "chbr", val )
  end
end
