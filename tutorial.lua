
local composer = require( "composer" )
local globalData = require( "globalData" )
local scene = composer.newScene()

-- Actual device screen values (This will differ per device)
local screenTop = display.screenOriginY
local screenLeft = display.screenOriginX
local screenHeight = display.actualContentHeight
local screenWidth = display.actualContentWidth

-- Sound variables
local buttonTap

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function playButtonTap()
	if (globalData.fxOn == true) then
		audio.play( buttonTap )
	end
end

local function gotoMenu()
	playButtonTap()
	local options = { effect = "slideRight", time = 500 }
    composer.gotoScene( "menu" , options)
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	print ("Creating Tutorial Scene")

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local background = display.newImageRect( sceneGroup, "images/tutorial_background.png", screenWidth, screenHeight )
	background.x = display.contentCenterX
    background.y = display.contentCenterY

	local buttonBack = display.newImageRect( sceneGroup, "images/back_button.png", 260, 144)
	buttonBack.x = display.contentCenterX
	buttonBack.y = screenTop + (screenHeight * 0.92)
	
	buttonBack:addEventListener( "tap", gotoMenu )

	-- Setup audio
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
		print ("Showing Tutorial Scene")

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
		print ("Hiding Tutorial Scene")
		
		--composer.removeScene( "tutorials" )

	end
end


-- destroy()
function scene:destroy( event )

	print ("Destroying Tutorial Scene")

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
