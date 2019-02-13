
local composer = require( "composer" )

local scene = composer.newScene()

-- Actual device screen values (This will differ per device)
local screenTop = display.screenOriginY
local screenLeft = display.screenOriginX
local screenHeight = display.actualContentHeight
local screenWidth = display.actualContentWidth

-- Game difficulty
local difficulty = "Normal"

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function gotoGame()
	local options = { effect = "slideUp", time = 500, params = { difficulty = difficulty} }
    composer.gotoScene( "game" , options)
end
 
local function gotoTutorial()
	local options = { effect = "slideLeft", time = 500 }
    composer.gotoScene( "tutorial" , options)
end

local function gotoHighScores()
local options = { effect = "slideRight", time = 500 }
    composer.gotoScene( "highscores" , options)
end

local function setDifficulty() 
	if (difficulty == "Easy") then
		difficulty = "Normal"
		levelNormal.isVisible = true
		levelEasy.isVisible = false
	elseif (difficulty == "Normal") then
		difficulty = "Hard"
		levelHard.isVisible = true
		levelNormal.isVisible = false
	elseif (difficulty == "Hard") then
		difficulty = "Easy"
		levelEasy.isVisible = true
		levelHard.isVisible = false
	end
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	local background = display.newImageRect( sceneGroup, "images/menu_background.png", screenWidth, screenHeight )
    background.x = display.contentCenterX
	background.y = display.contentCenterY

	local title = display.newImageRect( sceneGroup, "images/menu_title.png", 851, 470 )
    title.x = display.contentCenterX
	title.y = screenTop + (screenHeight * 0.23)

	local buttonStart = display.newImageRect( sceneGroup, "images/menu_button_start.png", 686, 144)
	buttonStart.x = display.contentCenterX
	buttonStart.y = screenTop + (screenHeight * 0.43)

	local buttonDifficulty = display.newImageRect( sceneGroup, "images/menu_button_difficulty.png", 686, 144)
	buttonDifficulty.x = display.contentCenterX
	buttonDifficulty.y = screenTop + (screenHeight * 0.53)
	
	-- Level buttons (Are globally instantiated, because they are used in the setDifficulty method)
	levelEasy = display.newImageRect( sceneGroup, "images/menu_level_easy.png", 226, 43)
	levelEasy.anchorX = 0
	levelEasy.x = display.contentCenterX - (buttonDifficulty.width / 2)
	levelEasy.y = screenTop + (screenHeight * 0.60)
	levelEasy.isVisible = false

	levelNormal = display.newImageRect( sceneGroup, "images/menu_level_normal.png", 433, 43)
	levelNormal.anchorX = 0
	levelNormal.x = display.contentCenterX - (buttonDifficulty.width / 2)
	levelNormal.y = screenTop + (screenHeight * 0.60)
	levelNormal.isVisible = true

	levelHard = display.newImageRect( sceneGroup, "images/menu_level_hard.png", 686, 43)
	levelHard.anchorX = 0
	levelHard.x = display.contentCenterX - (buttonDifficulty.width / 2)
	levelHard.y = screenTop + (screenHeight * 0.60)
	levelHard.isVisible = false

	local buttonTutorial = display.newImageRect( sceneGroup, "images/menu_button_tutorial.png", 686, 144)
	buttonTutorial.x = display.contentCenterX
	buttonTutorial.y = screenTop + (screenHeight * 0.67)

	local buttonHighscores = display.newImageRect( sceneGroup, "images/menu_button_highscores.png", 686, 144)
	buttonHighscores.x = display.contentCenterX
	buttonHighscores.y = screenTop + (screenHeight * 0.77)
	
	buttonStart:addEventListener( "tap", gotoGame )
	buttonDifficulty:addEventListener( "tap", setDifficulty )
	buttonTutorial:addEventListener( "tap", gotoTutorial )
	buttonHighscores:addEventListener( "tap", gotoHighScores )


end




-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

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
