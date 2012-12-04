local board = display.newImage( "board.png" )

-- Listener Function for Touch Events on the Board
-- Precondition: A touch begins, moves, or ends
-- Postcondition: The board is resized or moved
function board:touch( event )
  if self.touches and self.touches[1] then
    if self.touches[1].id == event.id then
      event.lastX = self.touches[1].lastX
      event.lastY = self.touches[1].lastY
      self.touches[1] = event
    elseif self.touches[2] and self.touches[2].id == event.id then
      event.lastX = self.touches[2].lastX
      event.lastY = self.touches[2].lastY
      self.touches[2] = event
    end
  else
    self.touches = {}
  end

  if event.phase == "cancelled" or event.phase == "ended" then
    display.getCurrentStage():setFocus( nil )
    self.lastDistance = nil
    if self.touches[1].id == event.id then
      self.touches[1] = self.touches[2]
      self.touches[2] = nil
    else
      self.touches[2] = nil
    end
  end

  if event.phase == "began" then
    display.getCurrentStage():setFocus( self )
    if #self.touches == 0 then
      self.touches[1] = event
    elseif #self.touches == 2 then
      self.touches[1] = event
    else
      self.touches[2] = event
    end
  end

  if event.phase == "moved" then
    local dx, dy = 0, 0
    
    if #self.touches == 1 then
      -- Dragging

      -- Used to calculate dx and dy in order to update the stones
      local lastX = self.x
      local lastY = self.y

      self.x = self.x + event.x - event.lastX
      self.y = self.y + event.y - event.lastY

      dx = self.x - lastX
      dy = self.y - lastY
    else
      -- Pinch to Zoom Resizing
      x1, x2, y1, y2 = self.touches[1].x, self.touches[2].x, self.touches[1].y, self.touches[2].y
      distance = math.sqrt( math.pow( x1 - x2, 2 ) + math.pow( y1 - y2, 2 ) )

      if self.lastDistance then
        dd = distance - self.lastDistance

        -- Enforce a maximum and minimum size
        scale = self.xScale + dd / 500
        scale = math.min( scale, 3 )
        scale = math.max( scale, 1 )
        
        self.xScale = scale
        self.yScale = scale
      end

      self.lastDistance = distance
    end

    self.stones:updateStones( dx, dy )
  end

  if self.touches[1] and self.touches[1].id == event.id then
    self.touches[1].lastX = event.x
    self.touches[1].lastY = event.y
  end

  if self.touches[2] and self.touches[2].id == event.id then
    self.touches[2].lastX = event.x
    self.touches[2].lastY = event.y
  end
end

board.stones = display.newGroup()

function board.stones:updateStones( dx, dy )
  for i = 1, board.stones.numChildren do
    stone = board.stones[i]
    if dx ~= 0 or dy ~= 0 then
      stone.x = stone.x + dx
      stone.y = stone.y + dy
    else
      stone.xScale = 0.09 * board.xScale
      stone.yScale = 0.09 * board.yScale
    end
  end
end

return board
