rem --
rem -- init()
rem --
rem -- Initialize a new Main Scene component. This handles all the screen
rem -- logic for the application. It is in charge of the stack of views
rem -- as well as the main menu content.
rem --
sub init()
  rem --
  rem -- Set initial control values.
  rem --
  m.gViews = m.top.findNode("gViews")
  m.aFadeMenu = m.top.findNode("aFadeMenu")
  m.aFadeView = m.top.findNode("aFadeView")
  m.gMainMenu = m.top.findNode("gMainMenu")
  m.bsLoading = m.top.findNode("bsLoading")
  m.gMenuBar = m.top.findNode("gMenuBar")
  m.pBackground = m.top.findNode("pBackground")
  m.mbMenuBar = m.top.findNode("mbMenuBar")
  m.config = invalid

  rem --
  rem -- Set the Application Root URL to use.
  rem --
  appInfo = CreateObject("roAppInfo")
  m.AppRootUrl = AppendResolutionToUrl(appInfo.GetValue("app_root_url"))

  rem --
  rem -- Configure UI elements for the screen size we are running.
  rem --
  resolution = m.top.getScene().currentDesignResolution
  if resolution.resolution = "FHD"
    rem --
    rem -- Configure for 1920x1080.
    rem --
    m.mbMenuBar.translation = [0, 1000]
    m.mbMenuBar.width = 1920
    m.mbMenuBar.height = 80
    m.bsLoading.translation = [912, 492]
    m.bsLoading.poster.width = 96
    m.bsLoading.poster.height = 96
  else
    rem --
    rem -- Configure for 1280x720.
    rem --
    m.mbMenuBar.translation = [0, 670]
    m.mbMenuBar.width = 1280
    m.mbMenuBar.height = 50
    m.bsLoading.translation = [592, 312]
    m.bsLoading.poster.width = 96
    m.bsLoading.poster.height = 96
  end if

  rem --
  rem -- Observe the fields we need to monitor for changes.
  rem --
  m.pBackground.observeField("loadStatus", "onBackgroundStatus")
  m.mbMenuBar.observeField("selectedButtonIndex", "onSelectedButtonIndex")
  m.aFadeMenu.observeField("state", "onFadeMenuState")
  m.aFadeView.observeField("state", "onFadeViewState")

  LogMessage("Launching with Root URL: " + m.AppRootUrl)

  rem --
  rem -- Show the loading spinner and begin the task to load the
  rem -- Application Root URL.
  rem --
  m.bsLoading.control = "start"
  m.task = CreateObject("roSGNode", "URLTask")
  m.task.url = m.AppRootUrl
  m.task.observeField("content", "onContentChanged")
  m.task.control = "RUN"
end sub

rem *******************************************************
rem ** METHODS
rem *******************************************************

rem --
rem -- PushView(view)
rem --
rem -- Push a new view onto the stack and set it as the primary
rem -- view with focus.
rem --
rem -- @param view The view to be pushed onto the view stack.
rem --
sub PushView(view as Object)
  rem --
  rem -- Set the view to scale around its center and make it invisible
  rem -- for the fade-in.
  rem --
  resolution = m.top.getScene().currentDesignResolution
  view.scaleRotateCenter = [resolution.width / 2, resolution.height / 2]
  view.opacity = 0

  rem --
  rem -- Set the id of the view so that our animations can target it.
  rem --
  view.id = "viewAnimationTarget"
  m.gViews.appendChild(view)

  rem --
  rem -- Remove all old animations.
  rem --
  while m.aFadeView.getChildCount() > 0
    m.aFadeView.removeChildIndex(0)
  end while

  rem --
  rem -- Configure the animation that handles fading in.
  rem --
  field = m.aFadeView.createChild("FloatFieldInterpolator")
  field.key = [0.0, 1.0]
  field.keyValue = [0.0, 1.0]
  field.fieldToInterp = "viewAnimationTarget.opacity"

  rem --
  rem -- Configure the animation that handles the subtle zoom effect.
  rem --
  field = m.aFadeView.createChild("Vector2DFieldInterpolator")
  field.key = [0.0, 0.5, 1.0]
  field.keyValue = [[0.95, 0.95], [1.0, 1.0], [1.0, 1.0]]
  field.fieldToInterp = "viewAnimationTarget.scale"

  rem --
  rem -- Indicate that we are fading in, then start the animation.
  rem --
  m.viewFadingIn = true
  m.aFadeView.control = "start"
