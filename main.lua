-- timer setup
local readingInterval = 10000
local readingTimer = tmr.create()

-- change this when server is live
serverUrl = 'http://192.168.1.140:8000/headstation/upload_data/'

-- function to read all analog, 1-wire, I2C etc.. sensors
function readSensors()
    print("reading sensor")
    -- random temperature - replace with sensor reading
    temperature = math.random(20,30)
    headers = 'Content-Type: application/json\r\n'
    dataString = {}
    dataString['action'] = 'uploadData'
    dataString['temperature'] = temperature
    -- post to server
    http.post(	serverUrl,
    			headers,
    			sjson.encode(dataString),
    			function(code, data)
    				if (code < 0) then
    					print("HTTP request failed, code: "..code.."")
    				else
    					print(code, data)
    				end
    			end
    			)

end





print("hello")
readingTimer:register(readingInterval, tmr.ALARM_AUTO, readSensors)
readingTimer:start()
