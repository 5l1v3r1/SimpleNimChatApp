import json 
type 
  Message* = object
    username*: string
    message*: string

proc parseMessage* (data: string): Message = 
  let dataJson = parseJson(data)
  #result is implicitly the return variable on any function
  result.username = dataJson["username"].getStr()
  result.message = dataJson["message"].getStr()


proc createMessage* (username,message: string): string = 
  # % turns into appropriate json object $ turns into string
  result = $(%{
    "username": %username,
    "message": %message
    }) & "\c\l"


when isMainModule:
    block:
      let data = """{"username": "John", "message": "Hi"} """
      let parsed = parseMessage(data)
      doAssert parsed.username == "John"
      doAssert parsed.message == "Hi"
      echo("All tests passed")
    block:
      let data = """foobar"""
      try:
        let parsed = parseMessage(data)
        doAssert false
      except JsonParsingError:
        doAssert true
      except:
        doAssert false
    block:
      let expected = """{"username":"Matt","message":"hello"}""" & "\c\l"
      doAssert createMessage("Matt", "hello") == expected
    block:
      let expected = """{"username":"\"Matt","message":"hello"}""" & "\c\l"
      doAssert createMessage("\"Matt", "hello") == expected