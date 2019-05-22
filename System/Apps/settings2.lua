--[[config
{
	name = "Indstillinger",
	window = {
		pos = {
			x = 2,
			y = 3,
		},
		size = {
			x = 30,
			y = 13,
		},
		focusable = true,
		stealFocus = true,
		focusModes = {
			defaultable = true,
			onWindowBarClick = true,
		}
	}
}
endconfig]]--
 --EmilOS 2 Settings App
 --Optimized for Windowing
 --(c) 2016 Emil Inc. All Rights Reserved.

 --Locals
local objectManager = objectify.objectManager()
local settings = framework.getSettings()

local style = objectify.styles.default()
style.switch = {
	offState = {
		track = {
			char = string.char(140),
			textColor = "lightGray",
			backgroundColor = "inherit",
		},
		knob = {
			char = " ",
			textColor = "inherit",
			backgroundColor = "gray",
		},
	},
	onState = {
		track = {
			char = string.char(140),
			textColor = "lightBlue",
			backgroundColor = "inherit",
		},
		knob = {
			char = " ",
			textColor = "inherit",
			backgroundColor = "blue",
		},
	},
}
style.selectableList.highlighted.backgroundColor = "lightGray"

objectManager.addObject(objectify.createObject.selectableList("CategoryList",1,1,10,objectify.modes.SINGLE_SELECT,{langStrings.settings_general,langStrings.settings_graphics,"Sikkerhed",langStrings.settings_network}))
objectManager.getByTag("CategoryList").recalculateHitbox()

local alignX = objectManager.getByTag("CategoryList").hitbox.endX + 3

objectManager.addObject(objectify.createObject.dropdown("General_Language",alignX,3,15,4,fs.list("/System/lang/"))).display = false

objectManager.addObject(objectify.createObject.dropdown("Graphics_Background",alignX,3,10,5,langStrings.firstboot_colors)).display = false
objectManager.addObject(objectify.createObject.dropdown("Graphics_Theme",alignX,6,10,5,langStrings.firstboot_themes)).display = false
objectManager.addObject(objectify.createObject.switch("Graphics_Shadows",alignX,9,not settings.dontDoMenuShadows)).display = false
objectManager.addObject(objectify.createObject.switch("Graphics_Animations",alignX,12,not settings.noAnim)).display = false

objectManager.addObject(objectify.createObject.button("Security_Password",alignX,3,"Skift...",nil,true)).display = false

objectManager.getByTag("General_Language").setSelectedString(settings.langPack)
objectManager.getByTag("Graphics_Background").setSelected(settings.background_selected)
objectManager.getByTag("Graphics_Theme").setSelected(settings.theme)

objectManager.setGlobalStyle(style)

local function redrawScreen()
	term.setBackgroundColor(colors.white)
	term.clear()
	term.setTextColor(colors.lightGray)
	alignX = objectManager.getByTag("CategoryList").hitbox.endX + 3
	local windowX, windowY = term.getSize()
	for i=1,windowY,1 do
		term.setCursorPos(alignX - 2,i)
		write(string.char(149))
	end
	for k,v in pairs(objectManager.getObjectList()) do
		if v.tag ~= "CategoryList" then
			v.display = false
		end
	end
	local catListSelected = objectManager.getByTag("CategoryList").getSelected()
	if catListSelected then
		term.setTextColor(colors.gray)
		if catListSelected == 1 then
			term.setCursorPos(alignX,2)
			write(langStrings.settings_language)
			objectManager.getByTag("General_Language").display = true
		elseif catListSelected == 2 then
			term.setCursorPos(alignX,2)
			write(langStrings.settings_background)
			objectManager.getByTag("Graphics_Background").display = true
			term.setCursorPos(alignX,5)
			write(langStrings.firstboot_theme)
			objectManager.getByTag("Graphics_Theme").display = true
			term.setCursorPos(alignX,8)
			write(langStrings.firstboot_shadows)
			objectManager.getByTag("Graphics_Shadows").display = true
			term.setCursorPos(alignX,11)
			write(langStrings.settings_animations)
			objectManager.getByTag("Graphics_Animations").display = true
		elseif catListSelected == 3 then
			term.setCursorPos(alignX,2)
			write(langStrings.settings_password)
			objectManager.getByTag("Security_Password").display = true
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
	objectManager.getByTag("CategoryList").entries = {langStrings.settings_general,langStrings.settings_graphics,"Sikkerhed",langStrings.settings_network}
	os.queueEvent("EmilOS_ReloadSettings")
