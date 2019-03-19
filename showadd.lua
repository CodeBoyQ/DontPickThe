local composer = require( "composer" )
local applovin = require( "plugin.applovin" )
local scene = composer.newScene()
local mySdkKey = "lJGWoNRVdEDq-xW2-C9DNx9VtFCH9vIWTfKcbuG8L6_zGVD8iN4L4rI8ET8T6_twep0gRzIBFk6zOa9DNZVbnX"

local textBox

local function gotoHighScores()
	local options = { effect = "slideRight", time = 500 }
    composer.gotoScene( "highscores" , options)
end

local function adListener( event )

	if ( event.phase == "init" ) then  -- Successful initialization
		print( "AppLovin event: initialization successful" )
		--textBox.text = textBox.text .. "\Initialised"

        -- Load an AppLovin ad
        applovin.load( "interstitial" )
 
    elseif ( event.phase == "loaded" ) then  -- The ad was successfully loaded
		print( "AppLovin event: " .. tostring(event.type) .. " ad loaded successfully" )
		--textBox.text = textBox.text .. "\nLoaded"

		-- Show the Applovin ad
		applovin.show( "interstitial" )
 
	elseif ( event.phase == "failed" ) then  -- The ad failed to load
		print( "AppLovin event: " .. tostring(event.type) .. " ad failed to load" )
		print( event.type )
        print( event.isError )
        print( event.response )
		--textBox.text = textBox.text .. "\nFAILED " .. event.type
		--textBox.text = textBox.text .. "\n" .. event.response

    elseif ( event.phase == "displayed" or event.phase == "playbackBegan" ) then  -- The ad was displayed/played
		print( "AppLovin event: " .. tostring(event.type) .. " ad displayed" )
		--textBox.text = textBox.text .. "\nDisplayed"
 
    elseif ( event.phase == "hidden" or event.phase == "playbackEnded" ) then  -- The ad was closed/hidden
        print( "AppLovin event: " .. tostring(event.type) .. " ad closed/hidden" )
		--textBox.text = textBox.text .. "\nHidden"

		-- Goto Highscores
		gotoHighScores()

    elseif ( event.phase == "clicked" ) then  -- The ad was clicked/tapped
		print( "AppLovin event: " .. tostring(event.type) .. " ad clicked/tapped" )
		--textBox.text = textBox.text .. "\nClicked"

		-- Goto Highscores
		gotoHighScores()
	end

end
 

 
-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	textBox = display.newText( sceneGroup, "Loading...", display.contentCenterX, display.contentCenterY, native.systemFont, 100 ) 
	textBox:setFillColor( 0.65,  0.49, 0.918 )
	
end

-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)


	elseif ( phase == "did" ) then

		-- Initialize the AppLovin plugin
		applovin.init( adListener, { sdkKey=mySdkKey, verboseLogging=false, testMode=false } )

		-- Code here runs when the scene is entirely on screen
		--while (not applovin.isLoaded( "interstitial" )) do
		--	textBox.text = textBox.text .. "a"
		--end

		-- Show the Applovin ad
		--applovin.show( "interstitial" )

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

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

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
