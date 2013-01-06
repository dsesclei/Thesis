local storyboard = require( "storyboard" )
local scene = storyboard.newScene()
local widget = require "widget"

function scene:createScene( event )
	local group = self.view

	-- display a background image
	local background = display.newImage( "goban.png" )
	background:setReferencePoint( display.CenterReferencePoint )
	background.x, background.y = 450, 450
  background:scale( 2, 2 )

  local banner = display.newImage( "banner.png" )
	banner:setReferencePoint( display.CenterReferencePoint )
  banner:scale( 1.5, 1.5 )
  banner.x, banner.y = 150, display.contentHeight / 2
	
  -- Create a faded white background behind the banner for legibility
  local banner_bg = display.newRect( 0, banner.y - banner.height * 1.5 / 2 - 25, display.contentWidth, banner.height * 1.5 + 50 )
	banner_bg:setReferencePoint( display.TopLeftReferencePoint )
  banner_bg:setFillColor( 255, 255, 255 )
  banner_bg.alpha = .5

  local playBtn

  local onPlay = function( event )
    storyboard.gotoScene( "game", "fade", 500 )
    playBtn:removeSelf()
    playBtn = nil
  end

  playBtn = widget.newButton {
    label = "Play",
    default = "button.png",
    defaultColor = { 0, 0, 0 },
    overColor = { 255, 255, 255 },
    fontSize = 36,
    onRelease = onPlay
  }

  playBtn.x = display.contentWidth - 125
  playBtn.y = display.contentHeight / 2
	
	group:insert( background )
  group:insert( banner_bg )
  group:insert( banner )
end

function scene:enterScene( event )
	local group = self.view
end

function scene:exitScene( event )
	local group = self.view
end

function scene:destroyScene( event )
	local group = self.view
	

end

scene:addEventListener( "createScene", scene )
scene:addEventListener( "enterScene", scene )
scene:addEventListener( "exitScene", scene )
scene:addEventListener( "destroyScene", scene )

return scene
