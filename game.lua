
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
local lives = 3
local nrOfBalls = 25
local score = 0
 
local ballsTable = {}
 
local gameLoopTimer
local livesText
local scoreText
local debugText

local backGroup
local mainGroup
local uiGroup

-- Probability system (order small to large chance) minimum is 10
local chance7Balls = 100 -- One out of x balls each turn will give you 7 extra balls
local chance3Balls = 30 -- One out of x balls each turn will give you 3 extra balls
local chance1Balls = 10 -- One out of x balls each turn will give you 1 extra balls
local chanceJoker = 10 -- One out of x balls each turn will give you an extra life

-- Debug options
local showBallContent = true

-- Viewport settings, Everything in the game is set relatively to the viewport instead of the display, so I can use content settings to zoom out for developing purposes
local viewportWidth = 768 
local viewportHeight = 1024
local ballReleaseAreaHeight = 500

-- Calculated variables
local viewportLeft = display.contentCenterX - (viewportWidth / 2)
local viewportRight = display.contentCenterX + (viewportWidth / 2)
local viewportTop = display.contentCenterY - (viewportHeight / 2)
local viewportBottom = display.contentCenterY + (viewportHeight / 2)

local explosionSound
local fireSound
local musicTrack

local floor

local function updateText()
    livesText.text = "Lives: " .. lives
    scoreText.text = "Score: " .. score
end

local function addFloorBody()
    physics.addBody( floor, "static", {bounce=0.2})
end

local function endAfterTapAnimation()
    updateText()
    addFloorBody()
    resultText = display.newText( mainGroup, "Normal 222 Ball", display.contentCenterX, display.contentCenterY - 100, native.systemFont, 150 )
end

local function playAfterTapAnimation(ballType)
    physics.removeBody( floor )
    print(ballType)

    resultText = display.newText( mainGroup, "Normal Ball", display.contentCenterX, display.contentCenterY - 100, native.systemFont, 150 )

    transition.to( resultText, { time=3000, alpha=0, onComplete=endAfterTapAnimation })
    --display.remove(resultText)
    --timer.performWithDelay(4000, addFloorBody)

end



local function doLevelUp()
    -- Clear the ballTable
    for i = #ballsTable, 1, -1 do
        local thisBall = ballsTable[i]
        display.remove( thisBall )
        table.remove( ballsTable, i )
    end
end

local function doGameOver()
	composer.setVariable( "finalScore", score )
    composer.gotoScene( "highscores", { time=800, effect="crossFade" } )
end

local function tapBall( event )

    local ball = event.target

    if (ball.name == "Bomb") then
        -- Player looses a life
        lives = lives - 1
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
        lives = lives + 1
        nrOfBalls = nrOfBalls - 1
    else
        -- Normal
        nrOfBalls = nrOfBalls - 1
    end

    playAfterTapAnimation(ball.name)

    if (lives == 0) then
        -- goto Game Over
    elseif (nrOfBalls == 0) then
        -- goto Ultimate Winner
    else
        -- goto Next
        --doLevelUp()
    end

end

