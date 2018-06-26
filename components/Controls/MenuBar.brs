rem --
rem -- init
rem --
rem -- The MenuBar presents a horizontal bar of buttons to the user.
rem -- MenuBar inherits from Rectangle so you can use the same fields
rem -- to configure the look of the bar itself.
rem --
sub init()
  rem --
  rem -- Set initial control values.
  rem --
  m.gButtons = m.top.findNode("gButtons")
  m.selectedButtonIndex = invalid

  rem --
  rem -- Observe the fields we need to monitor for changes.
  rem --
  m.top.observeField("focusedChild", "onFocusedChildChange")
  m.top.observeField("width", "onLayoutChange")
  m.top.observeField("height", "onLayoutChange")
end sub

rem *******************************************************
rem ** EVENT HANDLERS
rem *******************************************************

rem --
rem -- onButtonsChange
rem --
rem -- Called when the field holding the button definitions has changed
rem -- values. Reconstruct the menu bar to contain the new buttons.
rem --
sub onButtonsChange()
  rem --
  rem --Remove existing buttons.
  rem --
  while m.gButtons.getChildCount() > 0
    m.gButtons.removeChild(0)
  end while
  m.selectedButtonIndex = invalid

  rem --
  rem -- Loop through the array of button titles and create a new
  rem -- button for each item.
  rem --
  for each b in m.top.buttons
    rem --
    rem -- Create the button with explicit height matching our own height
    rem -- and a width of 0 to make it automatically size.
    rem --
    c = m.gButtons.createChild("MenuButton")
    c.width = 0
    c.height = m.top.height
    c.text = b

    rem --
    rem -- Make sure the first button is selected.
    rem --
    if m.selectedButtonIndex = invalid
      m.selectedButtonIndex = 0
    end if
  end for

  rem --
  rem -- Force a layout update for the new buttons.
  rem --
  onLayoutChange()
end sub

rem --
rem -- onLayoutChange
rem --
rem -- Called when our own size has changed so that we can re-layout
rem -- all the buttons to be centered correctly.
rem --
sub onLayoutChange()
  rem --
  rem -- Loop through all the buttons and set their initial spacing.
  rem --
  translationX = 0
  for i = 1 to m.gButtons.getChildCount() step 1
    c = m.gButtons.getChild(i - 1)
    c.translation = [translationX, 0]
    translationX = translationX + c.boundingWidth + m.top.horizSpacing
  end for

  rem --
  rem -- Loop through all the buttons a second time to fix their alignment
  rem -- to be centered horizontally.
  rem --
  offset = Int(m.top.width / 2) - Int((translationX - m.top.horizSpacing) / 2)
  for i = 1 to m.gButtons.getChildCount() step 1
    c = m.gButtons.getChild(i - 1)
    c.translation = [c.translation[0] + offset, c.translation[1]]
  end for
end sub

rem --
rem -- onFocusedChildChange
rem --
rem -- Called when we gain focus. Ensure that the selected
rem -- button actually has the focus instead.
rem --
sub onFocusedChildChange()
  if m.selectedButtonIndex <> invalid and m.top.IsInFocusChain() and not m.gButtons.getChild(m.selectedButtonIndex).HasFocus()
    m.gButtons.getChild(m.selectedButtonIndex).SetFocus(true)
  end if
end sub

rem --
rem -- onKeyEvent
rem --
rem -- param key: Contains the key that was pressed on the remote.
rem -- param press: True if the button was pressed, false if released.
rem --
rem -- Called when the user presses a button on the remote. Check if we
rem -- need to handle any keys to change selection or activate their
rem -- current button.
rem --
function onKeyEvent(key as string, press as boolean) as boolean
  if press
    if key = "left"
      rem --
      rem -- Select the previous button.
      rem --
      if m.selectedButtonIndex <> invalid and m.selectedButtonIndex > 0
        m.selectedButtonIndex = m.selectedButtonIndex - 1
        onFocusedChildChange()
      end if

      return true
    else if key = "right"
      rem --
      rem -- Select the next button.
      rem --
      if m.selectedButtonIndex <> invalid and m.selectedButtonIndex < m.gButtons.getChildCount() - 1
        m.selectedButtonIndex = m.selectedButtonIndex + 1
        onFocusedChildChange()
      end if

      return true
    else if key = "OK"
      rem --
      rem -- Activate the selected button.
      rem --
      if m.selectedButtonIndex <> invalid
        m.top.selectedButton = m.gButtons.getChild(m.selectedButtonIndex)
        m.top.selectedButtonIndex = m.selectedButtonIndex
      end if

      return true
    end if
  end if

  return false
end function
