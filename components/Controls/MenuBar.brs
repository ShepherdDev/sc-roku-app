sub init()
  m.gButtons = m.top.findNode("gButtons")
  m.selectedButtonIndex = invalid

  m.top.focusable = true
  m.top.observeField("focusedChild", "OnFocusedChildChange")

  onButtonsChange()
  onFocusedChildChange()
end sub

sub onButtonsChange()
  ''
  'Remove existing buttons.'
  ''
  while m.gButtons.getChildCount() > 0
    m.gButtons.removeChild(0)
  end while
  m.selectedButtonIndex = invalid

  translationX = 0
  for each b in m.top.buttons
    c = m.gButtons.createChild("MenuButton")
    c.width = 0
    c.height = m.top.height
    c.text = b

    if m.selectedButtonIndex = invalid
      m.selectedButtonIndex = 0
    end if
  end for

  onLayoutChange()
end sub

sub onLayoutChange()
  translationX = 0
  for i = 1 to m.gButtons.getChildCount() step 1
    c = m.gButtons.getChild(i - 1)
    c.translation = [translationX, 0]
    translationX = translationX + c.boundingWidth + m.top.horizSpacing
  end for

  offset = Int(m.top.width / 2) - Int((translationX - m.top.horizSpacing) / 2)
  for i = 1 to m.gButtons.getChildCount() step 1
    c = m.gButtons.getChild(i - 1)
    c.translation = [c.translation[0] + offset, c.translation[1]]
  end for
end sub

sub onFocusedChildChange()
  if m.selectedButtonIndex <> invalid and m.top.IsInFocusChain() and not m.gButtons.getChild(m.selectedButtonIndex).HasFocus()
    m.gButtons.getChild(m.selectedButtonIndex).SetFocus(true)
  end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
  if press
    if key = "left"
      if m.selectedButtonIndex <> invalid and m.selectedButtonIndex > 0
        m.selectedButtonIndex = m.selectedButtonIndex - 1
        onFocusedChildChange()
      end if

      return true
    else if key = "right"
      if m.selectedButtonIndex <> invalid and m.selectedButtonIndex < m.gButtons.getChildCount() - 1
        m.selectedButtonIndex = m.selectedButtonIndex + 1
        onFocusedChildChange()
      end if

      return true
    else if key = "OK"
      if m.selectedButtonIndex <> invalid
        m.top.selectedButton = m.gButtons.getChild(m.selectedButtonIndex)
        m.top.selectedButtonIndex = m.selectedButtonIndex
      end if

      return true
    end if
  end if

  return false
end function

function getButton(index as integer) as Object
  return m.gButtons.getChild(index)
end function
