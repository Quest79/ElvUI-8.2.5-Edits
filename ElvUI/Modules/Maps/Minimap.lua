local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local M = E:GetModule('Minimap')

--Lua functions
local _G = _G
local pairs = pairs
local tinsert = tinsert
local utf8sub = string.utf8sub
--WoW API / Variables
local CloseAllWindows = CloseAllWindows
local CloseMenus = CloseMenus
local CreateFrame = CreateFrame
local GarrisonLandingPageMinimapButton_OnClick = GarrisonLandingPageMinimapButton_OnClick
local GetMinimapZoneText = GetMinimapZoneText
local GetZonePVPInfo = GetZonePVPInfo
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local IsShiftKeyDown = IsShiftKeyDown
local MainMenuMicroButton_SetNormal = MainMenuMicroButton_SetNormal
local PlaySound = PlaySound
local ShowUIPanel, HideUIPanel = ShowUIPanel, HideUIPanel
local ToggleAchievementFrame = ToggleAchievementFrame
local ToggleCharacter = ToggleCharacter
local ToggleCollectionsJournal = ToggleCollectionsJournal
local ToggleFrame = ToggleFrame
local ToggleFriendsFrame = ToggleFriendsFrame
local ToggleGuildFrame = ToggleGuildFrame
local ToggleHelpFrame = ToggleHelpFrame
local ToggleLFDParentFrame = ToggleLFDParentFrame

--Create the new minimap tracking dropdown frame and initialize it
local ElvUIMiniMapTrackingDropDown = CreateFrame("Frame", "ElvUIMiniMapTrackingDropDown", _G.UIParent, "UIDropDownMenuTemplate")
ElvUIMiniMapTrackingDropDown:SetID(1)
ElvUIMiniMapTrackingDropDown:SetClampedToScreen(true)
ElvUIMiniMapTrackingDropDown:Hide()
_G.UIDropDownMenu_Initialize(ElvUIMiniMapTrackingDropDown, _G.MiniMapTrackingDropDown_Initialize, "MENU");
ElvUIMiniMapTrackingDropDown.noResize = true

--Create the minimap micro menu
local menuFrame = CreateFrame("Frame", "MinimapRightClickMenu", E.UIParent)
local menuList = {
	{text = _G.CHARACTER_BUTTON,
	func = function() ToggleCharacter("PaperDollFrame") end},
	{text = _G.SPELLBOOK_ABILITIES_BUTTON,
	func = function()
		if not _G.SpellBookFrame:IsShown() then
			ShowUIPanel(_G.SpellBookFrame)
		else
			HideUIPanel(_G.SpellBookFrame)
		end
	end},
	{text = _G.TALENTS_BUTTON,
	func = function()
		if not _G.PlayerTalentFrame then
			_G.TalentFrame_LoadUI()
		end

		local PlayerTalentFrame = _G.PlayerTalentFrame
		if not PlayerTalentFrame:IsShown() then
			ShowUIPanel(PlayerTalentFrame)
		else
			HideUIPanel(PlayerTalentFrame)
		end
	end},
	{text = _G.COLLECTIONS,
	func = ToggleCollectionsJournal},
	{text = _G.CHAT_CHANNELS,
	func = _G.ToggleChannelFrame},
	{text = _G.TIMEMANAGER_TITLE,
	func = function() ToggleFrame(_G.TimeManagerFrame) end},
	{text = _G.ACHIEVEMENT_BUTTON,
	func = ToggleAchievementFrame},
	{text = _G.SOCIAL_BUTTON,
	func = ToggleFriendsFrame},
	{text = L["Calendar"],
	func = function() _G.GameTimeFrame:Click() end},
	{text = _G.GARRISON_TYPE_8_0_LANDING_PAGE_TITLE,
	func = function() GarrisonLandingPageMinimapButton_OnClick() end},
	{text = _G.ACHIEVEMENTS_GUILD_TAB,
	func = ToggleGuildFrame},
	{text = _G.LFG_TITLE,
	func = ToggleLFDParentFrame},
	{text = _G.ENCOUNTER_JOURNAL,
	func = function()
		if not IsAddOnLoaded('Blizzard_EncounterJournal') then
			_G.EncounterJournal_LoadUI()
		end

		ToggleFrame(_G.EncounterJournal)
	end},
	{text = _G.MAINMENU_BUTTON,
	func = function()
		if not _G.GameMenuFrame:IsShown() then
			if _G.VideoOptionsFrame:IsShown() then
				_G.VideoOptionsFrameCancel:Click();
			elseif _G.AudioOptionsFrame:IsShown() then
				_G.AudioOptionsFrameCancel:Click();
			elseif _G.InterfaceOptionsFrame:IsShown() then
				_G.InterfaceOptionsFrameCancel:Click();
			end

			CloseMenus();
			CloseAllWindows()
			PlaySound(850) --IG_MAINMENU_OPEN
			ShowUIPanel(_G.GameMenuFrame);
		else
			PlaySound(854) --IG_MAINMENU_QUIT
			HideUIPanel(_G.GameMenuFrame);
			MainMenuMicroButton_SetNormal();
		end
	end}
}

