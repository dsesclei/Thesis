local panel = display.newRect( 0, 0, display.contentWidth, 100 )

-- Precondition: A reference to the board
-- Postcondition: A local variable is set to this reference, for easy access later
function panel.setBoard( givenBoard )
  board = givenBoard
end

function panel:updateScores()
  panel.black.text = "Black: " .. board.blackScore
  panel.white.text = "White: " .. board.whiteScore
end

function panel:updateTurn()
  if board.turn == "black" then
    panel.black.alpha = 1
    panel.white.alpha = .5
  else
    panel.white.alpha = 1
    panel.black.alpha = .5
  end
end

-- Precondition: The panel is tapped
-- Postcondition: The player passes. If both players pass, the game ends
function panel:tap( event )
  if board.gameOver then
    panel.info.text = "Tap here to pass"
    board:reset()
  else
    if board.turn == "black" then
      panel.black.text = "PASS"
      board.turn = "white"
    else
      panel.white.text = "PASS"
      board.turn = "black"
    end

    panel:updateTurn()

    if board.passed == true then
      board:endGame()
      panel.black.alpha = 1
      panel.white.alpha = 1
      if board.blackScore > board.whiteScore then
        panel.info.text = "Black wins!"
      elseif board.blackScore < board.whiteScore then
        panel.info.text = "White wins!"
      else
        panel.info.text = "Tie game!"
      end

      panel.info.text = panel.info.text .. " Tap here to play again."
    end

    board.passed = true
  end

  -- Stop event propagation
  return true
end

panel:setFillColor( 0, 0, 0 )
panel.alpha = .7

panel.black = display.newText( "", 0, 0, "Railway", 36 )
panel.black:setReferencePoint( display.CenterReferencePoint )

panel.black.x = display.contentWidth / 4
panel.black.y = 70

panel.white = display.newText( "", 0, 0, "Railway", 36 )
panel.white:setReferencePoint( display.CenterReferencePoint )

panel.white.x = display.contentWidth - display.contentWidth / 4
panel.white.y = 70

panel.info = display.newText( "Tap here to pass", 0, 0, "Railway", 27 )
panel.info:setReferencePoint( display.CenterReferencePoint )
panel.info.x = display.contentWidth / 2
panel.info.y = 20

local board = nil

return panel
