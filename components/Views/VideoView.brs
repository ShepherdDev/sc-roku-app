rem --
rem -- init
rem --
rem -- Initialize a new Video view. This is used to watch a full-screen
rem -- video on the device.
rem --
sub init()
  rem --
  rem -- Set initial control values.
  rem --
  m.vVideo = m.top.findNode("vVideo")

  rem --
  rem -- Configure the size of the video to full-screen.
  rem --
  resolution = m.top.getScene().currentDesignResolution
  m.vVideo.width = resolution.width
  m.vVideo.height = resolution.height

  rem --
  rem -- Observe the fields we need to monitor for changes.
  rem --
  m.top.observeField("focusedChild", "onFocusedChildChange")
end sub

rem *******************************************************
rem ** EVENT HANDLERS
rem *******************************************************

rem --
rem -- onUriChange
rem --
rem -- The URI for the video we are supposed to play has changed. Update
rem -- the video object to play the new URI.
rem --
sub onUriChange()
  rem --
  rem -- Determine if this is an HLS or MP4 style video link.
  rem --
  if m.top.uri.Instr("m3u8") <> -1 or m.top.uri.Instr("M3u8") <> -1 or m.top.uri.Instr("m3U8") <> -1 or m.top.uri.Instr("M3U8")
    format = "hls"
  else
    format = "mp4"
  end if

  rem --
  rem -- Configure the new video content object.
  rem --
  m.vVideo.control = "stop"
  videoContent = createObject("roSGNode", "ContentNode")
  videoContent.url = m.top.uri
  videoContent.streamformat = format

  rem --
  rem -- Begin playing the video.
  rem --
  m.vVideo.content = videoContent
  m.vVideo.control = "play"
end sub

rem --
rem -- onFocusedChildChange
rem --
rem -- Called when we gain or lose focus. If we are gaining focus then
rem -- ensure that the video object has the true focus.
rem --
sub onFocusedChildChange()
  if m.top.IsInFocusChain() and not m.vVideo.HasFocus()
    m.vVideo.SetFocus(true)
  end if
end sub
