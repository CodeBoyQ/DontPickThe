
local composer = require( "composer" )
local globalData = require( "globalData" )
local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Physics variables
local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 70.8 )
local bounceRate = 0.7
local emitter

-- Statusbar items
local nrOfBalls = 15
local nrOfBallsProgress
local nrOfBallsProgressInit = 477
local ballsText 
local joker = 0
local jokerImage
local score = 0
local scoreText

local ballsTable = {}
local gameLoopTimer
local floor

local gameIsPaused = false

-- Global settings
local musicOn = globalData.musicOn
local fxOn = globalData.fxOn

-- Message items
local messageBackground

-- UI Groups
local backGroup
local mainGroup
local uiGroup

-- Game settings
local maxNrOfBalls = 25

-- Probability system (order small to large chance) minimum is 10
local chance7Balls    = 50 -- Every ball has 1 out of x chance to give you 7 extra balls
local chance3Balls    =  20 -- Every ball has 1 out of x chance to give you 3 extra balls
local chance1Balls    =  7 -- Every ball has 1 out of x chance to give you 1 extra balls
local chanceJoker     =  20 -- Every ball has 1 out of x chance to give you a Joker. If the user already has a joker this chance = 0
local chanceExtraBomb =  20 -- Every ball has 1 out of x chance to be an extra Bomb

-- Debug options, set all to false for production mode
local ballContentVisible = true
local dumpMemoryDebugMode = false

-- Actual device screen values (This will differ per device)
local screenTop = display.screenOriginY
local screenLeft = display.screenOriginX
local screenHeight = display.actualContentHeight
local screenWidth = display.actualContentWidth
    
-- The boundaries of the area (out of screen) from where the balls will be released and the radius of the balls
local ballRadius = 150
local ballReleaseAreaHeight = 800
local ballReleaseAreaMinX = screenLeft + ballRadius
local ballReleaseAreaMaxX = screenLeft + screenWidth - ballRadius
local ballReleaseAreaMinY = screenTop - ballReleaseAreaHeight + ballRadius
local ballReleaseAreaMaxY = screenTop - ballRadius

-- Sound variables
local explosionSound
local musicTrackGame
local ballBallBounceSound
local ballWallBounceSound

-- Setup Image sheet for ball
local ballsSheetOptions =
{
    width = ballRadius*2,
    height = ballRadius*2,
    numFrames = 8
}

local ballsImageSheet = graphics.newImageSheet( "images/balls_imagesheet.png", ballsSheetOptions )

local sequencesBall = {
    {
        name = "notUsed",
        start = 1,
        count = 8,
        time = 800,
        loopCount = 0
    },
}

local normalFrame = 1
local ball1Frame = 2
local ball3Frame = 3
local ball7Frame = 4
local jokerFrame = 5
local bombFrame = 6

local function pauseGame()
    gameIsPaused = true
	local options = { effect = "slideUp", time = 500}
    composer.gotoScene( "pause" , options)
end

local function clearBallTable()

    -- Remove balls from table and display
    for i = #ballsTable, 1, -1 do
        local thisBall = ballsTable[i]
        display.remove( thisBall )
        table.remove( ballsTable, i )
    end

end

local function updateStatubar()
    ballsText.text = nrOfBalls
    scoreText.text = score
    if (joker == 1) then
        jokerImage.alpha = 1
    else
        jokerImage.alpha = 0.3
    end
    transition.to( nrOfBallsProgress, { time=1000, width = nrOfBallsProgressInit * (nrOfBalls / maxNrOfBalls) })
end

local function determineGamestatus()
    if (joker < 0) then
        -- Game Over
        composer.setVariable( "finalScore", score )
        composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
    elseif (nrOfBalls == 0) then
        -- Ultimate Winner
    else
        -- Next Level
        updateStatubar()
        physics.addBody( floor, "static", {bounce=bounceRate})
        clearBallTable()
        dropBalls(nrOfBalls)
    end
end

local function explosion(tappedBall)
  emitter.x = tappedBall.x
  emitter.y = tappedBall.y
  emitter:start()
end

