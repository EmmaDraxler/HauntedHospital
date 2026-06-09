local utf8 = require("utf8")
local timer = 0
local state = "title"
local corridorTimer = 0
local corridorScene = false
local corridorStep = 1
local screenWidth = 0
local image
local zombieImage -- Einheitlicher Name für das Zombie-Bild
local bloodDrops = {}

-- Variablen für die Mausposition
local mouseX = 0
local mouseY = 0

-- Schriftart-Variablen
local labFont
local corridorFont
local titleFont

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

-- Weiter Button
local weiterButton = { x = 250, y = 550, width = 300, height = 50 }

-- Optionen
local option1 = { x = 0, y = 550, width = 220, height = 60, text = "Zur Tür gehen" }
local option2 = { x = 0, y = 550, width = 220, height = 60, text = "Im Labor umsehen" }

function love.load()
    if love.filesystem.getInfo("CreepyLab.png") then
        image = love.graphics.newImage("CreepyLab.png")
    end

    if love.filesystem.getInfo("zombieKopf.png") then
        zombieImage = love.graphics.newImage("zombieKopf.png")
    end

    if love.filesystem.getInfo("cour.ttf") then
        labFont = love.graphics.newFont("cour.ttf", 26)
    else
        labFont = love.graphics.newFont(26)
    end

    if love.filesystem.getInfo("chiller.ttf") then
        corridorFont = love.graphics.newFont("chiller.ttf", 44)
        titleFont = love.graphics.newFont("chiller.ttf", 80)
    else
        corridorFont = love.graphics.newFont(44)
        titleFont = love.graphics.newFont(80)
    end
end

function love.update(dt)
    local screenWidth = love.graphics.getWidth()

    -- Dynamische Button-Größenberechnung
    local aktuellerFont = labFont
    if state == "title" or state == "jumpscare" or state == "gameover" then
        aktuellerFont = titleFont
    elseif state == "corridor" and corridorStep >= 3 then
        aktuellerFont = corridorFont
    end

    -- Weiter-Button zentrieren
    local weiterText = "Weiter"
    local wBreite = aktuellerFont:getWidth(weiterText)
    weiterButton.width = math.max(300, wBreite + 60)
    weiterButton.x = (screenWidth - weiterButton.width) / 2

    -- Option-Buttons an den Text anpassen
    local t1Breite = aktuellerFont:getWidth(option1.text)
    local t2Breite = aktuellerFont:getWidth(option2.text)
    local padding = 40

    option1.width = math.max(220, t1Breite + padding)
    option2.width = math.max(220, t2Breite + padding)

    local abstand = 40
    local gesamtBreiteOptionen = option1.width + option2.width + abstand
    option1.x = (screenWidth - gesamtBreiteOptionen) / 2
    option2.x = option1.x + option1.width + abstand

    mouseX, mouseY = love.mouse.getPosition()

    if state == "title" then
        timer = timer + dt
        if timer >= 2 then
            state = "scene"
            typewriterProgress = 0 -- FEHLERBEHEBUNG: Startet den Effekt exakt beim Szenenwechsel
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
        if corridorTimer > 11 and corridorStep == 4 then
            state = "gameover" -- Beendet die Florszene nach Ablauf der Zeit
        end
    end

    if state == "jumpscare" then
        timer = timer + dt

        for i = #bloodDrops, 1, -1 do
            local drop = bloodDrops[i]
            drop.y = drop.y + drop.speed * dt
            drop.alpha = drop.alpha - 0.5 * dt

            if drop.alpha <= 0 or drop.y > love.graphics.getHeight() then
                table.remove(bloodDrops, i)
            end
        end

        if math.random() < 0.4 then
            local startX = love.graphics.getWidth() / 2 + math.random(-30, 30)
            local startY = love.graphics.getHeight() / 2 + 70

            table.insert(bloodDrops, {
                x = startX,
                y = startY,
                radius = math.random(3, 6),
                speed = math.random(150, 300),
                alpha = 1.0
            })
        end

        if timer >= 1.5 then
            state = "gameover"
        end
    end
end

