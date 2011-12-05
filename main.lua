local N, NS = ...
local T, C, L = unpack(Tukui)
if select(2, UnitClass('player') ~= 'PRIEST') then
  return nil
end
local mod = CreateFrame('statusbar', N, UIParent)
mod:SetScript('OnEvent', function(self, event, ...)
  return self[event](self, ...)
end)
mod:RegisterEvent('ADDON_LOADED')
local playerGUID = nil
local holyWalk = nil
local duration = 0
CreateFrame('GameTooltip', 'Tukui_PowerWordShieldTooltip', nil, 'GameTooltipTemplate'):SetOwner(WorldFrame, 'ANCHOR_NONE')
local ParseTooltip
ParseTooltip = function()
  Tukui_PowerWordShieldTooltip:ClearLines()
  Tukui_PowerWordShieldTooltip:SetUnitBuff('player', 'Power Word: Shield')
  return tonumber(Tukui_PowerWordShieldTooltipTextLeft2:GetText():match(".* (%d+%s?) .*"))
end
mod.ADDON_LOADED = function(self, addon)
  if addon == N then
    self:UnregisterEvent('ADDON_LOADED')
    self:Hide()
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
mod.COMBAT_LOG_EVENT_UNFILTERED = function(self, ...)
  local _, event, _, _, _, _, _, dstGUID, _, _, _, spellID, _, _, _, _, _, _, _, absorbed = ...
  if dstGUID ~= playerGUID then
    return nil
  end
  if spellID == 17 then
    if event == 'SPELL_AURA_REMOVED' then
      self:Hide()
    elseif event == 'SPELL_AURA_APPLIED' then
      duration = 15
      self:Show()
    elseif event == 'SPELL_AURA_REFRESH' then
      duration = 15
    end
  elseif spellID == 96219 then
    holyWalk = event ~= 'SPELL_AURA_REMOVED'
  end
  return true
end
mod.PLAYER_ENTERING_WORLD = function(self)
  if select(2, IsInInstance()) == 'arena' then
    self:Hide()
    return true
  end
end
mod.OnUpdate = function(self, delay)
  self.label:SetText(ParseTooltip())
  duration = duration - delay
  self:SetValue(duration)
  if holyWalk then
    self:SetStatusBarColor(0, 1, 0, 0.3)
  else
    self:SetStatusBarColor(1, duration / 15, 0, 0.3)
  end
  return true
end
