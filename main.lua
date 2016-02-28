

LIGHTBLUE = {149, 250, 255}

timers = {}

scopescale = 1

showcase = {}


-- Simple number rounding function
function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
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
    love.graphics.translate(item.x, item.y)
    
    -- scale the item
    love.graphics.scale(sx, sx)
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

end


function addInventory(size, units, name, image, description)
    
    table.insert(showcase, 
        {
            size=size,
            name=name,
            image=image,
            description=description,
            x=0,
            y=0
            })
    
end