end
local function showExpandedWindow(localObjectManager,onEventFunction)
	local objM = localObjectManager
	local windowX, windowY = term.getSize()
	local expandedWindow = window.create(term.current(),2,2,windowX - 2,windowY - 2)
	local oldTerm = term.redirect(expandedWindow)
	term.setBackgroundColor(colors.white)
	term.setTextColor(colors.black)
	term.clear()
	objM.drawAll()
	while true do
		local e = {os.pullEvent()}
		windowX, windowY = term.getSize()
		oldTerm = term.redirect(expandedWindow)
		if e[1] == "term_resize" then
			term.redirect(oldTerm)
			redrawScreen()
			expandedWindow.reposition(2,2,windowX - 2,windowY - 2)
			oldTerm = term.redirect(expandedWindow)
			term.clear()
			objM.drawAll()
		elseif e[1] == "mouse_click" then
			if e[3] == 1 or e[3] == windowX or e[4] == 1 or e[4] == windowY then
				break
			end
		end
		if string.sub(e[1],1,5) == "mouse" then
			e[3], e[4] = e[3] + 1, e[4] + 1
		end
		if onEventFunction(e,objM) == "closeWindow" then
			break
		end
	end
	term.redirect(oldTerm)
end
local function isInsideHitbox(obj,e)
	return e[3] >= obj.hitbox.startX and e[3] <= obj.hitbox.endX and e[4] >= obj.hitbox.startY and e[4] <= obj.hitbox.endY
end

sleep(0.05)

if System and not System.isAdmin() then
	term.setBackgroundColor(colors.black)
	term.setTextColor(colors.white)
	term.clear()
	term.setCursorPos(2,2)
	term.setTextColor(colors.white)
	write("This app needs admin rights")
	System.requestAdmin()
	while true do
		e = {os.pullEvent()}
		if e[1] == "sys_admingranted" then
			break
		end
	end
end

redrawScreen()

while true do
	local e = {os.pullEventRaw()}
	if e[1] == "mouse_click" then
		for k,v in pairs(objectManager.getObjectList()) do
			if isInsideHitbox(v,e) then
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
					elseif v.tag == "Graphics_Background" then
						v.expand()
						v.setSelected(v.getNewSelection())
						if objectManager.getByTag("Graphics_Background").selected then
							local backgroundColor = bit.blshift(1,objectManager.getByTag("Graphics_Background").selected - 1)
							if backgroundColor == 0 then
								backgroundColor = 1
							end
							for k,v in pairs(colors) do
								if v == backgroundColor then
									settings.background = k
									break
								end
							end
							settings.background_selected = objectManager.getByTag("Graphics_Background").selected
						end
					elseif v.tag == "Graphics_Theme" then
						v.expand()
						v.setSelected(v.getNewSelection())
						if objectManager.getByTag("Graphics_Theme").selected then
							if objectManager.getByTag("Graphics_Theme").selected == 1 then
								settings.topBarColor = "white"
								settings.topBarTextColor = "gray"
								settings.menuBackground = "white"
								settings.menuText = "black"
								settings.menuHighlight = "lightBlue"
								settings.menuInactive = "lightGray"
								settings.windowBorderColor = "white"
								settings.windowBorderTextColor = "gray"
							elseif objectManager.getByTag("Graphics_Theme").selected == 2 then
								settings.topBarColor = "gray"
								settings.topBarTextColor = "lightGray"
								settings.menuBackground = "gray"
								settings.menuText = "white"
								settings.menuHighlight = "lightBlue"
								settings.menuInactive = "lightGray"
								settings.windowBorderColor = "gray"
								settings.windowBorderTextColor = "lightGray"
							end
							settings.theme = objectManager.getByTag("Graphics_Theme").selected
						end
					elseif v.tag == "Graphics_Shadows" then
						v.toggle()
						settings.dontDoMenuShadows = not settings.dontDoMenuShadows
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
	elseif e[1] == "mouse_up" then
		for k,v in pairs(objectManager.getObjectList()) do
			if isInsideHitbox(v,e) then
				if v.type == "button" and v.highlighted then
					if v.tag == "Security_Password" then
						local objM = objectify.objectManager()
						objM.addObject(objectify.createObject.textView("TextView1",2,2,"Skift adgangskode"))
						objM.addObject(objectify.createObject.textInput("CurrentPassword",2,4,15,""))
						showExpandedWindow(objM,function(e,eObjM)
							if e[1] == "mouse_click" then
								for k,v in pairs(eObjM.list) do
									if isInsideHitbox(v,e) then
										if v.tag == "CurrentPassword" then
											v.onClick()
										end
									end
								end
								eObjM.drawAll()
							end
						end)
					end
				end
			end
		end
		redrawScreen()
	elseif e[1] == "EmilOS_ReloadSettings" then
		settings = framework.getSettings()
	elseif e[1] == "term_resize" then
		redrawScreen()
	elseif e[1] == "terminate" then
		return
	end
end