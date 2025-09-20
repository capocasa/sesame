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

#proc sents(arg: pointer, conn: ptr Tcp, length: cushort): cint {.cdecl.} =
#  discard conn.close
#  return 0

proc receives(arg: pointer, conn: ptr Tcp, p: ptr Pbuf, err: cint): cint {.cdecl.} =
  if p.isNil:
    discard conn.close
    return 0
  if p.totalLength == 0:
    p.free
    discard conn.close
    return 0
  var line = newString(p.totalLength)
  copyMem(addr line[0], p.payload, p.length.cint)
  conn.received(p.length)
  let body = "OK " & line & " " & $p.totalLength & " " & $p.length & " <<"
  let response = "HTTP/1.1 200 OK\r\nContent-Length: " & $body.len & "\r\n\r\n" & body
  discard conn.write(response, response.len.cushort, cuchar 1)
  discard conn.output
  discard conn.close
  p.free
  return 0

proc accepts(arg: pointer, conn: ptr Tcp, err: cint): cint {.cdecl.} =
  #conn.sent(cast[pointer](sents))
  conn.receive(cast[pointer](receives))
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

