local c = require("config")
local gameLogic = require("game_logic")
local gameDrawer = require("game_drawer")
local inputHandler = require("input_handler")

function love.load()
    -- Medien laden
    if love.filesystem.getInfo("CreepyLab.png") then c.images.image = love.graphics.newImage("CreepyLab.png") end
    if love.filesystem.getInfo("Korridor.png") then c.images.corridorImage = love.graphics.newImage("Korridor.png") end
    if love.filesystem.getInfo("zombieKopf.png") then c.images.zombieImage = love.graphics.newImage("zombieKopf.png") end
    if love.filesystem.getInfo("chest.png") then c.images.chestImage = love.graphics.newImage("chest.png") end

    if love.filesystem.getInfo("cour.ttf") then c.fonts.labFont = love.graphics.newFont("cour.ttf", 26) else c.fonts.labFont = love.graphics.newFont(26) end
    if love.filesystem.getInfo("chiller.ttf") then
        c.fonts.corridorFont = love.graphics.newFont("chiller.ttf", 44)
        c.fonts.titleFont = love.graphics.newFont("chiller.ttf", 80)
    else
        c.fonts.corridorFont = love.graphics.newFont(44)
        c.fonts.titleFont = love.graphics.newFont(80)
    end

    -- Keypad erstellen
    local startX = (love.graphics.getWidth() - 260) / 2
    local startY = 250
    local bSize, spacing = 70, 15
    local layout = {{"1", "2", "3"}, {"4", "5", "6"}, {"7", "8", "9"}}

    for r, row in ipairs(layout) do
        for c_idx, num in ipairs(row) do
            table.insert(c.puzzleButtons, {
                text = num,
                x = startX + (c_idx - 1) * (bSize + spacing),
                y = startY + (r - 1) * (bSize + spacing),
                width = bSize, height = bSize
            })
        end
    end
    table.insert(c.puzzleButtons, { text = "0", x = startX + (bSize + spacing), y = startY + 3 * (bSize + spacing), width = bSize, height = bSize })
end

function love.update(dt)
    gameLogic.update(dt)
end

function love.draw()
    gameDrawer.draw()
end

function love.mousepressed(x, y, button)
    inputHandler.mousepressed(x, y, button)
end

function love.keypressed(key)
    inputHandler.keypressed(key)
end