end sub

rem --
rem -- PopActiveView()
rem --
rem -- Removes the top-most view from the stack and returns control
rem -- to the view behind it, or to the main menu if no views remain.
rem --
sub PopActiveView()
  rem --
  rem -- Tag the top-most view so our animations can target it.
  rem --
  m.gViews.getChild(m.gViews.getChildCount() - 1).id = "viewAnimationTarget"

  rem --
  rem -- Remove all existing animations.
  rem --
  while m.aFadeView.getChildCount() > 0
    m.aFadeView.removeChildIndex(0)
  end while

  rem --
  rem -- Configure the animation for fading the view out.
  rem --
  field = m.aFadeView.createChild("FloatFieldInterpolator")
  field.key = [0.0, 1.0]
  field.keyValue = [1.0, 0.0]
  field.fieldToInterp = "viewAnimationTarget.opacity"

  rem --
  rem -- Configure the animation for zooming the view out a bit.
  rem --
  field = m.aFadeView.createChild("Vector2DFieldInterpolator")
  field.key = [0.0, 0.0, 1.0]
  field.keyValue = [[1.0, 1.0], [1.0, 1.0], [0.95, 0.95]]
  field.fieldToInterp = "viewAnimationTarget.scale"

  rem --
  rem -- Set the flag indicating we are fading out and start the
  rem -- animations.
  rem --
  m.viewFadingIn = false
  m.aFadeView.control = "start"
end sub

rem --
rem -- PlayVideo(url)
rem --
rem -- Creates a new Video view and pushes it to the top of the view
rem -- stack.
rem --
rem -- @param url The URL of the video that will be played.
rem --
sub PlayVideo(url as string)
  view = createObject("roSGNode", "VideoView")
  view.mainScene = m.top
  view.uri = url

  PushView(view)
end sub

rem --
rem -- ShowItem(item)
rem --
rem -- Shows an item on screen by parsing the object data and
rem -- creating the appropriate view to handle the item data.
rem --
rem -- @param item The item to be shown.
rem --
sub ShowItem(item as Object)
  rem --
  rem -- Each item should have a Template and Url property.
  rem --
  if item.Template <> invalid and item.Url <> invalid and item.Url <> ""
    url = item.Url

    if item.Template = "Video"
      rem --
      rem -- Play a video.
      rem --
      LogMessage("Showing Video: " + url)

      PlayVideo(url)
    else if item.Template = "Image"
      rem --
      rem -- Show an image.
      rem --
      LogMessage("Showing Image: " + url)

      view = CreateObject("roSGNode", "ImageView")
      view.uri = url
      view.mainScene = m.top
      PushView(view)
    else if item.Template = "PosterList"
      rem --
      rem -- Show a Poster List sub-menu.
      rem --
      url = AppendResolutionToUrl(url)
      LogMessage("Showing PosterList: " + url)

      view = CreateObject("roSGNode", "PosterListView")
      view.uri = url
      view.mainScene = m.top
      PushView(view)
    end if
  end if
end sub

rem --
rem -- AppendResolutionToUrl(url)
rem --
rem -- Takes a URL and appends the common resolution parameter to it.
rem --
rem -- @param url The URL to have the resolution appended.
rem -- @returns A string that represents the new URL to be used.
rem --
function AppendResolutionToUrl(url as string) as string
  if url.InStr("?") = -1
    return url + "?Resolution=" + m.top.getScene().currentDesignResolution.height.ToStr() + "p"
  else
    return url + "&Resolution=" + m.top.getScene().currentDesignResolution.height.ToStr() + "p"
  end if
end function

rem *******************************************************
rem ** EVENT HANDLERS
rem *******************************************************

