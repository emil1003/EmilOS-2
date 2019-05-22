--EmilOS App Store 2
local version = 1.0
-- (c) 2017 Emil Inc. All rights reserved.

local objectManager = objectify.objectManager()
local settings = framework.getSettings()
local windowX, windowY = term.getSize()

local objectStyle = objectify.styles.default()
objectStyle.dropdown = {
	normal = {
		textColor = "gray",
		backgroundColor = "inherit",
	},
	highlighted = {
		textColor = "white",
		backgroundColor = "lightBlue",
	},
}

objectManager.addObject(objectify.createObject.dropdown("TabSelect",2,1,windowX - 3,2,{"Alle Apps","Installeret"})).setSelected(1)

objectManager.setGlobalStyle(objectStyle)

local function redrawScreen()
	term.setBackgroundColor(colors.white)
	term.clear()

	windowX, windowY = term.getSize()
	objectManager.getByTag("TabSelect").length = windowX - 3
	objectManager.drawAll()
end
local function isInsideHitbox(obj,e)
	return e[3] >= obj.hitbox.startX and e[3] <= obj.hitbox.endX and e[4] >= obj.hitbox.startY and e[4] <= obj.hitbox.endY
end

redrawScreen()

while true do
	local e = {os.pullEventRaw()}
	if e[1] == "mouse_click" then
		for k,v in pairs(objectManager.getObjectList()) do
			if isInsideHitbox(v,e) then
				if v.tag == "TabSelect" then
					v.expand()
					v.setSelected(v.getNewSelection())
				end
			end
		end
		redrawScreen()
	elseif e[1] == "EmilOS_ReloadSettings" then
		settings = framework.getSettings()
	elseif e[1] == "term_resize" then
		redrawScreen()
	end
end