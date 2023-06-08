local startTime = os.clock()
sleep(1.5)
print("os.clock = " .. os.clock()-startTime)


startTime = os.time()
sleep(1.5)
print("os.time = " .. os.time()-startTime)

startTime = os.epoch()
sleep(1.5)
print("os.epoch = " .. os.epoch()-startTime)


