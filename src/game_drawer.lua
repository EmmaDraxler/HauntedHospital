local c = require("config")
local gameDrawer = {}

function gameDrawer.draw()
    love.graphics.clear(0, 0, 0)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()

    -- Font-Zuweisung
    if c.state == "title" or c.state == "jumpscare" or c.state == "win" or c.state == "gameover" then love.graphics.setFont(c.fonts.titleFont)
    elseif c.state == "scene" or c.state == "jumpnrun" or c.state == "lagerraum" or c.state == "puzzle" then love.graphics.setFont(c.fonts.labFont)
    elseif c.state == "corridor" then if c.corridorStep >= 3 then love.graphics.setFont(c.fonts.corridorFont) else love.graphics.setFont(c.fonts.labFont) end end

    if c.state == "title" then
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("THE HAUNTED HOSPITAL", 0, (screenHeight - c.fonts.titleFont:getHeight()) / 2, screenWidth, "center")

    elseif c.state == "scene" then
        if c.images.image then love.graphics.draw(c.images.image, (screenWidth - c.images.image:getWidth()) / 2, 80) end
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf(c.typewriterText, (screenWidth - 600) / 2, 420, 600, "center")
        if c.showOptions then
            if c.mouseX > c.option1.x and c.mouseX < c.option1.x + c.option1.width and c.mouseY > c.option1.y and c.mouseY < c.option1.y + c.option1.height then
                love.graphics.setColor(0.1, 0.4, 0.1, 0.3) love.graphics.rectangle("fill", c.option1.x, c.option1.y, c.option1.width, c.option1.height)
                love.graphics.setColor(0.2, 0.9, 0.2)
            else love.graphics.setColor(0.5, 0.1, 0.1) end
            love.graphics.rectangle("line", c.option1.x, c.option1.y, c.option1.width, c.option1.height)
            love.graphics.setColor(1, 1, 1) love.graphics.printf(c.option1.text, c.option1.x, c.option1.y + 15, c.option1.width, "center")

            if c.mouseX > c.option2.x and c.mouseX < c.option2.x + c.option2.width and c.mouseY > c.option2.y and c.mouseY < c.option2.y + c.option2.height then
                love.graphics.setColor(0.2, 0.2, 0.2, 0.4) love.graphics.rectangle("fill", c.option2.x, c.option2.y, c.option2.width, c.option2.height)
                love.graphics.setColor(1, 1, 1)
            else love.graphics.setColor(0.4, 0.4, 0.4) end
            love.graphics.rectangle("line", c.option2.x, c.option2.y, c.option2.width, c.option2.height)
            love.graphics.setColor(1, 1, 1) love.graphics.printf(c.option2.text, c.option2.x, c.option2.y + 15, c.option2.width, "center")
        else
            if c.mouseX > c.weiterButton.x and c.mouseX < c.weiterButton.x + c.weiterButton.width and c.mouseY > c.weiterButton.y and c.mouseY < c.weiterButton.y + c.weiterButton.height then
                love.graphics.setColor(0.3, 0.3, 0.3, 0.3) love.graphics.rectangle("fill", c.weiterButton.x, c.weiterButton.y, c.weiterButton.width, c.weiterButton.height)
                love.graphics.setColor(0.8, 0.8, 0.8)
            else love.graphics.setColor(0.3, 0.3, 0.3) end
            love.graphics.rectangle("line", c.weiterButton.x, c.weiterButton.y, c.weiterButton.width, c.weiterButton.height)
            love.graphics.setColor(1, 1, 1) love.graphics.printf("Weiter", c.weiterButton.x, c.weiterButton.y + 10, c.weiterButton.width, "center")
        end

    elseif c.state == "corridor" then
        if c.images.corridorImage then love.graphics.draw(c.images.corridorImage, (screenWidth - c.images.corridorImage:getWidth()) / 2, (screenHeight - c.images.corridorImage:getHeight()) / 2) end
        local flurX = screenWidth / 2 - 250
        if c.corridorStep >= 3 and c.images.zombieImage then
            love.graphics.setColor(1, 1, 1)
            love.graphics.draw(c.images.zombieImage, flurX + 83 - (c.images.zombieImage:getWidth()*0.3/2), 500 - (c.images.zombieImage:getHeight()*0.3), 0, 0.3, 0.3)
            love.graphics.draw(c.images.zombieImage, flurX + 416 - (c.images.zombieImage:getWidth()*0.25/2), 480 - (c.images.zombieImage:getHeight()*0.25), 0, 0.25, 0.25)
            love.graphics.draw(c.images.zombieImage, flurX + 250 - (c.images.zombieImage:getWidth()*0.5/2), 530 - (c.images.zombieImage:getHeight()*0.5), 0, 0.5, 0.5)
        end
        love.graphics.setColor(1, 1, 1)
        if c.corridorStep == 1 then love.graphics.printf("Du betrittst den Flur...", 0, 500, screenWidth, "center")
        elseif c.corridorStep == 2 then love.graphics.printf("Du schaust nach links...", 0, 500, screenWidth, "center")
        elseif c.corridorStep == 3 then love.graphics.setColor(1, 0, 0) love.graphics.printf("ZOMBIES!! LAUF!", 0, 500, screenWidth, "center")
        elseif c.corridorStep == 4 then love.graphics.printf("Du rennst um dein Leben!!", 0, 500, screenWidth, "center") end

    elseif c.state == "jumpnrun" then
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.printf("DIE HORDE JAGT DICH! Nicht in den Abgrund fallen!", 0, 30, screenWidth, "center")

        love.graphics.push()
        love.graphics.translate(-c.cameraX, 0)

        love.graphics.setColor(0.4, 0, 0, 0.6)
        love.graphics.rectangle("fill", c.cameraX, screenHeight - 60, screenWidth, 60)
        love.graphics.setColor(1, 0, 0)
        for i = 0, screenWidth, 80 do love.graphics.print("ZOMBIES", c.cameraX + i, screenHeight - 45) end

        for _, plat in ipairs(c.jnrPlatforms) do love.graphics.setColor(0.3, 0.3, 0.4) love.graphics.rectangle("fill", plat.x, plat.y, plat.width, plat.height) end
        for _, mp in ipairs(c.movingPlatforms) do love.graphics.setColor(0.5, 0.5, 0.7) love.graphics.rectangle("fill", mp.x, mp.y, mp.width, mp.height) end
        for _, haz in ipairs(c.jnrHazards) do love.graphics.setColor(1, 0, 0) love.graphics.rectangle("fill", haz.x, haz.y, haz.width, haz.height) end

        love.graphics.setColor(0, 1, 0)
        love.graphics.rectangle("fill", c.jnrGoal.x, c.jnrGoal.y, c.jnrGoal.width, c.jnrGoal.height)
        love.graphics.setColor(0, 0, 0)
        love.graphics.rectangle("fill", c.jnrGoal.x + c.jnrGoal.width - 12, c.jnrGoal.y + c.jnrGoal.height / 2, 6, 6)
        love.graphics.setColor(1, 1, 1)
        love.graphics.print("LAGER", c.jnrGoal.x - 5, c.jnrGoal.y - 30)

        love.graphics.setColor(0.2, 0.5, 1)
        love.graphics.rectangle("fill", c.player.x, c.player.y, c.player.size, c.player.size)

        if c.zombieWallX > c.cameraX - 200 then
            love.graphics.setColor(1, 0, 0, 0.4)
            love.graphics.rectangle("fill", c.cameraX, 0, c.zombieWallX - c.cameraX, screenHeight)
            love.graphics.setColor(1, 0, 0) love.graphics.setLineWidth(5)
            love.graphics.line(c.zombieWallX, 0, c.zombieWallX, screenHeight)
            love.graphics.setLineWidth(1) love.graphics.print("ZOMBIES!", c.zombieWallX - 110, 200)
        end
        love.graphics.pop()

    elseif c.state == "lagerraum" then
        love.graphics.setColor(1, 0.2, 0.2)
        love.graphics.printf("LAUF! FINDE DEN AUSGANG!", 0, 30, screenWidth, "center")

        love.graphics.setColor(1, 1, 1)
        for i, row in ipairs(c.storageMap) do
            for j, cell in ipairs(row) do
                if cell == 1 then
                    if c.images.chestImage then love.graphics.draw(c.images.chestImage, (j - 1) * c.tileSize, (i - 1) * c.tileSize)
                    else love.graphics.rectangle("fill", (j - 1) * c.tileSize, (i - 1) * c.tileSize, c.tileSize, c.tileSize) end
                elseif cell == 3 then
                    love.graphics.setColor(0, 1, 0) love.graphics.rectangle("fill", (j - 1) * c.tileSize, (i - 1) * c.tileSize, c.tileSize, c.tileSize)
                    love.graphics.setColor(1, 1, 1)
                end
            end
        end

        love.graphics.setColor(0.2, 0.5, 1)
        love.graphics.rectangle("fill", c.player.x, c.player.y, c.player.size, c.player.size)

        if c.zombieWallX > -c.tileSize then
            love.graphics.setColor(1, 0, 0, 0.4) love.graphics.rectangle("fill", 0, 0, c.zombieWallX, screenHeight)
            love.graphics.setColor(1, 0, 0) love.graphics.setLineWidth(5)
            love.graphics.line(c.zombieWallX, 0, c.zombieWallX, screenHeight)
            love.graphics.setLineWidth(1) love.graphics.print("ZOMBIES!", c.zombieWallX - 110, 200)
        end

    elseif c.state == "puzzle" then
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Finde den Code\nDie Zahlen steigen mit der Panik.", 0, 60, screenWidth, "center")

        local displayCode = c.puzzleInput
        while string.len(displayCode) < 4 do displayCode = displayCode .. "_" end
        love.graphics.setColor(1, 0, 0)
        love.graphics.printf("Code: " .. displayCode, 0, 160, screenWidth, "center")
        love.graphics.printf("(Taste 'C' zum Löschen)", 0, 200, screenWidth, "center")

        for _, btn in ipairs(c.puzzleButtons) do
            local abgenutzt = (btn.text == "2" or btn.text == "4" or btn.text == "7" or btn.text == "9")
            if abgenutzt then love.graphics.setColor(0.7, 0.6, 0.2) else love.graphics.setColor(0.3, 0.3, 0.3) end

            love.graphics.rectangle("fill", btn.x, btn.y, btn.width, btn.height)
            love.graphics.setColor(1, 1, 1) love.graphics.rectangle("line", btn.x, btn.y, btn.width, btn.height)
            love.graphics.printf(btn.text, btn.x, btn.y + 20, btn.width, "center")
        end

    elseif c.state == "jumpscare" then
        if c.images.image then love.graphics.draw(c.images.image, (screenWidth - c.images.image:getWidth()) / 2, 80) end
        if math.floor(c.timer * 22) % 2 == 0 then love.graphics.setColor(0.5, 0, 0, 0.4) love.graphics.rectangle("fill", 0, 0, screenWidth, screenHeight) end
        if c.images.zombieImage then local scale = 0.8 love.graphics.setColor(1, 1, 1) love.graphics.draw(c.images.zombieImage, (screenWidth - c.images.zombieImage:getWidth()*scale)/2, (screenHeight - c.images.zombieImage:getHeight()*scale)/2, 0, scale, scale) end
        love.graphics.printf("EIN ZOMBIE!!!", 0, (screenHeight - c.fonts.titleFont:getHeight()) / 2, screenWidth, "center")

    elseif c.state == "gameover" then
        love.graphics.printf("GAME OVER", 0, 180, screenWidth, "center")
        love.graphics.setFont(c.fonts.labFont) love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Die Zombies haben dich erwischt...", 0, 320, screenWidth, "center")
        love.graphics.printf("Drücke 'R' zum Neustarten", 0, 420, screenWidth, "center")

    elseif c.state == "win" then
        -- Haupt-Gewinn-Nachricht
        love.graphics.setColor(0, 1, 0)
        love.graphics.printf("DU HAST ES GESCHAFFT!", 0, 100, screenWidth, "center")

        love.graphics.setFont(c.fonts.labFont)
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Du bist erfolgreich entkommen!", 0, 220, screenWidth, "center")

        -- HIER SIND DIE NEUEN CREDITS EINGEBAUT
        love.graphics.setColor(0.6, 0.6, 0.6) -- Etwas dunkleres Grau für die Credits
        love.graphics.printf("--- CREDITS ---", 0, 340, screenWidth, "center")
        love.graphics.printf("Idee: Medhavi und Emma Gode", 0, 380, screenWidth, "center")
        love.graphics.printf("Bilder: Gemini", 0, 420, screenWidth, "center")

        -- Neustart-Hinweis ganz unten
        love.graphics.setColor(1, 1, 1)
        love.graphics.printf("Drücke 'R' zum Neustarten", 0, 520, screenWidth, "center")
    end
end

return gameDrawer