--if(C_StorePublic.IsEnabled()) then
	tinsert(menuList, {text = _G.BLIZZARD_STORE, func = function() _G.StoreMicroButton:Click() end})
--end
tinsert(menuList, 	{text = _G.HELP_BUTTON, func = ToggleHelpFrame})

function M:GetLocTextColor()
	local pvpType = GetZonePVPInfo()
	if pvpType == "arena" then
		return 0.84, 0.03, 0.03
	elseif pvpType == "friendly" then
		return 0.05, 0.85, 0.03
	elseif pvpType == "contested" then
		return 0.9, 0.85, 0.05
	elseif pvpType == "hostile" then
		return 0.84, 0.03, 0.03
	elseif pvpType == "sanctuary" then
		return 0.035, 0.58, 0.84
	elseif pvpType == "combat" then
		return 0.84, 0.03, 0.03
	else
		return 0.9, 0.85, 0.05
	end
end

function M:ADDON_LOADED(_, addon)
	if addon == "Blizzard_TimeManager" then
		_G.TimeManagerClockButton:Kill()
	elseif addon == "Blizzard_FeedbackUI" then
		_G.FeedbackUIButton:Kill()
	end
end

function M:Minimap_OnMouseDown(btn)
	_G.HideDropDownMenu(1, nil, ElvUIMiniMapTrackingDropDown)
	menuFrame:Hide()

	local position = self:GetPoint()
	if btn == "MiddleButton" or (btn == "RightButton" and IsShiftKeyDown()) then
		if InCombatLockdown() then _G.UIErrorsFrame:AddMessage(E.InfoColor.._G.ERR_NOT_IN_COMBAT) return end
		if position:match("LEFT") then
			E:DropDown(menuList, menuFrame)
		else
			E:DropDown(menuList, menuFrame, -160, 0)
		end
	elseif btn == "RightButton" then
		_G.ToggleDropDownMenu(1, nil, ElvUIMiniMapTrackingDropDown, "cursor");
	else
		_G.Minimap_OnClick(self)
	end
end

function M:Minimap_OnMouseWheel(d)
	if d > 0 then
		_G.MinimapZoomIn:Click()
	elseif d < 0 then
		_G.MinimapZoomOut:Click()
	end
end

function M:Update_ZoneText()
	if E.db.general.minimap.locationText == 'HIDE' or not E.private.general.minimap.enable then return; end
	_G.Minimap.location:SetText(utf8sub(GetMinimapZoneText(),1,46))
	_G.Minimap.location:SetTextColor(M:GetLocTextColor())
	_G.Minimap.location:FontTemplate(E.Libs.LSM:Fetch("font", E.db.general.minimap.locationFont), E.db.general.minimap.locationFontSize, E.db.general.minimap.locationFontOutline)
end

function M:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent('PLAYER_REGEN_ENABLED')
	self:UpdateSettings()
end

