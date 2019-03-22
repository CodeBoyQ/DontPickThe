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

-- Preload some globalData
local normalFrame = globalData.normalFrame
local ball1Frame = globalData.ball1Frame
local ball3Frame = globalData.ball3Frame
local ball7Frame = globalData.ball7Frame
local jokerFrame = globalData.jokerFrame
local bombFrame = globalData.bombFrame
local ballsImageSheet = globalData.ballsImageSheet
local sequencesBall = globalData.sequencesBall
local ballRadius = globalData.ballRadius
 
local tutorialPagesTable = {}   
local carouselIndicatorTable = {}


-- Pointer
local currentPage = 1

-- Controls
local buttonLeft
local buttonRight
local buttonBack

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function playButtonTap()
	if (globalData.musicOn == true) then
		audio.play( buttonTap )
	end
end

local function initCarouselIndicator (parentScene, nrOfIndicators)

	local offSet = screenWidth * 0.07

	local carouselWidth = (nrOfIndicators - 1) * offSet
	local startingPoint = (screenWidth - carouselWidth) / 2

	local currentPosition = startingPoint

	for i = nrOfIndicators, 1, -1 do
		local newDot = display.newImageRect( parentScene, "images/tutorial_dot.png", 37, 37) 
		newDot.x = currentPosition
		newDot.y = screenTop + (screenHeight * 0.92) - 200
		newDot.alpha = 0.3
		table.insert( carouselIndicatorTable, newDot )
		currentPosition = currentPosition + offSet
	end

	-- Enable the first dot
	carouselIndicatorTable[1].alpha = 1

end

local function setCarouselIndicator (pageNr)

	for i = #carouselIndicatorTable, 1, -1 do
		carouselIndicatorTable[i].alpha = 0.3
	end

	carouselIndicatorTable[pageNr].alpha = 1
end

local function gotoMenu()
	playButtonTap()
	local options = { effect = "slideRight", time = 500 }
    composer.gotoScene( "menu" , options)
end

local function showPage(pageIndex)
	-- Show page with the given index from the tutorialPagesTable
	tutorialPagesTable[pageIndex].isVisible = true
	--transition.from ( tutorialPagesTable[pageIndex], { time=1000, width = nrOfBallsProgressInit * (nrOfBalls / maxNrOfBalls) })
end

local function hidePage(pageIndex)
	-- Hide page with the given index from the tutorialPagesTable
	tutorialPagesTable[pageIndex].isVisible = false
end

local function goLeft()
	playButtonTap()

	-- Hide Old page
	hidePage(currentPage)

	-- Show New page
	currentPage = currentPage - 1
	showPage(currentPage)

	-- Update the carousel indicator
	setCarouselIndicator (currentPage)

	-- Enable Right button
	buttonRight.isVisible = true

	-- Disable button if this is the most Left page
	if (currentPage == 1) then
		buttonLeft.isVisible = false
	end
end

