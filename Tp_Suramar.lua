local ICON_OFFSET = 14;
local ACTIVE_ICON = [[Interface/MINIMAP/Vehicle-AllianceMagePortal]];
local INACTIVE_ICON = [[Interface/MINIMAP/Vehicle-HordeMagePortal]];
local MAP_ID = 1033;
local POINTS = {
	{ teleX = 31.30, teleY = 10.78, teleName = "TELE_MOON_GUARD", questID = 43808 },
	{ teleX = 22.68, teleY = 36.42, teleName = "TELE_FALANAAR", questID = 42230 },
	{ teleX = 42.07, teleY = 34.91, teleName = "TELE_TELANOR", questID = 43809 },
	{ teleX = 36.61, teleY = 46.54, teleName = "TELE_RUINS_ELUNE", questID = 40956 },
	{ teleX = 43.41, teleY = 60.56, teleName = "TELE_SANCTUM_ORDER", questID = 43813 },
	{ teleX = 43.07, teleY = 76.91, teleName = "TELE_LUNASTRE", questID = 43811 },
	{ teleX = 38.19, teleY = 77.13, teleName = "TELE_FELSOUL_HOLD", questID = 41575 },
	{ teleX = 46.66, teleY = 81.00, teleName = "TELE_WANING_CRESENT", questID = 42487, removedBy = 38649 },
	{ teleX = 64.00, teleY = 60.40, teleName = "TELE_TWILIGHT_VINEYARDS", questID = 44084 },
	{ teleX = 52.00, teleY = 78.76, teleName = "TELE_EVERMOON_TERRACE", questID = 42889 },
	{ teleX = 54.50, teleY = 69.40, teleName = "TELE_ASTRAVAR_HARBOR", questID = 44719 }
};

Telemancy = {
	hasSetup = false,
	icons = {}, 
	strings = {} 
};

local t = Telemancy;
local L = Telemancy.strings;

local eventFrame = CreateFrame("FRAME");
eventFrame:RegisterEvent("WORLD_MAP_UPDATE");
eventFrame:SetScript("OnEvent", function(...) t.OnEvent(...); end);

t.OnEvent = function(self, event, ...)
	if event == "WORLD_MAP_UPDATE" then
		if WorldMapFrame:IsShown() then
			if GetCurrentMapAreaID() == MAP_ID and GetCurrentMapDungeonLevel() == 0 then
				t.UpdateIcons();
				return;
			end
		end

		t.HideIcons();
	end
end

t.UpdateIcons = function()
	if not t.hasSetup then
		t.Setup();
	end

	local frameWidth, frameHeight = WorldMapPOIFrame:GetSize();
	for key, icon in pairs(t.icons) do
		if icon.removedBy and IsQuestFlaggedCompleted(icon.removedBy) then
			icon:Hide();
		else
			icon:SetPoint("TOPLEFT", (frameWidth * icon.teleX) - ICON_OFFSET, (frameHeight * icon.teleY) + ICON_OFFSET);
			icon:Show();
		end
	end
end

t.HideIcons = function()
	for key, icon in pairs(t.icons) do
		icon:Hide();
	end
end

t.UpdateIconState = function(icon)
	if IsQuestFlaggedCompleted(icon.questID) then
		if not icon.isActive then
			icon.texture:SetTexture(ACTIVE_ICON);
			icon.isActive = true;
		end
	else
		if icon.isActive then
			icon.texture:SetTexture(INACTIVE_ICON);
			icon.isActive = false;
		end
	end
end

t.OnIconUpdate = function(self, elapsed)
	if self.updateTimer >= 1 then
		local frameWidth, frameHeight = WorldMapPOIFrame:GetSize();
		self:SetFrameStrata("TOOLTIP");
		self:SetPoint("TOPLEFT", (frameWidth * self.teleX) - ICON_OFFSET, (frameHeight * self.teleY) + ICON_OFFSET);

		t.UpdateIconState(self);

		self.updateTimer = 0;
	else
		self.updateTimer = self.updateTimer + elapsed;
	end
end

t.OnIconEnter = function(self)
	WorldMapFrameAreaLabel:SetText("Telemancy: " .. L[self.teleName]);	
	if IsQuestFlaggedCompleted(self.questID) then
		WorldMapFrameAreaDescription:SetText(L["TELE_ACTIVE"]);
	else
		WorldMapFrameAreaDescription:SetText(L["TELE_INACTIVE"]);
	end	
	WorldMapFrameAreaLabel:Show();
	WorldMapFrameAreaDescription:Show();
end

t.OnIconLeave = function(self)
	WorldMapFrameAreaLabel:SetText("");
	WorldMapFrameAreaDescription:SetText("");
end

t.Setup = function()
	local template = {
		size = 28,
		parent = WorldMapPOIFrame,
		strata = "TOOLTIP",
		textures = {
			injectSelf = "texture",
			texture = INACTIVE_ICON,
		},
		scripts = {
			OnUpdate = t.OnIconUpdate,
			OnEnter = t.OnIconEnter,
			OnLeave = t.OnIconLeave
		}
	};

	for key, point in pairs(POINTS) do
		point.teleX = point.teleX / 100;
		point.teleY = -(point.teleY / 100);
		
		template.data = point; 
		template.data.updateTimer = 0;

		local frame = Krutilities:Frame(template); 
		table.insert(t.icons, frame); 
		t.UpdateIconState(frame); 
	end

	POINTS = nil; 
	t.hasSetup = true;
end