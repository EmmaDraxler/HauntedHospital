local c = require("config")
local gameLogic = {}

local function getCollisionRect(map, x, y, size)
    local minX = math.floor(x / c.tileSize) + 1
    local minY = math.floor(y / c.tileSize) + 1
    local maxX = math.floor((x + size) / c.tileSize) + 1
    local maxY = math.floor((y + size) / c.tileSize) + 1

    local rects = {}
    for i = minY, maxY do
        for j = minX, maxX do
            if map[i] and map[i][j] == 1 then
                table.insert(rects, {x = (j - 1) * c.tileSize, y = (i - 1) * c.tileSize, width = c.tileSize, height = c.tileSize})
            end
        end
    end
    return rects
end

local function isPlayerAtExit(map, x, y, size)
    local minX = math.floor(x / c.tileSize) + 1
    local minY = math.floor(y / c.tileSize) + 1
    local maxX = math.floor((x + size) / c.tileSize) + 1
    local maxY = math.floor((y + size) / c.tileSize) + 1

    for i = minY, maxY do
        for j = minX, maxX do
            if map[i] and map[i][j] == 3 then return true end
        end
    end
    return false
end

function gameLogic.update(dt)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Button-Größen dynamisch anpassen
    local aktuellerFont = c.fonts.labFont
    if c.state == "title" or c.state == "jumpscare" or c.state == "gameover" or c.state == "win" then aktuellerFont = c.fonts.titleFont
    elseif c.state == "corridor" and c.corridorStep >= 3 then aktuellerFont = c.fonts.corridorFont end

    c.weiterButton.width = math.max(300, aktuellerFont:getWidth("Weiter") + 60)
    c.weiterButton.x = (screenWidth - c.weiterButton.width) / 2
    c.option1.width = math.max(220, aktuellerFont:getWidth(c.option1.text) + 40)
    c.option2.width = math.max(220, aktuellerFont:getWidth(c.option2.text) + 40)
    local gesamtBreite = c.option1.width + c.option2.width + 40
    c.option1.x = (screenWidth - gesamtBreite) / 2
    c.option2.x = c.option1.x + c.option1.width + 40

    c.mouseX, c.mouseY = love.mouse.getPosition()

    -- Status-Updates
    if c.state == "title" then
        c.timer = c.timer + dt
        if c.timer >= 2 then c.state = "scene" c.typewriterProgress = 0 end

    elseif c.state == "scene" then
        local vollerText = c.texte[c.aktuellerText]
        local textLaenge = c.utf8.len(vollerText)
        if c.typewriterProgress < textLaenge then
            c.typewriterProgress = c.typewriterProgress + (c.typewriterSpeed * dt)
            local zeichenAnzahl = math.floor(c.typewriterProgress)
            local bytePosition = c.utf8.offset(vollerText, zeichenAnzahl + 1)
            if bytePosition then c.typewriterText = string.sub(vollerText, 1, bytePosition - 1) end
        else c.typewriterText = vollerText end

    elseif c.state == "corridor" then
        c.corridorTimer = c.corridorTimer + dt
        if c.corridorTimer > 2 and c.corridorStep == 1 then c.corridorStep = 2
        elseif c.corridorTimer > 5 and c.corridorStep == 2 then c.corridorStep = 3
        elseif c.corridorTimer > 8 and c.corridorStep == 3 then c.corridorStep = 4
        elseif c.corridorTimer > 11 and c.corridorStep == 4 then
            c.state = "jumpnrun"
            c.player.x = 50 c.player.y = 400 c.player.vx = 0 c.player.vy = 0
            c.zombieWallX = -200
        end

    elseif c.state == "jumpnrun" then
        c.zombieWallX = c.zombieWallX + c.zombieWallSpeed * dt
        if c.player.x < c.zombieWallX or c.player.y > screenHeight then c.state = "gameover" end

        c.player.vx = 0
        if love.keyboard.isDown("right") then c.player.vx = c.player.speed end

        c.player.vy = c.player.vy + c.jnrGravity * dt
        c.player.x = c.player.x + c.player.vx * dt
        c.player.y = c.player.y + c.player.vy * dt

        for _, mp in ipairs(c.movingPlatforms) do
            mp.x = mp.x + mp.speed * mp.direction * dt
            if mp.x > mp.endX then mp.x = mp.endX mp.direction = -1
            elseif mp.x < mp.startX then mp.x = mp.startX mp.direction = 1 end
        end

        c.player.onGround = false
        for _, plat in ipairs(c.jnrPlatforms) do
            if c.checkCollision(c.player.x, c.player.y, c.player.size, c.player.size, plat.x, plat.y, plat.width, plat.height) then
                if c.player.vy > 0 and c.player.y + c.player.size - c.player.vy * dt <= plat.y then
                    c.player.y = plat.y - c.player.size
                    c.player.vy = 0
                    c.player.onGround = true
                end
            end
        end

        for _, mp in ipairs(c.movingPlatforms) do
            if c.checkCollision(c.player.x, c.player.y, c.player.size, c.player.size, mp.x, mp.y, mp.width, mp.height) then
                if c.player.vy > 0 and c.player.y + c.player.size - c.player.vy * dt <= mp.y then
                    c.player.y = mp.y - c.player.size
                    c.player.vy = 0
                    c.player.onGround = true
                    c.player.x = c.player.x + mp.speed * mp.direction * dt
                end
            end
        end

        for _, haz in ipairs(c.jnrHazards) do
            if c.checkCollision(c.player.x, c.player.y, c.player.size, c.player.size, haz.x, haz.y, haz.width, haz.height) then
                c.player.x = math.max(c.player.x - 100, c.zombieWallX + 20)
                c.player.vy = -200
            end
        end

        if c.checkCollision(c.player.x, c.player.y, c.player.size, c.player.size, c.jnrGoal.x, c.jnrGoal.y, c.jnrGoal.width, c.jnrGoal.height) then
            c.geheZuLagerraum()
        end

        c.cameraX = c.player.x - screenWidth / 2 + c.player.size / 2
        if c.cameraX < 0 then c.cameraX = 0 end
        if c.cameraX > c.levelWidth - screenWidth then c.cameraX = c.levelWidth - screenWidth end

    elseif c.state == "lagerraum" then
        c.zombieWallX = c.zombieWallX + c.zombieWallSpeed * 0.5 * dt
        if c.player.x < c.zombieWallX then c.state = "gameover" end

        c.player.vx, c.player.vy = 0, 0
        if love.keyboard.isDown("up") then c.player.vy = -c.player.speed
        elseif love.keyboard.isDown("down") then c.player.vy = c.player.speed end
        if love.keyboard.isDown("left") then c.player.vx = -c.player.speed
        elseif love.keyboard.isDown("right") then c.player.vx = c.player.speed end

        c.player.x = c.player.x + c.player.vx * dt
        c.player.y = c.player.y + c.player.vy * dt

        local rects = getCollisionRect(c.storageMap, c.player.x, c.player.y, c.player.size)
        for _, rect in ipairs(rects) do
            if c.checkCollision(c.player.x, c.player.y, c.player.size, c.player.size, rect.x, rect.y, rect.width, rect.height) then
                if c.player.vx > 0 then c.player.x = rect.x - c.player.size
                elseif c.player.vx < 0 then c.player.x = rect.x + rect.width
                elseif c.player.vy > 0 then c.player.y = rect.y - c.player.size
                elseif c.player.vy < 0 then c.player.y = rect.y + rect.height end
            end
        end

        if isPlayerAtExit(c.storageMap, c.player.x, c.player.y, c.player.size) then c.geheZuRaetsel() end

    elseif c.state == "puzzle" then
        if string.len(c.puzzleInput) == 4 then
            if c.puzzleInput == c.puzzleLösung then c.state = "win" else c.puzzleInput = "" end
        end

    elseif c.state == "jumpscare" then
        c.timer = c.timer + dt
        if c.timer >= 1.5 then c.state = "gameover" end
    end
end

return gameLogic