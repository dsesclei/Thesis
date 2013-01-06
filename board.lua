local board = display.newGroup()
board.stones = display.newGroup()

-- Postcondition: The board is drawn upon the screen
function drawBoard()
  local weight = 2
  local box = display.newRect( 0, 0, 500, 500 )
  box:setFillColor( 0, 0, 0, 0 )
  box:setStrokeColor( 0, 0, 0 )
  box.strokeWidth = weight

  local dd = 500 / 18

  -- Draw the horizontal and vertical grid lines
  for i=1,17 do
    local line = display.newLine( i * dd, 0, i * dd, 500 )
    line.width = weight
    line:setColor( 0, 0, 0 )
    board:insert( line )
  end

  for i=1,17 do
    local line = display.newLine( 0, i * dd, 500, i * dd )
    line.width = weight
    line:setColor( 0, 0, 0 )
    board:insert( line )
  end

  -- Draw the star points
  points = { 4, 4,
             4, 10,
             4, 16,
             10, 4,
             10, 10,
             10, 16,
             16, 4,
             16, 10,
             16, 16 }

  local pointWidth = 12
  while #points > 0 do
    local x = table.remove( points, 1 ) - 1
    local y = table.remove( points, 1 ) - 1
    local point = display.newRect( x * dd - ( pointWidth / 2 ), y * dd - ( pointWidth / 2), pointWidth, pointWidth )
    point:setFillColor( 0, 0, 0 )
    board:insert( point )
  end

  board:insert( box )
  board.x = 0
  board.y = 0
  board:setReferencePoint( display.CenterReferencePoint )
  board:scale( 1, 1 )
end

-- Postcondition: An empty grid is returned
function newGrid()
  local grid = {}

  for i=1,19 do
    grid[i] = {}
  end

  return grid
end

-- Postcondition: The game is reset to its default state
function board:reset()
  -- Center the board
  board.x = display.contentWidth / 2
  board.y = display.contentHeight / 2

  board:scale( 1, 1 )

  board.whiteScore = 0
  board.blackScore = 0
  board.passed = false
  board.gameOver = false
  board.turn = "black"

  while board.stones.numChildren > 0 do
    board.stones:remove( 1 )
  end

  board.grid = newGrid()

  panel:updateScores()
  panel:updateTurn()
end

-- Precondition: A reference to the panel
-- Postcondition: A local variable is set to this reference, for easy access later
function board.setPanel( givenPanel )
  panel = givenPanel
end

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

      -- Boundaries that ensure it won't go beyond the 4 4 star point
      if self.x < -165 * self.xScale then
        self.x = -165 * self.xScale
      end

      if self.y < -165 * self.xScale then
        self.y = -165 * self.xScale
      end

      if self.x > display.contentWidth + ( 165 * self.xScale ) then
        self.x = display.contentWidth + ( 165 * self.xScale )
      end

      if self.y > display.contentHeight + ( 165 * self.yScale ) then
        self.y = display.contentHeight + ( 165 * self.yScale )
      end
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
  
  return true
end

-- Precondition: The board is tapped
-- Postcondition: A stone is placed on the board
function board:tap( event )
  if not board.gameOver then
    local stroke = 35
    local stone = display.newCircle( 0, 0, 140 - ( stroke / 2 ) )

    stone:setStrokeColor( 0, 0, 0 )
    if board.turn == "black" then
      stone:setFillColor( 0, 0, 0 )
    end

    stone.strokeWidth = stroke
    stone.x = event.x
    stone.y = event.y
    stone.xScale = 0.09 * board.xScale
    stone.yScale = 0.09 * board.xScale
    board.stones:addStone( stone )
  end

  return true
end

-- Precondition: The display object to be added
-- Postcondition: The stone is fixed to the grid and added to the board
function board.stones:addStone( stone )
  -- Add the stone if it is over an empty grid location
  if board.stones:snapToGrid( stone ) and not board.grid[stone.row][stone.col] then
    board.grid[stone.row][stone.col] = stone

    if board.turn == "black" then
      stone.color = "black"
      board.turn = "white"
    else
      stone.color = "white"
      board.turn = "black"
    end
    
    self:captureStones( stone )

    -- Prevent suicides
    if self:countLiberties( stone.row, stone.col, stone.color ) == 0 then
      board.grid[stone.row][stone.col] = nil
      stone:removeSelf()

      if board.turn == "black" then
        board.turn = "white"
      else
        board.turn = "black"
      end

      return
    end

    board.passed = false

    panel:updateTurn()
    panel:updateScores()
    self:insert(stone)
    self:updateStones()
  else
    stone:removeSelf()
  end