local function handleTapBallEvent( event )

    -- Check the tapped ball type

    local ball = event.target

    transition.to( ball, { time=1000, alpha=0, transition=easing.inOutBounce} )

    local message
    local messageType = "Good" -- Good or Bad
    local messageSize = 100

    -- Play explotion particle
    explosion (ball)

    if (ball.name == "Bomb") then
        -- Player looses a life
        joker = joker - 1
        message = "Negative Energy!!!"
        if (joker == 0) then
            message = message .. "\nLuckily you had a negative \n energy blocker :-)"
            messageSize =70
        else
            messageType = "Bad"
        end 
        -- Play explosionsound
        if (fxOn) then
            audio.play( explosionSound )
        end
    elseif (ball.name == "7Balls") then
        -- Player gets 7 extra balls and goes to the next level
        nrOfBalls = nrOfBalls + 7
        message = "Good energy!! :-) \n+7!"
    elseif (ball.name == "3Balls") then
        -- Player gets 3 extra balls and goes to the next level
        nrOfBalls = nrOfBalls + 3
        message = "Good energy!! \n+3!"
    elseif (ball.name == "1Balls") then
        -- Player gets 1 extra balls and goes to the next level
        nrOfBalls = nrOfBalls + 1
        message = "Good energy!! \n+1!"
    elseif (ball.name == "Joker") then
        -- Player gets 1 extra life
        joker = 1
        nrOfBalls = nrOfBalls - 1
        message = "You found a \nNegative energy \nblocker!"
        messageSize = 70
    else
        -- Normal
        nrOfBalls = nrOfBalls - 1
        message = "You have \n chosen wisely!"
    end

    -- There can only be a maximum of [maxNrOfBalls] in the game
    if (nrOfBalls > maxNrOfBalls) then
        local overflowBonus = (nrOfBalls - maxNrOfBalls) * 100
        nrOfBalls = maxNrOfBalls
        score = score + overflowBonus -- You get bonus points for the balls that you've lost because they exceed
        message = message .. "\n Overflow Bonus!! " .. overflowBonus
    end

    -- Update score
    score = score + nrOfBalls

    -- Show the content of all the balls
    for i = #ballsTable, 1, -1 do
        local thisBall = ballsTable[i]
        showBallContent(thisBall)
    end

    -- Let the balls fall through the ground
    physics.removeBody( floor )

    -- Show the message
    messageBackground = display.newImageRect( uiGroup, "images/game_message_bg.png", 500, 350) --1199 x 795
    messageBackground.x = display.contentCenterX
    messageBackground.y = display.contentCenterY
    transition.to( messageBackground, { time=1000, alpha=0, width = 10052, height = 715, transition=easing.outCirc} )
   
    local options = 
    {
        text = message,     
        x = display.contentCenterX,
        y = display.contentCenterY,
        --width = 1280,
        font = native.systemFont,   
        fontSize = messageSize,
        align = "center"  -- Alignment parameter
    }
    messageText = display.newText( options )

    if (messageType=="Bad") then
        messageText:setFillColor( 0,  0, 0 )
    end
 
    transition.to( messageText, { time=3000, delay = 0, alpha=0, xScale=3, yScale=3, onComplete=determineGamestatus })


end

-- This function is not local, since it is used in multiple places
function dropBalls(numberOfBalls)

    -- Determine which ball is the bomb
    local bomb = math.random(1, numberOfBalls)

    -- Drop the balls
    for i = numberOfBalls, 1, -1 do
  
        -- Create the ball and insert it to the table
        newBall = display.newSprite( mainGroup, ballsImageSheet, sequencesBall )
        table.insert( ballsTable, newBall )

        -- Determine the ball type
        if (bomb == i) then
            newBall.name = "Bomb"
        else
            if (math.random(1, chance7Balls) == 7) then
                newBall.name = "7Balls"
            elseif (math.random(1, chance3Balls) == 3) then
                newBall.name = "3Balls"
            elseif (math.random(1, chance1Balls) == 1) then
                newBall.name = "1Ball"
            elseif (joker == 0 and math.random(1, chanceJoker) == 8) then -- If the player already has a Joker, no Joker balls will be created
                newBall.name = "Joker"
            elseif (math.random(1, chanceExtraBomb) == 3) then
                newBall.name = "Bomb"
            end
        end

        -- Make the content visible or not
        if (ballContentVisible == true) then
            showBallContent(newBall)
        else
            hideBallContent(newBall)
        end 
        
        -- Position ball in random starting position
        newBall.x = math.random (ballReleaseAreaMinX, ballReleaseAreaMaxX)
        newBall.y = math.random (ballReleaseAreaMinY, ballReleaseAreaMaxY)

        -- Add physics and listener
        physics.addBody( newBall, "dynamic", { radius=ballRadius, density=50, friction = 0.3, bounce=bounceRate } )
        newBall:addEventListener( "tap", handleTapBallEvent )

    end

end

