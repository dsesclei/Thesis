system.activate("multitouch")

local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local board = nil

function definitions()
  -- Listener Function for Touch Events on the Board
  function board:touch( event )
    if not self.touches then
      self.touches = {}
    end
    
    if event.phase == "cancelled" or event.phase == "ended" then
      self.lastDistance = nil
      if self.touches[1].id == event.id then
        self.touches[1] = self.touches[2]
        self.touches[2] = nil
      else
        self.touches[2] = nil
      end
    end

    if event.phase == "began" then
      if #self.touches == 0 then
        self.touches[1] = event
        self.startX, self.startY = board.x, board.y
      elseif #self.touches == 2 then
        self.touches[1] = event
      else
        self.touches[2] = event
      end
    end

    if event.phase == "moved" then
      if self.touches[1].id == event.id then
        self.touches[1] = event
      else
        self.touches[2] = event
      end

      if #self.touches == 1 then
        -- Dragging
        board.x = self.startX + event.x - event.xStart
        board.y = self.startY + event.y - event.yStart
      else
        -- Pinch to Zoom Resizing
        x1, x2, y1, y2 = self.touches[1].x, self.touches[2].x, self.touches[1].y, self.touches[2].y
        distance = math.sqrt( math.pow( x1 - x2, 2 ) + math.pow( y1 - y2, 2 ) )

        if self.lastDistance then
          dd = distance - self.lastDistance
          
          self.xScale = self.xScale + dd / 300
          self.yScale = self.yScale + dd / 300
          print(self.xScale)
        end

        self.lastDistance = distance
      end
    end
  end
end

function scene:createScene( event )
	local group = self.view

  -- Create a solid white background
  background = display.newRect( 0, 0, display.contentWidth, display.contentHeight )

  board = display.newImage( "board.png" )
  board.width = 300
  board.height = 300
  -- Center the board
  board.x = display.contentWidth / 2
  board.y = display.contentHeight / 2
  group:addEventListener( "touch", board )

  definitions()

  group:insert( background )
  group:insert( board )
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
