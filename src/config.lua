local config = {
    utf8 = require("utf8"),
    state = "title",
    timer = 0,
    corridorTimer = 0,
    corridorStep = 1,
    mouseX = 0,
    mouseY = 0,

    -- Schriften und Bilder
    fonts = {},
    images = {},

    -- Text-Story
    typewriterText = "",
    typewriterProgress = 0,
    typewriterSpeed = 30,
    aktuellerText = 1,
    showOptions = false,
    texte = {
        "Du wachst auf.",
        "Wo bist du?",
        "Du bist in einem Labor vom HAUNTED HOSPITAL.",
        "Du weißt nicht, wie du hierher gekommen bist, aber: RAUS AUS DIESEM VERFLUCHTEN ORT!",
        "Was willst du tun?"
    },

    -- Buttons
    weiterButton = { x = 250, y = 550, width = 300, height = 50 },
    option1 = { x = 0, y = 550, width = 220, height = 60, text = "Zur Tür gehen" },
    option2 = { x = 0, y = 550, width = 220, height = 60, text = "Im Labor umsehen" },

    -- Spieler
    player = { x = 50, y = 400, vx = 0, vy = 0, size = 30, onGround = false, speed = 300 },

    -- Jump 'n' Run
    jnrGravity = 1500,
    jnrJumpForce = -650,
    zombieWallX = -200,
    zombieWallSpeed = 110,
    cameraX = 0,
    levelWidth = 3500,
    jnrGoal = { x = 3250, y = 340, width = 50, height = 80 },

    jnrPlatforms = {
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
    },
    movingPlatforms = {
        { x = 900, y = 420, width = 150, height = 30, startX = 900, endX = 1150, speed = 100, direction = 1 },
        { x = 1700, y = 350, width = 150, height = 30, startX = 1700, endX = 1950, speed = 130, direction = 1 }
    },
    jnrHazards = {
        { x = 400, y = 360, width = 40, height = 20 },
        { x = 1500, y = 300, width = 50, height = 20 },
        { x = 2050, y = 420, width = 40, height = 20 },
        { x = 2700, y = 440, width = 60, height = 20 }
    },

    -- Labyrinth
    tileSize = 64,
    storageMap = {
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1},
        {1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,1},
        {1,0,1,0,1,0,1,1,1,1,1,1,1,1,0,1},
        {1,0,1,0,0,0,1,0,0,0,0,0,0,1,0,1},
        {1,1,1,1,1,1,1,0,1,1,1,1,0,1,0,1},
        {1,0,0,0,0,0,0,0,1,0,0,1,0,1,0,1},
        {1,0,1,1,1,1,1,1,1,0,0,1,0,1,0,1},
        {1,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1},
        {1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,1}
    },

    -- Rätsel
    puzzleInput = "",
    puzzleLösung = "2479",
puzzleButtons = {}
}

-- Helferfunktion Kollision
function config.checkCollision(x1, y1, w1, h1, x2, y2, w2, h2)
return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

-- Szenenwechsel-Funktionen
function config.geheZuLagerraum()
config.state = "lagerraum"
config.player.x = config.tileSize + config.tileSize / 2 - config.player.size / 2
config.player.y = config.tileSize + config.tileSize / 2 - config.player.size / 2
config.player.vx = 0
config.player.vy = 0
config.zombieWallX = -config.tileSize
end

function config.geheZuRaetsel()
config.state = "puzzle"
config.puzzleInput = ""
end

return config