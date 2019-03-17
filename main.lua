local composer = require( "composer" )
local globalData = require( "globalData" )
display.setDefault("background", 1, 1, 1)

local developMode = false

-- Set Global data defaults
globalData.difficulty = "Normal"
globalData.musicOn = true
globalData.fxOn = true 
globalData.lastGameScore = -1 -- Used for Highscores
globalData.lastGameDifficulty = globalData.difficulty -- Used to show Highscores

-- Debug options defaults
globalData.ballContentVisible = false
globalData.dumpMemoryDebugMode = false
 
-- Content Values for debugging
print( "Scaling: " .. display.pixelWidth / display.actualContentWidth )
print( "Display: " .. display.contentWidth .. " "  .. display.contentHeight) -- Je werkveld zie config.lua > application > content
print( "display.screenOriginX: "  .. display.screenOriginX) -- De absolute linkerkant van je scherm
print( "display.screenOriginY: "  .. display.screenOriginY) -- De absolute bovenkant van je scherm
print( "display.actualContentWidth: "  .. display.actualContentWidth) -- De totale actuele breedte van je scherm in pixels
print( "display.actualContentHeight: "  .. display.actualContentHeight) -- De totale actuele hoogte van je scherm in pixels
print( "display.contentHeight: "  .. display.contentHeight) -- De totale hoogte van je scherm in pixels
print( "display.viewableContentHeight: "  .. display.viewableContentHeight) -- De totale hoogte van je scherm in pixels

-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )
 
-- Seed the random number generator
math.randomseed( os.time() )
 
-- Reserve channel 1 for background music
audio.reserveChannels( 1 )  -- Menu and Game music

-- Reduce the overall volume of the channel
audio.setVolume( 0.3, { channel = 1 } )

-- Go to the menu screen
if (developMode) then
    -- Settings for develop mode
    globalData.musicOn = false
    audio.setVolume( 0, { channel = 1 } )
    globalData.ballContentVisible = true
    globalData.dumpMemoryDebugMode = false

    -- Highscore screen
    --globalData.lastGameScore = 100 -- Used for Highscores
    --globalData.lastGameDifficulty = "Easy" -- Used to show Highscores
    --composer.gotoScene( "highscores" )

    composer.gotoScene( "game")
else
    composer.gotoScene( "splash")
end

