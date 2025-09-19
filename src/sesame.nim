import picostdlib/[gpio, time, cyw43, lwip]

const ssid = "CBC"
const phrase = "Rigatoni_con_basilico_e_mozzarella"
#const ssid = "ravi"
#const phrase = "Md2bcq!7bm"

const wpaAuth = 0x00400004
const timeout = 10000

const speed = 200

#while not stdioUsbConnected():
#  sleep 1

cyw43.init()

var blinkCode = 1

enableStation()

# blink, blink, blink, I'm booting!
for i in 0..2:
  cyw43.setGpio(0, true)
  sleep(speed)
  cyw43.setGpio(0, false)
  sleep(speed)

# set up wifi
if connectWifi(ssid, phrase, wpaAuth, timeout):
  blinkCode += 1

# tcp server handlers

proc receives(arg: pointer, conn: ptr Tcp, p: ptr Pbuf, err: cint): cint {.cdecl.} =
  var response = cstring"Echo: received data\n"
  discard write(conn, response, response.len.cushort, cuchar 1)
  discard output(conn)
  discard close(conn)

proc accepts(arg: pointer, newConn: ptr Tcp, err: cint): cint {.cdecl.} =
  newConn.receive(cast[pointer](receives))
  return 0

# tcp server init

var conn = initTcp()
discard `bind`(conn, nil, 80)
conn = conn.listen  # yes, replace the Tcp
conn.accept(cast[pointer](accepts))

# loop

while true:
  for i in 0..blinkCode:
    cyw43.setGpio(0, true)
    sleep(speed)
    cyw43.setGpio(0, false)
    sleep(speed) 
  sleep(speed * 4) 

