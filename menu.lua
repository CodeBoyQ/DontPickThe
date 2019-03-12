
local composer = require( "composer" )

local scene = composer.newScene()

-- Actual device screen values (This will differ per device)
local screenTop = display.screenOriginY
local screenLeft = display.screenOriginX
local screenHeight = display.actualContentHeight
local screenWidth = display.actualContentWidth

-- Global game settings
local difficulty = "Normal"
local musicOn = true
local fxOn = true 

-- Sound variables
local backgroundTrack
local backgroundTrackChorus

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function gotoGame()
	local options = { effect = "slideUp", time = 500, params = { difficulty = difficulty, musicOn = musicOn, fxOn = fxOn} }
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

local function toggleMusic(event)
	if (musicOn == true) then
		event.target.alpha = 0.3
		audio.pause(1)
		musicOn = false
	else
		event.target.alpha = 1
		audio.resume(1)
		musicOn = true
	end
end

local function toggleFx(event)
	if (fxOn == true) then
		event.target.alpha = 0.3
		fxOn = false
	else
		event.target.alpha = 1
		fxOn = true
	end
end

-- These functions had to be global, since they call each other
function playMusic()
	print("playMusic")
	audio.play( backgroundTrack, { channel = 1, loops = 1, onComplete=playChorusMusic } )
end

function playChorusMusic()
	print("playChorusMusic")
	audio.play( backgroundTrackChorus, { channel = 1, loops = 1, onComplete=playMusic } )
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
	buttonDifficulty.y = screenTop + (screenHeight * 0.52)
	
	-- Level buttons (Are globally instantiated, because they are used in the setDifficulty method)
	levelEasy = display.newImageRect( sceneGroup, "images/menu_level_easy.png", 226, 43)
	levelEasy.anchorX = 0
	levelEasy.x = display.contentCenterX - (buttonDifficulty.width / 2)
	levelEasy.y = screenTop + (screenHeight * 0.58)
	levelEasy.isVisible = false

	levelNormal = display.newImageRect( sceneGroup, "images/menu_level_normal.png", 433, 43)
	levelNormal.anchorX = 0
	levelNormal.x = display.contentCenterX - (buttonDifficulty.width / 2)
	levelNormal.y = screenTop + (screenHeight * 0.58)
	levelNormal.isVisible = true

	levelHard = display.newImageRect( sceneGroup, "images/menu_level_hard.png", 686, 43)
	levelHard.anchorX = 0
	levelHard.x = display.contentCenterX - (buttonDifficulty.width / 2)
	levelHard.y = screenTop + (screenHeight * 0.58)
	levelHard.isVisible = false

	local buttonTutorial = display.newImageRect( sceneGroup, "images/menu_button_tutorial.png", 686, 144)
	buttonTutorial.x = display.contentCenterX
	buttonTutorial.y = screenTop + (screenHeight * 0.65)

	local buttonHighscores = display.newImageRect( sceneGroup, "images/menu_button_highscores.png", 686, 144)
	buttonHighscores.x = display.contentCenterX
	buttonHighscores.y = screenTop + (screenHeight * 0.74)

	local buttonMusicOnOff = display.newImageRect( sceneGroup, "images/menu_button_music.png", 134, 139)
	buttonMusicOnOff.x = display.contentCenterX - (screenWidth * 0.07)
	buttonMusicOnOff.y = screenTop + (screenHeight * 0.84)

	local buttonFxOnOff = display.newImageRect( sceneGroup, "images/menu_button_fx.png", 154, 137)
	buttonFxOnOff.x = display.contentCenterX + (screenWidth * 0.07)
	buttonFxOnOff.y = screenTop + (screenHeight * 0.84)
	
	buttonStart:addEventListener( "tap", gotoGame )
	buttonDifficulty:addEventListener( "tap", setDifficulty )
	buttonTutorial:addEventListener( "tap", gotoTutorial )
	buttonHighscores:addEventListener( "tap", gotoHighScores )
	buttonMusicOnOff:addEventListener( "tap", toggleMusic )
	buttonFxOnOff:addEventListener( "tap", toggleFx )

	-- Setup Audio
	backgroundTrack = audio.loadStream( "audio/menuLoop.wav")
	backgroundTrackChorus = audio.loadStream( "audio/menuLoopChorus.wav")

end




-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

		-- Start the music!
		playMusic()

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

		-- Music is not stopped, because you have to be able to switch between tutorials en highscores
		-- audio.stop( 1 )

	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

	-- Dispose audio!
	audio.dispose( backgroundTrack )
	audio.dispose( backgroundTrackChorus )

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