local function goRight()
	playButtonTap()

	-- Hide Old page
	hidePage(currentPage)

	-- Show New page
	currentPage = currentPage + 1
	showPage(currentPage)

	-- Update the carousel indicator
	setCarouselIndicator (currentPage)

	-- Enable Left button
	buttonLeft.isVisible = true

	-- Disable Right button if this is the most Right page
	if (currentPage == #tutorialPagesTable) then
		buttonRight.isVisible = false
	end
end

local function clearTable(table)
    -- Remove objects from table and display
    for i = #table, 1, -1 do
        local object = table[i]
        display.remove( table )
        table.remove( table, i )
    end
end

local function setupTextPage(parentSceneGroup, myText)

	local options = {
		parent = parentSceneGroup,
		text = myText,
		x = display.contentCenterX,
		y = screenTop + (screenHeight * 0.3),
		width = screenWidth * 0.55,
		height = 0,
		font = native.systemFont,
		fontSize = 90,
		align = "center",
	}
	  
	local textField = display.newText( options )
	textField:setFillColor( 1.0,  1.0, 1.0 )
	textField.anchorY = 0

end


local function setupBallPage(parentSceneGroup, ballType, myText)
	local ball = display.newSprite( parentSceneGroup, ballsImageSheet, sequencesBall )
	ball:setFrame(ballType)
	ball.x = display.contentCenterX
	ball.y = screenTop + (screenHeight * 0.35)

	local options = {
		parent = parentSceneGroup,
		text = myText,
		x = display.contentCenterX,
		y = display.contentCenterY - 150,
		width = screenWidth * 0.55,
		height = 0,
		font = native.systemFont,
		fontSize = 90,
		align = "center",
	}
	  
	local textField = display.newText( options )
	textField:setFillColor( 1.0,  1.0, 1.0 )
	textField.anchorY = 0

end

local function setup3BallPage(parentSceneGroup, myText)
	local ball1 = display.newSprite( parentSceneGroup, ballsImageSheet, sequencesBall )
	ball1:setFrame(ball1Frame)
	ball1.x = display.contentCenterX - 350
	ball1.y = screenTop + (screenHeight * 0.35)

	local ball2 = display.newSprite( parentSceneGroup, ballsImageSheet, sequencesBall )
	ball2:setFrame(ball3Frame)
	ball2.x = display.contentCenterX
	ball2.y = screenTop + (screenHeight * 0.35)

	local ball3 = display.newSprite( parentSceneGroup, ballsImageSheet, sequencesBall )
	ball3:setFrame(ball7Frame)
	ball3.x = display.contentCenterX + 350
	ball3.y = screenTop + (screenHeight * 0.35)

	local options = {
		parent = parentSceneGroup,
		text = myText,
		x = display.contentCenterX,
		y = display.contentCenterY - 150,
		width = screenWidth * 0.55,
		height = 0,
		font = native.systemFont,
		fontSize = 90,
		align = "center",
	}
	  
	local textField = display.newText( options )
	textField:setFillColor( 1.0,  1.0, 1.0 )
	textField.anchorY = 0

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
	
	local title = display.newImageRect( sceneGroup, "images/tutorial_title.png", 849, 269 )
    title.x = display.contentCenterX
	title.y = screenTop + (screenHeight * 0.15)

	-- Setup Pages
	local intro1Page = display.newGroup()
	setupTextPage(intro1Page, "You start out with 15 balls \n\nTheir content is invisible to you \n\nAt least one of them holds \“Negative energy\”")
	sceneGroup:insert( intro1Page )  -- Insert into the scene's view group
	table.insert( tutorialPagesTable, intro1Page )
	intro1Page.isVisible = true

	local intro2Page = display.newGroup()
	setupTextPage(intro2Page, "Each round you have to pick out one ball \n\nIf you pick a ball with “Negative energy” the game is over")
	sceneGroup:insert( intro2Page )  -- Insert into the scene's view group
	table.insert( tutorialPagesTable, intro2Page )
	intro2Page.isVisible = false

	local intro3Page = display.newGroup()
	setupTextPage(intro3Page, "Each round, the number of balls decrease, meaning that the probability of picking a \“Negative energy\” ball will increase")
	sceneGroup:insert( intro3Page )  -- Insert into the scene's view group
	table.insert( tutorialPagesTable, intro3Page )
	intro3Page.isVisible = false

	local negativeEnergyPage = display.newGroup()
	setupBallPage(negativeEnergyPage, bombFrame, "Negative energy ball \n\nTry to avoid this ball, because it will mean the end of you!")
	sceneGroup:insert( negativeEnergyPage )  -- Insert into the scene's view group
	table.insert( tutorialPagesTable, negativeEnergyPage )
	negativeEnergyPage.isVisible = false

	local negativeEnergyBlockerPage = display.newGroup()
	setupBallPage(negativeEnergyBlockerPage, jokerFrame, "Negative energy blocker \n\nThis protects you from a Negative energy ball")
	sceneGroup:insert( negativeEnergyBlockerPage )  -- Insert into the scene's view group
	table.insert( tutorialPagesTable, negativeEnergyBlockerPage )
	negativeEnergyBlockerPage.isVisible = false

	local normalEnergyPage = display.newGroup()
	setupBallPage(normalEnergyPage, normalFrame, "Positive energy ball \n\nA normal positive energy ball")
	sceneGroup:insert( normalEnergyPage )  -- Insert into the scene's view group
	table.insert( tutorialPagesTable, normalEnergyPage )
	normalEnergyPage.isVisible = false

	local positiveEnergyPage = display.newGroup()
	setup3BallPage(positiveEnergyPage, "Positive energy plus balls \n\nThese balls give you respectively 1, 3 or 7 extra balls in the next round")
	sceneGroup:insert( positiveEnergyPage )  -- Insert into the scene's view group
	table.insert( tutorialPagesTable, positiveEnergyPage )
	positiveEnergyPage.isVisible = false

	endPage = display.newGroup()
	setupTextPage(endPage, "Use your focus and meditation (or pure luck ;-)) to choose right!\n\n\nGood luck!")
	sceneGroup:insert( endPage )  -- Insert into the scene's view group
	table.insert( tutorialPagesTable, endPage )
	endPage.isVisible = false

	-- Setup the carouselIndicator dots
	initCarouselIndicator (sceneGroup, #tutorialPagesTable)

	-- Set active page
	--intro1Page.isVisible = true

	-- Setup Controls
	buttonLeft = display.newImageRect( sceneGroup, "images/tutorial_button_left.png", 160, 144)
	buttonLeft.x = screenLeft + (screenWidth * 0.10)
	buttonLeft.y = screenTop + (screenHeight * 0.5)
	buttonLeft.isVisible = false

	buttonRight = display.newImageRect( sceneGroup, "images/tutorial_button_right.png", 160, 144)
	buttonRight.x = screenLeft + screenWidth - (screenWidth * 0.10)
	buttonRight.y = screenTop + (screenHeight * 0.5)
	
	buttonBack = display.newImageRect( sceneGroup, "images/back_button.png", 260, 144)
	buttonBack.x = display.contentCenterX
	buttonBack.y = screenTop + (screenHeight * 0.92)
	
	buttonLeft:addEventListener( "tap", goLeft)
	buttonRight:addEventListener( "tap", goRight)
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
	clearTable(tutorialPagesTable)
	clearTable(carouselIndicatorTable)
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
