-----------------------------------------------------------------------------------------
--
-- main.lua
--
-----------------------------------------------------------------------------------------

local testBalloon = false
local testWAS = true
local widget = require("widget")

if (testWAS) then
    local wickeyappstore = require("wickeyappstore")
    local json = require("json")

    local label = display.newText("output", 50, 220, native.systemFont, 16)
    label.x = display.contentCenterX
    local data = native.newTextBox(160, 360, 320, 250)
    data.isEditable = true

    -- JS event listener.
    local function pluginListener(event)
        local str = json.prettify(event)
        if (event.name == "wasUser") then
            data.text = "wasUser got event from JS plugin:" .. str
        else
            str = "got event from JS plugin:\n" .. str
            print(str)
            data.text = str
        end
    end

    local getScore = function()
        -- call JS native plugin
        data.text = wickeyappstore.dataGet("highScore")
    end
    local saveScore = function()
        -- call JS native plugin
        wickeyappstore.dataSave("highScore", 10)
    end
    local gameoverCleanup = function()
        -- call JS native plugin
        wickeyappstore.dataPersist()
    end
    local getUser = function()
        -- call JS native plugin
        wickeyappstore.user(
            function(event)
                print("++++wickeyappstore.user++++")
                if (event) then
                    local str = json.prettify(event)
                    data.text = str
                else
                    data.text = "null"
                end
            end
        )
    end
    wickeyappstore.onOpen(
        function()
            print("++++wickeyappstore.onOpen++++")
        end
    )
    wickeyappstore.onClose(
        function()
            print("++++wickeyappstore.onClose++++")
        end
    )
    local saveConflictRes = function(localSave, cloudSave)
        local keepSave = localSave
        if (localSave and cloudSave) then
            if (cloudSave.highScore > localSave.highScore) then
                keepSave = cloudSave
            end
        end
        return keepSave
    end
    local initRestored = false
    local restoreSave = function()
        wickeyappstore.dataRestore(
            function(_data)
                print("++++wickeyappstore.dataRestore++++")
                initRestored = true
            end,
            saveConflictRes
        )
    end

    wickeyappstore.onLoad(
        function()
            print("++++wickeyappstore.onLoad++++")
            restoreSave()
            wickeyappstore.loginChange(
                function(_loggedIn)
                    print("++++wickeyappstore.loginChange++++")
                    if (initRestored == true) then
                        restoreSave()
                    end
                end
            )
        end
    )

    widget.newButton {
        onRelease = getUser,
        left = 60,
        top = 5,
        width = 200,
        height = 50,
        label = "Get User",
        labelColor = {default = {1, 1, 1}, over = {0.6, 0.6, 0.6}}
    }
    widget.newButton {
        onRelease = saveScore,
        left = 60,
        top = 35,
        width = 200,
        height = 50,
        label = "Save Data",
        labelColor = {default = {1, 1, 1}, over = {0.6, 0.6, 0.6}}
    }
    widget.newButton {
        onRelease = getScore,
        left = 60,
        top = 65,
        width = 200,
        height = 50,
        label = "Read Saved Data",
        labelColor = {default = {1, 1, 1}, over = {0.6, 0.6, 0.6}}
    }
    widget.newButton {
        onRelease = gameoverCleanup,
        left = 60,
        top = 120,
        width = 200,
        height = 50,
        label = "Persist",
        labelColor = {default = {1, 1, 1}, over = {0.6, 0.6, 0.6}}
    }
end

if (testBalloon) then
    -- Your code here
    local tapCount = 0

    local background = display.newImageRect("background.png", 360, 570)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    local tapText = display.newText(tapCount, display.contentCenterX, 20, native.systemFont, 40)
    tapText:setFillColor(0, 0, 0)

    local platform = display.newImageRect("platform.png", 300, 50)
    platform.x = display.contentCenterX
    platform.y = display.contentHeight - 25

    local balloon = display.newImageRect("balloon.png", 112, 112)
    balloon.x = display.contentCenterX
    balloon.y = display.contentCenterY
    balloon.alpha = 0.8

    local physics = require("physics")
    physics.start()

    physics.addBody(platform, "static")
    physics.addBody(balloon, "dynamic", {radius = 50, bounce = 0.3})

    local function pushBalloon()
        balloon:applyLinearImpulse(0, -0.75, balloon.x, balloon.y)
        tapCount = tapCount + 1
        tapText.text = tapCount
    end

    balloon:addEventListener("tap", pushBalloon)
end
