local panel = display.newRect( 0, 0, display.contentWidth, 100 )
panel:setFillColor( 0, 0, 0 )
panel.alpha = 0.7

panel.txt = display.newText( "Drag stones from here to the board below", 10, 20, "Helvetica", 28 )
panel.txt:setReferencePoint( display.TopCenterReferencePoint )

local board = nil

-- Precondition: A reference to the board
-- Postcondition: A local variable is set to this reference, for easy access later
function panel.setBoard( givenBoard )
  board = givenBoard
end

-- Precondition: The panel is touched
-- Postcondition: The stones are moved or created accordingly
function panel:touch( event )
  if event.phase == "cancelled" or event.phase == "ended" then
    display.getCurrentStage():setFocus( nil )

    if board.stones:snapToGrid( self.stone ) then
      board.stones:insert( self.stone )
      board.stones:updateStones()
    else
      self.stone:removeSelf()
    end

    self.stone = nil
  end

  -- Create new stone
  if event.phase == "began" then
    display.getCurrentStage():setFocus( self )
    self.stone = display.newImage( "white_stone.png" )
    self.stone.x = event.x
    self.stone.y = event.y
    self.stone.xScale = 0.09 * board.xScale
    self.stone.yScale = 0.09 * board.xScale
  end

  if event.phase == "moved" then
    self.stone.x = event.x
    self.stone.y = event.y
  end

  return true
end

return panel
