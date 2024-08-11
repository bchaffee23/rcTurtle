local statusChannel = "2"
local targetID = 5

term.clear()
term.setCursorPos(1,1)
print("Monitoring Turtle ", targetID)
print("--------------------------")
print("")

rednet.open("back")

function receiveUpdates()
    while true do
        local senderID, message, protocol = rednet.receive(statusChannel)
        targetID = senderID
        if message then
            local file = fs.open("update_log.txt", "w")
            file.write(message)
            file.close()
        end
        print(message)
        sleep(0.05)
        local posX, posY = term.getCursorPos(x, y)
        if posY > 15 then
            term.clear()
            term.setCursorPos(1,1)
            print("Monitoring Turtle ", targetID)
            print("--------------------------")
        end
    end
end

receiveUpdates()
