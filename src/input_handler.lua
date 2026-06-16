local c = require("config")
local inputHandler = {}

function inputHandler.mousepressed(x, y, button)
    if button == 1 then
        if c.state == "scene" then
            if c.showOptions then
                if x > c.option1.x and x < c.option1.x + c.option1.width and y > c.option1.y and y < c.option1.y + c.option1.height then
                    c.state = "corridor" c.corridorTimer = 0 c.corridorStep = 1
                end
                if x > c.option2.x and x < c.option2.x + c.option2.width and y > c.option2.y and y < c.option2.y + c.option2.height then
                    c.state = "jumpscare" c.timer = 0
                end
            else
                if x > c.weiterButton.x and x < c.weiterButton.x + c.weiterButton.width and y > c.weiterButton.y and y < c.weiterButton.y + c.weiterButton.height then
                    if c.aktuellerText < #c.texte then c.aktuellerText = c.aktuellerText + 1 c.typewriterProgress = 0
                    else c.showOptions = true end
                end
            end
        elseif c.state == "puzzle" then
            for _, btn in ipairs(c.puzzleButtons) do
                if x > btn.x and x < btn.x + btn.width and y > btn.y and y < btn.y + btn.height then
                    if string.len(c.puzzleInput) < 4 then c.puzzleInput = c.puzzleInput .. btn.text end
                end
            end
        end
    end
end

function inputHandler.keypressed(key)
    if key == "escape" then love.event.quit() end

    if c.state == "jumpnrun" and key == "up" and c.player.onGround then
        c.player.vy = c.jnrJumpForce
    end

    if c.state == "puzzle" and key == "c" then
        c.puzzleInput = ""
    end

    -- Cheat-Taste 'k'
    if key == "k" then
        if c.state == "jumpnrun" then c.geheZuLagerraum()
        elseif c.state == "lagerraum" then c.geheZuRaetsel()
        elseif c.state == "puzzle" then c.state = "win" end
    end

    -- Restart-Logik
    if (c.state == "gameover" or c.state == "lagerraum" or c.state == "puzzle" or c.state == "win") and key == "r" then
        c.state = "title"
        c.timer = 0
        c.corridorTimer = 0
        c.corridorStep = 1
        c.aktuellerText = 1
        c.typewriterProgress = 0
        c.showOptions = false
        c.zombieWallX = -200
    end
end

return inputHandler