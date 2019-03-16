
local composer = require( "composer" )

local scene = composer.newScene()


local function test1()
	--local normal = 60
	--local ball1 = 20
	--local ball3 = 10
	--local ball7 = 8
	--local joker = 2
	local NORMAL = "Normal"
	local BOMB = "Bomb"
	local BALL7 = "7Balls"
	local BALL3 = "3Balls"
	local BALL1 = "1Balls"
	local JOKER = "Joker"

	

	local ballType        = {BALL7, BALL3, 	BALL1, 	JOKER, 	BOMB, 	NORMAL}
	local ballProbability = {1,		2,		5,		1,		1,		10}

	local ballArray = {}
	local index = 1

	-- Calculate total
	for i = 1, #ballProbability do
		local currentBall = ballType[i]
		local ballOccurancies = ballProbability[i]
		for j = 1, ballOccurancies do
			--print (currentBall)
			ballArray[index] = currentBall
			index = index + 1
		end
	end


	print ("Size: " .. #ballArray)
	for m = 1, #ballArray do
		print (ballArray[m])
	end
end

local function test2()
	local ballArray = {}

	print ("ballAraay" .. #ballArray)
	for i = 1, 5 do
		ballArray[i] = "abc"
	end

	print ("size: " .. #ballArray)
	for m = 1, #ballArray do
		print (ballArray[m])
	end
end

local function test3()
	print (math.random(1, 5))
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
	test3()



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
