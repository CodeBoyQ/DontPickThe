local composer = require( "composer" )
local globalData = require( "globalData" )
local scene = composer.newScene()

-- Actual device screen values (This will differ per device)
local screenTop = display.screenOriginY
local screenLeft = display.screenOriginX
local screenHeight = display.actualContentHeight
local screenWidth = display.actualContentWidth

-- Music buttons
local buttonMusicOnOff

-- Sound variables
local buttonTap

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function playButtonTap()
	if (globalData.musicOn == true) then
		audio.play( buttonTap )
	end
end

local function continueGame()
	playButtonTap()
	local options = { effect = "fade", time = 200}
    composer.gotoScene( "game" , options)
end
 
local function gotoMainMenu()
	playButtonTap()
	local options = { effect = "fade", time = 200, params = {shutdownGame = true}}
    composer.gotoScene( "game" , options) -- First ga back to game scene to clean up the game gracefully
end

local function refreshMusic()
	if (globalData.musicOn == false) then
		buttonMusicOnOff.alpha = 0.3
		audio.setVolume( 0, { channel = 1 } )
	else
		buttonMusicOnOff.alpha = 1
		audio.setVolume( 0.3, { channel = 1 } )
	end
end

local function toggleMusic(event)
	playButtonTap()
	if (globalData.musicOn == true) then
		event.target.alpha = 0.3
		audio.setVolume( 0, { channel = 1 } )
		globalData.musicOn = false
	else
		event.target.alpha = 1
		audio.setVolume( 0.3, { channel = 1 } )
		globalData.musicOn = true
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	print ("Creating Pause Scene")

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local background = display.newImageRect( sceneGroup, "images/menu_background.png", screenWidth, screenHeight )
    background.x = display.contentCenterX
	background.y = display.contentCenterY

	local title = display.newImageRect( sceneGroup, "images/pause_title.png", 681, 272 )
    title.x = display.contentCenterX
	title.y = screenTop + (screenHeight * 0.35)

	local buttonMainMenu = display.newImageRect( sceneGroup, "images/pause_button_main_menu.png", 686, 144)
	buttonMainMenu.x = display.contentCenterX
	buttonMainMenu.y = screenTop + (screenHeight * 0.50)

	local buttonContinue = display.newImageRect( sceneGroup, "images/pause_button_continue.png", 686, 144)
	buttonContinue.x = display.contentCenterX
	buttonContinue.y = screenTop + (screenHeight * 0.59)

	buttonMusicOnOff = display.newImageRect( sceneGroup, "images/menu_button_music.png", 134, 139)
	buttonMusicOnOff.x = display.contentCenterX
	buttonMusicOnOff.y = screenTop + (screenHeight * 0.71)

	buttonMainMenu:addEventListener( "tap", gotoMainMenu )
	buttonContinue:addEventListener( "tap", continueGame )
	buttonMusicOnOff:addEventListener( "tap", toggleMusic )

	-- Setup Audio
	buttonTap = audio.loadSound ("audio/menuTapButton.wav")

end




-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		print ("Showing Pause Scene")
		refreshMusic()

	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		print ("Hiding Pause Scene")

	end
end


-- destroy()
function scene:destroy( event )

	print ("Destroying Pause Scene")

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view
	audio.dispose( buttonTap )

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
