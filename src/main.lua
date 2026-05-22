local timer = 0
local state = "title"
local corridorTimer = 0
local corridorScene = false
local corridorStep = 1

local image

local texte = {
    "Du wachst auf.",
    "Wo bist du?",
    "Du bist in einem Labor vom HAUNTED HOSPITAL.",
    "Du hast keinen Plan, wie du hierhin gekommen bist, aber was du weißt: RAUS AUS DIESEM VERFLUCHTEN ORT!",
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
    image = love.graphics.newImage("CreepyLab.png")
end

function love.update(dt)

    if state == "title" then
        timer = timer + dt

        if timer >= 2 then
            state = "scene"
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
end

function love.draw()
    love.graphics.clear(0, 0, 0)

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

        -- Bild
        love.graphics.draw(image, 200, 100)

        -- Text
        love.graphics.setColor(1, 1, 1)

        love.graphics.printf(
                texte[aktuellerText],
                100,
                450,
                600,
                "center"
        )

        -- OPTIONEN
        if showOptions then

            -- Option 1
            love.graphics.setColor(0.3, 0.3, 0.3)

            love.graphics.rectangle(
                    "fill",
                    option1.x,
                    option1.y,
                    option1.width,
                    option1.height
            )

            love.graphics.setColor(1,1,1)

            love.graphics.printf(
                    option1.text,
                    option1.x,
                    option1.y + 20,
                    option1.width,
                    "center"
            )

            -- Option 2
            love.graphics.setColor(0.3, 0.3, 0.3)

            love.graphics.rectangle(
                    "fill",
                    option2.x,
                    option2.y,
                    option2.width,
                    option2.height
            )

            love.graphics.setColor(1,1,1)

            love.graphics.printf(
                    option2.text,
                    option2.x,
                    option2.y + 20,
                    option2.width,
                    "center"
            )

        else

            -- Weiter Button
            love.graphics.setColor(0.2, 0.2, 0.2)

            love.graphics.rectangle(
                    "fill",
                    weiterButton.x,
                    weiterButton.y,
                    weiterButton.width,
                    weiterButton.height
            )

            love.graphics.setColor(1, 1, 1)

            love.graphics.printf(
                    "Weiter",
                    weiterButton.x,
                    weiterButton.y + 15,
                    weiterButton.width,
                    "center"
            )
        end
    end

    elseif state == "corridor" then

    -- Dunkler Hintergrund
    love.graphics.clear(0.05, 0.05, 0.05)

    -- Flur
    love.graphics.setColor(0.2, 0.2, 0.2)
    love.graphics.rectangle("fill", 150, 0, 500, 600)

    -- Bluttexte
    love.graphics.setColor(1, 0, 0)

    love.graphics.print("HELP", 220, 150)
    love.graphics.print("RUN", 500, 250)

    -- Handabdrücke
    love.graphics.circle("fill", 250, 350, 20)
    love.graphics.circle("fill", 550, 400, 20)

    -- SCHRITT 1
    if corridorStep == 1 then

    love.graphics.setColor(1,1,1)

    love.graphics.printf(
    "Du betrittst den Flur...",
    0,
    500,
    800,
    "center"
    )

    -- SCHRITT 2
    elseif corridorStep == 2 then

    love.graphics.setColor(1,1,1)

    love.graphics.printf(
    "Du schaust nach links...",
    0,
    500,
    800,
    "center"
    )

    -- SCHRITT 3 = Zombies
    elseif corridorStep == 3 then

    love.graphics.setColor(0, 1, 0)

    -- Zombies
    love.graphics.rectangle("fill", 180, 200, 80, 200)
    love.graphics.rectangle("fill", 300, 180, 80, 220)
    love.graphics.rectangle("fill", 420, 210, 80, 190)

    love.graphics.setColor(1,0,0)

    love.graphics.printf(
    "ZOMBIES!!",
    "LAUF!"

    end
    end
end
0,
500,
800,
"center"
)

-- SCHRITT 4
elseif corridorStep == 4 then

-- SCHRITT 5
elseif corridorStep == 5 then

-- Bewegungs-Effekt
for i = 1, 20 do
love.graphics.line(
math.random(0,800),
math.random(0,600),
math.random(0,800),
math.random(0,600)
)
end
end
end

function love.mousepressed(x, y, button)

if state == "scene" and button == 1 then

-- WENN Optionen sichtbar
if showOptions then

-- Option 1
if x > option1.x and
x < option1.x + option1.width and
y > option1.y and
y < option1.y + option1.height then

print("Spieler geht zur Tür")
end

-- Option 2
if x > option2.x and
x < option2.x + option2.width and
y > option2.y and
y < option2.y + option2.height then

print("Spieler bleibt im Labor")
end

else

-- Weiter Button geklickt?
if x > weiterButton.x and
x < weiterButton.x + weiterButton.width and
y > weiterButton.y and
y < weiterButton.y + weiterButton.height then

-- Noch Texte übrig
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

end
