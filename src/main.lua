local utf8 = require("utf8")
local timer = 0
local state = "title"
local corridorTimer = 0
local corridorScene = false
local corridorStep = 1
local screenWidth = 0
local image

-- Variablen für die Mausposition (wichtig für die Hover-Effekte!)
local mouseX = 0
local mouseY = 0

-- Schriftart-Variablen für das dynamische Umschalten
local labFont
local corridorFont
local titleFont

local typewriterText = ""
local typewriterProgress = 0
local typewriterSpeed = 30 -- Wie viele Buchstaben pro Sekunde eingetippt werden

local texte = {
    "Du wachst auf.",
    "Wo bist du?",
    "Du bist in einem Labor vom HAUNTED HOSPITAL.",
    "Du weißt nicht, wie du hierher gekommen bist, aber: RAUS AUS DIESEM VERFLUCHTEN ORT!",
    "Was willst du tun?"
}

local aktuellerText = 1

-- Zeigt Optionen erst später
local showOptions = false

-- Weiter Button
local weiterButton = {
    x = 250,
    y = 550,
    width = 300,
    height = 50
}

-- Optionen
local option1 = {
    x = 0,
    y = 550,
    width = 220,
    height = 60,
    text = "Zur Tür gehen"
}

local option2 = {
    x = 0,
    y = 550,
    width = 220,
    height = 60,
    text = "Im Labor umsehen"
}

function love.load()
    -- SICHERHEITS-CHECK: Nur laden, wenn die Dateien wirklich existieren
    if love.filesystem.getInfo("CreepyLab.png") then
        image = love.graphics.newImage("CreepyLab.png")
    end

    if love.filesystem.getInfo("cour.ttf") then
        labFont = love.graphics.newFont("cour.ttf", 26)
    else
        labFont = love.graphics.newFont(26) -- Fallback
    end

    if love.filesystem.getInfo("chiller.ttf") then
        corridorFont = love.graphics.newFont("chiller.ttf", 44)
        titleFont = love.graphics.newFont("chiller.ttf", 80)
    else
        corridorFont = love.graphics.newFont(44) -- Fallback
        titleFont = love.graphics.newFont(80)    -- Fallback
    end
end

function love.update(dt)
    local screenWidth = love.graphics.getWidth()

    -- -----------------------------------------------------------------
    -- ÄNDERUNG 1: Dynamische Button-Größenberechnung in das Update verschoben
    -- -----------------------------------------------------------------
    -- Wir holen uns die gerade aktive Schriftart für die Größenberechnung
    local aktuellerFont = labFont
    if state == "title" then
        aktuellerFont = titleFont
    elseif state == "corridor" and corridorStep >= 3 then
        aktuellerFont = corridorFont
    end

    -- Weiter-Button zentrieren
    local weiterText = "Weiter"
    local wBreite = aktuellerFont:getWidth(weiterText)
    weiterButton.width = math.max(300, wBreite + 60)
    weiterButton.x = (screenWidth - weiterButton.width) / 2

    -- Option-Buttons an den Text anpassen und nebeneinander zentrieren
    local t1Breite = aktuellerFont:getWidth(option1.text)
    local t2Breite = aktuellerFont:getWidth(option2.text)
    local padding = 40

    option1.width = math.max(220, t1Breite + padding)
    option2.width = math.max(220, t2Breite + padding)

    local abstand = 40
    local gesamtBreiteOptionen = option1.width + option2.width + abstand
    option1.x = (screenWidth - gesamtBreiteOptionen) / 2
    option2.x = option1.x + option1.width + abstand
    -- -----------------------------------------------------------------

    -- Mausposition für Hover-Effekte
    mouseX, mouseY = love.mouse.getPosition()

    if state == "title" then
        timer = timer + dt
        if timer >= 2 then
            state = "scene"
        end
    end

    if state == "scene" then
        local vollerText = texte[aktuellerText]
        local textLaenge = utf8.len(vollerText)

        if typewriterProgress < textLaenge then
            typewriterProgress = typewriterProgress + (typewriterSpeed * dt)
            local zeichenAnzahl = math.floor(typewriterProgress)

            local bytePosition = utf8.offset(vollerText, zeichenAnzahl + 1)
            if bytePosition then
                typewriterText = string.sub(vollerText, 1, bytePosition - 1)
            end
        else
            typewriterText = vollerText
        end
    end

    if state == "corridor" then
        corridorTimer = corridorTimer + dt

        if corridorTimer > 2 and corridorStep == 1 then corridorStep = 2 end
        if corridorTimer > 5 and corridorStep == 2 then corridorStep = 3 end
        if corridorTimer > 8 and corridorStep == 3 then corridorStep = 4 end
        if corridorTimer > 11 and corridorStep == 4 then corridorStep = 5 end
    end
end

