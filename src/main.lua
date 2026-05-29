local utf8 = require("utf8")
local timer = 0
local state = "title"
local corridorTimer = 0
local corridorScene = false
local corridorStep = 1
local screenWidth = 0
local image

local horrorFont
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
    x = 150,
    y = 550,
    width = 220,
    height = 60,
    text = "Zur Tür gehen"
}

local option2 = {
    x = 430,
    y = 550,
    width = 220,
    height = 60,
    text = "Im Labor umsehen"
}

function love.load()
    -- Hinweis: Stellt sicher, dass "CreepyLab.png" im selben Ordner liegt!
    image = love.graphics.newImage("CreepyLab.png")
end

function love.update(dt)

    local screenWidth = love.graphics.getWidth()
    weiterButton.x = (screenWidth - weiterButton.width) / 2
    local abstand = 40
    local gesamtBreiteOptionen = option1.width + option2.width + abstand
    option1.x = (screenWidth - gesamtBreiteOptionen) / 2
    option2.x = option1.x + option1.width + abstand

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

                -- ÄNDERUNG 1: Wir runden die Zeichenanzahl ab

                local zeichenAnzahl = math.floor(typewriterProgress)
                local bytePos = utf8.offset(vollerText, zeichenAnzahl + 1) or (#vollerText + 1)
                typewriterText = string.sub(vollerText, 1, bytePos - 1)

                -- ÄNDERUNG 2: utf8.offset findet die exakte Speicherstelle für die Zeichenanzahl
                local bytePosition = utf8.offset(vollerText, zeichenAnzahl + 1)

                -- ÄNDERUNG 3: Wenn die Position gültig ist, schneiden wir dort sicher ab
                if bytePosition then
                    typewriterText = string.sub(vollerText, 1, bytePosition - 1)
                end
            else
                typewriterText = vollerText
                end
            end
            end


    if state == "corridor" then
        corridorTimer = corridorTimer + dt

        -- Nach links schauen
        if corridorTimer > 2 and corridorStep == 1 then
            corridorStep = 2
        end

        -- Zombies sehen
        if corridorTimer > 5 and corridorStep == 2 then
            corridorStep = 3
        end

        -- Nach rechts schauen
        if corridorTimer > 8 and corridorStep == 3 then
            corridorStep = 4
        end

        -- Weglaufen
        if corridorTimer > 11 and corridorStep == 4 then
            corridorStep = 5
        end
    end

function love.draw()
    -- Standard-Hintergrund (Schwarz)
    love.graphics.clear(0, 0, 0)
    local screenWidth = love.graphics.getWidth()

    if horrorFont then
        love.graphics.setFont(horrorFont)
    end

    if state == "title" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(
                "THE HAUNTED HOSPITAL",
                0,
                300,
                love.graphics.getWidth(),
                "center"
        )

    elseif state == "scene" then
        -- Bild zeichnen
        if image then
            love.graphics.draw(image, 200, 100)
        end

        -- Text anzeigen
        love.graphics.setColor(1, 1, 1)
        --love.graphics.printf(
                --texte[aktuellerText],
                --100,
               -- 450,
               -- 600,
               -- "center"
       -- )
        -- 3. BILD MITTIG ZEICHNEN
        --if image then
           -- local imageX = (screenWidth - image:getWidth()) / 2
           -- love.graphics.draw(image, imageX, 80)
       -- end

        -- 4. STORY-TEXT MITTIG ANZEIGEN
        local textBreite = 600
        local textX = (screenWidth - textBreite) / 2
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(
                typewriterText,
                textX,
                420,
                textBreite,
                "center"
        )


        -- OPTIONEN ANZEIGEN
        if showOptions then
            -- Option 1
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle("fill", option1.x, option1.y, option1.width, option1.height)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(option1.text, option1.x, option1.y + 20, option1.width, "center")

            -- Option 2
            love.graphics.setColor(0.3, 0.3, 0.3)
            love.graphics.rectangle("fill", option2.x, option2.y, option2.width, option2.height)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf(option2.text, option2.x, option2.y + 20, option2.width, "center")
        else
            -- Weiter Button
            love.graphics.setColor(0.2, 0.2, 0.2)
            love.graphics.rectangle("fill", weiterButton.x, weiterButton.y, weiterButton.width, weiterButton.height)
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("Weiter", weiterButton.x, weiterButton.y + 15, weiterButton.width, "center")
        end

    elseif state == "corridor" then
        -- Dunklerer Flur-Hintergrund überschreibt das Standard-Schwarz
        love.graphics.clear(0.05, 0.05, 0.05)

        -- Flur-Grafik
        love.graphics.setColor(0.2, 0.2, 0.2)
        love.graphics.rectangle("fill", 150, 0, 500, 600)

        -- Bluttexte
        love.graphics.setColor(1, 0, 0)
        love.graphics.print("HELP", 220, 150)
        love.graphics.print("RUN", 500, 250)

        -- Handabdrücke
        love.graphics.circle("fill", 250, 350, 20)
        love.graphics.circle("fill", 550, 400, 20)

        -- DIE EINZELNEN SCHRITTE IM FLUR
        if corridorStep == 1 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("Du betrittst den Flur...", 0, 500, 800, "center")

        elseif corridorStep == 2 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("Du schaust nach links...", 0, 500, 800, "center")

        elseif corridorStep == 3 then
            -- Zombies zeichnen
            love.graphics.setColor(0, 1, 0)
            love.graphics.rectangle("fill", 180, 200, 80, 200)
            love.graphics.rectangle("fill", 300, 180, 80, 220)
            love.graphics.rectangle("fill", 420, 210, 80, 190)

            -- Warntext fixiert
            love.graphics.setColor(1, 0, 0)
            love.graphics.printf("ZOMBIES!! LAUF!", 0, 500, 800, "center")

        elseif corridorStep == 4 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.printf("Du schaust nach rechts und suchst einen Ausweg...", 0, 500, 800, "center")

        elseif corridorStep == 5 then
            -- Bewegungs-Effekt (Zufallslinien)
            love.graphics.setColor(1, 1, 1)
            for i = 1, 20 do
                love.graphics.line(
                        math.random(0, 800),
                        math.random(0, 600),
                        math.random(0, 800),
                        math.random(0, 600)
                )
            end
        end
    end
end

function love.mousepressed(x, y, button)
    if state == "scene" and button == 1 then
        -- WENN Optionen sichtbar
        if showOptions then
            -- Option 1: Zur Tür gehen
            if x > option1.x and x < option1.x + option1.width and
                    y > option1.y and y < option1.y + option1.height then
                print("Spieler geht zur Tür")
                state = "corridor" -- Wechselt jetzt in den Flur!
            end

            -- Option 2: Im Labor umsehen
            if x > option2.x and x < option2.x + option2.width and
                    y > option2.y and y < option2.y + option2.height then
                print("Spieler bleibt im Labor")
            end
        else
            -- Weiter Button geklickt?
            if x > weiterButton.x and x < weiterButton.x + weiterButton.width and
                    y > weiterButton.y and y < weiterButton.y + weiterButton.height then

                -- Noch Texte übrig?
                if aktuellerText < #texte then
                    aktuellerText = aktuellerText + 1
                else
                    -- Nach letztem Klick Optionen zeigen
                    showOptions = true
                end
            end
        end
    end
end
