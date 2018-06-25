sub init()
  m.vVideo = m.top.findNode("vVideo")

  resolution = m.top.getScene().currentDesignResolution
  m.vVideo.width = resolution.width
  m.vVideo.height = resolution.height

  m.top.observeField("focusedChild", "onFocusedChildChange")
end sub

sub onUriChange()
  if m.top.uri.Instr("m3u8") <> -1 or m.top.uri.Instr("M3u8") <> -1 or m.top.uri.Instr("m3U8") <> -1 or m.top.uri.Instr("M3U8")
    format = "hls"
  else
    format = "mp4"
  end if

  m.vVideo.control = "stop"
  videoContent = createObject("roSGNode", "ContentNode")
  videoContent.url = m.top.uri
  videoContent.streamformat = format

  m.vVideo.content = videoContent
  m.vVideo.control = "play"
end sub

sub onFocusedChildChange()
  if m.top.IsInFocusChain() and not m.vVideo.HasFocus()
    m.vVideo.SetFocus(true)
  end if
end sub
