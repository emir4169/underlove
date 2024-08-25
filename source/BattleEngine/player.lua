Player = {}

local hideHeart = false
local lastButton

local heart = {
    image = love.graphics.newImage('assets/images/ut-heart.png'),
    x = Ui.arenaTo.x - 8,
    y = Ui.arenaTo.y - 8
}

local sfx = {
    move = love.audio.newSource('assets/sound/sfx/menumove.wav', 'static'),
    select = love.audio.newSource('assets/sound/sfx/menuconfirm.wav', 'static'),
    heal = love.audio.newSource('assets/sound/sfx/snd_heal_c.wav', 'static')
}

Player.stats = {name = 'Chara', love = 1, hp = 1, maxhp = 20, armor = 'Bandage', weapon = 'Stick'}
Player.vars = {def = 1, atk = 1} -- don't edit these

Player.inventory = {}

if global.battleState == 'enemyTalk' then
    heart.x = Ui.arenaTo.x - 8
    heart.y = Ui.arenaTo.y - 8
end

local function buttonPos()
    heart.y = 446
    if global.choice == 0 then 
        heart.x = 40
    elseif global.choice == 1 then
        heart.x = 194
    elseif global.choice == 2 then
        heart.x = 353
    elseif global.choice == 3 then
        heart.x = 507
    end
end

function Player:update(dt)
    if global.battleState == 'buttons' then
        if input.right then
            sfx.move:stop()
            sfx.move:play()
            global.choice = global.choice + 1
            if global.choice == 4 then
                global.choice = 0
            end
        elseif input.left then
            sfx.move:stop()
            sfx.move:play()
            global.choice = global.choice - 1
            if global.choice == -1 then
                global.choice = 3
            end
        elseif input.primary then
            sfx.select:stop()
            sfx.select:play()
            if global.choice == 2 then
                global.battleState = 'item'
                Writer:stop()
            end
            input.primary = false
        end
        buttonPos()
    end
    if global.battleState == 'enemyTurn' then
        heart.x = heart.x + ((love.keyboard.isDown('right')and 1 or 0) - (love.keyboard.isDown('left')and 1 or 0)) * 4 / ((love.keyboard.isDown('x')and 1 or 0) + 1) * love.timer.getDelta() * 30
        heart.y = heart.y + ((love.keyboard.isDown('down')and 1 or 0) - (love.keyboard.isDown('up')and 1 or 0)) * 4 / ((love.keyboard.isDown('x')and 1 or 0) + 1) * love.timer.getDelta() * 30
        heart.x = math.max(maxLeft, math.min(heart.x, maxRight))
        heart.y = math.max(maxUp, math.min(heart.y, maxDown))
    end
    if global.battleState == 'item' then
        heart.x, heart.y = 472, 348
        if input.secondary then
            input.secondary = false
            buttonPos()
            gotoMenu()
        end
    end
    if global.battleState == 'useItem' then
        if Writer.isDone and input.primary then
            gotoMenu()
            global.choice = lastButton
            buttonPos()
            hideHeart = false
        end
    end
end

function Player:draw()
    love.graphics.setColor(1, 0, 0)
    if not hideHeart then
        love.graphics.draw(heart.image, heart.x, heart.y)
    end
end

return Player