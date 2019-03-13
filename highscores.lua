
local composer = require( "composer" )
local globalData = require( "globalData" )
local scene = composer.newScene()

-- Actual device screen values (This will differ per device)
local screenTop = display.screenOriginY
local screenLeft = display.screenOriginX
local screenHeight = display.actualContentHeight
local screenWidth = display.actualContentWidth

local finalScore

-- Sound variables
local buttonTap

local function playButtonTap()
	if (globalData.fxOn == true) then
		audio.play( buttonTap )
	end
end

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Initialize variables
local json = require( "json" )
 
local scoresTable = {}
 
local filePath = system.pathForFile( "scores.json", system.DocumentsDirectory )

local function loadScores()
 
    local file = io.open( filePath, "r" )
 
    if file then
        local contents = file:read( "*a" )
        io.close( file )
        scoresTable = json.decode( contents )
	end
 
    if ( scoresTable == nil or #scoresTable == 0 ) then
        scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
    end
end

local function saveScores()
 
    for i = #scoresTable, 11, -1 do
        table.remove( scoresTable, i )
    end
 
    local file = io.open( filePath, "w" )
 
    if file then
        file:write( json.encode( scoresTable ) )
        io.close( file )
    end
end

local function gotoMenu()
	playButtonTap()
	local options = { effect = "slideLeft", time = 500 }
    composer.gotoScene( "menu" , options)
end

local function tableContains(score)
	local contains = false
	for i = 1, 10 do
		if ( scoresTable[i] ) then
			if (scoresTable[i] == score) then
			contains = true
			end
        end
	end
	return contains
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	print ("Creating Highscores Scene")

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

	-- Setup audio
	buttonTap = audio.loadSound ("audio/menuTapButton.wav")

	-- Load the previous scores
	loadScores()
	
	-- Read the finalScore (if redirected to this scene from the Menu scene there is no final score)
	finalScore = composer.getVariable( "finalScore" )
	if (finalScore == nil) then
		finalScore = -1
	end

	-- Insert the final score from the last game into the table (if not duplicate) and then reset it
	if (not tableContains(finalScore)) then
		table.insert( scoresTable, finalScore)
	end
	composer.setVariable( "finalScore", -1 )

	-- Sort the table entries from highest to lowest
	local function compare( a, b )
		return a > b
	end
	table.sort( scoresTable, compare )

	-- Save the scores
	saveScores()

	local background = display.newImageRect( sceneGroup, "images/highscores_background.png", screenWidth, screenHeight )
    background.x = display.contentCenterX
	background.y = display.contentCenterY

	local title = display.newImageRect( sceneGroup, "images/highscores_title.png", 845, 271 )
    title.x = display.contentCenterX
	title.y = screenTop + (screenHeight * 0.15)

	local buttonBack = display.newImageRect( sceneGroup, "images/back_button.png", 260, 144)
	buttonBack.x = display.contentCenterX
	buttonBack.y = screenTop + (screenHeight * 0.92)
	buttonBack:addEventListener( "tap", gotoMenu )
 
	for i = 1, 10 do
        if ( scoresTable[i] ) then
            local yPos = screenTop + (screenHeight * 0.23) + ( i * screenHeight / 20 )
 
            local rankNum = display.newText( sceneGroup, i .. ".", display.contentCenterX - 50, yPos, native.systemFont, 70 )
            rankNum.anchorX = 1
 
			local thisScore = display.newText( sceneGroup, scoresTable[i], display.contentCenterX-30, yPos, native.systemFont, 70 )
			thisScore.anchorX = 0

			-- Display the final Score in a different color
			
			if (tonumber(thisScore.text) == finalScore)then
				rankNum:setFillColor( 1.0, 1.0, 0 )
				thisScore:setFillColor (1.0, 1.0, 0)

				if (i == 1) then
					-- New Highscore
					local newHighScoreText = display.newText( sceneGroup, "New Highscore!!!", display.contentCenterX, screenHeight * 0.72, native.systemFont, 90 )
					newHighScoreText:setFillColor (1.0, 1.0, 0)
				end
			end


        end
	end
	
end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		print ("Showing Highscores Scene")
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
		print ("Hiding Highscores Scene")
		composer.removeScene( "highscores" )
	end
end


-- destroy()
function scene:destroy( event )

	print ("Destroying Highscores Scene")

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
