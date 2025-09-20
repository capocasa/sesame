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

#### A tiny web server using the lwip tcp server
# todo: its own module
import httpcore

type
  Request = ptr Tcp

# respond helper, must be called
proc respond(conn: ptr Tcp, code: HttpCode, body: string) =
  let response = "HTTP/1.1 " & $code & "\r\nContent-Length: " & $body.len & "\r\n\r\n" & body
  discard write(conn, response, response.len.cushort, cuchar 1)
  discard output(conn)
  discard close(conn)

# main template
template startNphd(requestHandler: proc(conn: Request, httpMethod: HttpMethod, path: string), port: uint16) =
  # callbacks
  proc receiveRequest(arg: pointer, conn: ptr Tcp, p: ptr Pbuf, err: cint): cint {.cdecl.} =
    if p.isNil:
      discard close(conn)
      return 0
    if p.totalLength == 0:
      free(p)
      discard close(conn)
      return 0
    var requestStr = newString(p.totalLength)
    copyMem(addr requestStr[0], p.payload, p.length.cint)
    received(conn, p.length)
    `requestHandler`(conn, HttpGet, "/")
    free(p)
    return 0

  proc acceptConnection(arg: pointer, conn: ptr Tcp, err: cint): cint {.cdecl.} =
    receive(conn, cast[pointer](receiveRequest))
    return 0

  # tcp server init

  var conn = initTcp()
  discard `bind`(conn, nil, cushort port)
  conn = listen(conn) # yes, replace the Tcp
  accept(conn, cast[pointer](acceptConnection))

#### web server init code

proc requested(r: Request, httpMethod: HttpMethod, path: string) =
  r.respond(Http200, "Hello, World!")

startNphd(requested, 80)

# loop

while true:
  for i in 0..blinkCode:
    cyw43.setGpio(0, true)
    sleep(speed)
    cyw43.setGpio(0, false)
    sleep(speed) 
  sleep(speed * 4) 

