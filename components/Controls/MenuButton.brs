sub init()
  m.lblText = m.top.findNode("lblText")
  m.gActive = m.top.findNode("gActive")
  m.pLeft = m.gActive.findNode("pLeft")
  m.pCenter = m.gActive.findNode("pCenter")
  m.pRight = m.gActive.findNode("pRight")

  m.top.focusable = true
  m.top.observeField("focusedChild", "OnFocusedChildChange")

  onSizeChange()
  onFocusedChildChange()
end sub

sub onSizeChange()
  m.lblText.text = m.top.text

  m.pLeft.width = m.top.edgeWidth
  m.pRight.width = m.top.edgeWidth

  m.lblText.height = m.top.height
  m.pLeft.height = m.top.height
  m.pCenter.height = m.top.height
  m.pRight.height = m.top.height
  m.pCenter.translation = [m.pLeft.width, 0]
  m.lblText.translation = [m.pLeft.width, 0]

  if m.top.width = 0
    m.lblText.width = 0
    width = m.lblText.boundingRect().width
  else
    width = m.top.width - m.pLeft.width - m.pRight.width
  end if

  m.lblText.width = width
  m.pCenter.width = width
  m.pRight.translation = [m.pLeft.width + m.pCenter.width, 0]

  m.top.boundingWidth = m.pLeft.width + m.pCenter.width + m.pRight.width
end sub

sub onFocusedChildChange()
  if m.top.HasFocus()
    m.gActive.visible = true
  else
    m.gActive.visible = false
  end if
end sub
