sub LogMessage(msg as string)
  if CreateObject("roAppInfo").IsDev() = true
    print msg
  end if
end sub
