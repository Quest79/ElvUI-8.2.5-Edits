local E, L, V, P, G = unpack(select(2, ...)); --Import: Engine, Locales, PrivateDB, ProfileDB, GlobalDB
local S = E:GetModule('Skins')

--Lua functions
local _G = _G
--WoW API / Variables
local hooksecurefunc = hooksecurefunc

local function WorldMapBountyBoard(Frame)
	Frame.BountyName:FontTemplate()

	S:HandleCloseButton(Frame.TutorialBox.CloseButton)
end

local function SkinPartySyncPopups(frame)
	if not frame then return end

	local frameName = frame or frame:GetName()

	frameName:StripTextures()
	frameName:CreateBackdrop("Transparent")

	local Confirm = frameName.ButtonContainer.Confirm
	local Decline = frameName.ButtonContainer.Decline
	S:HandleButton(Confirm)
	S:HandleButton(Decline)
end

local function LoadSkin()
	if E.private.skins.blizzard.enable ~= true or E.private.skins.blizzard.worldmap ~= true then return end

	local WorldMapFrame = _G.WorldMapFrame
	WorldMapFrame:StripTextures()
	WorldMapFrame.BorderFrame:StripTextures()
	WorldMapFrame.BorderFrame:SetFrameStrata(WorldMapFrame:GetFrameStrata())
	WorldMapFrame.BorderFrame.NineSlice:Hide()
	WorldMapFrame.NavBar:StripTextures()
	WorldMapFrame.NavBar.overlay:StripTextures()
	WorldMapFrame.NavBar:Point("TOPLEFT", 1, -40)

	WorldMapFrame.ScrollContainer:CreateBackdrop()
	WorldMapFrame:CreateBackdrop("Transparent")
	WorldMapFrame.backdrop:SetPoint("TOPLEFT", WorldMapFrame, "TOPLEFT", -8, 0)
	WorldMapFrame.backdrop:SetPoint("BOTTOMRIGHT", WorldMapFrame, "BOTTOMRIGHT", 0, -9)

	S:HandleButton(WorldMapFrame.NavBar.homeButton)
	WorldMapFrame.NavBar.homeButton.xoffset = 1
	WorldMapFrame.NavBar.homeButton.text:FontTemplate()

	-- Quest Frames
	local QuestMapFrame = _G.QuestMapFrame
	QuestMapFrame.VerticalSeparator:Hide()

	if E.private.skins.parchmentRemover.enable then
		QuestMapFrame.DetailsFrame:StripTextures(true)
		QuestMapFrame.DetailsFrame:CreateBackdrop()
		QuestMapFrame.DetailsFrame.backdrop:Point('TOPLEFT', 0, 0)
		QuestMapFrame.DetailsFrame.backdrop:Point('BOTTOMRIGHT', QuestMapFrame.DetailsFrame.RewardsFrame, 'TOPRIGHT', 0, 1)
		QuestMapFrame.DetailsFrame.RewardsFrame:StripTextures()
		QuestMapFrame.DetailsFrame.RewardsFrame:SetTemplate()
	end

	local QuestScrollFrame = _G.QuestScrollFrame
	QuestScrollFrame.DetailFrame:StripTextures()
	QuestScrollFrame.DetailFrame.BottomDetail:Hide()
	QuestScrollFrame.Contents.Separator.Divider:Hide()

	local QuestScrollFrameScrollBar = _G.QuestScrollFrameScrollBar
	QuestScrollFrame.DetailFrame:CreateBackdrop()
	QuestScrollFrame.DetailFrame.backdrop:SetFrameLevel(1)
	QuestScrollFrame.DetailFrame.backdrop:Point("TOPLEFT", QuestScrollFrame.DetailFrame, "TOPLEFT", 3, 1)
	QuestScrollFrame.DetailFrame.backdrop:Point("BOTTOMRIGHT", QuestScrollFrame.DetailFrame, "BOTTOMRIGHT", -2, -7)
	QuestScrollFrame.Background:SetInside(QuestScrollFrame.DetailFrame.backdrop)
	QuestScrollFrame.Contents.StoryHeader.Background:Width(251)
	QuestScrollFrame.Contents.StoryHeader.Background:Point("TOP", 0, -9)
	QuestScrollFrame.Contents.StoryHeader.Text:Point("TOPLEFT", 18, -20)
	QuestScrollFrame.Contents.StoryHeader.HighlightTexture:SetAllPoints(QuestScrollFrame.Contents.StoryHeader.Background)
	QuestScrollFrame.Contents.StoryHeader.HighlightTexture:SetAlpha(0)
	S:HandleScrollBar(QuestScrollFrameScrollBar, 3, 3)
	QuestScrollFrameScrollBar:Point("TOPLEFT", QuestScrollFrame.DetailFrame, "TOPRIGHT", 1, -15)
	QuestScrollFrameScrollBar:Point("BOTTOMLEFT", QuestScrollFrame.DetailFrame, "BOTTOMRIGHT", 6, 10)

	S:HandleButton(QuestMapFrame.DetailsFrame.BackButton)
	S:HandleButton(QuestMapFrame.DetailsFrame.AbandonButton)
	S:HandleButton(QuestMapFrame.DetailsFrame.ShareButton, true)
	S:HandleButton(QuestMapFrame.DetailsFrame.TrackButton)
	S:HandleButton(QuestMapFrame.DetailsFrame.CompleteQuestFrame.CompleteButton, true)

	if E.private.skins.blizzard.tooltip then
		QuestMapFrame.QuestsFrame.StoryTooltip:SetTemplate("Transparent")
		QuestScrollFrame.WarCampaignTooltip:SetTemplate("Transparent")
	end

	QuestMapFrame.DetailsFrame.CompleteQuestFrame:StripTextures()

	S:HandleNextPrevButton(WorldMapFrame.SidePanelToggle.CloseButton, "left")
	S:HandleNextPrevButton(WorldMapFrame.SidePanelToggle.OpenButton, "right")

	S:HandleCloseButton(WorldMapFrame.BorderFrame.CloseButton)
	S:HandleMaxMinFrame(WorldMapFrame.BorderFrame.MaximizeMinimizeFrame)
	WorldMapFrame.BorderFrame.MaximizeMinimizeFrame:ClearAllPoints()
	WorldMapFrame.BorderFrame.MaximizeMinimizeFrame:Point("RIGHT", WorldMapFrame.BorderFrame.CloseButton, "LEFT", 12, 0)

	if E.global.general.disableTutorialButtons then
		WorldMapFrame.BorderFrame.Tutorial:Kill()
	end

	-- Add a hook to adjust the OverlayFrames
	hooksecurefunc(WorldMapFrame, "AddOverlayFrame", S.WorldMapMixin_AddOverlayFrame)

	-- Elements
	S:HandleDropDownBox(WorldMapFrame.overlayFrames[1]) -- NavBar handled in ElvUI/modules/skins/misc

	WorldMapFrame.overlayFrames[2]:StripTextures()
	WorldMapFrame.overlayFrames[2].Icon:SetTexture([[Interface\Minimap\Tracking\None]])
	WorldMapFrame.overlayFrames[2]:SetHighlightTexture([[Interface\Minimap\Tracking\None]], "ADD")
	WorldMapFrame.overlayFrames[2]:GetHighlightTexture():SetAllPoints(WorldMapFrame.overlayFrames[2].Icon)

	WorldMapBountyBoard(WorldMapFrame.overlayFrames[3]) -- BountyBoard
	--WorldMapActionButtonTemplate(WorldMapFrame.overlayFrames[4]) -- ActionButtons
	--WorldMapZoneTimerTemplate(WorldMapFrame.overlayFrames[5]) -- Timer?

	-- 8.2.5 Party Sync
	QuestMapFrame.QuestSessionManagement:StripTextures()
	-- TODO: Deal with the Button
	--S:HandleButton(QuestMapFrame.QuestSessionManagement.ExecuteSessionCommand, nil, nil, nil, true)

	SkinPartySyncPopups(_G.QuestSessionManager.CheckStartDialog)
	SkinPartySyncPopups(_G.QuestSessionManager.StartDialog)

	local minimizeButton = _G.QuestSessionManager.StartDialog.MinimizeButton
	minimizeButton:StripTextures()
	minimizeButton:Size(16, 16)

	minimizeButton.tex = minimizeButton:CreateTexture(nil, "OVERLAY")
	minimizeButton.tex:SetTexture(E.Media.Textures.MinusButton)
	minimizeButton.tex:SetInside()
	minimizeButton:SetHighlightTexture("Interface\\Buttons\\UI-PlusButton-Hilight", "ADD")

	SkinPartySyncPopups(_G.QuestSessionManager.CheckLeavePartyDialog)
	SkinPartySyncPopups(_G.QuestSessionManager.CheckStopDialog)
	SkinPartySyncPopups(_G.QuestSessionManager.CheckConvertToRaidDialog)
	SkinPartySyncPopups(_G.QuestSessionManager.ConfirmJoinGroupRequestDialog)
	SkinPartySyncPopups(_G.QuestSessionManager.ConfirmInviteToGroupDialog)
	SkinPartySyncPopups(_G.QuestSessionManager.ConfirmInviteToGroupReceivedDialog)
	SkinPartySyncPopups(_G.QuestSessionManager.ConfirmRequestToJoinGroupDialog)
	SkinPartySyncPopups(_G.QuestSessionManager.ConfirmBNJoinGroupRequestDialog)
	SkinPartySyncPopups(_G.QuestSessionManager.ConfirmInviteTravelPassConfirmationDialog)
end

S:AddCallback("SkinWorldMap", LoadSkin)
