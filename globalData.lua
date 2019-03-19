local composer = require( "composer" )
local applovin = require( "plugin.applovin" )

-- Pseudo-global space
local M = {}

    -- Apploving plugin
    function M.adListener( event )

        if ( event.phase == "init" ) then  -- Successful initialization
            print( "AppLovin event: initialization successful. Only done once" )

            -- Preload an AppLovin ad
            applovin.load( "interstitial" )
    
        elseif ( event.phase == "loaded" ) then  -- The ad was successfully loaded
            print( "AppLovin event: " .. tostring(event.type) .. " ad loaded successfully" )
        elseif ( event.phase == "failed" ) then  -- The ad failed to load
            print( "AppLovin event: " .. tostring(event.type) .. " ad failed to load" )
            print( event.type )
            print( event.isError )
            print( event.response )
        elseif ( event.phase == "displayed" or event.phase == "playbackBegan" ) then  -- The ad was displayed/played
            print( "AppLovin event: " .. tostring(event.type) .. " ad displayed" )
        elseif ( event.phase == "hidden" or event.phase == "playbackEnded" ) then  -- The ad was closed/hidden
            print( "AppLovin event: " .. tostring(event.type) .. " ad closed/hidden" )

            -- Goto Highscores
            composer.gotoScene( "highscores", { time=800, effect="crossFade" } )

        elseif ( event.phase == "clicked" ) then  -- The ad was clicked/tapped
            print( "AppLovin event: " .. tostring(event.type) .. " ad clicked/tapped" )
        end

    end
 
return M