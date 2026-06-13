-- =================================================================
-- 1. EXTERNE BIBLIOTHEKEN & GLOBALE VARIABLEN
-- =================================================================
local utf8 = require("utf8") -- Für die korrekte Verarbeitung von Umlauten

local timer = 0              -- Universeller Timer für Titelbildschirm und Jumpscares
local state = "title"        -- Steuert den aktuellen Zustand
local corridorTimer = 0      -- Timer für die Flur-Sequenz
local corridorStep = 1       -- Welcher Event im Flur aktiv ist

-- Bild-Variablen
local image
local corridorImage
local zombieImage

-- Mauspositionen
local mouseX = 0
local mouseY = 0

-- Schriftarten
local labFont
local corridorFont
local titleFont

-- Schreibmaschinen-Effekt (Intro-Text)
local typewriterText = ""
local typewriterProgress = 0
local typewriterSpeed = 30

local texte = {
    "Du wachst auf.",
    "Wo bist du?",
    "Du bist in einem Labor vom HAUNTED HOSPITAL.",
    "Du weißt nicht, wie du hierher gekommen bist, aber: RAUS AUS DIESEM VERFLUCHTEN ORT!",
    "Was willst du tun?"
}

local aktuellerText = 1
local showOptions = false

-- Buttons
local weiterButton = { x = 250, y = 550, width = 300, height = 50 }
local option1 = { x = 0, y = 550, width = 220, height = 60, text = "Zur Tür gehen" }
local option2 = { x = 0, y = 550, width = 220, height = 60, text = "Im Labor umsehen" }

-- =================================================================
-- 2. JUMP 'N' RUN VARIABLEN (ZOMBIE-GESCHWINDIGKEIT ANGEPASST)
-- =================================================================
local jnrPlayer = { x = 50, y = 400, vx = 0, vy = 0, size = 30, onGround = false }
local jnrGravity = 1500      -- Schwerkraft nach unten
local jnrJumpForce = -650    -- Sprungkraft
local jnrSpeed = 300         -- Laufgeschwindigkeit nach rechts

-- NEU: Der Verfolger (Geschwindigkeit für mehr Fairness verringert)
local zombieWallX = -200     -- Startet links außerhalb des Bildschirms
local zombieWallSpeed = 110  -- Von 160 auf 110 reduziert: Mehr Zeit für Koordination!

-- KAMERA-VARIABLE
local cameraX = 0

-- LEVEL-BREITE: 3500 Pixel
local levelWidth = 3500

-- FESTE PLATTFORMEN
local jnrPlatforms = {
    { x = 0, y = 450, width = 250, height = 150 },
    { x = 350, y = 380, width = 200, height = 220 },
    { x = 650, y = 480, width = 200, height = 150 },
    { x = 1200, y = 400, width = 150, height = 200 },
    { x = 1450, y = 320, width = 200, height = 280 },
    { x = 2000, y = 440, width = 250, height = 160 },
    { x = 2350, y = 360, width = 180, height = 240 },
    { x = 2650, y = 460, width = 220, height = 140 },
    { x = 2950, y = 380, width = 150, height = 220 },
    { x = 3200, y = 420, width = 300, height = 180 }
}

-- BEWEGLICHE PLATTFORMEN
local movingPlatforms = {
    {
        x = 900, y = 420, width = 150, height = 30,
        startX = 900, endX = 1150, speed = 100, direction = 1
    },
    {
        x = 1700, y = 350, width = 150, height = 30,
        startX = 1700, endX = 1950, speed = 130, direction = 1
    }
}

-- HINDERNISSE (Stacheln)
local jnrHazards = {
    { x = 400, y = 360, width = 40, height = 20 },
    { x = 1500, y = 300, width = 50, height = 20 },
    { x = 2050, y = 420, width = 40, height = 20 },
    { x = 2700, y = 440, width = 60, height = 20 }
}

-- DAS ZIEL
local jnrGoal = { x = 3250, y = 340, width = 50, height = 80 }

