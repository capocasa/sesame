#### A tiny web server using the lwip tcp server
# todo: its own module
import picostdlib/[lwip]
import std/[httpcore,strutils]
export httpcore

type
  Request* = ptr Tcp

# respond helper, must be called
proc respond*(conn: ptr Tcp, code: HttpCode, body: string) =
  let response = "HTTP/1.1 " & $code & "\r\nContent-Length: " & $body.len & "\r\n\r\n" & body
  discard write(conn, response, response.len.cushort, cuchar 1)
  discard output(conn)
  discard close(conn)

# main template
template startNphd*(requestHandler: proc(conn: Request, httpMethod: HttpMethod, path: string), port: uint16) =
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
    let p1 = requestStr.find(' ')
    let p2 = requestStr.find(' ', p1+1)
    let httpMethod = parseEnum[HttpMethod](requestStr[0..<p1])
    let path = requestStr[p1+1..<p2]
    # TODO: parse the rest of the request
    `requestHandler`(conn, httpMethod, path)
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

