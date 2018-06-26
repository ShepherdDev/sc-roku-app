rem --
rem -- init()
rem --
rem -- Initialize a new URLTask component. This handles retrieving
rem -- content from a remote URL. The content should be a UTF-8 encoded
rem -- string (such as JSON).
rem --
sub init()
  rem --
  rem -- Specify the function that will be called on the background
  rem -- thread to process the request.
  rem --
  m.top.functionName = "runRequest"
end sub

rem --
rem -- runRequest()
rem --
rem -- Called on a background thread to process the request.
rem --
sub runRequest()
  rem --
  rem -- Create a URLTransfer object that will handle the heavy lifting
  rem -- of requesting a remote URL.
  rem --
  ut = CreateObject("roURLTransfer")

  rem --
  rem -- Configure to handle HTTPS certificates.
  rem --
  ut.SetCertificatesFile("common:/certs/ca-bundle.crt")
  ut.InitClientCertificates()

  rem --
  rem -- Configure the remote URL and the message port that we will
  rem -- be listening on.
  rem --
  ut.SetPort(CreateObject("roMessagePort"))
  ut.SetURL(m.top.url)

  rem --
  rem -- Begin processing in the background and wait for a response.
  rem --
  if ut.AsyncGetToString()
    rem --
    rem -- Wait for the response to come in.
    rem --
    event = wait(m.top.timeout, ut.GetPort())

    rem --
    rem -- Check to be sure we got the expected response type.
    rem --
    if type(event) = "roUrlEvent"
      rem --
      rem -- Check the response code to ensure we got a success
      rem -- response.
      rem --
      m.top.responseCode = event.GetResponseCode()
      if m.top.responseCode = 200
        m.top.success = true
      else
        m.top.success = false
      end if

      m.top.content = event.GetString()
    else
      m.top.success = false
      m.top.content = invalid
    end if
  end if
end sub
