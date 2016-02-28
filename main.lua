

LIGHTBLUE = {149, 250, 255}

timers = {}

scopescale = 1

showcase = {}

-- Set the screen origin to the center, offset vertically to view
-- showcase images nicely
screenWidth, screenHeight = love.graphics.getDimensions()
screenOrigin = {x = screenWidth / 2, y = screenHeight / 2 - 200}


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
    
    -- Center screen around the origin
    love.graphics.translate(screenOrigin.x, screenOrigin.y)
    
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
    
    addInventory(1, "Y", "yottameter")
    addInventory(1, "Z", "zettameter")
    addInventory(1, "E", "exameter")
    addInventory(1, "P", "petameter")
    addInventory(1, "T", "terameter")
    addInventory(1, "G", "gigameter")
    addInventory(1, "M", "megameter")
    addInventory(1, "k", "kilometer")
    addInventory(1, "h", "hectometer")
    addInventory(1, "da", "decameter")
    addInventory(1, "", "meter")
    addInventory(1, "d", "decimeter")
    addInventory(1, "c", "centimeter")
    addInventory(1, "m", "millimeter")
    addInventory(1, "u", "micrometer")
    addInventory(1, "n", "nanometer")
    addInventory(1, "p", "picometer")
    addInventory(1, "f", "femtometer")
    addInventory(1, "a", "attometer")
    addInventory(1, "z", "zeptometer")
    addInventory(1, "y", "yoctometer")

    addInventory(1.83, "", "Human", 
        love.graphics.newImage("images/human.png"), "")

end


-- Calculate the size of an object from it's relative size and unit of measure.
-- We use the metric system of SI units, meters is the base unit and is
-- indicated by an empty prefix unit.
-- https://en.wikipedia.org/wiki/Metric_prefix
function calculateSizeFromUnits(size, unit)
   
   -- Fractions (small things)
   if unit == "d" then
       -- deci
       return size * 10^-1
   elseif unit == "c" then
       -- centi
       return size * 10^-2
   elseif unit == "m" then
       -- milli
       return size * 10^-3
   elseif unit == "u" then
       -- micro
       return size * 10^-6
   elseif unit == "n" then
       -- nano
       return size * 10^-9
   elseif unit == "p" then
       -- pico
       return size * 10^-12
   elseif unit == "f" then
       -- femto
       return size * 10^-15
   elseif unit == "a" then
       -- atto
       return size * 10^-18
   elseif unit == "z" then
       -- zepto
       return size * 10^-21
   elseif unit == "y" then
       -- yocto
       return size * 10^-24
   end
   
   -- Multiples (large things)
   if unit == "da" then
       -- deca
       return size * 10^1
   elseif unit == "h" then
       -- hecto
       return size * 10^2
   elseif unit == "k" then
       -- kilo
       return size * 10^3
   elseif unit == "M" then
       -- mega
       return size * 10^6
   elseif unit == "G" then
       -- Giga
       return size * 10^9
   elseif unit == "T" then
       -- tera
       return size * 10^12
   elseif unit == "P" then
       -- peta
       return size * 10^15
   elseif unit == "E" then
       -- exa
       return size * 10^18
   elseif unit == "Z" then
       -- zeta
       return size * 10^21
   elseif unit == "Y" then
       -- yota
       return size * 10^24
   end
   
   -- Uncalculated for unknown units of measure
   return size
    
end


function addInventory(size, unit, name, image, description)
    
    local imageW, imageH = 0, 0
    
    if image then
        imageW, imageH = image:getDimensions()
    end
    
    table.insert(showcase, 
        {
            sizeFormatted=tostring(size) .. unit,
            size=calculateSizeFromUnits(size, unit),
            unit=unit,
            name=name,
            image=image,
            description=description,
            x=0,
            y=0,
            ox=imageW / 2,
            oy=imageH / 2
            })
    
end

