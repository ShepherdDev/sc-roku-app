sub init()
  m.pImage = m.top.findNode("pImage")

  resolution = m.top.getScene().currentDesignResolution
  m.pImage.width = resolution.width
  m.pImage.height = resolution.height

  m.pImage.uri = m.top.uri
  m.top.observeField("uri", "onUriChange")
end sub

sub onUriChange()
  m.pImage.uri = m.top.uri
end sub
