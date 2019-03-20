
local composer = require( "composer" )
local globalData = require( "globalData" )
local applovin = require( "plugin.applovin" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

-- Actual device screen values (This will differ per device)
local screenTop = display.screenOriginY
local screenLeft = display.screenOriginX
local screenHeight = display.actualContentHeight
local screenWidth = display.actualContentWidth

-- Physics variables
local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 70.8 )
local ballBounceRate = 0.7
local ballFriction = 0.8
local ballDensity = 1.6
local wallDensity = 0.1
local wallFriction = 0.3
local wallBounceRate = 0.7
local minVelocityForCollision = display.contentHeight / 3.0 -- Collision for the balls and walls is only detected if one of the ball has a velocity greater than x. This is to prevent continuous collision detection, because the balls are in constant motion, even when they tend to stand still
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
local ballTapAllowed = true -- This variable is used to make sure that only one ball can be clicked simultaniously during one game

-- Message items
local messageBackground

-- UI Groups
local backGroup
local mainGroup
local uiGroup

-- Object name constants
local BOMB = "Bomb"
local BALL7 = "7Balls"
local BALL3 = "3Balls"
local BALL1 = "1Balls"
local JOKER = "Joker"
local NORMAL = "Normal"
local WALL = "Wall"

local normalFrame = 1
local ball1Frame = 2
local ball3Frame = 3
local ball7Frame = 4
local jokerFrame = 5
local bombFrame = 6

-- Game settings
local maxNrOfBalls = 25

-- Each difficultyLevel has a different balance for the probility of certain types of balls to occur
-- E.g. a ballType = {A, B, C} and ballProbability = {30, 10, 50}
-- Means that each ball has a chance of 30/90 to be "A", a chance of 10/90 to be "B" and a chance of 50/90 to be "C"
-- Use the ballProbabilityEasy to design the difficulty levels. The total amount is not important. It is the balance that counts
-- NOTE: Each game has at lest 1 BOMB. The BOMB below creates extra BOMBS
-- NOTE: Verdeling Goed (BALL7, BALL3, BALL1), Neutraal (NORMAL) en Slecht (BOMB)
local ballType              = {BALL7, BALL3, 	BALL1, 	JOKER, 	BOMB, 	NORMAL}    
local ballProbabilityEasy   = {3,		5,		10,		5,		10,		50} -- 40, 10, 50
local ballProbabilityNormal = {3,		7,		15,		5,		10,		60} -- 30, 10, 60
local ballProbabilityHard   = {2,		6,		10,		2,		40,		30} -- 20, 40, 30

-- The ballTypes and ballProbability variables determine the ballProbabilitySequence
-- e.g. ballTypes = {A, B, C} and a ballProbability = {1, 2, 3}
-- will result in a ballProbabilitySequence = {A, B, B, C, C, C}
local ballProbabilitySequence = {}
    
-- The boundaries of the area (out of screen) from where the balls will be released and the radius of the balls
local ballReleaseAreaHeight = screenHeight
local ballReleaseAreaMinX = screenLeft + globalData.ballRadius
local ballReleaseAreaMaxX = screenLeft + screenWidth - globalData.ballRadius
local ballReleaseAreaMinY = screenTop - ballReleaseAreaHeight + globalData.ballRadius
local ballReleaseAreaMaxY = screenTop - globalData.ballRadius

-- Sound variables
local musicTrackGame
local ballBallBounceSound
local ballWallBounceSound
local tapBallSound
local tapNegativeBallSound
local tapPositiveBallSound
local tapPositiveBallExtraSound

local function pauseGame()
    gameIsPaused = true
	local options = { effect = "fade", time = 200}
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

