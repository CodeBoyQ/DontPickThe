
local composer = require( "composer" )

local scene = composer.newScene()

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local physics = require( "physics" )
physics.start()
physics.setGravity( 0, 19.8 )
 
-- Initialize variables
local nrOfBalls = 25
local joker = 0
local score = 0
 
local ballsTable = {}
 
local gameLoopTimer
local jokerText
local scoreText
local ballsText
local messageScreen

local backGroup
local mainGroup
local uiGroup

-- Probability system (order small to large chance) minimum is 10
local chance7Balls = 100 -- One out of x balls each turn will give you 7 extra balls
local chance3Balls = 30 -- One out of x balls each turn will give you 3 extra balls
local chance1Balls = 10 -- One out of x balls each turn will give you 1 extra balls
local chanceJoker = 10 -- One out of x balls each turn will give you an extra life

-- Debug options
local ballContentVisible = false

-- The height of the content area where the balls are released
local ballReleaseAreaHeight = 800

-- Actual device screen values (This will differ per device)
local screenTop = display.screenOriginY
local screenLeft = display.screenOriginX
local screenHeight = display.actualContentHeight
local screenWidth = display.actualContentWidth

local explosionSound
local fireSound
local musicTrack

local floor

local function updateText()
    ballsText.text = "Balls: " .. nrOfBalls
    jokerText.text = "Joker: " .. joker
    scoreText.text = "Score: " .. score
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
        updateText()
        physics.addBody( floor, "static", {bounce=0.2})
        for i = #ballsTable, 1, -1 do
            local thisBall = ballsTable[i]
            display.remove( thisBall )
            table.remove( ballsTable, i )
        end
        initialiseBalls(nrOfBalls)
    end
end

local function playTapAnimation(ballType)
    physics.removeBody( floor )
    print(ballType)

    -- Show the content of all the balls
    for i = #ballsTable, 1, -1 do
        local thisBall = ballsTable[i]
        showBallContent(thisBall)
    end

    -- Play the animation and after that determine the next step for the game
    messageScreen = display.newImageRect( mainGroup, "images/message.png", 200, 100)
    messageScreen.x = display.contentCenterX
    messageScreen.y = display.contentCenterY
    
    transition.to( messageScreen, { time=3000, alpha=0, width=1600, height=800, onComplete=determineGamestatus })

end

local function tapBall( event )

    local ball = event.target

    if (ball.name == "Bomb") then
        -- Player looses a life
        joker = joker - 1
    elseif (ball.name == "7Balls") then
        -- Player gets 7 extra balls and goes to the next level
        nrOfBalls = nrOfBalls + 7
    elseif (ball.name == "3Balls") then
        -- Player gets 3 extra balls and goes to the next level
        nrOfBalls = nrOfBalls + 3
    elseif (ball.name == "1Balls") then
        -- Player gets 1 extra balls and goes to the next level
        nrOfBalls = nrOfBalls + 1
    elseif (ball.name == "Joker") then
        -- Player gets 1 extra life
        joker = 1
        nrOfBalls = nrOfBalls - 1
    else
        -- Normal
        nrOfBalls = nrOfBalls - 1
    end

    playTapAnimation(ball.name)

end

-- This function is not local, since it is used in multiple places
function initialiseBalls(numberOfBalls)

    -- Calculate the ball-radius according to the number of balls
    local ballRadius = math.floor((screenHeight * 0.60) / math.sqrt(numberOfBalls) / 2)

    local ballReleaseAreaMinX = screenLeft + ballRadius
    local ballReleaseAreaMaxX = screenLeft + screenWidth - ballRadius
    local ballReleaseAreaMinY = screenTop - ballReleaseAreaHeight + ballRadius
    local ballReleaseAreaMaxY = screenTop - ballRadius

    -- Create the balls
    local bomb = math.random(1, numberOfBalls)

    for i = numberOfBalls, 1, -1 do

        -- Initiate ball Note: Ball template is needed to have a reference for deletion after all the balls are created        
        local newBall = display.newImageRect( mainGroup, "images/ball_bomb.png", 2 * ballRadius, 2 * ballRadius )

        -- Determine the ball type
        if (bomb == i) then
            newBall.name = "Bomb"
        elseif (math.random(1, chance7Balls) == 7) then
            newBall.name = "7Balls"
        elseif (math.random(1, chance3Balls) == 3) then
            newBall.name = "3Balls"
        elseif (math.random(1, chance1Balls) == 1) then
            newBall.name = "1Ball"
        elseif (math.random(1, chanceJoker) == 8) then
            newBall.name = "Joker"
        else
            newBall.name = "Normal"
        end

        -- Make the content visible or not
        if (ballContentVisible == true) then
            showBallContent(newBall)
        else
            hideBallContent(newBall)
            --local height = newBall.height
            --local width = newBall.width
            --newBall = display.newImageRect( mainGroup, "images/ball_joker.png", width, height) 
        end 
        
        -- Position ball in random starting position
        newBall.x = math.random (ballReleaseAreaMinX, ballReleaseAreaMaxX)
        newBall.y = math.random (ballReleaseAreaMinY, ballReleaseAreaMaxY)

        -- Add physics and listener
        physics.addBody( newBall, "dynamic", { radius=ballRadius, density=50, friction = 0.3, bounce=0.2 } )
        newBall:addEventListener( "tap", tapBall )

        -- Insert the ball in to the table
        table.insert( ballsTable, newBall )

    end

    --display.remove(ballTemplate)

