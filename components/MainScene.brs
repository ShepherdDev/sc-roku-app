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
  m.mbMenuBar.observeField("selectedButtonIndex", "onSelectedButtonIndex")
  m.aFadeMenu.observeField("state", "onFadeMenuState")
  m.aFadeView.observeField("state", "onFadeViewOutState")

  appInfo = CreateObject("roAppInfo")
  m.AppRootUrl = AppendResolutionToUrl(appInfo.GetValue("app_root_url"))
  m.IsDev = appInfo.IsDev()

  LogMessage("Launching with Root URL: " + m.AppRootUrl)

  m.bsLoading.control = "start"
  m.task = CreateObject("roSGNode", "URLTask")
  m.task.url = m.AppRootUrl
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

sub ShowMenuSelection(item as Object)
  if item.Template <> invalid and item.Url <> invalid and item.Url <> ""
    url = item.Url

    if item.Template = "Video"
      LogMessage("Showing Video: " + url)

      PlayVideo(url)
    else if item.Template = "Image"
      LogMessage("Showing Image: " + url)

      view = CreateObject("roSGNode", "ImageView")
      view.uri = url
      view.mainScene = m.top
      PushView(view)
    else if item.Template = "PosterList"
      url = AppendResolutionToUrl(url)
      LogMessage("Showing PosterList: " + url)

      view = CreateObject("roSGNode", "PosterListView")
      view.uri = url
      view.mainScene = m.top
      PushView(view)
    end if
  end if
end sub

function AppendResolutionToUrl(url as string) as string
  if url.InStr("?") = -1
    return url + "?Resolution=" + m.top.getScene().currentDesignResolution.height.ToStr() + "p"
  else
    return url + "&Resolution=" + m.top.getScene().currentDesignResolution.height.ToStr() + "p"
  end if
end function

sub onContentChanged()
  m.config = invalid
  if m.task.success = true
    m.config = parseJSON(m.task.content)
  end if

  if m.config <> invalid
    m.pBackground.uri = m.config.BackgroundUrl

    buttons = []
    for each b in m.config.buttons
      buttons.Push(b.Title)
    end for

    m.mbMenuBar.buttons = buttons
  else
    LogMessage("Failed to load main scene content.")
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

sub onSelectedButtonIndex()
  item = m.config.Buttons[m.mbMenuBar.selectedButtonIndex]

  ShowMenuSelection(item)
end sub