end

-- Precondition: The stone that is doing the capturing
-- Postcondition: The captured stones are removed from the board
function board.stones:captureStones( stone )
  -- Make a table of adjacent stones and see if any of them can be captured
  local adj = {}
  if stone.row - 1 >= 1 then
    table.insert( adj, board.grid[stone.row - 1][stone.col] )
  end

  if stone.row + 1 <= 19 then
    table.insert( adj, board.grid[stone.row + 1][stone.col] )
  end

  if stone.col - 1 >= 1 then
    table.insert( adj, board.grid[stone.row][stone.col - 1] )
  end

  if stone.col + 1 <= 19 then
    table.insert( adj, board.grid[stone.row][stone.col + 1] )
  end

  for i,v in ipairs( adj ) do
    if self:countLiberties( v.row, v.col, v.color ) == 0 and v.color ~= stone.color then
      self:removeGroup( v.row, v.col )
    end
  end
end

-- Precondition: A stone that has been dropped on the screen
-- Postcondition: If the stone falls on the grid, it is assigned a row and column.
--                otherwise, the function returns false and it is deleted.
function board.stones:snapToGrid( stone )
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

-- Precondition: The position and color of a stone in the group to be removed
-- Postcondition: The group is removed from the board
function board.stones:removeGroup( row, col, color )
  if row < 1 or row > 19 or col < 1 or col > 19 then
    return
  end

  local stone = board.grid[row][col]
  color = color or stone.color

  if stone and stone.color == color then
    if stone.color == "black" then
      board.whiteScore = board.whiteScore + 1
    else
      board.blackScore = board.blackScore + 1
    end

    board.stones:remove( stone )
    board.grid[row][col] = nil

    self:removeGroup( row - 1, col, color )
    self:removeGroup( row + 1, col, color )
    self:removeGroup( row, col - 1, color )
    self:removeGroup( row, col + 1, color )
  end
end

-- Precondition: A position of a stone on the board and a color to look for
-- Postcondition: The number of liberties that the group has
function board.stones:countLiberties( row, col, color, hist )
  hist = hist or newGrid()
  local stone = board.grid[row][col]

  if row < 1 or row > 19 or col < 1 or col > 19 then
    return 0, hist
  end

  hist[row][col] = true

  if not board.grid[row][col] then
    return 1, hist
  elseif board.grid[row][col].color == color then
    local left, right, up, down = 0, 0, 0, 0

    if hist[row - 1] and not hist[row - 1][col] then
      left, hist = self:countLiberties( row - 1, col, color, hist )
    end

    if hist[row + 1] and not hist[row + 1][col] then
      right, hist = self:countLiberties( row + 1, col, color, hist )
    end

    if hist[col - 1] and not hist[row][col - 1] then
      up, hist = self:countLiberties( row, col - 1, color, hist )
    end

    if hist[col + 1] and not hist[row][col + 1] then
      down, hist = self:countLiberties( row, col + 1, color, hist )
    end

    return left + right + up + down, hist
  else
    return 0, hist
  end
end

-- Precondition: Both players have passed
-- Postcondition: The game ends and the score is counted up
function board:endGame()
  board.gameOver = true

  -- Use Stone Scoring method. A player's score is the number of stones that
  -- they have on the board added to the number of stones that they have captured.
  for ir,r in pairs( board.grid ) do
    for ic, c in pairs( r ) do
      if board.grid[ir] ~= nil and board.grid[ir][ic] ~= nil then
        if board.grid[ir][ic].color == "black" then
          board.blackScore = board.blackScore + 1
        else
          board.whiteScore = board.whiteScore + 1
        end
      end
    end
  end
  
  panel:updateScores()
end

drawBoard()
local panel = nil

return board
