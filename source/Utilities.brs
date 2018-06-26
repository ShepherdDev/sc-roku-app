rem --
rem -- ReadConfig()
rem --
rem -- Read the configuration file specified in the manifest.
rem --
rem -- @returns An object representing the JSON config file.
function ReadConfig() as object
  appInfo = CreateObject("roAppInfo")
  json = ReadAsciiFile(appInfo.GetValue("app_config"))

  return ParseJSON(json)
end function

rem --
rem -- LogMessage(msg)
rem --
rem -- If running in development mode, logs a message to the
rem -- BrightScript console.
rem --
rem -- @param msg The string to be logged to the console.
rem --
sub LogMessage(msg as string)
  if CreateObject("roAppInfo").IsDev() = true
    print msg
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