function showBallContent(ball) 
    if (ball.name == "Bomb") then
        ball:setFrame(bombFrame)
    elseif (ball.name == "7Balls") then
        ball:setFrame(ball7Frame)
    elseif (ball.name == "3Balls") then
        ball:setFrame(ball3Frame)
    elseif (ball.name == "1Balls") then
        ball:setFrame(ball1Frame)
    elseif (ball.name == "Joker") then
        ball:setFrame(jokerFrame)
    else
        ball:setFrame(normalFrame)
    end
end

function hideBallContent(ball)
    ball:setFrame(normalFrame)
end
 
local function gameLoop()
 
    -- Actions that keep continueing
    -- Noop
    
end
 
local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2

        if ( obj1.name == "wall" or obj2.name == "wall" ) then
            -- Ball hits wall
            -- audio.play( ballBallBounceSound)
        elseif ( obj1.name ~= "wall" and obj2.name ~= "wall" ) then
            -- Ball to ball collision
			--audio.play( ballBallBounceSound )
        end
    end
end

local function  setupExplosion()
    local dx = 200
    local p = "images/habra.png"
    local emitterParams = {
          startParticleSizeVariance = dx/2,
          startColorAlpha = 0.61,
          startColorGreen = 0.3031555,
          startColorRed = 0.08373094,
          yCoordFlipped = 0,
          blendFuncSource = 770,
          blendFuncDestination = 1,
          rotatePerSecondVariance = 153.95,
          particleLifespan = 0.7237,
          tangentialAcceleration = -144.74,
          startParticleSize = dx,
          textureFileName = p,
          startColorVarianceAlpha = 1,
          maxParticles = 128,
          finishParticleSize = dx/3,
          duration = 0.75,
          finishColorRed = 0.078,
          finishColorAlpha = 0.75,
          finishColorBlue = 0.3699196,
          finishColorGreen = 0.5443883,
          maxRadiusVariance = 172.63,
          finishParticleSizeVariance = dx/2,
          gravityy = 220.0,
          speedVariance = 258.79,
          tangentialAccelVariance = -92.11,
          angleVariance = -300.0,
          angle = -900.11
    }
    emitter = display.newEmitter(emitterParams )
    emitter:stop()
end

local function setupSounds()
    explosionSound = audio.loadSound( "audio/explosion.wav" )
    ballBallBounceSound = audio.loadSound ("audio/ball_ball_bounce.wav")
    ballWallBounceSound = audio.loadSound ("audio/ball_wall_bounce.wav")
    musicTrackGame = audio.loadStream( "audio/gameLoop.wav")
end

local function disposeSounds()
    audio.stop() -- All sounds on all Channels must be stopped before disposing them. This counts for the Music playing on Channel 1
    audio.dispose( explosionSound )
    audio.dispose( musicTrackGame )
    audio.dispose( ballBallBounceSound )
    audio.dispose( ballWallBounceSound )
end

local function setupBackground()

    -- The background image is stretched to the actual screensize
	local background = display.newImageRect( backGroup, "images/game_background.png", screenWidth, screenHeight )
	background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- The walls are postioned to the left, bottom and right of the actual device screen
    local leftWall = display.newImageRect( backGroup, "images/wall.png", 100, screenHeight + ballReleaseAreaHeight ) -- The ballReleaseAreaHeight area is where the balls are created to fall in to the screen
    leftWall.x = screenLeft - 50
    leftWall.y = display.contentCenterY - (ballReleaseAreaHeight/2)
    leftWall.name = "wall"
    physics.addBody( leftWall, "static")

    local rightWall = display.newImageRect( backGroup, "images/wall.png", 100, screenHeight + ballReleaseAreaHeight) -- The ballReleaseAreaHeight area is where the balls are created to fall in to the screen
    rightWall.x = screenLeft + screenWidth + 50
    rightWall.y = display.contentCenterY - (ballReleaseAreaHeight/2)
    rightWall.name = "wall"
    physics.addBody( rightWall, "static")
    
    -- Floor is a global variable since it will be used on multiple places (e.g. )
    floor = display.newImageRect( backGroup, "images/wall.png", display.actualContentWidth, 100 )
    floor.x = display.contentCenterX
    floor.y = screenTop + screenHeight + 50
    floor.name = "wall"
    physics.addBody( floor, "static", {bounce=bounceRate})
end

