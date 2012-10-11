local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local board, boardStartX, boardStartY = nil

local onTouch = function( event )
  if event.phase == "began" then
    boardStartX, boardStartY = board.x, board.y
  end

  board.x = boardStartX + event.x - event.xStart
  board.y = boardStartY + event.y - event.yStart
end

function scene:createScene( event )
	local group = self.view

  -- Create a solid white background
  display.newRect( 0, 0, display.contentWidth, display.contentHeight )

  board = display.newImage( "board.png" )
  board.width = 300
  board.height = 300
  -- Center the board
  board.x = display.contentWidth / 2
  board.y = display.contentHeight / 2
  Runtime:addEventListener( "touch", onTouch )
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
