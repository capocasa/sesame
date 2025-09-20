import picostdlib/[gpio, time, cyw43]
import nphd

const ssid = "CBC"
const phrase = "Rigatoni_con_basilico_e_mozzarella"
#const ssid = "ravi"
#const phrase = "Md2bcq!7bm"

const
  wpaAuth = 0x00400004
  timeout = 10000
  slow = 200
  fast = 80

cyw43.init()

enableStation()

# blink, blink, blink, I'm booting!
for i in 0..2:
  cyw43.setGpio(0, true)
  sleep(fast)
  cyw43.setGpio(0, false)
  sleep(fast)

# set up wifi
if not connectWifi(ssid, phrase, wpaAuth, timeout):
  while true:
    cyw43.setGpio(0, true)
    sleep(fast)
    cyw43.setGpio(0, false)
    sleep(fast) 

#### web server init code

proc requested(r: Request, httpMethod: HttpMethod, path: string) =
  case ($httpMethod & " " & path)  # TOOD: make this a bit more elegant
  of "GET /":
    r.respond(Http200, "Can do things")
    cyw43.setGpio(0, true)
    sleep(fast)
    cyw43.setGpio(0, false)
    sleep(fast) 

  of "POST /":
    r.respond(Http200, "Done")
    cyw43.setGpio(0, true)
    sleep(slow)
    cyw43.setGpio(0, false)
    sleep(slow) 

  else:
    r.respond(Http404, $Http404)

startNphd(requested, 80)

#notify boot
for i in 0..1:
  cyw43.setGpio(0, true)
  sleep(fast)
  cyw43.setGpio(0, false)
  sleep(fast) 

# loop
while true:
  sleep(fast)

