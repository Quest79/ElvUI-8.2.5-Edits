local BUI, E, L, V, P, G = unpack(select(2, ...))
local UF = E:GetModule('UnitFrames');
local BU = BUI:GetModule('Units');

--Replace ElvUI AuraBars creation. Don't want to create shadows on PostUpdate
function BU:Create_AuraBarsWithShadow()
	local bar = self.statusBar

	self:SetTemplate('Default', nil, nil, UF.thinBorders, true)
	self:CreateSoftShadow()
	local inset = UF.thinBorders and E.mult or nil
	bar:SetInside(self, inset, inset)
	UF.statusbars[bar] = true
	UF:Update_StatusBar(bar)

	UF:Configure_FontString(bar.spelltime)
	UF:Configure_FontString(bar.spellname)
	UF:Update_FontString(bar.spelltime)
	UF:Update_FontString(bar.spellname)

	bar.spellname:ClearAllPoints()
	bar.spellname:Point('LEFT', bar, 'LEFT', 2, 0)
	bar.spellname:Point('RIGHT', bar.spelltime, 'LEFT', -4, 0)
	bar.spellname:SetWordWrap(false)

	bar.iconHolder:SetTemplate(nil, nil, nil, UF.thinBorders, true)
	bar.iconHolder:CreateSoftShadow()
	bar.icon:SetInside(bar.iconHolder, inset, inset)
	bar.icon:SetDrawLayer('OVERLAY')

	bar.bg = bar:CreateTexture(nil, 'BORDER')
	bar.bg:Show()

	bar.iconHolder:RegisterForClicks('RightButtonUp')
	bar.iconHolder:SetScript('OnClick', function(self)
		if E.db.unitframe.auraBlacklistModifier == "NONE" or not ((E.db.unitframe.auraBlacklistModifier == "SHIFT" and IsShiftKeyDown()) or (E.db.unitframe.auraBlacklistModifier == "ALT" and IsAltKeyDown()) or (E.db.unitframe.auraBlacklistModifier == "CTRL" and IsControlKeyDown())) then return; end
		local auraName = self:GetParent().aura.name

		if auraName then
			E:Print(format(L["The spell '%s' has been added to the Blacklist unitframe aura filter."], auraName))
			E.global.unitframe.aurafilters.Blacklist.spells[auraName] = { enable = true, priority = 0 }
			UF:Update_AllFrames()
		end
	end)
end

function BU:Configure_AuraBars(frame)
	if not BUI.ShadowMode then return end

	if not frame.VARIABLES_SET then return end
	local auraBars = frame.AuraBars

	auraBars.PostCreateBar = BU.Create_AuraBarsWithShadow
	auraBars.gap = frame.BORDER*2
	auraBars.spacing = frame.BORDER*2
end