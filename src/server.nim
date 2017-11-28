import asyncdispatch, asyncnet
#to connect without client object done open cmd and type telnet, then open localhost 7687
type
  Client = ref object
    socket: AsyncSocket
    netAddr: string
    id: int
    connected: bool

  Server = ref object
    socket: AsyncSocket
    clients: seq[Client]

proc newServer(): Server = Server(socket: newAsyncSocket(), clients: @[])
proc `$`(client: Client): string =
  $client.id & " (" & client.netAddr & ")"
var server = newServer();

proc processMessages(server: Server, client: Client) {.async.} = 
  while true:
    # wait for the user to give a line
    let line = await client.socket.recvLine()
    #will be this is they are disconnecting so end proc
    if line.len == 0:
      echo(client, " disconnected!")
      client.connected = false
      client.socket.close()
      return
    echo( client, " sent: " , line)
    for c in server.clients:
      if c.id != client.id and c.connected:
        await c.socket.send(line & "\c\l")

proc loop(server: Server, port = 7687) {.async.} = 
  server.socket.bindAddr(port.Port)
  server.socket.listen()

  while true:
  # tuple unpacking these will be variables after
   let (netAddr, clientSocket) = await server.socket.acceptAddr()
   echo("Accepted Connection From: ", netAddr)
   let client = Client(
      socket: clientSocket,
      netAddr: netAddr,
      id: server.clients.len,
      connected: true
    )
   server.clients.add(client)
   # runs async procedures without checking their results, ie run this
   asyncCheck processMessages(server, client)



waitFor loop(server)