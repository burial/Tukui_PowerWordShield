N, NS = ...
T, C, L = unpack Tukui
return nil if select 2, UnitClass('player') ~= 'PRIEST'

mod = CreateFrame('statusbar', N, UIParent)
mod\SetScript('OnEvent', (event, ...) => self[event](self, ...))
mod\RegisterEvent('ADDON_LOADED')

playerGUID = nil
holyWalk = nil

duration = 0

CreateFrame('GameTooltip', 'Tukui_PowerWordShieldTooltip', nil, 'GameTooltipTemplate')\SetOwner(WorldFrame, 'ANCHOR_NONE')

ParseTooltip = ->
  Tukui_PowerWordShieldTooltip\ClearLines!
  Tukui_PowerWordShieldTooltip\SetUnitBuff('player', 'Power Word: Shield')
  tonumber( Tukui_PowerWordShieldTooltipTextLeft2\GetText!\match(".* (%d+%s?) .*") )

mod.ADDON_LOADED = (addon) =>
  if addon == N
    self\UnregisterEvent('ADDON_LOADED')
    self\Hide!

    playerGUID = UnitGUID('player')

    self\SetPoint('CENTER', 0, -364)
    self\SetWidth(129)
    self\SetHeight(21)
    self\SetStatusBarTexture(C.media.normTex)
    self\SetMinMaxValues(0, 15)
    self\SetTemplate!
    self\CreateShadow!

    self.label = self\CreateFontString(nil, 'ARTWORK')
    self.label\SetPoint('CENTER')
    self.label\SetFont(C.media.uffont, 17, 'OUTLINE')
    self.label\SetJustifyH('CENTER')

    self\SetScript('OnUpdate', self.OnUpdate)
    self\RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')

    self.ADDON_LOADED = nil
    true

mod.COMBAT_LOG_EVENT_UNFILTERED = (...) =>
  _, event, _, _, _, _, _, dstGUID, _, _, _, spellID, _, _, _, _, _, _, _, absorbed = ...

  if dstGUID ~= playerGUID
    return nil

  if spellID == 17 -- shield
    if event == 'SPELL_AURA_REMOVED'
      self\Hide!
    elseif event == 'SPELL_AURA_APPLIED'
      duration = 15
      self\Show!
    elseif event == 'SPELL_AURA_REFRESH'
      duration = 15

  elseif spellID == 96219 -- holy walk
    holyWalk = event ~= 'SPELL_AURA_REMOVED'

  true

mod.PLAYER_ENTERING_WORLD = =>
  if select(2, IsInInstance!) == 'arena'
    self\Hide!
    true

mod.OnUpdate = (delay) =>
  self.label\SetText(ParseTooltip!)

  duration = duration - delay

  self\SetValue(duration)

  if holyWalk
    self\SetStatusBarColor(0, 1, 0, 0.3)
  else
    self\SetStatusBarColor(1, duration / 15, 0, 0.3)

  true
