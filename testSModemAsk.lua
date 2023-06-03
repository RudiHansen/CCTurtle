rednet.open("left") --enable modem on the right side of the PC

rednet.broadcast("Hello","Q")

id,message, foo = rednet.receive() --wait until a mesage is received
print(id)
print(message)
print(foo)