rem --
rem -- onContentChanged()
rem --
rem -- The URL download task has finished and provided content for
rem -- use to parse. We then populate the UI with the information.
rem --
sub onContentChanged()
  rem --
  rem -- Try to parse the retrieved content as JSON.
  rem --
  m.config = invalid
  if m.task.success = true
    m.config = parseJSON(m.task.content)
  end if

  if m.config <> invalid
    rem --
    rem -- Configure UI elements with the configuration options.
    rem --
    m.pBackground.uri = m.config.BackgroundUrl

    rem --
    rem -- Build a list of buttons provided in the config.
    rem --
    buttons = []
    for each b in m.config.buttons
      buttons.Push(b.Title)
    end for

    rem --
    rem -- Set the menu bar's buttons to those we found in the config.
    rem --
    m.mbMenuBar.buttons = buttons
  else
    LogMessage("Failed to load main scene content.")
  end if
end sub

rem --
rem -- onBackgroundStatus()
rem --
rem -- Called once the background image has finished loading. At this
rem -- point we can show the menu bar and hide the loading spinner.
rem --
sub onBackgroundStatus()
  rem --
  rem -- Verify that the image either loaded or failed. We don't want
  rem -- to activate during the loading state.
  rem --
  if m.pBackground.loadStatus = "ready" or m.pBackground.loadStatus = "failed"
    rem --
    rem -- Prepare the main menu controls for fading in.
    rem --
    m.gMainMenu.opacity = 0
    m.gMainMenu.visible = true
    m.mbMenuBar.setFocus(true)

    rem --
    rem -- Start fading in the menu and fading out the spinner.
    rem --
    m.aFadeMenu.control = "start"
  end if
end sub

rem --
rem -- onFadeMenuState()
rem --
rem -- The menu fade animation has completed. Make sure the spinner
rem -- is stopped and no longer visible at all.
rem --
sub onFadeMenuState()
  if m.aFadeMenu.state = "stopped"
    m.bsLoading.control = "stop"
    m.bsLoading.visible = false
  end if
end sub

rem --
rem -- onFadeViewState()
rem --
rem -- A fade animation for showing or hiding a view has completed. Do
rem -- final processing.
rem --
sub onFadeViewState()
  if m.aFadeView.state = "stopped"
    if m.viewFadingIn = true
      rem --
      rem -- If we were fading in, make sure the new view has focus
      rem -- and clear the animation identifier.
      rem --
      m.gViews.getChild(m.gViews.getChildCount() - 1).setFocus(true)
      m.gViews.getChild(m.gViews.getChildCount() - 1).id = ""
    else
      rem --
      rem -- If we were fading out, remove the old view.
      rem --
      m.gViews.removeChildIndex(m.gViews.getChildCount() - 1)

      rem --
      rem -- Set the focus to either the previous view on the stack
      rem -- or the main menu bar if no views remain.
      rem --
      if m.gViews.getChildCount() > 0
        m.gViews.getChild(m.gViews.getChildCount() - 1).setFocus(true)
      else
        m.mbMenuBar.setFocus(true)
      end if
    end if
  end if
end sub

rem --
rem -- onKeyEvent(key, press)
rem --
rem -- A key has been pressed or released on the remote. Do any
rem -- required processing to handle the event.
rem --
rem -- @param key The description of the key that was pressed or released.
rem -- @param press True if the key was pressed, false if it was released.
rem --
function onKeyEvent(key as string, press as boolean) as boolean
  rem --
  rem -- Consume all key events if we are currently transitioning
  rem -- between views.
  rem --
  if m.aFadeView.state = "running"
    return true
  end if

  if press
    if key = "back"
      rem --
      rem -- If the back button was pressed and we have views on
      rem -- the stack, then pop the active view. Otherwise allow
      rem -- the back button to exit out of the app.
      rem --
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

rem --
rem -- onSelectedButtonIndex()
rem --
rem -- A menu button has been selected. Show the selected item on
rem -- the screen.
rem --
sub onSelectedButtonIndex()
  item = m.config.Buttons[m.mbMenuBar.selectedButtonIndex]

  ShowItem(item)
end sub
