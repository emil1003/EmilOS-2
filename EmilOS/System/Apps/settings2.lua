 --EmilOS 2 Settings App
 --Optimized for Windowing
 --(c) 2016 Emil Inc. All Rights Reserved.

 --Locals
local objectManager = objectify.objectManager()
local settings = framework.getSettings()

objectManager.addObject(objectify.createObject.selectableList("CategoryList",1,1,10,objectify.modes.SINGLE_SELECT,{langStrings.settings_general,langStrings.settings_graphics,langStrings.settings_network}))
objectManager.getByTag("CategoryList").recalculateHitbox()

local alignX = objectManager.getByTag("CategoryList").hitbox.endX + 3

objectManager.addObject(objectify.createObject.dropdown("General_Language",alignX,3,15,4,fs.list("/System/lang/"))).display = false

objectManager.addObject(objectify.createObject.switch("Graphics_Animations",alignX,3,not settings.noAnim)).display = false

objectManager.getByTag("General_Language").setSelectedString(settings.langPack)

local function redrawScreen()
	term.setBackgroundColor(colors.white)
	term.clear()
	term.setTextColor(colors.lightGray)
	alignX = objectManager.getByTag("CategoryList").hitbox.endX + 3
	local windowX, windowY = term.getSize()
	for i=1,windowY,1 do
		term.setCursorPos(objectManager.getByTag("CategoryList").hitbox.endX + 1,i)
		write(string.char(149))
	end
	for k,v in pairs(objectManager.getObjectList()) do
		if v.tag ~= "CategoryList" then
			v.display = false
		end
	end
	if objectManager.getByTag("CategoryList").selected[1] then
		term.setTextColor(colors.gray)
		if objectManager.getByTag("CategoryList").selected[1] == 1 then
			term.setCursorPos(alignX,2)
			write(langStrings.settings_language)
			objectManager.getByTag("General_Language").display = true
		elseif objectManager.getByTag("CategoryList").selected[1] == 2 then
			term.setCursorPos(alignX,2)
			write(langStrings.settings_animations)
			objectManager.getByTag("Graphics_Animations").display = true
		end
	end
	objectManager.drawAll()
end
local function saveSettings()
	local file = fs.open("/System/settings","w")
	file.write(textutils.serialize(settings))
	file.close()
	local langFile = fs.open("System/lang/"..settings.langPack,"r")
	_G.langStrings = textutils.unserialize(langFile.readAll())
	langFile.close()
	objectManager.getByTag("CategoryList").entries = {langStrings.settings_general,langStrings.settings_graphics,langStrings.settings_network}
	os.queueEvent("EmilOS_ReloadSettings")
end

redrawScreen()

while true do
	local e = {os.pullEventRaw()}
	if e[1] == "mouse_click" then
		for k,v in pairs(objectManager.getObjectList()) do
			if e[3] >= v.hitbox.startX and e[3] <= v.hitbox.endX and e[4] >= v.hitbox.startY and e[4] <= v.hitbox.endY then
				if v.tag == "CategoryList" then
					v.toggleSelected(e[4])
					redrawScreen()
				elseif v.display then
					if v.type == "button" then
						v.highlight()
					elseif v.tag == "General_Language" then
						v.expand()
						v.setSelected(v.getNewSelection())
						settings.langPack = v.getSelected()
					elseif v.tag == "Graphics_Animations" then
						v.toggle()
						settings.noAnim = not settings.noAnim
					end
					if v.type ~= "button" then
						saveSettings()
						redrawScreen()
					end
				end
			end
		end
	elseif e[1] == "term_resize" then
		redrawScreen()
	elseif e[1] == "terminate" then
		return
	end
end