-- =================================================================
-- 3. LOVE2D HAUPTFUNKTION: LOAD
-- =================================================================
function love.load()
    if love.filesystem.getInfo("CreepyLab.png") then image = love.graphics.newImage("CreepyLab.png") end
    if love.filesystem.getInfo("Korridor.png") then corridorImage = love.graphics.newImage("Korridor.png") end
    if love.filesystem.getInfo("zombieKopf.png") then zombieImage = love.graphics.newImage("zombieKopf.png") end

    if love.filesystem.getInfo("cour.ttf") then labFont = love.graphics.newFont("cour.ttf", 26) else labFont = love.graphics.newFont(26) end
    if love.filesystem.getInfo("chiller.ttf") then
        corridorFont = love.graphics.newFont("chiller.ttf", 44)
        titleFont = love.graphics.newFont("chiller.ttf", 80)
    else
        corridorFont = love.graphics.newFont(44)
        titleFont = love.graphics.newFont(80)
    end
end

-- HELFERFUNKTION: KOLLISIONSABFRAGE
local function checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

-- =================================================================
-- 4. LOVE2D HAUPTFUNKTION: UPDATE
-- =================================================================
function love.update(dt)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    local aktuellerFont = labFont
    if state == "title" or state == "jumpscare" or state == "gameover" or state == "win" then aktuellerFont = titleFont
    elseif state == "corridor" and corridorStep >= 3 then aktuellerFont = corridorFont end

    local weiterText = "Weiter"
    local wBreite = aktuellerFont:getWidth(weiterText)
    weiterButton.width = math.max(300, wBreite + 60)
    weiterButton.x = (screenWidth - weiterButton.width) / 2

    local t1Breite = aktuellerFont:getWidth(option1.text)
    local t2Breite = aktuellerFont:getWidth(option2.text)
    option1.width = math.max(220, t1Breite + 40)
    option2.width = math.max(220, t2Breite + 40)

    local gesamtBreiteOptionen = option1.width + option2.width + 40
    option1.x = (screenWidth - gesamtBreiteOptionen) / 2
    option2.x = option1.x + option1.width + 40

    mouseX, mouseY = love.mouse.getPosition()

    if state == "title" then
        timer = timer + dt
        if timer >= 2 then state = "scene" typewriterProgress = 0 end
    end

    if state == "scene" then
        local vollerText = texte[aktuellerText]
        local textLaenge = utf8.len(vollerText)
        if typewriterProgress < textLaenge then
            typewriterProgress = typewriterProgress + (typewriterSpeed * dt)
            local zeichenAnzahl = math.floor(typewriterProgress)
            local bytePosition = utf8.offset(vollerText, zeichenAnzahl + 1)
            if bytePosition then typewriterText = string.sub(vollerText, 1, bytePosition - 1) end
        else typewriterText = vollerText end
    end

    if state == "corridor" then
        corridorTimer = corridorTimer + dt
        if corridorTimer > 2 and corridorStep == 1 then corridorStep = 2 end
        if corridorTimer > 5 and corridorStep == 2 then corridorStep = 3 end
        if corridorTimer > 8 and corridorStep == 3 then corridorStep = 4 end
        if corridorTimer > 11 and corridorStep == 4 then
            state = "jumpnrun"
            jnrPlayer.x = 50 jnrPlayer.y = 400 jnrPlayer.vx = 0 jnrPlayer.vy = 0
            zombieWallX = -200
        end
    end

    -- JUMP 'N' RUN UPDATE LOGIK
    if state == "jumpnrun" then
        -- Bewegung des Verfolgers nach rechts
        zombieWallX = zombieWallX + zombieWallSpeed * dt

        -- Kollision mit der Zombie-Wand hinter dir -> Game Over!
        if jnrPlayer.x < zombieWallX then
            state = "gameover"
        end

        jnrPlayer.vx = 0
        if love.keyboard.isDown("right") then
            jnrPlayer.vx = jnrSpeed
        end

        jnrPlayer.vy = jnrPlayer.vy + jnrGravity * dt
        jnrPlayer.x = jnrPlayer.x + jnrPlayer.vx * dt
        jnrPlayer.y = jnrPlayer.y + jnrPlayer.vy * dt

        -- Alle beweglichen Plattformen updaten
        for _, mp in ipairs(movingPlatforms) do
            mp.x = mp.x + mp.speed * mp.direction * dt
            if mp.x > mp.endX then
                mp.x = mp.endX
                mp.direction = -1
            elseif mp.x < mp.startX then
                mp.x = mp.startX
                mp.direction = 1
            end
        end

        -- Kollision feste Plattformen
        jnrPlayer.onGround = false
        for _, plat in ipairs(jnrPlatforms) do
            if checkCollision(jnrPlayer.x, jnrPlayer.y, jnrPlayer.size, jnrPlayer.size, plat.x, plat.y, plat.width, plat.height) then
                if jnrPlayer.vy > 0 and jnrPlayer.y + jnrPlayer.size - jnrPlayer.vy * dt <= plat.y then
                    jnrPlayer.y = plat.y - jnrPlayer.size
                    jnrPlayer.vy = 0
                    jnrPlayer.onGround = true
                end
            end
        end

        -- Kollision bewegliche Plattformen
        for _, mp in ipairs(movingPlatforms) do
            if checkCollision(jnrPlayer.x, jnrPlayer.y, jnrPlayer.size, jnrPlayer.size, mp.x, mp.y, mp.width, mp.height) then
                if jnrPlayer.vy > 0 and jnrPlayer.y + jnrPlayer.size - jnrPlayer.vy * dt <= mp.y then
                    jnrPlayer.y = mp.y - jnrPlayer.size
                    jnrPlayer.vy = 0
                    jnrPlayer.onGround = true
                    jnrPlayer.x = jnrPlayer.x + mp.speed * mp.direction * dt
                end
            end
        end

        -- Kollision mit Stacheln
        for _, haz in ipairs(jnrHazards) do
            if checkCollision(jnrPlayer.x, jnrPlayer.y, jnrPlayer.size, jnrPlayer.size, haz.x, haz.y, haz.width, haz.height) then
                jnrPlayer.x = math.max(jnrPlayer.x - 100, zombieWallX + 20) -- Wirft Spieler etwas zurück
                jnrPlayer.vy = -200
            end
        end

        -- ZIEL ERREICHT?
        if checkCollision(jnrPlayer.x, jnrPlayer.y, jnrPlayer.size, jnrPlayer.size, jnrGoal.x, jnrGoal.y, jnrGoal.width, jnrGoal.height) then
            state = "lagerraum"
        end

        -- Abgrund-Kollision bedeutet jetzt direkt GAMEOVER
        if jnrPlayer.y > screenHeight then
            state = "gameover"
        end

        -- Kameraführung
        cameraX = jnrPlayer.x - screenWidth / 2 + jnrPlayer.size / 2
        if cameraX < 0 then cameraX = 0 end
        if cameraX > levelWidth - screenWidth then cameraX = levelWidth - screenWidth end
    end

    if state == "jumpscare" then
        timer = timer + dt
        if timer >= 1.5 then state = "gameover" end
    end
