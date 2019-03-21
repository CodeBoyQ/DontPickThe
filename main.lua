local composer = require( "composer" )
local globalData = require( "globalData" )
local applovin = require( "plugin.applovin" )
display.setDefault("background", 1, 1, 1)

local developMode = false

-- Set Global data defaults
globalData.difficulty = "Normal"
globalData.musicOn = true
globalData.fxOn = true 
globalData.lastGameScore = -1 -- Used for Highscores
globalData.lastGameDifficulty = globalData.difficulty -- Used to show Highscores

globalData.ballRadius = 150 -- Don't change this!

globalData.normalFrame = 1
globalData.ball1Frame = 2
globalData.ball3Frame = 3
globalData.ball7Frame = 4
globalData.jokerFrame = 5
globalData.bombFrame = 6

globalData.ballsSheetOptions =
{
    width = globalData.ballRadius * 2,
    height = globalData.ballRadius * 2,
    numFrames = 8
}

globalData.ballsImageSheet = graphics.newImageSheet( "images/balls_imagesheet.png", globalData.ballsSheetOptions )

globalData.sequencesBall = {
    {
        name = "notUsed",
        start = 1,
        count = 8,
        time = 800,
        loopCount = 0
    },
}

-- Initialize the AppLovin plugin (which will already preload the first ad)
local mySdkKey = "lJGWoNRVdEDq-xW2-C9DNx9VtFCH9vIWTfKcbuG8L6_zGVD8iN4L4rI8ET8T6_twep0gRzIBFk6zOa9DNZVbnX"
applovin.init( globalData.adListener, { sdkKey=mySdkKey, verboseLogging=false, testMode=false } )


-- Debug options defaults
globalData.ballContentVisible = false
globalData.dumpMemoryDebugMode = false
 
-- Hide status bar
display.setStatusBar( display.HiddenStatusBar )
 
-- Seed the random number generator
math.randomseed( os.time() )
 
-- Global Audio Setup
audio.reserveChannels( 1 )  -- Reserve channel 1 for background music
audio.setVolume( 0.3, { channel = 1 } ) -- Reduce the overall volume of the channel

-- Start the Game
if (developMode) then

    -- Content Values for debugging
    print( "Scaling: " .. display.pixelWidth / display.actualContentWidth )
    print( "Display: " .. display.contentWidth .. " "  .. display.contentHeight) -- Je werkveld zie config.lua > application > content
    print( "display.screenOriginX: "  .. display.screenOriginX) -- De absolute linkerkant van je scherm
    print( "display.screenOriginY: "  .. display.screenOriginY) -- De absolute bovenkant van je scherm
    print( "display.actualContentWidth: "  .. display.actualContentWidth) -- De totale actuele breedte van je scherm in pixels
    print( "display.actualContentHeight: "  .. display.actualContentHeight) -- De totale actuele hoogte van je scherm in pixels
    print( "display.contentHeight: "  .. display.contentHeight) -- De totale hoogte van je scherm in pixels
    print( "display.viewableContentHeight: "  .. display.viewableContentHeight) -- De totale hoogte van je scherm in pixels

    -- Settings for develop mode
    globalData.musicOn = false
    audio.setVolume( 0, { channel = 1 } )
    globalData.ballContentVisible = true
    globalData.dumpMemoryDebugMode = false

    -- Highscore screen
    --globalData.lastGameScore = 100 -- Used for Highscores
    --globalData.lastGameDifficulty = "Easy" -- Used to show Highscores
    --composer.gotoScene( "highscores" )

    composer.gotoScene( "tutorial")

else
    composer.gotoScene( "splash")
end

