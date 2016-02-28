

LIGHTBLUE = {149, 250, 255}

timers = {}

scopescale = 1

showcase = {}


-- Simple number rounding function
function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end


-- Determine the x,y coordinates on circle based on given angle.
-- Assume the circle is draw at origin 0,0
function pointOnCircle(radius, angle)
    -- convert angle into degrees
    --angle = math.pi / 2
    local x = (radius * math.cos(angle))
    local y = (radius * math.sin(angle))
    return x, y
end

function love.load(arg)
    
    love.graphics.setBackgroundColor(LIGHTBLUE)
    
    addTimer(buildShowcase, 0)
    
end


function love.keypressed(key, isrepeat)
    
    if key == "escape" then
        love.event.quit()
    end
    
end


function love.mousepressed(x, y, button)
    
    local zoomamount = 0.1
    
    if button == "wu" then
        scopescale = scopescale - (scopescale * zoomamount)
    end
    
    if button == "wd" then
        scopescale = scopescale + (scopescale * zoomamount)
    end
    
    
end


function love.update(dt)
    
    updateTimers(dt)
    
end


function love.draw()
    
    love.graphics.setColor({31, 31, 66, 192})
    love.graphics.print("scope scale: " .. tostring(scopescale))
        
    local fps = love.timer.getFPS()
    love.graphics.print("fps: " .. tostring(fps), 0, 20)

    -- New graphics stack for drawing the showcase
    love.graphics.push()
    
    -- Center of window
    local width, height = love.graphics.getDimensions()
    love.graphics.translate(width / 2, height / 2)
    
    for _, item in ipairs(showcase) do
        drawShowcase(item)
    end
    
    love.graphics.pop()
    
end


function drawShowcase(item)
    
    -- determine scale of the item vs baseline
    local sx = item.size / scopescale
    
    -- limit visiblity to items in the 0.1 .. 10 scale range
    if sx < 0.1 or sx > 10 then return end
    
    love.graphics.push()
    
    -- position the item in a circular fashion
    local ix, iy = pointOnCircle(100 * sx, sx)
    
    -- draw a guide circle to indicate the bounds of this item (100px size)
    --love.graphics.circle("line", 0, 0, 100 * sx)
    
    -- translate position of the item
    love.graphics.translate(ix, iy)
    
    -- scale the item
    love.graphics.scale(sx, sx)
    
    -- draw image
    if item.image then
        love.graphics.draw(item.image, 0, 0, sx-1.8, 1, 1, item.ox, item.oy)
    end
    
    -- draw title
    love.graphics.setColor({31, 31, 31, 255})
    love.graphics.print(item.name)
    
    love.graphics.pop()
    
end


function addTimer(func, delay)
    
    local entry = {}
    entry.func = func
    entry.delay = delay
    table.insert(timers, entry)
    
end


function updateTimers(dt)
    
    for _, timer in ipairs(timers) do
        
       timer.delay = timer.delay - dt
       
       if timer.delay < 0 then
           timer.func()
       end
       
    end
    
end


function buildShowcase()
    
    addInventory(1000000000, "m", "Billion", nil, nil)
    addInventory(100000000, "m", "Hun Million", nil, nil)
    addInventory(10000000, "m", "Ten Million", nil, nil)
    addInventory(1000000, "m", "Million", nil, nil)
    addInventory(100000, "m", "Hundred Thousand", nil, nil)
    addInventory(10000, "m", "Ten Thousand", nil, nil)
    addInventory(1000, "m", "Thousand", nil, nil)
    addInventory(100, "m", "Hundred", nil, nil)
    addInventory(10, "m", "Ten", nil, nil)

    addInventory(1, "m", "One Metre", nil, nil)
    addInventory(0.1, "m", "Tenth Metre", nil, nil)
    addInventory(0.01, "m", "Hundreth Metre", nil, nil)
    addInventory(0.001, "m", "Thousanth Metre", nil, nil)
    addInventory(0.0001, "m", "Ten Thousanth", nil, nil)
    addInventory(0.00001, "m", "Hun Thousanth", nil, nil)
    addInventory(0.000001, "m", "Millionth", nil, nil)
    addInventory(0.0000001, "m", "Ten Millionth", nil, nil)
    addInventory(0.00000001, "m", "Hun Millionth", nil, nil)
    addInventory(0.000000001, "m", "Billionth", nil, nil)

    addInventory(2, "m", "2", nil, nil)
    addInventory(3, "m", "3", nil, nil)
    addInventory(4, "m", "4", nil, nil)
    addInventory(5, "m", "5", nil, nil)
    addInventory(15, "m", "15", nil, nil)
    addInventory(25, "m", "25", nil, nil)
    addInventory(35, "m", "35", nil, nil)
    addInventory(55, "m", "55", nil, nil)
    addInventory(70, "m", "70", nil, nil)
    addInventory(85, "m", "85", nil, nil)
    addInventory(90, "m", "90", nil, nil)

    addInventory(200, "m", "200", nil, nil)
    addInventory(300, "m", "300", nil, nil)
    addInventory(400, "m", "400", nil, nil)
    addInventory(500, "m", "500", nil, nil)
    addInventory(600, "m", "600", nil, nil)
    addInventory(700, "m", "700", nil, nil)
    addInventory(800, "m", "800", nil, nil)
    addInventory(900, "m", "900", nil, nil)

    addInventory(1.83, "m", "Human", love.graphics.newImage("images/human.png"), "")

end


function addInventory(size, units, name, image, description)
    
    local imageW, imageH = 0, 0
    
    if image then
        imageW, imageH = image:getDimensions()
    end
    
    table.insert(showcase, 
        {
            size=size,
            name=name,
            image=image,
            description=description,
            x=0,
            y=0,
            ox=imageW / 2,
            oy=imageH / 2
            })
    
end