end

function showBallContent(ball) 
    print("Start showBallContent")
    local height = ball.height
    local width = ball.width
    local image
    if (ball.name == "Bomb") then
        image = "images/ball_bomb.png"
    elseif (ball.name == "7Balls") then
        image = "images/ball_7.png"
    elseif (ball.name == "3Balls") then
        image = "images/ball_3.png"
    elseif (ball.name == "1Balls") then
        image = "images/ball_1.png"
    elseif (ball.name == "Joker") then
        image = "images/ball_joker.png"
    else
        image = "images/ball.png"
    end
    ball = display.newImageRect( mainGroup, image, width, height) 
end

function hideBallContent(ball)
    --print("Start hideBallContent")
    local height = ball.height
    local width = ball.width
    ball = display.newImageRect( mainGroup, "images/ball_joker.png", width, height) 
end
 
local function gameLoop()
 
    -- Actions that keep continueing

end
 
local function onCollision( event )
 
    if ( event.phase == "began" ) then
 
        local obj1 = event.object1
        local obj2 = event.object2
 
        if ( ( obj1.myName == "laser" and obj2.myName == "asteroid" ) or
             ( obj1.myName == "asteroid" and obj2.myName == "laser" ) )
        then
            -- Remove both the laser and asteroid
            display.remove( obj1 )
			display.remove( obj2 )
			
			-- Play explosion sound!
			audio.play( explosionSound )
 
            for i = #ballsTable, 1, -1 do
                if ( ballsTable[i] == obj1 or ballsTable[i] == obj2 ) then
                    table.remove( ballsTable, i )
                    break
                end
            end
 
            -- Increase score
            score = score + 100
            scoreText.text = "Score: " .. score
 
        elseif ( ( obj1.myName == "ship" and obj2.myName == "asteroid" ) or
                 ( obj1.myName == "asteroid" and obj2.myName == "ship" ) )
        then
            if ( died == false ) then
				died = true
				
				-- Play explosion sound!
				audio.play( explosionSound )
 
            end
        else
        end
    end
end


-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

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

    -- Load the background and walls
    -- The walls are postioned to the left, bottom and right of the actual device screen
	local background = display.newImageRect( backGroup, "images/background.png", "720", "1140" )
	background.x = display.contentCenterX
    background.y = display.contentCenterY

    local leftWall = display.newImageRect( backGroup, "images/wall.png", 100, screenHeight + ballReleaseAreaHeight ) -- The ballReleaseAreaHeight area is where the balls are created to fall in to the screen
    leftWall.x = screenLeft - 50
    leftWall.y = display.contentCenterY - (ballReleaseAreaHeight/2)
    physics.addBody( leftWall, "static")

    local rightWall = display.newImageRect( backGroup, "images/wall.png", 100, screenHeight + ballReleaseAreaHeight) -- The ballReleaseAreaHeight area is where the balls are created to fall in to the screen
    rightWall.x = screenLeft + screenWidth + 50
    rightWall.y = display.contentCenterY - (ballReleaseAreaHeight/2)
    physics.addBody( rightWall, "static")
    
    floor = display.newImageRect( backGroup, "images/wall.png", display.actualContentWidth, 100 )
    floor.x = display.contentCenterX
    floor.y = screenTop + screenHeight + 50
    physics.addBody( floor, "static", {bounce=0.2})

	-- Display information
    ballsText = display.newText( uiGroup, "Balls: " .. nrOfBalls, screenLeft + (screenWidth * 0.2), screenTop + (screenHeight * 0.1), native.systemFont, 36 ) 
    jokerText = display.newText( uiGroup, "Joker: " .. joker, screenLeft + (screenWidth * 0.5), screenTop + (screenHeight * 0.1), native.systemFont, 36 )
    scoreText = display.newText( uiGroup, "Score: " .. score, screenLeft + (screenWidth * 0.8), screenTop + (screenHeight * 0.1), native.systemFont, 36 )

    explosionSound = audio.loadSound( "audio/explosion.wav" )
	fireSound = audio.loadSound( "audio/fire.wav" )
	
    musicTrack = audio.loadStream( "audio/80s-Space-Game_Looping.wav")

    initialiseBalls(nrOfBalls)

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		physics.start()
        Runtime:addEventListener( "collision", onCollision )
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
		Runtime:removeEventListener( "collision", onCollision )
		physics.pause()
		composer.removeScene( "game" )

		-- Stop the music!
		audio.stop( 1 )
	end
end


-- destroy()
function scene:destroy( event )

	local sceneGroup = self.view
	-- Code here runs prior to the removal of scene's view

	-- Dispose audio!
	audio.dispose( explosionSound )
	audio.dispose( fireSound )
    audio.dispose( musicTrack )
    
    --TODO dispose of all the balls in the table

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
