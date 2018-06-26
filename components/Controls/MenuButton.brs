rem --
rem -- init()
rem --
rem -- Initialize a new MenuButton instance. This object handles the visual
rem -- display of a single button in the MenuBar.
rem --
sub init()
  rem --
  rem -- Set initial control values.
  rem --
  m.lblText = m.top.findNode("lblText")
  m.gActive = m.top.findNode("gActive")
  m.pLeft = m.gActive.findNode("pLeft")
  m.pCenter = m.gActive.findNode("pCenter")
  m.pRight = m.gActive.findNode("pRight")

  rem --
  rem -- Observe the fields we need to monitor for changes.
  rem --
  m.top.observeField("focusedChild", "onFocusedChildChange")
end sub

rem *******************************************************
rem ** EVENT HANDLERS
rem *******************************************************

rem --
rem -- onSizeChange()
rem --
rem -- Called when our size has changed. Re-layout all the
rem -- elements of the button to fit the size.
rem --
sub onSizeChange()
  rem --
  rem -- Set the text of the button.
  rem --
  m.lblText.text = m.top.text

  rem --
  rem -- Set the edge width as specified.
  rem --
  m.pLeft.width = m.top.edgeWidth
  m.pRight.width = m.top.edgeWidth

  rem --
  rem -- Set the height of everything to match our height.
  rem --
  m.lblText.height = m.top.height
  m.pLeft.height = m.top.height
  m.pCenter.height = m.top.height
  m.pRight.height = m.top.height

  rem --
  rem -- Adjust the position of the center elements.
  rem --
  m.pCenter.translation = [m.pLeft.width, 0]
  m.lblText.translation = [m.pLeft.width, 0]

  rem --
  rem -- Determine the width of the center elements.
  rem --
  if m.top.width = 0
    m.lblText.width = 0
    width = m.lblText.boundingRect().width
  else
    width = m.top.width - m.pLeft.width - m.pRight.width
  end if

  rem --
  rem -- Set the width of the center elements and then position the
  rem -- right edge.
  rem --
  m.lblText.width = width
  m.pCenter.width = width
  m.pRight.translation = [m.pLeft.width + m.pCenter.width, 0]

  rem --
  rem -- Finally, update our boundingWidth so that the MenuBar knows how
  rem -- much space this button is taking up.
  rem --
  m.top.boundingWidth = m.pLeft.width + m.pCenter.width + m.pRight.width
end sub

rem --
rem -- onFocusedChildChange()
rem --
rem -- Called when we receive or lose focus. Update the UI elements to
rem -- match.
rem --
sub onFocusedChildChange()
  if m.top.HasFocus()
    m.gActive.visible = true
  else
    m.gActive.visible = false
  end if
end sub