-- Constructs the ballProbabilitySequence for the chosen difficulty level
local function setGameDifficulty()
    local ballProbability
    if (globalData.difficulty == "Easy") then
        ballProbability = ballProbabilityEasy
    elseif (globalData.difficulty == "Normal") then
        ballProbability = ballProbabilityNormal
    elseif (globalData.difficulty == "Hard") then
        ballProbability = ballProbabilityHard
    end

    local index = 1
    for i = 1, #ballProbability do
		local currentBall = ballType[i]
        local ballOccurancies = ballProbability[i]
        print ("" .. currentBall .. " " .. ballOccurancies)
        for j = 1, ballOccurancies do
            
			ballProbabilitySequence[index] = currentBall
			index = index + 1
		end
    end

    --print ("Size: " .. #ballProbabilitySequence)
    --local sequence = ""
    --for m = 1, #ballProbabilitySequence do
    --    sequence = sequence .. " " .. ballProbabilitySequence[m]
    --end
    --print ("Sequence: " .. sequence)
end

local function playFx(sound)
    if (globalData.fxOn) then
        audio.play( sound )
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

local function gameOver()
    globalData.lastGameScore = score
    globalData.lastGameDifficulty = globalData.difficulty

    if (applovin.isLoaded( "interstitial" )) then
        -- The ad is loaded at the beginning of the game, so we asume that it will be loaded by now
        applovin.show( "interstitial" )
    else
        -- This shouldn't happen, because it meanse that the ad hasn't been loaded
        composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
    end
end

local function determineGamestatus()
    if (joker < 0) then
        -- Game Over
        gameOver()
    elseif (nrOfBalls == 0) then
        -- Ultimate Winner
    else
        -- Next Level
        physics.addBody( floor, "static", { density=wallDensity, friction=wallFriction, bounce=wallBounceRate })
        clearBallTable()
        ballTapAllowed = true
        dropBalls(nrOfBalls)
    end
end

local function emissionAnimation(tappedBall)
  emitter.x = tappedBall.x
  emitter.y = tappedBall.y
  emitter:start()
end

local function handleTapBallEvent( event )

    if (ballTapAllowed) then

        ballTapAllowed = false

        -- Check the tapped ball type
        local ball = event.target

        transition.to( ball, { time=1000, alpha=0, transition=easing.inOutBounce} )

        local message
        local messageType = "Good" -- Good or Bad
        local messageSize = 100

        -- Play explotion particle
        emissionAnimation (ball)

        if (ball.name == BOMB) then
            -- Player looses a life
            joker = joker - 1
            message = "Negative Energy!!!"
            playFx(tapNegativeBallSound)
            if (joker == 0) then
                message = message .. "\nLuckily you had a negative \n energy blocker :-)"
                messageSize =70
            else
                message = message .. "\nGAME OVER!!"
                nrOfBalls = 0 -- You do not get any more points after Game Over
                messageType = "Bad"
            end           
        elseif (ball.name == BALL7) then
            -- Player gets 7 extra balls and goes to the next level
            nrOfBalls = nrOfBalls + 7
            message = "Good energy!! :-) \n+7!"
            playFx(tapPositiveBallSound)
        elseif (ball.name == BALL3) then
            -- Player gets 3 extra balls and goes to the next level
            nrOfBalls = nrOfBalls + 3
            message = "Good energy!! \n+3!"
            playFx(tapPositiveBallSound)
        elseif (ball.name == BALL1) then
            -- Player gets 1 extra balls and goes to the next level
            nrOfBalls = nrOfBalls + 1
            message = "Good energy!! \n+1!"
            playFx(tapPositiveBallSound)
        elseif (ball.name == JOKER) then
            -- Player gets a Joker (Negative Energy Blocker)
            joker = 1
            nrOfBalls = nrOfBalls - 1
            message = "You found a \nNegative energy \nblocker!"
            messageSize = 70
            playFx(tapPositiveBallSound)
            playFx(tapPositiveBallExtraSound)
        else
            -- Normal
            nrOfBalls = nrOfBalls - 1
            message = "You have \n chosen wisely!"
            playFx(tapBallSound)
        end

        -- There can only be a maximum of [maxNrOfBalls] in the game
        if (nrOfBalls > maxNrOfBalls) then
            local overflowBonus = (nrOfBalls - maxNrOfBalls) * 50
            nrOfBalls = maxNrOfBalls
            score = score + overflowBonus -- You get bonus points for the balls that you've lost because they exceed
            message = message .. "\n Overflow Bonus!! " .. overflowBonus
        end

        -- Update score and statusbar
        score = score + nrOfBalls
        updateStatubar()

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
    else
        print ("Ball tapped not allowed more than once!")
    end

end

function getRandomBallType()
    -- Pick a random ball from the ballProbabilitySequence
    local randomIndex = math.random(1, #ballProbabilitySequence)
    return ballProbabilitySequence[randomIndex]
end

-- This function is not local, since it is used in multiple places
function dropBalls(numberOfBalls)

    -- Determine which ball is the bomb
    local bomb = math.random(1, numberOfBalls)

    -- Drop the balls
    for i = numberOfBalls, 1, -1 do
  
        -- Create the ball and insert it to the table
        newBall = display.newSprite( mainGroup, globalData.ballsImageSheet, globalData.sequencesBall )
        table.insert( ballsTable, newBall )

        -- Determine the ball type
        if (bomb == i) then
            newBall.name = BOMB
        else
            newBall.name = getRandomBallType()
        end

        -- Make the content visible or not
        if (globalData.ballContentVisible == true) then
            showBallContent(newBall)
        else
            hideBallContent(newBall)
        end 
        
        -- Position ball in random starting position
        newBall.x = math.random (ballReleaseAreaMinX, ballReleaseAreaMaxX)
        newBall.y = math.random (ballReleaseAreaMinY, ballReleaseAreaMaxY)

        -- Add physics and listener
        physics.addBody( newBall, "dynamic", { radius=globalData.ballRadius, density=ballDensity, friction = ballFriction, bounce=ballBounceRate } )
        newBall:addEventListener( "tap", handleTapBallEvent )

    end

end

function showBallContent(ball) 
    if (ball.name == BOMB) then
        ball:setFrame(bombFrame)
    elseif (ball.name == BALL7) then
        ball:setFrame(ball7Frame)
    elseif (ball.name == BALL3) then
        ball:setFrame(ball3Frame)
    elseif (ball.name == BALL1) then
        ball:setFrame(ball1Frame)
    elseif (ball.name == JOKER) then
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

local function onPreCollision( event )

    -- Can be used to do preCollision tasks

end
 
local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2

        -- Calculate the velocity of both objects
        local vx1, vy1 = obj1:getLinearVelocity()
        local vx2, vy2 = obj2:getLinearVelocity()

        local velocity1 = math.abs(vx1) + math.abs(vy1)
        local velocity2 = math.abs(vx2) + math.abs(vy2)
    
        -- Only play collision sounds if one of the two items has a velocity higher than minVelocityForCollision
        if (velocity1 > minVelocityForCollision or velocity2 > minVelocityForCollision) then
            if ( obj1.name == WALL or obj2.name == WALL ) then
                -- Ball hits wall
                if (globalData.fxOn) then
                    --audio.play( ballWallBounceSound )
                end
            elseif ( obj1.name ~= WALL and obj2.name ~= WALL ) then
                -- Ball to ball collision
                -- Also check if the y position of the ball is in the viewable area
                if (globalData.fxOn and (obj1.y > screenTop and obj1.y < (screenTop + screenHeight))) then
                    audio.play( ballBallBounceSound )
                end
            end
        end
    end
end

local function  setupExplosion()
    local dx = 200
    local p = "images/particle.png"
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
    ballBallBounceSound = audio.loadSound ("audio/ball_ball_bounce.wav")
    ballWallBounceSound = audio.loadSound ("audio/ball_wall_bounce.wav")
    musicTrackGame = audio.loadStream( "audio/gameLoop.wav")
    tapBallSound = audio.loadStream( "audio/tapBall.wav")
    tapNegativeBallSound = audio.loadStream( "audio/tapNegative.wav")
    tapPositiveBallSound = audio.loadStream( "audio/tapPositive.wav")
    tapPositiveBallExtraSound = audio.loadStream( "audio/tapPositive_extra.wav")
    
end

local function disposeSounds()
    audio.stop() -- All sounds on all Channels must be stopped before disposing them. This counts for the Music playing on Channel 1
    audio.dispose( musicTrackGame )
    audio.dispose( ballBallBounceSound )
    audio.dispose( ballWallBounceSound )
    audio.dispose( tapBallSound)
    audio.dispose( tapPositiveBallSound)
    audio.dispose( tapPositiveBallExtraSound)
    audio.dispose( tapNegativeBallSound)
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
    leftWall.name = WALL
    physics.addBody( leftWall, "static", { density=wallDensity, friction=wallFriction, bounce=wallBounceRate })

    local rightWall = display.newImageRect( backGroup, "images/wall.png", 100, screenHeight + ballReleaseAreaHeight) -- The ballReleaseAreaHeight area is where the balls are created to fall in to the screen
    rightWall.x = screenLeft + screenWidth + 50
    rightWall.y = display.contentCenterY - (ballReleaseAreaHeight/2)
    rightWall.name = WALL
    physics.addBody( rightWall, "static", { density=wallDensity, friction=wallFriction, bounce=wallBounceRate })
    
    -- Floor is a global variable since it will be used on multiple places (e.g. )
    floor = display.newImageRect( backGroup, "images/wall.png", display.actualContentWidth, 100 )
    floor.x = display.contentCenterX
    floor.y = screenTop + screenHeight + 50
    floor.name = WALL
    physics.addBody( floor, "static", { density=wallDensity, friction=wallFriction, bounce=wallBounceRate })
    
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
    scoreText = display.newText( uiGroup, score, scoreBackground.x + scoreBackground.width - 50, scoreBackground.y, native.systemFont, 50 )
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
if (globalData.dumpMemoryDebugMode == true and system.getInfo("environment") == "simulator") then
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

    -- Setup game level
    setGameDifficulty()

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

    -- At the start of each game, preload an ad, to make it show faster after the game is over
    if (not applovin.isLoaded( "interstitial" )) then
        applovin.load( "interstitial" )
    end

    -- Start the game
    dropBalls(nrOfBalls)

end

-- show()
function scene:show( event )

	local sceneGroup = self.view
    local phase = event.phase
    
    local shutdownGame = false
    if (event.params ~= nil) then
        shutdownGame = event.params.shutdownGame
    end

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then

        -- Code here runs when the scene is entirely on screen
        print ("Showing Game Scene")
        if (gameIsPaused) then
            -- Resuming game from a paused state
            print("-Returning from Paused state")
            gameIsPaused = false

            if (shutdownGame) then
                -- The user requested to go to the Main Menu. Gracefully shutdown
                print ( "Shut down the game!")
                gameOver()
            end
        
        else

            -- Starting new game
            print("-Starting new game")
            physics.start()
            Runtime:addEventListener( "preCollision", onPreCollision )
            Runtime:addEventListener( "collision", onCollision )
            gameLoopTimer = timer.performWithDelay( 500, gameLoop, 0 )

            -- Inititialise the Music
            audio.stop(1) -- Stop Menu Music on Channel 1
            audio.play( musicTrackGame, { channel = 1, loops = -1 } ) -- Start Game Music on Channel 1
		end
	end
end


-- hide()
function scene:hide( event )

	local sceneGroup = self.view
    local phase = event.phase
    
	if ( phase == "will" ) then
		-- Code here runs when the scene is on screen (but is about to go off screen)
		timer.cancel( gameLoopTimer )

    elseif ( phase == "did" ) then
        -- Code here runs immediately after the scene goes entirely off screen
        print("Hiding Game Scene")
        if (gameIsPaused) then
            -- Hiding scene, because the game is paused. Don't clean up anything
            print("-Going to Pause screen")
        else
            -- Ending the game. Clean up!
            print("-End of Game")
            Runtime:removeEventListener( "collision", onCollision )
            Runtime:removeEventListener( "preCollision", onPreCollision )
            physics.pause()
            composer.removeScene( "game" )
            audio.stop() -- All channels are stopped
        end
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
