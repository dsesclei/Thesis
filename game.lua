system.activate("multitouch")

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()

function scene:createScene( event )
	local group = self.view

  -- Create a solid white background
  local background = display.newRect( 0, 0, display.contentWidth, display.contentHeight )

  local board = require( "board" )
  board.width = 500
  board.height = 500
  -- Center the board
  board.x = display.contentWidth / 2
  board.y = display.contentHeight / 2
  Runtime:addEventListener( "touch", board )

  local panel = require( "panel" )
  panel:addEventListener( "touch", panel )
  panel.setBoard( board )

  group:insert( background )
  group:insert( board )
  group:insert( board.stones )
  group:insert( panel )
end

function scene:enterScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. start timers, load audio, start listeners, etc.)
	
end

function scene:exitScene( event )
	local group = self.view
	
	-- INSERT code here (e.g. stop timers, remove listenets, unload sounds, etc.)
	
end

function scene:destroyScene( event )
	local group = self.view
end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )

return scene

