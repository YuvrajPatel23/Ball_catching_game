local physics = require("physics")
physics.start()
physics.setGravity(0, 9.8)

local json = require("json")
local path = system.pathForFile("highscore.json", system.DocumentsDirectory)

local score = 0
local lives = 3
local gameOver = false
local gamePaused = false
local ballTimer
local balls = {}
local gameOverBackground
local pauseButton
local ballSpawnDelay = 2000
local highestScore = 0

local highestscore = display.newText("Highest Score: " .. highestScore, display.contentCenterX, 50, native.systemFontBold, 36)
highestscore:setFillColor(0.1, 0.1, 0.9)
highestscore.anchorX = 0.5

local background = display.newImageRect("background.jpg", display.contentWidth, display.contentHeight)
background.x = display.contentCenterX
background.y = display.contentCenterY

local scoreShadow = display.newText("Score: 0", 32, 125, native.systemFontBold, 64)
scoreShadow:setFillColor(0, 0, 0, 0.0)
scoreShadow.anchorX = 0

local scoreText = display.newText("Score: 0", 30, 125, native.systemFontBold, 64)
scoreText:setFillColor(0.1, 0.1, 0.9)
scoreText.anchorX = 0

local livesText = display.newText("Lives: 3", display.contentCenterX, 125, native.systemFontBold, 72)
livesText:setFillColor(1, 0, 0)

pauseButton = display.newText("❚❚", display.contentWidth - 100, 125, native.systemFontBold, 150)
pauseButton:setFillColor(0.2, 0.8, 0.2)

local function loadHighScore()
    local filePath = system.pathForFile("highscore.json", system.DocumentsDirectory)
    local file = io.open(filePath, "r")
    if file then
        local contents = file:read("*a")
        io.close(file)
        local data = json.decode(contents)
        if data and data.highestScore then
            highestScore = data.highestScore
            highestscore.text = "Highest Score: " .. highestScore
        end
    end
end

local function saveHighScore()
    local filePath = system.pathForFile("highscore.json", system.DocumentsDirectory)
    local file = io.open(filePath, "w")
    if file then
        local data = { highestScore = highestScore }
        file:write(json.encode(data))
        io.close(file)
    end
end

local function togglePause()
    if gameOver then return end
    gamePaused = not gamePaused

    if gamePaused then
        pauseButton.text = "▶"
        physics.pause()
        if ballTimer then timer.cancel(ballTimer) end
        for i = 1, #balls do
            Runtime:removeEventListener("enterFrame", balls[i])
        end
    else
        pauseButton.text = "❚❚"
        physics.start()
        ballTimer = timer.performWithDelay(ballSpawnDelay, spawnBall, 0)
        for i = 1, #balls do
            Runtime:addEventListener("enterFrame", balls[i])
        end
    end
end
pauseButton:addEventListener("tap", togglePause)

local bucket = display.newImageRect("bucket.png", 175, 75)
bucket.x = display.contentCenterX
bucket.y = display.contentHeight - 125
physics.addBody(bucket, "kinematic", { isSensor = true })

local function moveBucket(event)
    if not gameOver and not gamePaused and (event.phase == "began" or event.phase == "moved") then
        bucket.x = event.x
    end
end
Runtime:addEventListener("touch", moveBucket)

local function restartGame()
    score = 0
    lives = 3
    gameOver = false
    gamePaused = false
    ballSpawnDelay = 1000
    scoreText.text = "Score: 0"
    scoreShadow.text = "Score: 0"
    livesText.text = "Lives: 3"
    bucket.x = display.contentCenterX

    pauseButton.text = "❚❚"
    physics.start()

    for i = #balls, 1, -1 do
        Runtime:removeEventListener("enterFrame", balls[i])
        display.remove(balls[i])
        table.remove(balls, i)
    end

    if restartButton then restartButton:removeSelf() restartButton = nil end
    if gameOverText then gameOverText:removeSelf() gameOverText = nil end
    if finalScoreText then finalScoreText:removeSelf() finalScoreText = nil end
    if highScoreText then highScoreText:removeSelf() highScoreText = nil end
    if gameOverBackground then gameOverBackground:removeSelf() gameOverBackground = nil end

    ballTimer = timer.performWithDelay(ballSpawnDelay, spawnBall, 0)
