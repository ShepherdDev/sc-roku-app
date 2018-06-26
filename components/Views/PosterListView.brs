sub init()
  m.pBackgroundRect = m.top.findNode("pBackgroundRect")
  m.pBackgroundImage = m.top.findNode("pBackgroundImage")
  m.lTitle = m.top.findNode("lTitle")
  m.llMenu = m.top.findNode("llMenu")
  m.cnMenuContent = m.top.findNode("cnMenuContent")
  m.pItemImage = m.top.findNode("pItemImage")
  m.lItemDetailLeft = m.top.findNode("lItemDetailLeft")
  m.lItemDetailRight = m.top.findNode("lItemDetailRight")
  m.lItemDescription = m.top.findNode("lItemDescription")
  m.bsLoading = m.top.findNode("bsLoading")
  m.task = invalid

  m.bsLoading.poster.width = 96
  m.bsLoading.poster.height = 96

  resolution = m.top.getScene().currentDesignResolution
  m.pBackgroundRect.width = resolution.width
  m.pBackgroundRect.height = resolution.height
  m.pBackgroundImage.width = resolution.width
  m.pBackgroundImage.height = resolution.height
  m.pBackgroundImage.loadWidth = resolution.width * 0.02
  m.pBackgroundImage.loadHeight = resolution.height * 0.02

  if resolution.resolution = "FHD"
    rem -- Configure for 1920x1080
    m.bsLoading.translation = [912, 492]
    m.lTitle.translation = [80, 60]
    m.lTitle.width = 1760
    m.pItemImage.width = 800
    m.pItemImage.height = 495
    m.pItemImage.translation = [80, 200]
    m.lItemDetailLeft.width = 400
    m.lItemDetailLeft.height = 40
    m.lItemDetailLeft.translation = [80, 700]
    m.lItemDetailRight.width = 400
    m.lItemDetailRight.height = 40
    m.lItemDetailRight.translation = [480, 700]
    m.lItemDescription.width = 800
    m.lItemDescription.height = 240
    m.lItemDescription.translation = [80, 760]
    m.llMenu.translation = [1050, 200]
    m.llMenu.itemSize = [750, 48]
    m.llMenu.itemSpacing = [0, 12]
  else
    rem -- Configure for 1280x720
    m.bsLoading.translation = [592, 312]
    m.lTitle.translation = [50, 40]
    m.lTitle.width = 1180
    m.pItemImage.width = 544
    m.pItemImage.height = 306
    m.pItemImage.translation = [50, 130]
    m.lItemDetailLeft.width = 272
    m.lItemDetailLeft.height = 26
    m.lItemDetailLeft.translation = [50, 440]
    m.lItemDetailRight.width = 272
    m.lItemDetailRight.height = 26
    m.lItemDetailRight.translation = [322, 440]
    m.lItemDescription.width = 544
    m.lItemDescription.height = 160
    m.lItemDescription.translation = [50, 480]
    m.llMenu.translation = [700, 130]
    m.llMenu.itemSize = [500, 32]
    m.llMenu.itemSpacing = [0, 8]
  end if

  m.top.observeField("uri", "onUriChange")
  m.top.observeField("focusedChild", "onFocusedChildChange")
  m.llMenu.observeField("itemFocused", "onItemFocusedChange")
  m.llMenu.observeField("itemSelected", "onItemSelectedChange")
end sub

sub onUriChange()
  if m.task = invalid
    m.task = CreateObject("roSGNode", "URLTask")
    m.task.observeField("content", "onContentChange")
  else
    m.task.control = "STOP"
  end if

  m.task.url = m.top.uri
  m.task.control = "RUN"
end sub

sub onContentChange()
  m.config = invalid
  if m.task.success = true
    m.config = parseJSON(m.task.content)
  end if

  if m.config <> invalid
    m.lTitle.text = m.config.Title
    m.pBackgroundImage.uri = m.config.Image

    while m.cnMenuContent.getChildCount() > 0
      m.cnMenuContent.removeChild(0)
    end while

    for each item in m.config.Items
      node = m.cnMenuContent.createChild("ContentNode")
      node.title = item.Title
    end for

    m.bsLoading.control = "stop"
    m.bsLoading.visible = false
  else
    LogMessage("Failed to load PosterList content")
  end if
end sub

sub onFocusedChildChange()
  if m.top.IsInFocusChain() and not m.llMenu.HasFocus()
    m.llMenu.SetFocus(true)
  end if
end sub

sub onItemFocusedChange()
  if m.config <> invalid
    m.pItemImage.uri = m.config.Items[m.llMenu.itemFocused].Image
    m.lItemDetailLeft.text = m.config.Items[m.llMenu.itemFocused].DetailLeft
    m.lItemDetailRight.text = m.config.Items[m.llMenu.itemFocused].DetailRight
    m.lItemDescription.text = m.config.Items[m.llMenu.itemFocused].Description
  end if
end sub

sub onItemSelectedChange()
  item = m.config.Items[m.llMenu.itemSelected]

  m.top.mainScene.callFunc("ShowMenuSelection", item)
end sub
