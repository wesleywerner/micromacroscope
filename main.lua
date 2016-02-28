

LIGHTBLUE = {149, 250, 255}

timers = {}

scopescale = 1

showcase = {}

-- Set the screen origin to the center, offset vertically to view
-- showcase images nicely
screenWidth, screenHeight = love.graphics.getDimensions()
screenOrigin = {x = screenWidth / 2, y = screenHeight / 2}

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
    
    --addTimer(buildShowcase, 0)
    buildShowcase()
    
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
    
    local zoomamount = 0.1
    
    if love.keyboard.isDown('w') then
        scopescale = scopescale - (scopescale * zoomamount)
    end
    
    if love.keyboard.isDown('s') then
        scopescale = scopescale + (scopescale * zoomamount)
    end

    
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
    
    -- Fade objects in and out of view
    local alpha = 255
    if sx < 1 then
        alpha = 255 * sx
    elseif sx > 5 then
        alpha = sx < 5 and 255 or (255 - 255 * (sx/10))
    end
    
    -- The diameter of the showcase view
    local viewDiameter = 150
    
    -- The closer the showcase is in view, to more we focus it
    -- to the center of the screen, i.e. reduce the diameter of the
    -- view diamter.
    local viewFocus = viewDiameter - (viewDiameter * sx * 0.1)
    
    -- position the item in a circular fashion
    local ix, iy = pointOnCircle(viewFocus, sx + item.r % 6)
    
    -- draw a guide circle to indicate the bounds of this item (100px size)
    love.graphics.setColor({31, 31, 66, alpha * 0.1})
    love.graphics.circle("line", 0, 0, viewDiameter * sx)
    
    -- translate position of the item
    love.graphics.translate(ix, iy)
    
    -- scale the item
    love.graphics.scale(sx, sx)
    
    -- draw image
    if item.image then
        love.graphics.setColor({255, 255, 255, alpha})
        love.graphics.draw(item.image, 
            0, 0,       -- x, y
            sx-1.8,     -- rotation
            1, 1,       -- scale
            item.ox,    -- offset x
            item.oy)    -- offset y
    end
    
    -- draw title
    love.graphics.setColor({31, 31, 31, alpha})
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
    
    addShowcase(1, "Y", "yottameter")
    addShowcase(1, "Z", "zettameter")
    addShowcase(1, "E", "exameter")
    addShowcase(1, "P", "petameter")
    addShowcase(1, "T", "terameter")
    addShowcase(1, "G", "gigameter")
    addShowcase(1, "M", "megameter")
    addShowcase(1, "k", "kilometer")
    addShowcase(1, "h", "hectometer")
    addShowcase(1, "da", "decameter")
    addShowcase(1, "", "meter")
    addShowcase(1, "d", "decimeter")
    addShowcase(1, "c", "centimeter")
    addShowcase(1, "m", "millimeter")
    addShowcase(1, "u", "micrometer")
    addShowcase(1, "n", "nanometer")
    addShowcase(1, "p", "picometer")
    addShowcase(1, "f", "femtometer")
    addShowcase(1, "a", "attometer")
    addShowcase(1, "z", "zeptometer")
    addShowcase(1, "y", "yoctometer")

    addShowcase(70, "p", "Carbon Atom", 
        love.graphics.newImage("images/carbon.png"), "")
    
    addShowcase(8, "u", "Red Blood Cell",
        love.graphics.newImage("images/red-blood-cell.png"), "")
    
    addShowcase(100, "u", "Grain of Salt",
        love.graphics.newImage("images/salt.png"), "")
    
    addShowcase(2, "m", "Fire Ant",
        love.graphics.newImage("images/fire-ant.png"), "")
    
    addShowcase(12, "m", "Coffee Bean",
        love.graphics.newImage("images/coffee-bean.png"), "")
    
    addShowcase(25, "c", "Cat",
        love.graphics.newImage("images/cat.png"), "")
    
    addShowcase(1.83, "", "Human", 
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
   elseif unit == "A" then
       -- angstrom
       return size * 10^-10
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


function addShowcase(size, unit, name, image, description)
    
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
            oy=imageH / 2,
            r=#showcase % 6
            })
    
end

