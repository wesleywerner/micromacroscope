

LIGHTBLUE = {149, 250, 255}

timers = {}

scopescale = 0.16

targetscale = scopescale

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


-- zoom the micro and macro scopes in and out
function zoomScope(zoomIn)
    
    local zoomamount = 0.7
    
    local direction = zoomIn and 1 or -1
    
    targetscale = scopescale + (scopescale * zoomamount) * direction
    
end


function love.load(arg)
    
    love.graphics.setBackgroundColor(LIGHTBLUE)
    
    smallFont = love.graphics.newFont(20)
    
    --addTimer(buildShowcase, 0)
    buildShowcase()
    
    log10max = math.log10(10^24)
    scaleWidthRatio = screenWidth / 2

end


function love.keypressed(key, isrepeat)
    
    if key == "escape" then
        love.event.quit()
    end
    
end


function love.mousepressed(x, y, button)
    
    if button == "wu" then
        zoomScope(false)
    end
    
    if button == "wd" then
        zoomScope(true)
    end
    
end


function love.update(dt)
    
    updateTimers(dt)
    
    if love.keyboard.isDown('w') then
        zoomScope(false)
    end
    
    if love.keyboard.isDown('s') then
        zoomScope(true)
    end
    
    -- Move the scope scale towards the target scale
    -- Use easing to transition the change smoothly
    local diff = (targetscale - scopescale)
    local sign = (targetscale - scopescale < 0) and -1 or 1
    scopescale = scopescale + (math.abs(diff) * 0.1 * sign)    

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
    
    -- Reset translation
    love.graphics.origin()
    drawInfobar()
    
end


function drawInfobar()
    
    love.graphics.push()
    
    local barHeight = 40
    local lineMarginFromBottom = 0
    
    -- fill
    love.graphics.setColor({255, 255, 255, 192})
    
    love.graphics.rectangle("fill", 0, 
        screenHeight - barHeight, screenWidth, barHeight)
    
    -- outline
    love.graphics.setLineWidth(3)
    
    love.graphics.setColor({255, 255, 255, 192})

    love.graphics.rectangle("line", 0, 
        screenHeight - barHeight, screenWidth, barHeight)
    
    -- guideline
    love.graphics.setColor({0, 128, 0, 96})
    love.graphics.setLineWidth(6)
    love.graphics.line(0, screenHeight - lineMarginFromBottom, 
        screenWidth, screenHeight - lineMarginFromBottom)
    
    -- draw the scale indicator
    -- our arrow is a triangle poly
    local log10scope = math.log10(scopescale)
    local scalePosition = scaleWidthRatio + log10scope / log10max * scaleWidthRatio
    local vertices = {-10, -10, 10, -10, 0, 10}
    love.graphics.push()
    love.graphics.translate(scalePosition, screenHeight - 10)
    love.graphics.setColor({0, 128, 0, 192})
    love.graphics.polygon('fill', vertices)
    love.graphics.pop()
    
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
            0,          -- rotation
            1, 1,       -- scale
            item.ox,    -- offset x
            item.oy)    -- offset y
    end
    
    love.graphics.pop()
    
    -- draw showcase label
    drawShowcaseLabel(sx, 
        {x=ix, y=iy}, 
        item.image and {item.image:getDimensions()},
        item.name, item.description)
        
end


function drawShowcaseLabel(scale, position, size, name, description)
    
    if scale < 1 or scale > 5 then return end
    
    local boxWidth = 150
    local boxHeight = 70
    
    -- fixed position relative to translated center
    --position = { x = -screenWidth / 2, y = screenHeight / 2 - boxHeight}
    
    love.graphics.push()
    
    -- box fill
    love.graphics.setColor({255, 255, 255, 128})
    love.graphics.rectangle("fill", position.x, position.y, boxWidth, boxHeight)
    
    -- outline
    love.graphics.setLineWidth(4)
    love.graphics.setColor({255, 255, 255, 192})
    love.graphics.rectangle("line", position.x, position.y, boxWidth, boxHeight)
    
    -- draw title
    love.graphics.setColor({0, 0, 0, 192})
    
    love.graphics.setFont(smallFont)
    love.graphics.printf(name, position.x, position.y, boxWidth, "center")
    
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
    
    addShowcase(220, "n", "Smallpox Virus")
    
    addShowcase(8, "u", "Red Blood Cell",
        love.graphics.newImage("images/red-blood-cell.png"), "")
    
    addShowcase(180, "u", "1000x Optical Magnification")
    
    addShowcase(0.3, "m", "Grain of Salt",
        love.graphics.newImage("images/salt.png"), "")
    
    addShowcase(2, "m", "Fire Ant",
        love.graphics.newImage("images/fire-ant.png"), "")
    
    addShowcase(12, "m", "Coffee Bean",
        love.graphics.newImage("images/coffee-bean.png"), "")
    
    addShowcase(25, "c", "Cat",
        love.graphics.newImage("images/cat.png"), "")
    
    addShowcase(1.83, "", "Human", 
        love.graphics.newImage("images/human.png"), "")
        
    addShowcase(5.486, "", "Giraffe",
        love.graphics.newImage("images/giraffe.png"), "")
    
    addShowcase(30, "", "TV Radio Wavelength",
        love.graphics.newImage("images/wave.png"), "")
    
    addShowcase(354, "k", "ISS Altitude",
        love.graphics.newImage("images/iss.png"), "")

    addShowcase(3474.8, "k", "Diameter of the Moon",
        love.graphics.newImage("images/moon.png"), "")
    
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

