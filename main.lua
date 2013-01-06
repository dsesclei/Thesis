-- hide the status bar on iOS devices
display.setStatusBar( display.HiddenStatusBar )

local storyboard = require "storyboard"

-- Load menu screen
storyboard.gotoScene( "menu" )
