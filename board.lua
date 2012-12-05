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
      self.x = self.x + event.x - event.lastX
      self.y = self.y + event.y - event.lastY
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

    self.stones:updateStones()
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

-- Precondition: A stone that has been dropped on the screen
-- Postcondition: If the stone falls on the grid, it is assigned a row and column.
--                otherwise, the function returns false and it is deleted.
function board.stones:snapToGrid( stone )
  local x = stone.x - board.x + (board.width * board.xScale) / 2
  local y = stone.y - board.y + (board.height * board.yScale) / 2
  local col = math.round( (x * 18) / (board.width * board.xScale) )
  local row = math.round( (y * 18) / (board.width * board.yScale) )
  
  if col >= 0 and col <= 18 and row >= 0 and row <= 18 then
    stone.row = row
    stone.col = col
    return true
  else
    return false
  end
end

-- Precondition: The board is resized or moved.
-- Postcondition: The stones are updated to match.
function board.stones:updateStones()
  for i = 1, board.stones.numChildren do
    stone = board.stones[i]
    stone.x = board.x - (board.width * board.xScale) / 2 + stone.col * (board.width * board.xScale / 18)
    stone.y = board.y - (board.height * board.yScale) / 2 + stone.row * (board.height * board.yScale / 18)
    stone.xScale = 0.09 * board.xScale
    stone.yScale = 0.09 * board.yScale
  end
end

return board
