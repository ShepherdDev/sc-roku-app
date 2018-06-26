rem --
rem -- init()
rem --
rem -- Initialize a new ImageView view. This displays a full-screen image
rem -- to the user.
rem --
sub init()
  rem --
  rem -- Set initial control values.
  rem --
  m.rImage = m.top.findNode("rImage")
  m.pImage = m.top.findNode("pImage")

  rem --
  rem -- Set the width and height of the background and image controls
  rem -- to be the width and height of the screen.
  rem --
  resolution = m.top.getScene().currentDesignResolution
  m.rImage.width = resolution.width
  m.rImage.height = resolution.height
  m.pImage.width = resolution.width
  m.pImage.height = resolution.height
end sub

rem *******************************************************
rem ** EVENT HANDLERS
rem *******************************************************

rem --
rem -- onUriChange()
rem --
rem -- Called when the URI has been changed to a new value. Update the
rem -- image to use this new URI value.
rem --
sub onUriChange()
  m.pImage.uri = m.top.uri
end sub