local function PositionTicketButtons()
	local pos = E.db.general.minimap.icons.ticket.position or "TOPRIGHT"
	_G.HelpOpenTicketButton:ClearAllPoints()
	_G.HelpOpenTicketButton:Point(pos, _G.Minimap, pos, E.db.general.minimap.icons.ticket.xOffset or 0, E.db.general.minimap.icons.ticket.yOffset or 0)
	_G.HelpOpenWebTicketButton:ClearAllPoints()
	_G.HelpOpenWebTicketButton:Point(pos, _G.Minimap, pos, E.db.general.minimap.icons.ticket.xOffset or 0, E.db.general.minimap.icons.ticket.yOffset or 0)
end

local isResetting
local function ResetZoom()
	_G.Minimap:SetZoom(0)
	_G.MinimapZoomIn:Enable(); --Reset enabled state of buttons
	_G.MinimapZoomOut:Disable();
	isResetting = false
end

local function SetupZoomReset()
	if E.db.general.minimap.resetZoom.enable and not isResetting then
		isResetting = true
		E:Delay(E.db.general.minimap.resetZoom.time, ResetZoom)
	end
end
hooksecurefunc(_G.Minimap, "SetZoom", SetupZoomReset)

function M:UpdateSettings()
	if InCombatLockdown() then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
		return
	end

	E.MinimapSize = E.private.general.minimap.enable and E.db.general.minimap.size or _G.Minimap:GetWidth() + 10
	E.MinimapWidth, E.MinimapHeight = E.MinimapSize, E.MinimapSize

	_G.Minimap:Size(E.MinimapSize, E.MinimapSize)

	local LeftMiniPanel = _G.LeftMiniPanel
	local RightMiniPanel = _G.RightMiniPanel
	local BottomMiniPanel = _G.BottomMiniPanel
	local BottomLeftMiniPanel = _G.BottomLeftMiniPanel
	local BottomRightMiniPanel = _G.BottomRightMiniPanel
	local TopMiniPanel = _G.TopMiniPanel
	local TopLeftMiniPanel = _G.TopLeftMiniPanel
	local TopRightMiniPanel = _G.TopRightMiniPanel
	local MMHolder = _G.MMHolder
	local Minimap = _G.Minimap

	if E.db.datatexts.minimapPanels then
		LeftMiniPanel:Show()
		RightMiniPanel:Show()
	else
		LeftMiniPanel:Hide()
		RightMiniPanel:Hide()
	end

	if E.db.datatexts.minimapBottom then
		BottomMiniPanel:Show()
	else
		BottomMiniPanel:Hide()
	end

	if E.db.datatexts.minimapBottomLeft then
		BottomLeftMiniPanel:Show()
	else
		BottomLeftMiniPanel:Hide()
	end

	if E.db.datatexts.minimapBottomRight then
		BottomRightMiniPanel:Show()
	else
		BottomRightMiniPanel:Hide()
	end

	if E.db.datatexts.minimapTop then
		TopMiniPanel:Show()
	else
		TopMiniPanel:Hide()
	end

	if E.db.datatexts.minimapTopLeft then
		TopLeftMiniPanel:Show()
	else
		TopLeftMiniPanel:Hide()
	end

	if E.db.datatexts.minimapTopRight then
		TopRightMiniPanel:Show()
	else
		TopRightMiniPanel:Hide()
	end

	MMHolder:Width((Minimap:GetWidth() + E.Border + E.Spacing*3))

	if E.db.datatexts.minimapPanels then
		--MMHolder:Height(Minimap:GetHeight() + (LeftMiniPanel and (LeftMiniPanel:GetHeight() + E.Border) or 24) + E.Spacing*3)
		MMHolder:Height(Minimap:GetHeight() + E.Border + E.Spacing*3)
	else
		MMHolder:Height(Minimap:GetHeight() + E.Border + E.Spacing*3)
	end

	Minimap.location:Width(E.MinimapSize)

	if E.db.general.minimap.locationText ~= 'SHOW' or not E.private.general.minimap.enable then
		Minimap.location:Hide()
	else
		Minimap.location:Show()
	end

	_G.MinimapMover:Size(MMHolder:GetSize())

	--Stop here if ElvUI Minimap is disabled.
	if not E.private.general.minimap.enable then
		return;
	end

	local GarrisonLandingPageMinimapButton = _G.GarrisonLandingPageMinimapButton
	if GarrisonLandingPageMinimapButton then
		local pos = E.db.general.minimap.icons.classHall.position or "TOPLEFT"
		local scale = E.db.general.minimap.icons.classHall.scale or 1
		GarrisonLandingPageMinimapButton:ClearAllPoints()
		GarrisonLandingPageMinimapButton:Point(pos, Minimap, pos, E.db.general.minimap.icons.classHall.xOffset or 0, E.db.general.minimap.icons.classHall.yOffset or 0)
		GarrisonLandingPageMinimapButton:SetScale(scale)

		local GarrisonLandingPageTutorialBox = _G.GarrisonLandingPageTutorialBox
		if GarrisonLandingPageTutorialBox then
			GarrisonLandingPageTutorialBox:SetScale(1/scale)
			GarrisonLandingPageTutorialBox:SetClampedToScreen(true)
		end
	end

	local GameTimeFrame = _G.GameTimeFrame
	if GameTimeFrame then
		if E.private.general.minimap.hideCalendar then
			GameTimeFrame:Hide()
		else
			local pos = E.db.general.minimap.icons.calendar.position or "TOPRIGHT"
			local scale = E.db.general.minimap.icons.calendar.scale or 1
			GameTimeFrame:ClearAllPoints()
			GameTimeFrame:Point(pos, Minimap, pos, E.db.general.minimap.icons.calendar.xOffset or 0, E.db.general.minimap.icons.calendar.yOffset or 0)
			GameTimeFrame:SetScale(scale)
			GameTimeFrame:Show()
		end
	end

	local MiniMapMailFrame = _G.MiniMapMailFrame
	if MiniMapMailFrame then
		local pos = E.db.general.minimap.icons.mail.position or "TOPRIGHT"
		local scale = E.db.general.minimap.icons.mail.scale or 1
		MiniMapMailFrame:ClearAllPoints()
		MiniMapMailFrame:Point(pos, Minimap, pos, E.db.general.minimap.icons.mail.xOffset or 3, E.db.general.minimap.icons.mail.yOffset or 4)
		MiniMapMailFrame:SetScale(scale)
	end

	local QueueStatusMinimapButton = _G.QueueStatusMinimapButton
	if QueueStatusMinimapButton then
		local pos = E.db.general.minimap.icons.lfgEye.position or "BOTTOMRIGHT"
		local scale = E.db.general.minimap.icons.lfgEye.scale or 1
		QueueStatusMinimapButton:ClearAllPoints()
		QueueStatusMinimapButton:Point(pos, Minimap, pos, E.db.general.minimap.icons.lfgEye.xOffset or 3, E.db.general.minimap.icons.lfgEye.yOffset or 0)
		QueueStatusMinimapButton:SetScale(scale)
		_G.QueueStatusFrame:SetScale(scale)
	end

	local MiniMapInstanceDifficulty = _G.MiniMapInstanceDifficulty
	local GuildInstanceDifficulty = _G.GuildInstanceDifficulty
	if MiniMapInstanceDifficulty and GuildInstanceDifficulty then
		local pos = E.db.general.minimap.icons.difficulty.position or "TOPLEFT"
		local scale = E.db.general.minimap.icons.difficulty.scale or 1
		local x = E.db.general.minimap.icons.difficulty.xOffset or 0
		local y = E.db.general.minimap.icons.difficulty.yOffset or 0
		MiniMapInstanceDifficulty:ClearAllPoints()
		MiniMapInstanceDifficulty:Point(pos, Minimap, pos, x, y)
		MiniMapInstanceDifficulty:SetScale(scale)
		GuildInstanceDifficulty:ClearAllPoints()
		GuildInstanceDifficulty:Point(pos, Minimap, pos, x, y)
		GuildInstanceDifficulty:SetScale(scale)
	end

	local MiniMapChallengeMode = _G.MiniMapChallengeMode
	if MiniMapChallengeMode then
		local pos = E.db.general.minimap.icons.challengeMode.position or "TOPLEFT"
		local scale = E.db.general.minimap.icons.challengeMode.scale or 1
		MiniMapChallengeMode:ClearAllPoints()
		MiniMapChallengeMode:Point(pos, Minimap, pos, E.db.general.minimap.icons.challengeMode.xOffset or 8, E.db.general.minimap.icons.challengeMode.yOffset or -8)
		MiniMapChallengeMode:SetScale(scale)
	end

	if _G.HelpOpenTicketButton and _G.HelpOpenWebTicketButton then
		local scale = E.db.general.minimap.icons.ticket.scale or 1
		_G.HelpOpenTicketButton:SetScale(scale)
		_G.HelpOpenWebTicketButton:SetScale(scale)

		PositionTicketButtons()
	end
