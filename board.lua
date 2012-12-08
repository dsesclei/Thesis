local board = display.newImage("board.png")

-- Listener Function for Touch Events on the Board
-- Precondition: A touch begins, moves, or ends
-- Postcondition: The board is resized or moved
function board:touch(event)
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
    display.getCurrentStage():setFocus(nil)
    self.lastDistance = nil
    if self.touches[1].id == event.id then
      self.touches[1] = self.touches[2]
      self.touches[2] = nil
    else
      self.touches[2] = nil
    end
  end

  if event.phase == "began" then
    display.getCurrentStage():setFocus(self)
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
      distance = math.sqrt(math.pow(x1 - x2, 2) + math.pow(y1 - y2, 2))

      if self.lastDistance then
        dd = distance - self.lastDistance

        -- Enforce a maximum and minimum size
        scale = self.xScale + dd / 500
        scale = math.min(scale, 3)
        scale = math.max(scale, 1)
        
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

board.turn = "black"
board.stones = display.newGroup()

function newGrid()
  local grid = {}

  for i=1,19 do
    grid[i] = {}
  end

  return grid
end

board.grid = newGrid()

function board.stones:addStone(stone)
  -- Add the stone if it is over an empty grid location
  if board.stones:snapToGrid(stone) and not board.grid[stone.row][stone.col] then
    board.grid[stone.row][stone.col] = stone

    if board.turn == "black" then
      stone.color = "black"
      board.turn = "white"
    else
      stone.color = "white"
      board.turn = "black"
    end
    
    self:captureStones(stone)

    -- Prevent suicides
    if self:countLiberties(stone.row, stone.col, stone.color) == 0 then
      print("suicide blocked")
      board.grid[stone.row][stone.col] = nil
      stone:removeSelf()

      if board.turn == "black" then
        board.turn = "white"
      else
        board.turn = "black"
      end

      return
    end


    self:insert(stone)
    self:updateStones()
  else
    stone:removeSelf()
  end
end

function board.stones:captureStones(stone)
  -- Make a table of adjacent stones and see if any of them can be captured
  local adj = {}
  if stone.row - 1 >= 1 then
    table.insert(adj, board.grid[stone.row - 1][stone.col])
  end

  if stone.row + 1 <= 19 then
    table.insert(adj, board.grid[stone.row + 1][stone.col])
  end

  if stone.col - 1 >= 1 then
    table.insert(adj, board.grid[stone.row][stone.col - 1])
  end

  if stone.col + 1 <= 19 then
    table.insert(adj, board.grid[stone.row][stone.col + 1])
  end

  
  for i,v in ipairs(adj) do
    print("-----")
    print(v.row, v.col)
    print(self:countLiberties(v.row, v.col, v.color))
    print(v.color, stone.color)
    if self:countLiberties(v.row, v.col, v.color) == 0 and v.color ~= stone.color then
      self:removeGroup(v.row, v.col)
    end
  end

end
-- Precondition: A stone that has been dropped on the screen
-- Postcondition: If the stone falls on the grid, it is assigned a row and column.
--                otherwise, the function returns false and it is deleted.
function board.stones:snapToGrid(stone)
  local x = stone.x - board.x + (board.width * board.xScale) / 2
  local y = stone.y - board.y + (board.height * board.yScale) / 2
  local col = math.round((x * 18) / (board.width * board.xScale)) + 1
  local row = math.round((y * 18) / (board.width * board.yScale)) + 1
  
  if col >= 1 and col <= 19 and row >= 1 and row <= 19 then
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
    stone.x = board.x - (board.width * board.xScale) / 2 + (stone.col - 1) * (board.width * board.xScale / 18)
    stone.y = board.y - (board.height * board.yScale) / 2 + (stone.row - 1) * (board.height * board.yScale / 18)
    stone.xScale = 0.09 * board.xScale
    stone.yScale = 0.09 * board.yScale
  end
end

function board.stones:removeGroup(row, col, color)
  local stone = board.grid[row][col]
  color = color or stone.color
  if row < 1 or row > 19 or col < 1 or col > 19 then
    return
  end

  if stone and stone.color == color then
    board.stones:remove(stone)
    board.grid[row][col] = nil

    self:removeGroup(row - 1, col, color)
    self:removeGroup(row + 1, col, color)
    self:removeGroup(row, col - 1, color)
    self:removeGroup(row, col + 1, color)
  end
end

-- Precondition: A position of a stone on the board and a color to look for
-- Postcondition: The number of liberties that the group has
function board.stones:countLiberties(row, col, color, hist)
  hist = hist or newGrid()
  stone = board.grid[row][col]

  if row < 1 or row > 19 or col < 1 or col > 19 then
    return 0, hist
  end

  hist[row][col] = true

  if not board.grid[row][col] then
    return 1, hist
  elseif board.grid[row][col].color == color then
    local left, right, up, down = 0, 0, 0, 0

    if not hist[row - 1][col] then
      left, hist = self:countLiberties(row - 1, col, color, hist)
    end

    if not hist[row + 1][col] then
      right, hist = self:countLiberties(row + 1, col, color, hist)
    end

    if not hist[row][col - 1] then
      up, hist = self:countLiberties(row, col - 1, color, hist)
    end

    if not hist[row][col + 1] then
      down, hist = self:countLiberties(row, col + 1, color, hist)
    end

    return left + right + up + down, hist
  else
    return 0, hist
  end
end

return board
