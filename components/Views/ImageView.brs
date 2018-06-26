sub init()
  m.rImage = m.top.findNode("rImage")
  m.pImage = m.top.findNode("pImage")

  resolution = m.top.getScene().currentDesignResolution
  m.rImage.width = resolution.width
  m.rImage.height = resolution.height
  m.pImage.width = resolution.width
  m.pImage.height = resolution.height

  m.pImage.uri = m.top.uri
  m.top.observeField("uri", "onUriChange")
end sub

sub onUriChange()
  m.pImage.uri = m.top.uri
end sub