end

local function MinimapPostDrag()
	_G.MinimapBackdrop:ClearAllPoints()
	_G.MinimapBackdrop:SetAllPoints(_G.Minimap)
end

local function GetMinimapShape()
	return 'SQUARE'
end

function M:SetGetMinimapShape()
	--This is just to support for other mods
	_G.GetMinimapShape = GetMinimapShape
	_G.Minimap:Size(E.db.general.minimap.size, E.db.general.minimap.size)
end

function M:Initialize()
	if not E.private.general.minimap.enable then return end
	self.Initialized = true

	menuFrame:SetTemplate("Transparent", true)

	local Minimap = _G.Minimap
	local mmholder = CreateFrame('Frame', 'MMHolder', Minimap)
	mmholder:Point("TOPRIGHT", E.UIParent, "TOPRIGHT", -3, -3)
	mmholder:Width((Minimap:GetWidth() + 29))
	mmholder:Height(Minimap:GetHeight() + 53)

	Minimap:SetQuestBlobRingAlpha(0)
	Minimap:SetArchBlobRingAlpha(0)
	Minimap:CreateBackdrop()
	Minimap:SetFrameLevel(Minimap:GetFrameLevel() + 2)
	Minimap:ClearAllPoints()
	Minimap:Point("TOPRIGHT", mmholder, "TOPRIGHT", -E.Border, -E.Border)

	suiCreateShadow(Minimap.backdrop,	0,0,0, .7, 1, 1, 2)  							-- schism shadow
	--suiCreateShadow(Minimap.backdrop,	1,1,1, .3, 1, 1, 2) -- white
	Minimap.backdrop:SetPoint("TOPLEFT", mmholder, "TOPLEFT", 0, 20) 			-- schism: useful bar backdrop boarder points. Doesnt alter bar1?
	Minimap.backdrop:SetPoint("BOTTOMRIGHT", mmholder, "BOTTOMRIGHT", 0, 0) 	-- schism
	--Minimap.backdrop:SetBackdropColor(0, 0, 0, 1) 								-- schism
	--Minimap.backdrop:SetBackdropBorderColor(0, 0, 0, 1) 						-- schism

	Minimap:HookScript('OnEnter', function(mm)
		if E.db.general.minimap.locationText ~= 'MOUSEOVER' or not E.private.general.minimap.enable then return; end
		mm.location:Show()
	end)

	Minimap:HookScript('OnLeave', function(mm)
		if E.db.general.minimap.locationText ~= 'MOUSEOVER' or not E.private.general.minimap.enable then return; end
		mm.location:Hide()
	end)

	--Fix spellbook taint
	ShowUIPanel(_G.SpellBookFrame)
	HideUIPanel(_G.SpellBookFrame)

	Minimap.location = Minimap:CreateFontString(nil, 'OVERLAY')
	Minimap.location:FontTemplate(nil, nil, 'OUTLINE')
	Minimap.location:Point('TOP', Minimap, 'TOP', 0, -2)
	Minimap.location:SetJustifyH("CENTER")
	Minimap.location:SetJustifyV("MIDDLE")

	--Minimap.location:SetFrameLevel(Minimap:GetFrameLevel()+4)
	-- schism
	local locFrame = CreateFrame('Frame', 'locFrame', Minimap)
	locFrame:Point('TOPLEFT', Minimap, 'TOPLEFT', 1, 20)
	locFrame:Point('BOTTOMRIGHT', Minimap, 'TOPRIGHT', 0, 0)
	locFrame:Width(Minimap:GetWidth())
	locFrame:Height(18)
	--locFrame:CreateBackdrop("Transparent")
	locFrame:SetBackdrop( { 
		bgFile = E["media"].blankTex, 
	  	edgeFile = nil, tile = false, tileSize = 0, edgeSize = 0, 
	  	insets = { left = -1, right = 0, top = 0, bottom = 0 }
	} );
	locFrame:SetBackdropColor(0, 0, 0, .4)
	locFrame:SetFrameLevel(Minimap:GetFrameLevel())

	--[[local locFrame2 = CreateFrame('Frame', 'locFrame', Minimap)
	locFrame2:Point('BOTTOM', Minimap, 'BOTTOM', 0, -18)
	locFrame2:Width(Minimap:GetWidth())
	locFrame2:Height(18)
	--locFrame:CreateBackdrop("Transparent")
	locFrame2:SetBackdrop( { 
		bgFile = E["media"].blankTex, 
	  	edgeFile = nil, tile = false, tileSize = 0, edgeSize = 0, 
	  	insets = { left = -1, right = 0, top = 0, bottom = 0 }
	} );
	locFrame2:SetBackdropColor(0, 0, 0, .6)
	locFrame2:SetFrameLevel(Minimap:GetFrameLevel())--]]

	--[[local f = CreateFrame("Frame", nil, Minimap.location)
	f:SetWidth(666)
	f:SetHeight(666)
	f:SetFrameStrata("HIGH")
	CreateFrame("frameType", ["name"], [parent], ["template"])
	f:SetBackdrop( { 
	  bgFile = bg, 
	  edgeFile = edge, tile = false, tileSize = 0, edgeSize = 32, 
	  insets = { left = 0, right = 0, top = 0, bottom = 0 }
	} );
	f:SetBackdropColor(0.1, 0.9, 0.3, 0.8)
	f:SetBackdropBorderColor(0.2, 0.2, 0.2, 0.9)
	--]]





	if E.db.general.minimap.locationText ~= 'SHOW' or not E.private.general.minimap.enable then
		Minimap.location:Hide()
	end

	local frames = {
		_G.MinimapBorder,
		_G.MinimapBorderTop,
		_G.MinimapZoomIn,
		_G.MinimapZoomOut,
		_G.MinimapNorthTag,
		_G.MinimapZoneTextButton,
		_G.MiniMapTracking,
		_G.MiniMapMailBorder
	}

	for _, frame in pairs(frames) do
		frame:Kill()
	end

	_G.MiniMapMailIcon:SetTexture(E.Media.Textures.Mail)

	--Hide the BlopRing on Minimap
	Minimap:SetArchBlobRingScalar(0)
	Minimap:SetQuestBlobRingScalar(0)

	if E.private.general.minimap.hideClassHallReport then
		_G.GarrisonLandingPageMinimapButton:Kill()
		_G.GarrisonLandingPageMinimapButton.IsShown = function() return true end
	end

	_G.QueueStatusMinimapButtonBorder:Hide()
	_G.QueueStatusFrame:SetClampedToScreen(true)
	_G.MiniMapWorldMapButton:Hide()
	_G.MiniMapInstanceDifficulty:SetParent(Minimap)
	_G.GuildInstanceDifficulty:SetParent(Minimap)
	_G.MiniMapChallengeMode:SetParent(Minimap)

	if _G.TimeManagerClockButton then _G.TimeManagerClockButton:Kill() end
	if _G.FeedbackUIButton then _G.FeedbackUIButton:Kill() end

	E:CreateMover(_G.MMHolder, 'MinimapMover', L["Minimap"], nil, nil, MinimapPostDrag, nil, nil, 'maps,minimap')

	_G.MinimapCluster:EnableMouse(false)
	Minimap:EnableMouseWheel(true)
	Minimap:SetScript("OnMouseWheel", M.Minimap_OnMouseWheel)
	Minimap:SetScript("OnMouseDown", M.Minimap_OnMouseDown)
	Minimap:SetScript("OnMouseUp", E.noop)

	self:RegisterEvent("PLAYER_ENTERING_WORLD", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED_INDOORS", "Update_ZoneText")
	self:RegisterEvent("ZONE_CHANGED", "Update_ZoneText")
	self:RegisterEvent('ADDON_LOADED')
	self:UpdateSettings()
end

E:RegisterModule(M:GetName())
