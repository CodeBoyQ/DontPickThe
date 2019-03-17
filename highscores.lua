local composer = require( "composer" )
local globalData = require( "globalData" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Initialize variables
local json = require( "json" )

-- Actual device screen values (This will differ per device)
local screenTop = display.screenOriginY
local screenLeft = display.screenOriginX
local screenHeight = display.actualContentHeight
local screenWidth = display.actualContentWidth

-- Sound variables
local buttonTap

-- Parameters
local selectedDifficulty

-- Tables that hold the highscores for each difficulty level in memory
local scoresTableEasy = {}
local scoresTableNormal = {}
local scoresTableHard = {}
 
-- Files that store the highscores for each difficulty level on disk
local filePathEasyScores = system.pathForFile( "scoresEasy.json", system.DocumentsDirectory )
local filePathNormalScores = system.pathForFile( "scoresNormal.json", system.DocumentsDirectory )
local filePathHardScores = system.pathForFile( "scoresHard.json", system.DocumentsDirectory )

-- UI elements
local easyButtonText
local normalButtonText
local hardButtonText
local highscoresRankDisplayTable = {} -- Reference to the highscore display ranknumbers
local highscoresDisplayTable = {} -- Reference to the highscore display scores
local newHighScoreText -- New Highscore label

local function playButtonTap()
	if (globalData.fxOn == true) then
		audio.play( buttonTap )
	end
end

local function gotoMenu()
	playButtonTap()
	local options = { effect = "slideLeft", time = 500 }
    composer.gotoScene( "menu" , options)
end

-- Load the highscores from disk for a certain difficulty level
local function loadScores(filePath)
 
	local file = io.open( filePath, "r" )
	local scoresTable = {}
    if file then
        local contents = file:read( "*a" )
        io.close( file )
        scoresTable = json.decode( contents )
	end
    if ( scoresTable == nil or #scoresTable == 0 ) then
        scoresTable = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	end
	return scoresTable

end

-- Load all the highsocres from disk
local function loadAllScores()
	scoresTableEasy = loadScores(filePathEasyScores)
	scoresTableNormal = loadScores(filePathNormalScores)
	scoresTableHard = loadScores(filePathHardScores)
end

-- Get scoresTable for the current Difficulty level
local function getScoresTable(difficultyLevel)
	if (difficultyLevel == "Easy") then
		return scoresTableEasy
	elseif (difficultyLevel == "Normal") then
		print ("getScoresTable Normal")
		return scoresTableNormal
	else
		print ("getScoresTable Hard")
		return scoresTableHard
	end
end

-- Get filePath for the current Difficulty level
local function getScoresFilepath(difficultyLevel)
	if (difficultyLevel == "Easy") then
		return filePathEasyScores
	elseif (difficultyLevel == "Normal") then
		print ("getScoresFilepath Normal")
		return filePathNormalScores
	else
		print ("getScoresFilepath Hard")
		return filePathHardScores
	end
end

-- Save the scoresTable to disk
local function saveScores(difficultyLevel)

	local scoresTable = getScoresTable(difficultyLevel)
	local filePath = getScoresFilepath(difficultyLevel)

	-- Save table to file
	local file = io.open( filePath, "w" )

	if file then
		file:write( json.encode( scoresTable ) )
		io.close( file )
	end
end

local function resetAllHighscores()
	scoresTableEasy = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	saveScores("Easy")
	scoresTableNormal = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	saveScores("Normal")
	scoresTableHard = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0 }
	saveScores("Hard")
end

-- Returns true if the given score is present in the chosen Table
local function tableContainsScore(scoresTable, score)
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

-- Update the Highscores for a certain difficulty level in memory and on disk
local function updateScores(difficultyLevel, score)

	local scoresTable = getScoresTable(difficultyLevel)
	local filePath = getScoresFilepath(difficultyLevel)

	-- Insert the score into the table (if not duplicate) and then reset it
	if (not tableContainsScore(scoresTable, score)) then
		table.insert( scoresTable, score)
	end

	-- Sort the table entries from highest to lowest
	local function compare( a, b )
		return a > b
	end
	table.sort( scoresTable, compare )

	-- Cut off the lowest score
	for i = #scoresTable, 11, -1 do 
		table.remove( scoresTable, i )
	end

	saveScores(difficultyLevel)

end

-- Update the UI Buttons
local function updateUI()

	easyButtonText:setFillColor(1.0, 1.0, 1.0)
	normalButtonText:setFillColor(1.0, 1.0, 1.0)
	hardButtonText:setFillColor(1.0, 1.0, 1.0)

	if ( selectedDifficulty== "Easy") then
		easyButtonText:setFillColor (1.0, 1.0, 0)
	elseif (selectedDifficulty == "Normal") then
		normalButtonText:setFillColor (1.0, 1.0, 0)
	else
		hardButtonText:setFillColor (1.0, 1.0, 0)
	end
end

-- Update the Highscore display to show the highscores for a certain difficulty level
local function updateHighscoreDisplay (selectedDifficulty)

	local scoresTable = getScoresTable(selectedDifficulty)
	newHighScoreText.isVisible = false -- Reset New Highscore Text
	
	for i = 1, 10 do
		local score = highscoresDisplayTable[i]	
		local rankNum = highscoresRankDisplayTable[i]

		score.text = scoresTable[i] -- Update the score
		rankNum:setFillColor (1.0, 1.0, 1.0) -- Reset color
		score:setFillColor (1.0, 1.0, 1.0) -- Reset color

		if (globalData.lastGameDifficulty == selectedDifficulty) then	
			if (globalData.lastGameScore > 0 and tonumber(score.text) == globalData.lastGameScore) then

				-- Display the score of the last game in a different color
				rankNum:setFillColor( 1.0, 1.0, 0 )
				score:setFillColor (1.0, 1.0, 0)
	
				-- If the last score was a New Highscore, show it!
				if (i == 1) then
					newHighScoreText.isVisible = true 		
				end
			end
		end

	end

	updateUI()

end

-- Update the highscore display to show the highscores for a certain difficulty level
local function updateHighscoreDisplayListener (event)
	selectedDifficulty = event.target.level
	playButtonTap()
	updateHighscoreDisplay(selectedDifficulty)
end

-- Init the highscore display elements
local function initHighscores(sceneGroup)

	for i = 1, 10 do
		local yPos = screenTop + (screenHeight * 0.27) + ( i * screenHeight / 20 )

		local rankNum = display.newText( sceneGroup, i .. ".", display.contentCenterX - 50, yPos, native.systemFont, 70 )
		table.insert(highscoresRankDisplayTable, rankNum)
		rankNum.anchorX = 1

		local thisScore = display.newText( sceneGroup, 0, display.contentCenterX-30, yPos, native.systemFont, 70 )
		table.insert(highscoresDisplayTable, thisScore)
		thisScore.anchorX = 0
	end

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

	-- Setup UI
	local background = display.newImageRect( sceneGroup, "images/highscores_background.png", screenWidth, screenHeight )
    background.x = display.contentCenterX
	background.y = display.contentCenterY

	local title = display.newImageRect( sceneGroup, "images/highscores_title.png", 845, 271 )
    title.x = display.contentCenterX
	title.y = screenTop + (screenHeight * 0.15)

	easyButtonText = display.newText( sceneGroup, "Easy", display.contentCenterX - 300, title.y + 200, native.systemFont, 80 )
	easyButtonText.level = "Easy"
	normalButtonText = display.newText( sceneGroup, "Normal", display.contentCenterX, title.y + 200, native.systemFont, 80 )
	normalButtonText.level = "Normal"
	hardButtonText = display.newText( sceneGroup, "Hard", display.contentCenterX + 300, title.y + 200, native.systemFont, 80 )
	hardButtonText.level = "Hard"

	local buttonBack = display.newImageRect( sceneGroup, "images/back_button.png", 260, 144)
	buttonBack.x = display.contentCenterX
	buttonBack.y = screenTop + (screenHeight * 0.92)

	-- New Highscore
	newHighScoreText = display.newText( sceneGroup, "New Highscore!!!", display.contentCenterX, screenTop + (screenHeight * 0.92) - 180, native.systemFont, 90 )
	newHighScoreText:setFillColor (1.0, 1.0, 0)
	newHighScoreText.isVisible = false

	-- Init the Highscore Display elements
	initHighscores(sceneGroup)

	-- Add event Listeners
	easyButtonText:addEventListener( "tap", updateHighscoreDisplayListener)
	normalButtonText:addEventListener( "tap", updateHighscoreDisplayListener)
	hardButtonText:addEventListener( "tap", updateHighscoreDisplayListener)
	buttonBack:addEventListener( "tap", gotoMenu )

	
 
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

		-- Load the previous scores
		loadAllScores()

		-- Select for which difficulty level the Highscores are displayed
		selectedDifficulty = globalData.lastGameDifficulty

		-- Update and save scores for the current difficulty level
		updateScores(globalData.lastGameDifficulty, globalData.lastGameScore)

		-- Update the display
		updateHighscoreDisplay(selectedDifficulty)

		-- Uncomment to reset the Highscores
		--resetAllHighscores()

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