end

local function endGame()
    gameOver = true
    if ballTimer then timer.cancel(ballTimer) end

    gameOverBackground = display.newRect(display.contentCenterX, display.contentCenterY, display.contentWidth, display.contentHeight)
    gameOverBackground:setFillColor(0.2, 0.2, 0.2)

    gameOverText = display.newText("Game Over", display.contentCenterX, display.contentCenterY - 120, native.systemFontBold, 64)
    gameOverText:setFillColor(1, 0, 0)

    finalScoreText = display.newText("Final Score: " .. score, display.contentCenterX, display.contentCenterY - 40, native.systemFontBold, 44)
    finalScoreText:setFillColor(1, 1, 1)

    highestScore = math.max(highestScore, score)
    saveHighScore()
    loadHighScore()

    highScoreText = display.newText("High Score: " .. highestScore, display.contentCenterX, display.contentCenterY + 20, native.systemFontBold, 40)
    highScoreText:setFillColor(1, 1, 0)

    restartButton = display.newText("Restart", display.contentCenterX, display.contentCenterY + 80, native.systemFontBold, 52)
    restartButton:setFillColor(0, 0.6, 1)
    restartButton:addEventListener("tap", restartGame)
end

function spawnBall()
    if gameOver or gamePaused then return end

    local ball = display.newCircle(math.random(40, display.contentWidth - 40), -30, 20)
    ball:setFillColor(1, 0, 0)
    physics.addBody(ball, "dynamic", { radius = 20, bounce = 0 })
    ball.myName = "ball"
    table.insert(balls, ball)

    function ball:enterFrame()
        if gamePaused then return end

        if self.y > display.contentHeight + 50 then
            Runtime:removeEventListener("enterFrame", self)
            display.remove(self)

            for i = #balls, 1, -1 do
                if balls[i] == self then
                    table.remove(balls, i)
                    break
                end
            end

            lives = lives - 1
            livesText.text = "Lives: " .. lives

            if lives <= 0 and not gameOver then
                endGame()
            end
        end
    end

    Runtime:addEventListener("enterFrame", ball)
end

local function onCollision(event)
    if gameOver or gamePaused then return end
    if event.phase == "began" then
        local obj1 = event.object1
        local obj2 = event.object2

        if (obj1 == bucket and obj2.myName == "ball") or (obj2 == bucket and obj1.myName == "ball") then
            local ball = obj1.myName == "ball" and obj1 or obj2
            Runtime:removeEventListener("enterFrame", ball)
            display.remove(ball)

            for i = #balls, 1, -1 do
                if balls[i] == ball then
                    table.remove(balls, i)
                    break
                end
            end

            score = score + 1
            scoreText.text = "Score: " .. score
            scoreShadow.text = scoreText.text

            if score % 10 == 0 then
                ballSpawnDelay = math.max(ballSpawnDelay - 100, 100)
                if ballTimer then timer.cancel(ballTimer) end
                ballTimer = timer.performWithDelay(ballSpawnDelay, spawnBall, 0)

                local bonusText = display.newText("+BONUS! SPEED UP!", bucket.x, bucket.y - 80, native.systemFontBold, 48)
                bonusText:setFillColor(1, 0.8, 0)
                transition.to(bonusText, {
                    y = bonusText.y - 40,
                    alpha = 0,
                    time = 800,
                    onComplete = function() display.remove(bonusText) end
                })
            end
        end
    end
end

Runtime:addEventListener("collision", onCollision)

loadHighScore()
ballTimer = timer.performWithDelay(ballSpawnDelay, spawnBall, 0)
