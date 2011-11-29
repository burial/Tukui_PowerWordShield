T, C, L = unpack Tukui
return nil if select 2, UnitClass('player') ~= 'PRIEST'

mod = CreateFrame('statusbar', 'Tukui_PowerWordShield', UIParent)
mod\SetScript('OnEvent', (event, ...) => self[event](self, ...))
mod\RegisterEvent('ADDON_LOADED')

playerGUID = nil
holyWalk = nil

duration = 0

tt = CreateFrame('GameTooltip', 'Tukui_PowerWordShieldTooltip', nil, 'GameTooltipTemplate')
tt\SetOwner(WorldFrame, 'ANCHOR_NONE')

ParseTooltip = ->
  tt\ClearLines!
  tt\SetUnitBuff('player', 'Power Word: Shield')
  text = Tukui_PowerWordShieldTooltipTextLeft2\GetText!
  text and tonumber(text\match(".* (%d+%s?) .*")) or '! ! ! ! !'

mod.ADDON_LOADED = (addon) =>
  if addon == 'Tukui_PowerWordShield'
    self\UnregisterEvent('ADDON_LOADED')
    self\SetAlpha(0)

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

events =
  SPELL_AURA_APPLIED: true
  SPELL_AURA_REMOVED: true
  SPELL_AURA_REFRESH: true

mod.COMBAT_LOG_EVENT_UNFILTERED = (...) =>
  _, event, _, _, _, _, _, dstGUID, _, _, _, spellID = ...

  return nil if dstGUID ~= playerGUID

  if spellID == 17 -- shield
    if event == 'SPELL_AURA_REMOVED'
      self\FadeOut!
    elseif event == 'SPELL_AURA_REFRESH'
      duration = 15
    elseif event == 'SPELL_AURA_APPLIED'
      duration = 15
      self\FadeIn!

  elseif spellID == 96219 -- holy walk
    holyWalk = event ~= 'SPELL_AURA_REMOVED'

  true

mod.PLAYER_ENTERING_WORLD = =>
  _, instanceType = IsInInstance!
  self\Hide! if instanceType == 'arena'
  true

mod.OnUpdate = (delay) =>
  self\Hide! if self\GetAlpha! == 0

  duration = duration - delay
  self.label\SetText(ParseTooltip!) -- todo: optimize

  self\SetValue(duration)

  if holyWalk
    self\SetStatusBarColor(0, 1, 0, 0.3)
  else
    self\SetStatusBarColor(1, duration / 15, 0, 0.3)

  true

mod.FadeIn = =>
  UIFrameFadeIn(self, 0.15, 0, 1) if not self\IsVisible!
  true

mod.FadeOut = =>
  UIFrameFadeOut(self, 0.15, 1, 0) if self\IsVisible!
  true
