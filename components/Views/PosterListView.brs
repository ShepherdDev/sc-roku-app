rem --
rem -- init
rem --
rem -- Initialize a new PosterList view that will display a list of items
rem -- in a poster-list style view. This puts a list of items on the right
rem -- side of the screen and a thumbnail preview image on the left. Some
rem -- extra detail information will be displayed below the image if it
rem -- is provided in the item details.
rem --
sub init()
  rem --
  rem -- Set initial view properties.
  rem --
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

  rem --
  rem -- Configure common resolution options for the view.
  rem --
  resolution = m.top.getScene().currentDesignResolution
  m.pBackgroundRect.width = resolution.width
  m.pBackgroundRect.height = resolution.height
  m.pBackgroundImage.width = resolution.width
  m.pBackgroundImage.height = resolution.height
  m.pBackgroundImage.loadWidth = resolution.width * 0.02
  m.pBackgroundImage.loadHeight = resolution.height * 0.02
  m.bsLoading.poster.width = 96
  m.bsLoading.poster.height = 96

  rem --
  rem -- Configure resolution-specific settings for the view.
  rem --
  if resolution.resolution = "FHD"
    rem --
    rem -- Configure for 1920x1080.
    rem --
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
    rem --
    rem -- Configure for 1280x720.
    rem --
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

  rem --
  rem -- Observe the fields we need to monitor for changes.
  rem --
  m.top.observeField("focusedChild", "onFocusedChildChange")
  m.llMenu.observeField("itemFocused", "onItemFocusedChange")
  m.llMenu.observeField("itemSelected", "onItemSelectedChange")
end sub

rem *******************************************************
rem ** EVENT HANDLERS
rem *******************************************************

rem --
rem -- onUriChange
rem --
rem -- The URI value has changed. This indicates the URL we should
rem -- pull our configuration information from. We need to re-download
rem -- the configuration and apply it to the display elements.
rem --
sub onUriChange()
  rem --
  rem -- Create a new task or re-use an existing one.
  rem --
  if m.task = invalid
    m.task = CreateObject("roSGNode", "URLTask")
    m.task.observeField("content", "onContentChange")
  else
    m.task.control = "STOP"
  end if

  rem --
  rem -- Set the URL for the task to pull content from and start it.
  rem --
  m.task.url = m.top.uri
  m.task.control = "RUN"
end sub

rem --
rem -- onContentChange
rem --
rem -- The content from the URLTask has been received. Parse it out
rem -- and update UI elements.
rem --
sub onContentChange()
  rem --
  rem -- Attempt to parse the data as JSON.
  rem --
  m.config = invalid
  if m.task.success = true
    m.config = parseJSON(m.task.content)
  end if

  if m.config <> invalid
    rem --
    rem -- Set the text and background image for the list.
    rem --
    m.lTitle.text = m.config.Title
    m.pBackgroundImage.uri = m.config.Image

    rem --
    rem -- Remove all the old menu items.
    rem --
    while m.cnMenuContent.getChildCount() > 0
      m.cnMenuContent.removeChild(0)
    end while

    rem --
    rem -- Add in new menu items for each item in the list.
    rem --
    for each item in m.config.Items
      node = m.cnMenuContent.createChild("ContentNode")
      node.title = item.Title
    end for

    rem --
    rem -- Hide the loading spinner.
    rem --
    m.bsLoading.control = "stop"
    m.bsLoading.visible = false
  else
    LogMessage("Failed to load PosterList content")
  end if
end sub

rem --
rem -- onFocusedChildChange
rem --
rem -- The focus has changed to or from us. If it was set to us then make
rem -- sure the item list control has the actual focus.
rem --
sub onFocusedChildChange()
  if m.top.IsInFocusChain() and not m.llMenu.HasFocus()
    m.llMenu.SetFocus(true)
  end if
end sub

rem --
rem -- onItemFocusedChange
rem --
rem -- The menu item focus has changed. Update the UI with the details
rem -- of the currently focused item.
rem --
sub onItemFocusedChange()
  if m.config <> invalid
    m.pItemImage.uri = m.config.Items[m.llMenu.itemFocused].Image
    m.lItemDetailLeft.text = m.config.Items[m.llMenu.itemFocused].DetailLeft
    m.lItemDetailRight.text = m.config.Items[m.llMenu.itemFocused].DetailRight
    m.lItemDescription.text = m.config.Items[m.llMenu.itemFocused].Description
  end if
end sub

rem --
rem -- onItemSelectedChange
rem --
rem -- An item has been selected from the list. Show the item on the screen.
rem --
sub onItemSelectedChange()
  item = m.config.Items[m.llMenu.itemSelected]

  m.top.mainScene.callFunc("ShowItem", item)
end sub
