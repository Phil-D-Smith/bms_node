-- load credentials file - SSID and PASSWORD
dofile("credentials.lua")

-- startup function to run after 5 seconds
function startup()
    if file.open("init.lua") == nil then
      print("init.lua not found")
    else
      print("Starting")
      file.close("init.lua")
      -- run actual program in main.lua
      dofile("main.lua")
    end
end

-- connected callback
wifi_connect = function(this) 
  print("Connection to AP("..this.SSID..")")
  if disconnectCount ~= nil then disconnectCount = nil end  
end

-- ip recieved callback
wifi_got_ip = function(this) 
  -- connection can be determined with net.dns.resolve().    
  print("IP address is: "..this.IP)
  print("5 seconds to abort...")
  -- timer to delay startup function, incase of errors in this file
  tmr.create():alarm(5000, tmr.ALARM_SINGLE, startup)
end

--disconnected callback
wifi_disconnect = function(this)
  if this.reason == wifi.eventmon.reason.ASSOC_LEAVE then 
    --the station has disassociated from previous access point
    return 
  end
  -- number of connection attempts
  local totalAttempts = 75
  print("\nConnection to AP("..this.SSID..") failed")

  --loops through and returns disconnect reason
  for key, value in pairs(wifi.eventmon.reason) do
    if value == this.reason then
      print("Reason: "..value.."("..key..")")
      break
    end
  end

  if disconnectCount == nil then 
    disconnectCount = 1 
  else
  	-- increment attempt, see totalAttempts
    disconnectCount = disconnectCount + 1 
  end
  if disconnectCount < totalAttempts then 
    print("Retrying connection (attempt "..(disconnectCount + 1).." of "..totalAttempts..")")
  else
    wifi.sta.disconnect()
    print("Abort")
    disconnectCount = nil  
  end
end

-- register some callback functions (incl startup on got_ip) for the wifi event monitors
wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, wifi_connect)
wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, wifi_got_ip)
wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, wifi_disconnect)

print("Connecting to WiFi...")
-- set wifi mode and connection to station with credentials
wifi.setmode(wifi.STATION)
wifi.sta.config({ssid=SSID, pwd=PASSWORD})