end

-- =================================================================
-- 5. LOVE2D HAUPTFUNKTION: DRAW
-- =================================================================
function love.draw()
    love.graphics.clear(0, 0, 0)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    if state == "title" or state == "jumpscare" or state == "gameover" or state == "win" then love.graphics.setFont(titleFont)
    elseif state == "scene" or state == "jumpnrun" or state == "lagerraum" then love.graphics.setFont(labFont)
    elseif state == "corridor" then if corridorStep >= 3 then love.graphics.setFont(corridorFont) else love.graphics.setFont(labFont) end end

    if state == "title" then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("THE HAUNTED HOSPITAL", 0, (screenHeight - titleFont:getHeight()) / 2, screenWidth, "center")

    elseif state == "scene" then
        if image then love.graphics.draw(image, (screenWidth - image:getWidth()) / 2, 80) end
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(typewriterText, (screenWidth - 600) / 2, 420, 600, "center")
        if showOptions then
            if mouseX > option1.x and mouseX < option1.x + option1.width and mouseY > option1.y and mouseY < option1.y + option1.height then
                love.graphics.setColor(0.1, 0.4, 0.1, 0.3) love.graphics.rectangle("fill", option1.x, option1.y, option1.width, option1.height)
                love.graphics.setColor(0.2, 0.9, 0.2)
            else love.graphics.setColor(0.5, 0.1, 0.1) end
            love.graphics.rectangle("line", option1.x, option1.y, option1.width, option1.height)
            love.graphics.setColor(1, 1, 1) love.graphics.printf(option1.text, option1.x, option1.y + 15, option1.width, "center")

            if mouseX > option2.x and mouseX < option2.x + option2.width and mouseY > option2.y and mouseY < option2.y + option2.height then
                love.graphics.setColor(0.2, 0.2, 0.2, 0.4) love.graphics.rectangle("fill", option2.x, option2.y, option2.width, option2.height)
                love.graphics.setColor(1, 1, 1)
            else love.graphics.setColor(0.4, 0.4, 0.4) end
            love.graphics.rectangle("line", option2.x, option2.y, option2.width, option2.height)
            love.graphics.setColor(1, 1, 1) love.graphics.printf(option2.text, option2.x, option2.y + 15, option2.width, "center")
        else
            if mouseX > weiterButton.x and mouseX < weiterButton.x + weiterButton.width and mouseY > weiterButton.y and mouseY < weiterButton.y + weiterButton.height then
                love.graphics.setColor(0.3, 0.3, 0.3, 0.3) love.graphics.rectangle("fill", weiterButton.x, weiterButton.y, weiterButton.width, weiterButton.height)
                love.graphics.setColor(0.8, 0.8, 0.8)
            else love.graphics.setColor(0.3, 0.3, 0.3) end
            love.graphics.rectangle("line", weiterButton.x, weiterButton.y, weiterButton.width, weiterButton.height)
            love.graphics.setColor(1, 1, 1) love.graphics.printf("Weiter", weiterButton.x, weiterButton.y + 10, weiterButton.width, "center")
        end

    elseif state == "corridor" then
        if corridorImage then love.graphics.setColor(1, 1, 1) love.graphics.draw(corridorImage, (screenWidth - corridorImage:getWidth()) / 2, (screenHeight - corridorImage:getHeight()) / 2) end
        local flurX = screenWidth / 2 - 250
        if corridorStep >= 3 and zombieImage then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(zombieImage, flurX + 83 - (zombieImage:getWidth()*0.3/2), 500 - (zombieImage:getHeight()*0.3), 0, 0.3, 0.3)
            love.graphics.draw(zombieImage, flurX + 416 - (zombieImage:getWidth()*0.25/2), 480 - (zombieImage:getHeight()*0.25), 0, 0.25, 0.25)
            love.graphics.draw(zombieImage, flurX + 250 - (zombieImage:getWidth()*0.5/2), 530 - (zombieImage:getHeight()*0.5), 0, 0.5, 0.5)
        end
        love.graphics.setColor(1, 1, 1)
        if corridorStep == 1 then love.graphics.printf("Du betrittst den Flur...", 0, 500, screenWidth, "center")
        elseif corridorStep == 2 then love.graphics.printf("Du schaust nach links...", 0, 500, screenWidth, "center")
        elseif corridorStep == 3 then love.graphics.setColor(1, 0, 0) love.graphics.printf("ZOMBIES!! LAUF!", 0, 500, screenWidth, "center")
        elseif corridorStep == 4 then love.graphics.printf("Du rennst um dein Leben!!", 0, 500, screenWidth, "center") end

        -- -----------------------------------------------------------------
        -- ZEICHNEN: JUMP 'N' RUN
        -- -----------------------------------------------------------------
    elseif state == "jumpnrun" then
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.printf("DIE HORDE JAGT DICH! Nicht in den Abgrund fallen!", 0, 30, screenWidth, "center")

        -- KAMERA STARTEN
        love.graphics.push()
        love.graphics.translate(-cameraX, 0)

        -- Visuelle Darstellung des Abgrunds (Zombies lauern unten)
        love.graphics.setColor(0.4, 0, 0, 0.6)
        love.graphics.rectangle("fill", cameraX, screenHeight - 60, screenWidth, 60)
        love.graphics.setColor(1, 0, 0)
        for i = 0, screenWidth, 80 do
            love.graphics.print("ZOMBIES", cameraX + i, screenHeight - 45)
        end

        -- 1. Feste Plattformen zeichnen
        for _, plat in ipairs(jnrPlatforms) do
            love.graphics.setColor(0.3, 0.3, 0.4)
            love.graphics.rectangle("fill", plat.x, plat.y, plat.width, plat.height)
        end

        -- 2. Alle beweglichen Plattformen zeichnen
        for _, mp in ipairs(movingPlatforms) do
            love.graphics.setColor(0.5, 0.5, 0.7)
            love.graphics.rectangle("fill", mp.x, mp.y, mp.width, mp.height)
        end

        -- 3. Hindernisse zeichnen
        for _, haz in ipairs(jnrHazards) do
            love.graphics.setColor(1, 0, 0)
            love.graphics.rectangle("fill", haz.x, haz.y, haz.width, haz.height)
        end

        -- 4. GRÜNE ZIEL-TÜR
        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill", jnrGoal.x, jnrGoal.y, jnrGoal.width, jnrGoal.height)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", jnrGoal.x + jnrGoal.width - 12, jnrGoal.y + jnrGoal.height / 2, 6, 6)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("LAGER", jnrGoal.x - 5, jnrGoal.y - 30)

        -- 5. Blauen Spieler zeichnen
        love.graphics.setColor(0.2, 0.5, 1)
        love.graphics.rectangle("fill", jnrPlayer.x, jnrPlayer.y, jnrPlayer.size, jnrPlayer.size)

        -- Zeichnen der verfolgenden Zombie-Hintergrundwand
        if zombieWallX > cameraX - 200 then
            love.graphics.setColor(1, 0, 0, 0.4)
            love.graphics.rectangle("fill", cameraX, 0, zombieWallX - cameraX, screenHeight)
            love.graphics.setColor(1, 0, 0)
            love.graphics.setLineWidth(5)
            love.graphics.line(zombieWallX, 0, zombieWallX, screenHeight)
            love.graphics.setLineWidth(1)
            love.graphics.print("ZOMBIES!", zombieWallX - 110, 200)
        end

        -- KAMERA BEENDEN
        love.graphics.pop()

        -- [DRAW: LAGERRAUM]
    elseif state == "lagerraum" then
        love.graphics.setColor(0, 1, 0)
        love.graphics.printf("GESCHAFFT!", 0, 150, screenWidth, "center")
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Du bist vorerst im Lagerraum in Sicherheit.", 0, 250, screenWidth, "center")
        love.graphics.printf("Die Zombies hämmern gegen die Tür...", 0, 310, screenWidth, "center")
        love.graphics.setColor(0.5, 0.5, 0.5)
        love.graphics.printf("Drücke 'R' für einen Neustart", 0, 450, screenWidth, "center")

        -- [DRAW: JUMPSCARE & GAMEOVER]
    elseif state == "jumpscare" then
        if image then love.graphics.draw(image, (screenWidth - image:getWidth()) / 2, 80) end
        if math.floor(timer * 22) % 2 == 0 then love.graphics.setColor(0.5, 0, 0, 0.4) love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight) end
        if zombieImage then local scale = 0.8 love.graphics.setColor(1, 1, 1) love.graphics.draw(zombieImage, (screenWidth - zombieImage:getWidth()*scale)/2, (screenHeight - zombieImage:getHeight()*scale)/2, 0, scale, scale) end
        love.graphics.printf("EIN ZOMBIE!!!", 0, (screenHeight - titleFont:getHeight()) / 2, screenWidth, "center")

    elseif state == "gameover" then
        love.graphics.printf("GAME OVER", 0, 180, screenWidth, "center")
        love.graphics.setFont(labFont) love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Die Zombies haben dich erwischt...", 0, 320, screenWidth, "center")
        love.graphics.printf("Drücke 'R' zum Neustarten", 0, 420, screenWidth, "center")
    end