local function initialiseBalls(numberOfBalls)

    -- Calculate the ball-radius according to the number of balls
    local ballRadius = math.floor((viewportHeight - 300) / math.sqrt(numberOfBalls) / 2)

    local ballReleaseAreaMinX = viewportLeft + ballRadius
    local ballReleaseAreaMaxX = viewportRight - ballRadius
    local ballReleaseAreaMinY = viewportTop - ballReleaseAreaHeight + ballRadius
    local ballReleaseAreaMaxY = viewportTop - ballRadius

    -- Create the balls
    local bomb = math.random(1, numberOfBalls)

    for i = numberOfBalls, 1, -1 do

        local newBall
        
        -- Decide what type of ball it is Normal, Bomb, Joker or 1,3,7Balls
        if (bomb == i) then
            if (showBallContent == true) then
                newBall = display.newImageRect( mainGroup, "images/ball_bomb.png", 2 * ballRadius, 2 * ballRadius)
            end
            newBall.name = "Bomb"
        elseif (math.random(1, chance7Balls) == 7) then
            if (showBallContent == true) then
                newBall = display.newImageRect( mainGroup, "images/ball_7.png", 2 * ballRadius, 2 * ballRadius)
            end
            newBall.name = "7Balls"
        elseif (math.random(1, chance3Balls) == 3) then
            if (showBallContent == true) then
                newBall = display.newImageRect( mainGroup, "images/ball_3.png", 2 * ballRadius, 2 * ballRadius)
            end
            newBall.name = "3Balls"
        elseif (math.random(1, chance1Balls) == 1) then
            if (showBallContent == true) then
                newBall = display.newImageRect( mainGroup, "images/ball_1.png", 2 * ballRadius, 2 * ballRadius)
            end
            newBall.name = "1Ball"
        elseif (math.random(1, chanceJoker) == 8) then
            if (showBallContent == true) then
                newBall = display.newImageRect( mainGroup, "images/ball_joker.png", 2 * ballRadius, 2 * ballRadius)
            end
            newBall.name = "Joker"
        else 
            newBall = display.newImageRect( mainGroup, "images/ball.png", 2 * ballRadius, 2 * ballRadius )
            newBall.name = "Normal"
        end
        
        -- Position ball in random starting position
        newBall.x = math.random (ballReleaseAreaMinX, ballReleaseAreaMaxX)
        newBall.y = math.random(ballReleaseAreaMinY, ballReleaseAreaMaxY)

        -- Add physics and listener
        physics.addBody( newBall, "dynamic", { radius=ballRadius, density=50, friction = 0.3, bounce=0.2 } )
        newBall:addEventListener( "tap", tapBall )

        -- Insert the ball in to the table
        table.insert( ballsTable, newBall )
    end
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
 
                -- Update lives
                lives = lives - 1
                livesText.text = "Lives: " .. lives
 
                if ( lives == 0 ) then
                    display.remove( ship )
                    timer.performWithDelay( 2000, endGame )
                else
                    ship.alpha = 0
                    --timer.performWithDelay( 1000, restoreShip )
                end
            end
        else
            --debugText.text = "raak";
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
	local background = display.newImageRect( backGroup, "images/background.png", viewportWidth, viewportHeight )
	background.x = display.contentCenterX
    background.y = display.contentCenterY
    
    local leftWall = display.newImageRect( backGroup, "images/block.png", 100, viewportHeight + ballReleaseAreaHeight ) -- The ballReleaseAreaHeight area is where the balls are created to fall in to the screen
    leftWall.x = viewportLeft - 50
    leftWall.y = display.contentCenterY - (ballReleaseAreaHeight/2)
    physics.addBody( leftWall, "static")
    
    local rightWall = display.newImageRect( backGroup, "images/block.png", 100, viewportHeight + ballReleaseAreaHeight) -- The ballReleaseAreaHeight area is where the balls are created to fall in to the screen
    rightWall.x = viewportRight + 50
    rightWall.y = display.contentCenterY - (ballReleaseAreaHeight/2)
    physics.addBody( rightWall, "static")
    
    floor = display.newImageRect( backGroup, "images/block.png", viewportWidth, 100 )
    floor.x = display.contentCenterX
    floor.y = viewportBottom + 50
    addFloorBody() -- The floor will be removed and added when necessary, so a function is needed

	-- Display lives and score
	livesText = display.newText( uiGroup, "Lives: " .. lives, viewportLeft + 200, viewportTop + 80, native.systemFont, 36 )
    scoreText = display.newText( uiGroup, "Score: " .. score, viewportLeft + 400, viewportTop + 80, native.systemFont, 36 )
    debugText = display.newText( uiGroup, "Debug", viewportLeft + 600, viewportTop + 80, native.systemFont, 36 ) 

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
