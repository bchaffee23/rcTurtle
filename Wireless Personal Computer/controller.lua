local commandChannel = "1"
local targetID = 5

term.clear()
term.setCursorPos(1,1)
rednet.open("back")

function sendCommand(command)
    if not targetID then
        print("Target ID not set. Please set the target ID first.")
        return
    end
    rednet.send(targetID, tostring(command), commandChannel)
    if command == 'list' then
        remoteList()
        local file = fs.open("status_report.txt", "r")
        local report = file.readAll()
        file.close()
        term.clear()
        term.setCursorPos(1,1)
        print("Commands for Turtle ", targetID, ": ")
        print("--------------------------")
        print(report)
        print("")
        print("Press Enter to continue.")
        read()
    else
        print("Command sent:", command)
        sleep(2)
    end
end

function saveFile(filename, content)
    local file = fs.open(filename, "w")
    file.write(content)
    file.close()
end

function remoteList()
    rednet.open("back")
    local senderID, message, protocol = rednet.receive(statusChannel)

    if message then
        local filename = "status_report.txt"
        saveFile(filename, message)
    else
        print("Communication error.")
    end
end

function interactiveMenu()
    while true do
        term.clear()
        term.setCursorPos(1,1)
        print("Command Interface - Ch", commandChannel)
        print("--------------------------")
        term.setCursorPos(1,18)
        print("--------------------------")
        write(" Get commands : 'list' ")
        term.setCursorPos(1,3)
        write("> ")
        local command = read()
        if command == 'exit' then break end
        sendCommand(command)
    end
end

interactiveMenu()