end

-- =================================================================
-- 6. LOVE2D HAUPTFUNKTION: MOUSEPRESSED
-- =================================================================
function love.mousepressed(x, y, button)
    if state == "scene" and button == 1 then
        if showOptions then
            if x > option1.x and x < option1.x + option1.width and y > option1.y and y < option1.y + option1.height then
                state = "corridor" corridorTimer = 0 corridorStep = 1
            end
            if x > option2.x and x < option2.x + option2.width and y > option2.y and y < option2.y + option2.height then
                state = "jumpscare" timer = 0 end
        else
            if x > weiterButton.x and x < weiterButton.x + weiterButton.width and y > weiterButton.y and y < weiterButton.y + weiterButton.height then
                if aktuellerText < #texte then aktuellerText = aktuellerText + 1 typewriterProgress = 0
                else showOptions = true end
            end
        end
    end
end

-- =================================================================
-- 7. LOVE2D HAUPTFUNKTION: KEYPRESSED
-- =================================================================
function love.keypressed(key)
    if key == "escape" then love.event.quit() end

    if state == "jumpnrun" and key == "up" and jnrPlayer.onGround then
        jnrPlayer.vy = jnrJumpForce
    end

    if (state == "gameover" or state == "lagerraum") and key == "r" then
        state = "title" timer = 0 corridorTimer = 0 corridorStep = 1 aktuellerText = 1 typewriterProgress = 0 showOptions = false
    end
end