local function setupStatusbar()

    local paddingTop = 0.07

    -- The Nr of balls bar
    local nrOfBallsBackground = display.newImageRect( uiGroup, "images/game_nrballs_background.png", 427, 90 )
    nrOfBallsBackground.anchorX = 0
    nrOfBallsBackground.x = screenLeft + (screenWidth * 0.1)
    nrOfBallsBackground.y = screenTop + (screenHeight * paddingTop)

    nrOfBallsProgress = display.newImageRect( uiGroup, "images/game_nrballs_progress.png", nrOfBallsProgressInit * (nrOfBalls / maxNrOfBalls), 142 )
    nrOfBallsProgress.anchorX = 0
    nrOfBallsProgress.x = screenLeft + (screenWidth * 0.1) - 26
    nrOfBallsProgress.y = screenTop + (screenHeight * paddingTop)

    local nrOfBallsBall = display.newImageRect( uiGroup, "images/game_nrballs_ball.png", 155, 155 )
    nrOfBallsBall.x = screenLeft + (screenWidth * 0.1)
    nrOfBallsBall.y = screenTop + (screenHeight * paddingTop)

    ballsText = display.newText( uiGroup, nrOfBalls, screenLeft + (screenWidth * 0.1), screenTop + (screenHeight * paddingTop), native.systemFont, 70 ) 
    ballsText:setFillColor( 0.65,  0.49, 0.918 )

    -- The Joker
    jokerImage = display.newImageRect( uiGroup, "images/game_joker.png", 106, 145 )
    jokerImage.x = screenLeft + (screenWidth * 0.50)
    jokerImage.y = screenTop + (screenHeight * paddingTop)
    jokerImage.alpha = 0.3

    -- Score bar
    local scoreBackground = display.newImageRect( uiGroup, "images/game_score_background.png", 410, 142 )
    scoreBackground.anchorX = 0
    scoreBackground.x = screenLeft + (screenWidth * 0.55)
    scoreBackground.y = screenTop + (screenHeight * paddingTop)
    scoreText = display.newText( uiGroup, score, screenLeft + (screenWidth * 0.83), scoreBackground.y, native.systemFont, 50 )
    scoreText.anchorX = scoreText.width

    -- Pause button
    local pauseButton = display.newImageRect( uiGroup, "images/game_button_pause.png", 105, 126 )
    pauseButton.x = screenLeft + (screenWidth * 0.93)
    pauseButton.y = screenTop + (screenHeight * paddingTop)

    pauseButton:addEventListener( "tap", pauseGame )

end

-- @DEBUG monitor Memory Usage
local printMemUsage = function()  
    local memUsed = (collectgarbage("count"))
    local texUsed = system.getInfo( "textureMemoryUsed" ) / 1048576 -- Reported in Bytes
   
    print("\n---------MEMORY USAGE INFORMATION---------")
    print("System Memory: ", string.format("%.00f", memUsed), "KB")
    print("Texture Memory:", string.format("%.03f", texUsed), "MB")
    print("------------------------------------------\n")
end

-- Only load memory monitor if running in simulator
if (dumpMemoryDebugMode == true and system.getInfo("environment") == "simulator") then
    Runtime:addEventListener( "enterFrame", printMemUsage)
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

    print ("Creating Game Scene")

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on screen

    physics.pause()  -- Temporarily pause the physics engine

	-- Set up display groups
	backGroup = display.newGroup()  -- Display group for the background image
	sceneGroup:insert( backGroup )  -- Insert into the scene's view group
	
	mainGroup = display.newGroup()  -- Display group for the balls, etc.
	sceneGroup:insert( mainGroup )  -- Insert into the scene's view group
	
	uiGroup = display.newGroup()    -- Display group for UI objects like the score
	sceneGroup:insert( uiGroup )    -- Insert into the scene's view group

    -- Setup display items
    setupBackground()
    setupStatusbar()
    setupExplosion()

    -- Setup sounds
    setupSounds()

    dropBalls(nrOfBalls)

end

-- show()
function scene:show( event )

    print ("Showing Game Scene")

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
        physics.start()
        Runtime:addEventListener( "collision", onCollision )
        gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )

        -- Start the music!
        if (musicOn) then
            audio.stop(1) -- Stop Menu Music on Channel 1
            audio.play( musicTrackGame, { channel = 1, loops = -1 } ) -- Start Game Music on Channel 1
        end
		
	end
end


-- hide()
function scene:hide( event )

    print("Hiding Game Scene")

	local sceneGroup = self.view
    local phase = event.phase
    
	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		timer.cancel( gameLoopTimer )

	elseif ( phase == "did" ) then
		-- Code here runs immediately after the scene goes entirely off screen
		Runtime:removeEventListener( "collision", onCollision )
		physics.pause()
		composer.removeScene( "game" )

		-- Stop the music!
        audio.stop() -- All channels are stopped
	end
end


-- destroy()
function scene:destroy( event )

    print("Destroying Game Scene")

	local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

    -- Dispose audio!
    disposeSounds()
    
    -- Dispose of all the balls in the table
    clearBallTable()

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
