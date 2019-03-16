local composer = require( "composer" )
local globalData = require( "globalData" )
display.setDefault("background", 1, 1, 1)

local developMode = false

-- Set Global data
globalData.difficulty = "Normal"
globalData.musicOn = true
globalData.fxOn = true 
 
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
    globalData.musicOn = false
    audio.setVolume( 0, { channel = 1 } )
    composer.gotoScene( "game" )
    --composer.setVariable( "finalScore", 500001 )
    --composer.gotoScene( "highscores")
else
    composer.gotoScene( "splash")
end

