sub Main(args as dynamic)
  'Indicate this is a Roku SceneGraph application'
  screen = CreateObject("roSGScreen")
  m.port = CreateObject("roMessagePort")
  screen.setMessagePort(m.port)

  scene = screen.CreateScene("CrexScene")
  screen.show()

  if (args.contentID <> invalid and args.mediaType <> invalid)
    item = args.contentID.Split("|")
    scene.callFunc("ShowItem", {Template: item[0], Url: item[1].Unescape()})
  end if

  while(true)
    msg = wait(0, m.port)
    msgType = type(msg)
    if msgType = "roSGScreenEvent"
      if msg.isScreenClosed() then return
    end if
  end while
end sub
