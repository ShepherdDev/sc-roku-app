sub init()
  m.top.functionName = "runRequest"
end sub

sub runRequest()
  ut = CreateObject("roURLTransfer")

  ' allow for https
  ut.SetCertificatesFile("common:/certs/ca-bundle.crt")
  ut.InitClientCertificates()

  ut.SetPort(CreateObject("roMessagePort"))
  ut.SetURL(m.top.url)
  if ut.AsyncGetToString()
    event = wait(m.top.timeout, ut.GetPort())
    if type(event) = "roUrlEvent"
      m.top.responseCode = event.GetResponseCode()
      if m.top.responseCode = 200
        m.top.success = true
      else
        m.top.success = false
      end if

      m.top.content = event.GetString()
    else
      stop
      m.top.success = false
      m.top.content = invalid
    end if
  end if
end sub
