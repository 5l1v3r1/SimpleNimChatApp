import os, threadpool, asyncdispatch, asyncnet
import protocol


proc connect(socket: AsyncSocket, serverAddr: string) {.async.} = 
  echo("Connecting to: ", serverAddr)
  await socket.connect(serverAddr, 7687.Port)
  echo("Connected")
  while true:
    let line = await socket.recvLine()
    let parsed = parseMessage(line)
    echo(parsed.username, " said: ", parsed.message)


echo("Chat application started")
if paramCount() == 0:
  quit("Please supply a server address to run application on, e.g. localhost")
let serverAddress = paramStr(1);
var socket = newAsyncSocket()

asyncCheck connect(socket, serverAddress)
echo("What would you like your username to be?")
var usernameFuture = spawn stdin.readline()
var username = ""
while username == "":
  if usernameFuture.isReady():
    username = ^usernameFuture


echo("What message would you like to send?")
var messageFuture = spawn stdin.readline()
while true:
  if messageFuture.isReady():
    let message = createMessage(username, ^messageFuture)
    asyncCheck socket.send(message)
    messageFuture = spawn stdin.readline()
  asyncdispatch.poll()