function love.draw()
    love.graphics.clear(0, 0, 0)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Schriftart-Zuweisung für alle Spielzustände
    if state == "title" then
        love.graphics.setFont(titleFont)
    elseif state == "scene" then
        love.graphics.setFont(labFont)
    elseif state == "corridor" then
        if corridorStep >= 3 then
            love.graphics.setFont(corridorFont)
        else
            love.graphics.setFont(labFont)
        end
    end

    if state == "title" then
        love.graphics.setColor(1, 0, 0) -- Reines Rot
        local titelY = (screenHeight - titleFont:getHeight()) / 2
        love.graphics.printf("THE HAUNTED HOSPITAL", 0, titelY, screenWidth, "center")

    elseif state == "scene" then
        if image then
            local imageX = (screenWidth - image:getWidth()) / 2
            love.graphics.draw(image, imageX, 80)
        end

        local textBreite = 600
        local textX = (screenWidth - textBreite) / 2
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(typewriterText, textX, 420, textBreite, "center")

        local aktuellerFont = love.graphics.getFont()
        love.graphics.setLineWidth(2)

        if showOptions then
            -- OPTION 1 ZEICHNEN ("Zur Tür gehen")
            if mouseX > option1.x and mouseX < option1.x + option1.width and
                    mouseY > option1.y and mouseY < option1.y + option1.height then
                love.graphics.setColor(0.1, 0.4, 0.1, 0.3)
                love.graphics.rectangle("fill", option1.x, option1.y, option1.width, option1.height)
                love.graphics.setColor(0.2, 0.9, 0.2)
            else
                love.graphics.setColor(0.5, 0.1, 0.1)
            end
            love.graphics.rectangle("line", option1.x, option1.y, option1.width, option1.height)
            love.graphics.setColor(1, 1, 1)
            local textY1 = option1.y + (option1.height - aktuellerFont:getHeight()) / 2
            love.graphics.printf(option1.text, option1.x, textY1, option1.width, "center")

            -- OPTION 2 ZEICHNEN ("Im Labor umsehen")
            if mouseX > option2.x and mouseX < option2.x + option2.width and
                    mouseY > option2.y and mouseY < option2.y + option2.height then
                love.graphics.setColor(0.2, 0.2, 0.2, 0.4)
                love.graphics.rectangle("fill", option2.x, option2.y, option2.width, option2.height)
                love.graphics.setColor(1, 1, 1)
            else
                love.graphics.setColor(0.4, 0.4, 0.4)
            end
            love.graphics.rectangle("line", option2.x, option2.y, option2.width, option2.height)
            love.graphics.setColor(1, 1, 1)
            local textY2 = option2.y + (option2.height - aktuellerFont:getHeight()) / 2
            love.graphics.printf(option2.text, option2.x, textY2, option2.width, "center")
        else
            -- WEITER-BUTTON ZEICHNEN
            if mouseX > weiterButton.x and mouseX < weiterButton.x + weiterButton.width and
                    mouseY > weiterButton.y and mouseY < weiterButton.y + weiterButton.height then
                love.graphics.setColor(0.3, 0.3, 0.3, 0.3)
                love.graphics.rectangle("fill", weiterButton.x, weiterButton.y, weiterButton.width, weiterButton.height)
                love.graphics.setColor(0.8, 0.8, 0.8)
            else
                love.graphics.setColor(0.3, 0.3, 0.3)
            end
            love.graphics.rectangle("line", weiterButton.x, weiterButton.y, weiterButton.width, weiterButton.height)
            love.graphics.setColor(1, 1, 1)
            local textYW = weiterButton.y + (weiterButton.height - aktuellerFont:getHeight()) / 2
            love.graphics.printf("Weiter", weiterButton.x, textYW, weiterButton.width, "center")
        end
        love.graphics.setLineWidth(1)

    elseif state == "corridor" then
        love.graphics.clear(0.05, 0.05, 0.05)

        -- Flur-Wände mittig
        local flurBreite = 500
        local flurX = (screenWidth - flurBreite) / 2
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", flurX, 0, flurBreite, 600)

        -- Wand-Warnungen (Chiller-Schrift)
        love.graphics.setFont(corridorFont)
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("HELP", flurX + 70, 150)
        love.graphics.print("RUN", flurX + 350, 250)
        love.graphics.circle("fill", flurX + 100, 350, 20)
        love.graphics.circle("fill", flurX + 400, 400, 20)

        -- Zurücksetzen der Schrift für den Story-Text (nach Schritt-Regel)
        if corridorStep >= 3 then
            love.graphics.setFont(corridorFont)
        else
            love.graphics.setFont(labFont)
        end

        -- Story-Schritte
        if corridorStep == 1 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("Du betrittst den Flur...", 0, 500, screenWidth, "center")
        elseif corridorStep == 2 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("Du schaust nach links...", 0, 500, screenWidth, "center")
        elseif corridorStep == 3 then
            -- Zombies
            love.graphics.setColor(0, 1, 0)
            love.graphics.rectangle("fill", flurX + 30, 200, 80, 200)
            love.graphics.rectangle("fill", flurX + 150, 180, 80, 220)
            love.graphics.rectangle("fill", flurX + 270, 210, 80, 190)
            love.graphics.setColor(1, 0, 0)
            love.graphics.printf("ZOMBIES!! LAUF!", 0, 500, screenWidth, "center")
        elseif corridorStep == 4 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("Du schaust nach rechts und suchst einen Ausweg...", 0, 500, screenWidth, "center")
        elseif corridorStep == 5 then
            love.graphics.setColor(1, 1, 1)
            for i = 1, 20 do
                love.graphics.line(math.random(0, screenWidth), math.random(0, 600), math.random(0, screenWidth), math.random(0, 600))
            end
        end
    end
end

function love.mousepressed(x, y, button)
    if state == "scene" and button == 1 then
        if showOptions then
            if x > option1.x and x < option1.x + option1.width and
                    y > option1.y and y < option1.y + option1.height then
                state = "corridor"
            end
            if x > option2.x and x < option2.x + option2.width and
                    y > option2.y and y < option2.y + option2.height then
                print("Spieler bleibt im Labor")
            end
        else
            if x > weiterButton.x and x < weiterButton.x + weiterButton.width and
                    y > weiterButton.y and y < weiterButton.y + weiterButton.height then
                if aktuellerText < #texte then
                    aktuellerText = aktuellerText + 1
                    typewriterProgress = 0
                else
                    showOptions = true
                end
            end
        end
    end
end