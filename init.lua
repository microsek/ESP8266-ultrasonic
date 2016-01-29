wifi.setmode(wifi.SOFTAP)

cfg={}
cfg.ssid="MicrosekESP"
cfg.pwd="qwerty123"

cfg.ip="192.168.0.1"
cfg.netmask="255.255.255.0"
cfg.gateway="192.168.0.1"

port = 9876

wifi.ap.setip(cfg)
wifi.ap.config(cfg)

n=0

hcsr04 = {};

function hcsr04.init(pin_trig, pin_echo)
    local self = {}
    self.time_start = 0
    self.time_end = 0
-- Choose the correct GPIO pins for the trigger and echo of the HC-SR04 module
    self.trig = 3
    self.echo =  4
    gpio.mode(self.trig, gpio.OUTPUT)
    gpio.mode(self.echo, gpio.INT)

    function self.echo_cb(level)
        if level == 1 then
            self.time_start = tmr.now()
            gpio.trig(self.echo, "down")
        else
            self.time_end = tmr.now()
        end
    end

    function self.measure()
        gpio.trig(self.echo, "up", self.echo_cb)
        gpio.write(self.trig, gpio.HIGH)
        tmr.delay(100)
        gpio.write(self.trig, gpio.LOW)
        tmr.delay(100000)
        if (self.time_end - self.time_start) < 0 then
            return -1
        end
        return (self.time_end - self.time_start) / 58
    end
    return self
end



function receiveData(conn, data)

  conn:send(device.measure())
end

device = hcsr04.init()
print("ESP8266 ultrasonic 1.0 powered by Microsek")
print("SSID: " .. cfg.ssid .. "  PASS: " .. cfg.pwd)
print("Microsek_sonic app must connect to " .. cfg.ip .. ":" .. port)

srv=net.createServer(net.TCP, 28800) 
srv:listen(port,function(conn)
    print("Microsek ESP connected")
     
    conn:on("receive",receiveData)
   
    conn:on("disconnection",function(c) 
        print("Microsek ESP disconnected")
    end)
    
end)
