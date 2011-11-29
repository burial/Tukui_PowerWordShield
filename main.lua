local T, C, L = unpack(Tukui)
if select(2, UnitClass('player') ~= 'PRIEST') then
  return nil
end
local mod = CreateFrame('statusbar', 'Tukui_PowerWordShield', UIParent)
mod:SetScript('OnEvent', function(self, event, ...)
  return self[event](self, ...)
end)
mod:RegisterEvent('ADDON_LOADED')
local playerGUID = nil
local holyWalk = nil
local duration = 0
local tt = CreateFrame('GameTooltip', 'Tukui_PowerWordShieldTooltip', nil, 'GameTooltipTemplate')
tt:SetOwner(WorldFrame, 'ANCHOR_NONE')
local ParseTooltip
ParseTooltip = function()
  tt:ClearLines()
  tt:SetUnitBuff('player', 'Power Word: Shield')
  local text = Tukui_PowerWordShieldTooltipTextLeft2:GetText()
  return text and tonumber(text:match(".* (%d+%s?) .*")) or '! ! ! ! !'
end
mod.ADDON_LOADED = function(self, addon)
  if addon == 'Tukui_PowerWordShield' then
    self:UnregisterEvent('ADDON_LOADED')
    self:SetAlpha(0)
    playerGUID = UnitGUID('player')
    self:SetPoint('CENTER', 0, -364)
    self:SetWidth(129)
    self:SetHeight(21)
    self:SetStatusBarTexture(C.media.normTex)
    self:SetMinMaxValues(0, 15)
    self:SetTemplate()
    self:CreateShadow()
    self.label = self:CreateFontString(nil, 'ARTWORK')
    self.label:SetPoint('CENTER')
    self.label:SetFont(C.media.uffont, 17, 'OUTLINE')
    self.label:SetJustifyH('CENTER')
    self:SetScript('OnUpdate', self.OnUpdate)
    self:RegisterEvent('COMBAT_LOG_EVENT_UNFILTERED')
    self.ADDON_LOADED = nil
    return true
  end
end
local events = {
  SPELL_AURA_APPLIED = true,
  SPELL_AURA_REMOVED = true,
  SPELL_AURA_REFRESH = true
}
mod.COMBAT_LOG_EVENT_UNFILTERED = function(self, ...)
  local _, event, _, _, _, _, _, dstGUID, _, _, _, spellID = ...
  if dstGUID ~= playerGUID then
    return nil
  end
  if spellID == 17 then
    if event == 'SPELL_AURA_REMOVED' then
      self:FadeOut()
    elseif event == 'SPELL_AURA_REFRESH' then
      duration = 15
    elseif event == 'SPELL_AURA_APPLIED' then
      duration = 15
      self:FadeIn()
    end
  elseif spellID == 96219 then
    holyWalk = event ~= 'SPELL_AURA_REMOVED'
  end
  return true
end
mod.PLAYER_ENTERING_WORLD = function(self)
  local _, instanceType = IsInInstance()
  if instanceType == 'arena' then
    self:Hide()
  end
  return true
end
mod.OnUpdate = function(self, delay)
  if self:GetAlpha() == 0 then
    self:Hide()
  end
  duration = duration - delay
  self.label:SetText(ParseTooltip())
  self:SetValue(duration)
  if holyWalk then
    self:SetStatusBarColor(0, 1, 0, 0.3)
  else
    self:SetStatusBarColor(1, duration / 15, 0, 0.3)
  end
  return true
end
mod.FadeIn = function(self)
  if not self:IsVisible() then
    UIFrameFadeIn(self, 0.15, 0, 1)
  end
  return true
end
mod.FadeOut = function(self)
  if self:IsVisible() then
    UIFrameFadeOut(self, 0.15, 1, 0)
  end
  return true
end