function love.draw()
    love.graphics.clear(0, 0, 0)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Saubere Schriftzuweisung je nach Zustand
    if state == "title" or state == "jumpscare" or state == "gameover" then
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
        love.graphics.setColor(1, 0, 0)
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
            -- OPTION 1
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

            -- OPTION 2
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
            -- WEITER-BUTTON
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

        local flurBreite = 500
        local flurX = (screenWidth - flurBreite) / 2
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", flurX, 0, flurBreite, 600)

        love.graphics.setFont(corridorFont)
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("HELP", flurX + 70, 150)
        love.graphics.print("RUN", flurX + 350, 250)
        love.graphics.circle("fill", flurX + 100, 350, 20)
        love.graphics.circle("fill", flurX + 400, 400, 20)

        if corridorStep >= 3 then
            love.graphics.setFont(corridorFont)
        else
            love.graphics.setFont(labFont)
        end

        --  Die Zombies bleiben ab Schritt 3 UND Schritt 4 sichtbar!
        -- ZOMBIES ZEICHNEN (Weiter nach unten verschoben)
        if corridorStep >= 3 then
            if zombieImage then
                love.graphics.setColor(1, 1, 1)

                local imgWidth = zombieImage:getWidth()
                local imgHeight = zombieImage:getHeight()

                -- Die Mitte der drei Flur-Spuren berechnen
                local spurLinks = flurX + (500 / 6)
                local spurMitte = flurX + (500 / 2)
                local spurRechts = flurX + (500 * 5 / 6)

                -- KORREKTUR: Höherer Wert schiebt die Zombies weiter nach unten
                local bodenY = 530

                -- Zombie 1 (Links, im Hintergrund)
                local scale1 = 0.3
                local x1 = spurLinks - (imgWidth * scale1 / 2)
                local y1 = (bodenY - 30) - (imgHeight * scale1)
                love.graphics.draw(zombieImage, x1, y1, 0, scale1, scale1)

                -- Zombie 3 (Rechts, weiter hinten)
                local scale3 = 0.25
                local x3 = spurRechts - (imgWidth * scale3 / 2)
                local y3 = (bodenY - 50) - (imgHeight * scale3)
                love.graphics.draw(zombieImage, x3, y3, 0, scale3, scale3)

                -- Zombie 2 (Mitte, ganz vorne)
                local scale2 = 0.5
                local x2 = spurMitte - (imgWidth * scale2 / 2)
                local y2 = bodenY - (imgHeight * scale2)
                love.graphics.draw(zombieImage, x2, y2, 0, scale2, scale2)
            else
                -- Fallback-Rechtecke
                love.graphics.setColor(0, 1, 0)
                love.graphics.rectangle("fill", flurX + 30, 300, 80, 200)
                love.graphics.rectangle("fill", flurX + 150, 280, 80, 220)
                love.graphics.rectangle("fill", flurX + 270, 310, 80, 190)
            end
        end
        end

        -- Texte für die jeweiligen Schritte im Flur
        if corridorStep == 1 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("Du betrittst den Flur...", 0, 500, screenWidth, "center")
        elseif corridorStep == 2 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("Du schaust nach links...", 0, 500, screenWidth, "center")
        elseif corridorStep == 3 then
            love.graphics.setColor(1, 0, 0)
            love.graphics.printf("ZOMBIES!! LAUF!", 0, 500, screenWidth, "center")
        elseif corridorStep == 4 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("Du schaust nach rechts und suchst einen Ausweg...", 0, 500, screenWidth, "center")
        end

    elseif state == "jumpscare" then
        if image then
            local imageX = (screenWidth - image:getWidth()) / 2
            love.graphics.draw(image, imageX, 80)
        end

        if math.floor(timer * 22) % 2 == 0 then
            love.graphics.setColor(0.5, 0, 0, 0.4)
            love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight)
        end

        if zombieImage then
            local scale = 1.6
            local zW = zombieImage:getWidth() * scale
            local zH = zombieImage:getHeight() * scale
            local zX = (screenWidth - zW) / 2
            local zY = (screenHeight - zH) / 2

            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(zombieImage, zX, zY, 0, scale, scale)
        end

        for _, drop in ipairs(bloodDrops) do
            love.graphics.setColor(0.7, 0, 0, drop.alpha)
            love.graphics.circle("fill", drop.x, drop.y, drop.radius)
        end

        love.graphics.setFont(titleFont)
        love.graphics.setColor(1, 1, 1)
        local textY = (screenHeight - titleFont:getHeight()) / 2
        love.graphics.printf("EIN ZOMBIE!!!", 0, textY, screenWidth, "center")

    elseif state == "gameover" then
        love.graphics.clear(0, 0, 0)
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("GAME OVER", 0, 180, screenWidth, "center")

        love.graphics.setFont(labFont)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Der Horror hat dich eingeholt...", 0, 320, screenWidth, "center")
        love.graphics.printf("Drücke 'R' zum Neustarten", 0, 420, screenWidth, "center")
    end


function love.mousepressed(x, y, button)
    if state == "scene" and button == 1 then
        if showOptions then
            if x > option1.x and x < option1.x + option1.width and
                    y > option1.y and y < option1.y + option1.height then
                state = "corridor"
                corridorTimer = 0
                corridorStep = 1
            end

            if x > option2.x and x < option2.x + option2.width and
                    y > option2.y and y < option2.y + option2.height then
                state = "jumpscare"
                timer = 0
                bloodDrops = {}
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

function love.keypressed(key)
    if state == "gameover" and key == "r" then
        state = "title"
        timer = 0
        corridorTimer = 0   -- Setzt die Flur-Variablen beim Reset zurück
        corridorStep = 1
        aktuellerText = 1
        typewriterProgress = 0
        showOptions = false
        bloodDrops = {}
    end
end