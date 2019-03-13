
local composer = require( "composer" )
local scene = composer.newScene()

-- Actual device screen values (This will differ per device)
local screenTop = display.screenOriginY
local screenLeft = display.screenOriginX
local screenHeight = display.actualContentHeight
local screenWidth = display.actualContentWidth

local hooplotMediaLogo
local dot

local logoSound

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function gotoMenu()
	local options = { effect = "fade", time = 500}
    composer.gotoScene( "menu" , options)
end

local function logoFadeOutAnimation()
    transition.to( hooplotMediaLogo, { time=2000, alpha = 0, onComplete=gotoMenu } )
end

local function playLogoSound()
    audio.play( logoSound )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    print ("Creating Splash Scene")

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	hooplotMediaLogo = display.newImageRect( sceneGroup, "images/splash_hooplot_media_logo_no_dot.png", 928, 143 )
    hooplotMediaLogo.x = display.contentCenterX
    hooplotMediaLogo.y = display.contentCenterY
    
    dot = display.newImageRect( sceneGroup, "images/splash_hooplot_media_dot.png", 22, 22 )
    dot.x = hooplotMediaLogo.x + 370
    dot.y = hooplotMediaLogo.y - 45
    
    logoSound = audio.loadSound ("audio/splash_logoSound.wav")

end


-- show()
function scene:show( event )

    print ("Showing Splash Scene")

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
        -- Code here runs when the scene is entirely on screen
        transition.from( hooplotMediaLogo, { time=3000, y = hooplotMediaLogo.y + 200, alpha = 0, transition=easing.outInCubic, onComplete=logoFadeOutAnimation } )
        timer.performWithDelay (700, playLogoSound)
        transition.from( dot, { time=3000, alpha = 0, y = screenTop + screenWidth * 0.2, transition=easing.outExpo } )
        

	end
end


-- hide()
function scene:hide( event )

    print ("Hiding Splash Scene")

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)

	elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        composer.removeScene( "splash" )

	end
end


-- destroy()
function scene:destroy( event )

    print ("Destroying Splash Scene")

	local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view
    audio.dispose( logoSound )

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
