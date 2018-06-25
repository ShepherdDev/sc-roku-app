sub init()
  m.gViews = m.top.findNode("gViews")
  m.aFadeMenu = m.top.findNode("aFadeMenu")
  m.aFadeView = m.top.findNode("aFadeView")
  m.gMainMenu = m.top.findNode("gMainMenu")
  m.bsLoading = m.top.findNode("bsLoading")
  m.gMenuBar = m.top.findNode("gMenuBar")
  m.pBackground = m.top.findNode("pBackground")
  m.mbMenuBar = m.top.findNode("mbMenuBar")
  m.config = invalid

  m.bsLoading.poster.width = 96
  m.bsLoading.poster.height = 96

  resolution = m.top.getScene().currentDesignResolution
  if resolution.resolution = "FHD"
    rem -- Configure for 1920x1080
    m.mbMenuBar.translation = [0, 1000]
    m.mbMenuBar.width = 1920
    m.mbMenuBar.height = 80
    m.bsLoading.translation = [912, 492]
  else
    rem -- Configure for 1280x720
    m.mbMenuBar.translation = [0, 670]
    m.mbMenuBar.width = 1280
    m.mbMenuBar.height = 50
    m.bsLoading.translation = [592, 312]
  end if

  m.pBackground.observeField("loadStatus", "onBackgroundStatus")
  m.mbMenuBar.observeField("selectedButtonIndex", "onButtonSelected")
  m.aFadeMenu.observeField("state", "onFadeMenuState")
  m.aFadeView.observeField("state", "onFadeViewOutState")

  m.bsLoading.control = "start"
  m.task = CreateObject("roSGNode", "URLTask")
  m.task.url = "https://www.shepherdchurch.com/Webhooks/Lava.ashx/roku/sc/main.json"
  m.task.observeField("content", "onContentChanged")
  m.task.control = "RUN"
end sub

sub PushView(view as Object)
  resolution = m.top.getScene().currentDesignResolution
  view.scaleRotateCenter = [resolution.width / 2, resolution.height / 2]
  view.opacity = 0
  m.gViews.appendChild(view)

  view.id = "viewAnimationTarget"
  m.viewFadingIn = true
  while m.aFadeView.getChildCount() > 0
    m.aFadeView.removeChildIndex(0)
  end while

  field = m.aFadeView.createChild("FloatFieldInterpolator")
  field.key = [0.0, 1.0]
  field.keyValue = [0.0, 1.0]
  field.fieldToInterp = "viewAnimationTarget.opacity"
  field = m.aFadeView.createChild("Vector2DFieldInterpolator")
  field.key = [0.0, 0.5, 1.0]
  field.keyValue = [[0.95, 0.95], [1.0, 1.0], [1.0, 1.0]]
  field.fieldToInterp = "viewAnimationTarget.scale"

  m.aFadeView.control = "start"
end sub

sub PopActiveView()
  m.gViews.getChild(m.gViews.getChildCount() - 1).id = "viewAnimationTarget"
  m.viewFadingIn = false
  while m.aFadeView.getChildCount() > 0
    m.aFadeView.removeChildIndex(0)
  end while

  field = m.aFadeView.createChild("FloatFieldInterpolator")
  field.key = [0.0, 1.0]
  field.keyValue = [1.0, 0.0]
  field.fieldToInterp = "viewAnimationTarget.opacity"
  field = m.aFadeView.createChild("Vector2DFieldInterpolator")
  field.key = [0.0, 0.0, 1.0]
  field.keyValue = [[1.0, 1.0], [1.0, 1.0], [0.95, 0.95]]
  field.fieldToInterp = "viewAnimationTarget.scale"

  m.aFadeView.control = "start"
end sub

sub PlayVideo(url as string)
  view = createObject("roSGNode", "VideoView")
  view.mainScene = m.top
  view.uri = url

  PushView(view)
end sub

sub onContentChanged()
  m.config = invalid
  if m.task.success = true
    m.config = parseJSON(m.task.content)
  end if

  if m.config <> invalid
    m.pBackground.uri = m.config.BackgroundUrl

    buttons = []
    if m.config.IsLiveNow = true
      buttons.Push("Watch Live")
    else
      buttons.Push("Service Schedule")
    end if
    buttons.Push("Current Series")
    buttons.Push("Archives")
    if m.config.LifeGroupUrl <> invalid and m.config.LifeGroupUrl <> ""
      buttons.Push("Life Groups")
    end if

    m.mbMenuBar.buttons = buttons
  else
    'TODO: Error'
  end if
end sub

sub onBackgroundStatus()
  if m.pBackground.loadStatus = "ready" or m.pBackground.loadStatus = "failed"
    m.gMainMenu.opacity = 0
    m.gMainMenu.visible = true
    m.mbMenuBar.setFocus(true)

    m.aFadeMenu.control = "start"
  end if
end sub

sub onFadeMenuState()
  if m.aFadeMenu.state = "stopped"
    m.bsLoading.control = "stop"
    m.bsLoading.visible = false
  end if
end sub

sub onFadeViewOutState()
  if m.aFadeView.state = "stopped"
    if m.viewFadingIn = true
      m.gViews.getChild(m.gViews.getChildCount() - 1).setFocus(true)
      m.gViews.getChild(m.gViews.getChildCount() - 1).id = ""
    else
      m.gViews.removeChildIndex(m.gViews.getChildCount() - 1)

      if m.gViews.getChildCount() > 0
        m.gViews.getChild(m.gViews.getChildCount() - 1).setFocus(true)
      else
        m.mbMenuBar.setFocus(true)
      end if
    end if
  end if
end sub

function onKeyEvent(key as string, press as boolean) as boolean
  if m.aFadeView.state = "running"
    return true
  end if

  if press
    if key = "back"
      if m.gViews.getChildCount() > 0
        PopActiveView()

        return true
      else
        return false
      end if
    end if
  end if

  return false
end function

sub onButtonSelected()
  if m.mbMenuBar.selectedButton.text = "Service Schedule"
    view = CreateObject("roSGNode", "ImageView")
    view.uri = m.config.NotLiveImage
    view.mainScene = m.top
    PushView(view)
  else if m.mbMenuBar.selectedButton.text = "Watch Live"
    PlayVideo(m.config.LiveUrl)
  else if m.mbMenuBar.selectedButton.text = "Current Series"
    view = CreateObject("roSGNode", "PosterListView")
    view.uri = m.config.CurrentSeriesUrl
    view.mainScene = m.top
    PushView(view)
  else if m.mbMenuBar.selectedButton.text = "Archives"
    view = CreateObject("roSGNode", "PosterListView")
    view.uri = m.config.ArchivesUrl
    view.mainScene = m.top
    PushView(view)
  else if m.mbMenuBar.selectedButton.text = "Life Groups"
    view = CreateObject("roSGNode", "PosterListView")
    view.uri = m.config.LifeGroupUrl
    view.mainScene = m.top
    PushView(view)
  end if
end sub
