

LIGHTBLUE = {149, 250, 255}

timers = {}

scopescale = 0.16

targetscale = scopescale

showcase = {}

visibleShowcases = {}

infoboxes = {}

infoboxWidth = 200

-- Set the screen origin to the center, offset vertically to view
-- showcase images nicely
screenWidth, screenHeight = love.graphics.getDimensions()
screenOrigin = {x = screenWidth / 2, y = screenHeight / 2}

-- the zoom control zone
zoomcontrol = {}
zoomcontrol.w = screenWidth * 0.1   -- 10% right aligned
zoomcontrol.h = screenHeight - screenHeight * 0.1   -- 10% from the bottom
zoomcontrol.x = screenWidth - zoomcontrol.w
zoomcontrol.y = 0
zoomcontrol.image = love.graphics.newImage("images/zoomcontrol.png")
zoomcontrol.scale = zoomcontrol.h / zoomcontrol.image:getHeight()
zoomcontrol.ox = -zoomcontrol.w / 2

-- the minimap draws icons of showcase items
minimap = love.graphics.newCanvas (screenWidth, 40)

-- Simple number rounding function
function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

-- Distance calculator
function dist(x1, y1, x2, y2)
    return math.sqrt((x1 - x2)^2 + (y1 - y2)^2)
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


-- zoom the scope by a delta value of -1..1 where 1 is the max zoom
-- speed, negative toggles the direction of the zoom
function zoomScopeByDelta(delta)
    
    local zoomamount = 1 * delta
    
    local direction = delta / delta     -- yields either 1 or -1
    
    if zoomamount ~= 0 then
        targetscale = scopescale + (scopescale * zoomamount) * direction
    end
    
end

function love.load(arg)
    
    love.graphics.setBackgroundColor(LIGHTBLUE)
    
    smallFont = love.graphics.newFont(18)
    infoFont = love.graphics.newFont(12)
    
    smallFontHeight = smallFont:getHeight()
    
    --addTimer(buildShowcase, 0)
    buildShowcase()
    
    log10max = math.log10(10^24)
    scaleWidthRatio = screenWidth / 2
    km50 = calculateSizeFromUnits(50, "k")
    km100 = calculateSizeFromUnits(100, "k")

    -- Build a lookup of scale names
    scaleLookup = {}
    table.insert(scaleLookup, 
        {value=calculateSizeFromUnits(1, "Y"), factor=10^24, name=" Yotametres"})
    table.insert(scaleLookup, 
        {value=calculateSizeFromUnits(1, "Z"), factor=10^21, name=" Zetametres"})
    table.insert(scaleLookup, 
        {value=calculateSizeFromUnits(1, "E"), factor=10^18, name=" Exametres"})
    table.insert(scaleLookup, 
        {value=calculateSizeFromUnits(9.4607, "P"), factor=9.4607*10^15, name=" Light Years"})
    table.insert(scaleLookup, 
        {value=calculateSizeFromUnits(1, "T"), factor=10^12, name=" Terametres"})
    table.insert(scaleLookup, 
        {value=calculateSizeFromUnits(1, "G"), factor=10^9, name=" Gigametres"})
    table.insert(scaleLookup, 
        {value=calculateSizeFromUnits(1, "M"), factor=10^6, name=" Megametres"})
    table.insert(scaleLookup, 
        {value=calculateSizeFromUnits(1, "k"), factor=10^3, name=" Kilometres"})
    table.insert(scaleLookup, 
        {value=calculateSizeFromUnits(1, ""), factor=1, name=" Metres"})
--    table.insert(scaleLookup, 
--        {value=calculateSizeFromUnits(1, "d"), factor=10^-1, name=" Decimetres"})
    table.insert(scaleLookup, 
        {value=calculateSizeFromUnits(1, "c"), factor=10^-2, name=" Centimetres"})
    table.insert(scaleLookup, 
        {value=calculateSizeFromUnits(1, "m"), factor=10^-3, name=" Millimetres"})
    table.insert(scaleLookup, 
        {value=calculateSizeFromUnits(1, "u"), factor=10^-6, name=" Micrometres"})
    table.insert(scaleLookup, 
        {value=calculateSizeFromUnits(1, "n"), factor=10^-9, name=" Nanometres"})
    table.insert(scaleLookup, 
        {value=calculateSizeFromUnits(1, "p"), factor=10^-12, name=" Picometres"})
    table.insert(scaleLookup, 
        {value=calculateSizeFromUnits(1, "f"), factor=10^-15, name=" Femtometres"})
    table.insert(scaleLookup, 
        {value=calculateSizeFromUnits(1, "a"), factor=10^-18, name=" Attometres"})
    table.insert(scaleLookup, 
        {value=calculateSizeFromUnits(1, "z"), factor=10^-21, name=" Zeptometres"})
    table.insert(scaleLookup, 
        {value=calculateSizeFromUnits(1, "y"), factor=10^-24, name=" Yoctometres"})

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
    
    if button == "l" then
        -- not on the zoom control
        if not (x > zoomcontrol.x and x < zoomcontrol.x + zoomcontrol.w) then
            dragitem = getNearestShowcase(x, y)
            if dragitem then
                dragitem.clickedX = dragitem.x + x
                dragitem.clickedY = dragitem.y + y
            end
        end
    end
    
end


function love.mousereleased(x, y, button)
    if button == "l" then
        dragitem = nil
    end
end

function love.touchgestured( x, y, theta, distance, touchcount )
   
   local dist = clamp(-0.7, distance * 100, 0.7)
   targetscale = scopescale + (scopescale * dist)
    
end


function love.update(dt)
    
    --updateTimers(dt)
    
    if love.keyboard.isDown('w') then
        zoomScope(false)
    end
    
    if love.keyboard.isDown('s') then
        zoomScope(true)
    end
    
    if love.mouse.isDown("l") then
        local mousex, mousey = love.mouse.getPosition()
        
        -- detect mouse / touch on the zoom control
        if (not dragitem and mousex > zoomcontrol.x and mousex < zoomcontrol.x + zoomcontrol.w) then
            zoomScopeByDelta((mousey - zoomcontrol.h/2) / zoomcontrol.h)
        else
        
            -- if not over the zoom control, drag a showcase on screen
            if dragitem then
                dragitem.offsetX = mousex - dragitem.clickedX
                dragitem.offsetY = mousey - dragitem.clickedY
            end
        end
        
    end
    
    -- Move the scope scale towards the target scale
    -- Use easing to transition the change smoothly
    local diff = (targetscale - scopescale)
    local sign = (targetscale - scopescale < 0) and -1 or 1
    scopescale = scopescale + (math.abs(diff) * 0.1 * sign)    

end


function love.draw()
    
    setBackground()
    infoboxes = {}
    visibleShowcases = {}
    
--    local fps = love.timer.getFPS()
--    love.graphics.print("fps: " .. tostring(fps), 0, 20)

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
    drawInfoboxes()
    drawZoomControl()
    
end


function drawZoomControl()
    love.graphics.setColor({255, 255, 255, 128})
    love.graphics.draw(zoomcontrol.image,
        zoomcontrol.x,
        zoomcontrol.y,
        0,  -- rotation
        zoomcontrol.scale,
        zoomcontrol.scale,
        zoomcontrol.ox,  -- ox
        0   -- oy
        )
end


-- Adjust the background based on the current scale
function setBackground()
    
    if scopescale > km100 then
        love.graphics.setBackgroundColor({0, 0, 0})
    
    -- 50 km (stratosphere)
    elseif scopescale > km50 then
        local d = 1 - (scopescale / km100)
        d = clamp(0, d, 1)
        love.graphics.setBackgroundColor({149*d, 250*d, 255*d})
    
    -- 1 metre
    elseif scopescale > 0.001 then
        love.graphics.setBackgroundColor(LIGHTBLUE)
        
    -- smallest
    elseif scopescale > 0 then
        love.graphics.setBackgroundColor({255, 255, 255})
        
    end
    
    
end



function drawInfobar()
    
    love.graphics.push()
    
    local barHeight = 40
    local lineMarginFromBottom = 0
    
    -- fill
    love.graphics.setColor({255, 255, 255, 192})
    
    love.graphics.rectangle("fill", 0, 
        screenHeight - barHeight, screenWidth, barHeight)
    
    -- minimap
    love.graphics.setColor({255, 255, 255, 255})
    love.graphics.draw(minimap, 0, screenHeight - barHeight)

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
    
    -- print the scale and units name
    love.graphics.setColor({0, 0, 0, 255})
    love.graphics.printf(getScaleUnitName(), 
        0, screenHeight - smallFont:getHeight(), screenWidth, "center")
    
    -- draw minmap icons
    love.graphics.setColor({255, 255, 255, 255})
    for _, item in pairs(visibleShowcases) do
        
        -- draw this item on the minimap
        if not item.mapped then
            love.graphics.push()
            love.graphics.setCanvas(minimap)
            love.graphics.translate(scalePosition, 0)
            love.graphics.draw(item.image, 0, 0, 0, 0.05, 0.05)
            love.graphics.setCanvas()
            love.graphics.pop()
            item.mapped = true
        end
        
    end
    
end


function drawShowcase(item)
    
    -- determine scale of the item vs baseline
    local sx = item.size / scopescale
    
    -- limit visiblity to items in the 0.1 .. 10 scale range
    if sx < 0.1 or sx > 10 then return end
    
    -- Keep a list of showcases that can be dragged
    if sx > 1 and sx < 5 then
        table.insert(visibleShowcases, item)
    end
    
    love.graphics.push()
    
    -- Fade objects in and out of view
    local alpha = 255
    if sx < 1 then
        alpha = 255 * sx
    elseif sx > 5 then
        alpha = sx < 5 and 255 or (255 - 255 * (sx/10))
    end
    
    -- The diameter of the showcase view
    local viewDiameter = screenHeight / 2
    
    -- The closer the showcase is in view, to more we focus it
    -- to the center of the screen, i.e. reduce the diameter of the
    -- view diamter.
    local viewFocus = viewDiameter - (viewDiameter * sx * 0.1)
    
    -- position the item in a circular fashion
    local ix, iy = pointOnCircle(viewFocus, (sx + item.r) % 6)
    
    -- draw a guide circle to indicate the bounds of this item (100px size)
    --love.graphics.setColor({31, 31, 66, alpha * 0.1})
    --love.graphics.circle("line", 0, 0, viewDiameter * sx)
    
    -- translate position of the item
    love.graphics.translate(ix, iy)
    
    -- translate internal showcase offset
    love.graphics.translate(item.offsetX, item.offsetY)
    
    -- store the showcase position
    item.x = ix
    item.y = iy
    
    -- scale the item
    local scaleClamped = clamp(0, sx, 2)
    love.graphics.scale(scaleClamped, scaleClamped)
    
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
    
    
    table.insert(infoboxes, item)
    
end


function drawInfoboxes()
    
    local textPadLeft = 20
    local textPadTop = 10
    local boxSpacing = 50   -- space between multiple boxes
    local yOffset = 20      -- initial offset
    
    for i, item in ipairs(infoboxes) do
        
        local sx = item.size / scopescale
        if sx > 1 and sx < 5 then
        
            item.infoX = 10
            item.infoY = yOffset-- + item.infoH
            yOffset = yOffset + item.infoH + boxSpacing
            
            -- box fill
            love.graphics.setColor({255, 255, 255, 192})
            love.graphics.rectangle("fill", 
                item.infoX, item.infoY, item.infoW, item.infoH)
            
            -- outline
            love.graphics.setLineWidth(4)
            love.graphics.setColor({0, 0, 0, 128})
            love.graphics.rectangle("line", 
                item.infoX, item.infoY, item.infoW, item.infoH)
            
            -- name
            love.graphics.setFont(smallFont)
            love.graphics.setColor({0, 0, 255})
            love.graphics.print(item.name, textPadLeft, item.infoY + textPadTop)
            
            -- descriptions
            if item.description then
                love.graphics.setColor({0, 0, 0})
                love.graphics.setFont(infoFont)
                love.graphics.printf(item.description, 
                    textPadLeft, 
                    smallFontHeight + item.infoY + textPadTop, 
                    infoboxWidth, "left")
            end

        end
    
    end
    
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
    
--    addShowcase(1, "Y", "yottameter")
--    addShowcase(1, "Z", "zettameter")
--    addShowcase(1, "E", "exameter")
--    addShowcase(1, "P", "petameter")
--    addShowcase(1, "T", "terameter")
--    addShowcase(1, "G", "gigameter")
--    addShowcase(1, "M", "megameter")
--    addShowcase(1, "k", "kilometer")
--    addShowcase(1, "h", "hectometer")
--    addShowcase(1, "da", "decameter")
--    addShowcase(1, "", "meter")
--    addShowcase(1, "d", "decimeter")
--    addShowcase(1, "c", "centimeter")
--    addShowcase(1, "m", "millimeter")
--    addShowcase(1, "u", "micrometer")
--    addShowcase(1, "n", "nanometer")
--    addShowcase(1, "p", "picometer")
--    addShowcase(1, "f", "femtometer")
--    addShowcase(1, "a", "attometer")
--    addShowcase(1, "z", "zeptometer")
--    addShowcase(1, "y", "yoctometer")

    addShowcase(70, "p", "Carbon Atom", 
        love.graphics.newImage("images/carbon.png"), 
        "Carbon is the fourth most abundant element in the universe by mass after hydrogen, helium, and oxygen. It is present in all forms of carbon-based life.")
    
    addShowcase(120, "n", "Influenza Virus",
        love.graphics.newImage("images/flu-virus.png"), 
        "Influenza spreads around the world in a yearly outbreak, resulting in about three to five million cases. Hand washing reduces the risk of infection because the virus is inactivated by soap.")
    
    addShowcase(4, "u", "Red Blood Cell",
        love.graphics.newImage("images/red-blood-cell.png"), 
        "Approximately a quarter of the cells in the human body are red blood cells. Nearly half of the blood's volume (40% to 45%) is red blood cells.")
    
    addShowcase(20, "u", "Intel 4004 transistor",
        love.graphics.newImage("images/intel-4004-chip.png"), 
        "This 4-bit microprocessor was the first commercially available microprocessor by Intel (1971). It had ~2,300 transistors and ran at a clock rate of 740 kHz.")
        
    addShowcase(0.3, "m", "Grain of Salt",
        love.graphics.newImage("images/salt.png"), 
        "Salt was prized by the ancient Hebrews, the Greeks, the Romans, the Byzantines, the Hittites and the Egyptians. Salt became an important article of trade and was transported by boat across the Mediterranean Sea, along specially built salt roads, and across the Sahara in camel caravans.")
    
    addShowcase(2, "m", "Fire Ant",
        love.graphics.newImage("images/fire-ant.png"), 
        "A typical fire ant colony produces large mounds in open areas, and feeds mostly on young plants and seeds.")
    
    addShowcase(12, "m", "Coffee Bean",
        love.graphics.newImage("images/coffee-bean.png"), 
        "A coffee bean is a seed of the coffee plant, and is the source for coffee. It is the pit inside the red or purple fruit often referred to as a cherry. Just like ordinary cherries, the coffee fruit is also a so-called stone fruit.")
    
    addShowcase(25, "c", "Cat",
        love.graphics.newImage("images/cat.png"), 
        "Cats average about 23–25 cm in height. Cats can hear sounds too faint or too high in frequency for human ears, such as those made by mice and other small animals. They can see in near darkness.")
    
    addShowcase(1.83, "", "Human", 
        love.graphics.newImage("images/human.png"), 
        "Humans are part of the animal kingdom. They are mammals, which means that they give birth to their young ones, rather than laying eggs like reptiles or birds, and females feed their babies with breast milk. The average human is 1.83 metres tall.")
        
    addShowcase(5.486, "", "Giraffe",
        love.graphics.newImage("images/giraffe.png"), 
        "Fully grown giraffes stand 4.3–5.7 m tall. Giraffe skin is blotched in patterns of browns and yellows. No two giraffes have the same pattern. The different sub-species have different coat patterns.")
    
    addShowcase(30, "", "TV Radio Wavelength",
        love.graphics.newImage("images/wave.png"), 
        "A wavelength is measured as the distance from the top of one crest to the top of its neighboring crest. While the wavelength of visible light is very very small, less than one micrometer and much less than the thickness of a human hair, radio waves can have a wavelength from a couple centimeters to several meters.")
    
    addShowcase(100, "", "100 metre sprint",
        love.graphics.newImage("images/100m-sprint.jpg"),
        "The 100-meter dash, is a sprint race in track and field competitions. The shortest common outdoor running distance, it is one of the most popular and prestigious events in the sport of athletics. The reigning 100 m Olympic champion is often named \"the fastest man in the world.\" The current men's world record is 9.58 seconds, set by Jamaica's Usain Bolt in 2009, while the women's world record of 10.49 seconds set by American Florence Griffith-Joyner in 1988 remains unbroken.")
    
    addShowcase(8.848, "k", "Mount Everest",
        love.graphics.newImage("images/mount-everest.png"),
        "Mount Everest is the largest and highest mountain on Earth. Mount Everest is in the Himalayas. It is about 8,848 metres high on the border between Nepal and China.")
    
    addShowcase(354, "k", "ISS",
        love.graphics.newImage("images/iss.png"), 
        "The International Space Station is a connected project among several countries: the United States, Russia, Europe, Japan, and Canada. Other nations such as Brazil, Italy, and China also work with the ISS through cooperation with other countries. It orbits the earth every 90 minutes, so the sun looks as if it is rising and setting every 45 minutes. The ISS maintains an orbit with an altitude of between 330 and 435 km.")

    addShowcase(3474.8, "k", "Earth's Moon",
        love.graphics.newImage("images/moon.png"), 
        "The diameter of the Moon is 3474 km. The Moon is thought to have formed approximately 4.5 billion years ago, not long after Earth. A person who jumped as high as possible on the moon would jump higher than on Earth, but still fall back to the ground. Because the Moon has no atmosphere, there is no air resistance, so a feather will fall as fast as a hammer.")
    
    addShowcase(1, "ly", "Light Year",
        love.graphics.newImage("images/light_year.png"),
        "The distance that light travels in one year. Since the speed of light is about 300,000 km per second, then a light year is about 10 trillion kilometers (9.4 × 10^15 km). The light year is used in astronomy because the universe is huge. Space objects such as stars and galaxies may be hundreds, thousands or millions of light years away.")
    
    addShowcase(4.37, "ly", "Alpha Centauri",
        love.graphics.newImage("images/alpha-centauri.png"),
        "Alpha Centauri is the brightest star in the southern Centaurus constellation, the closest star system to us at a mere 4.37 light years away.")
    
    addShowcase(6, "ly", "Barnard's Star",
        love.graphics.newImage("images/barnards-star.png"),
        "At 7–12 billion years of age, Barnard's Star is considerably older than the Sun, which is 4.5 billion years old, and it might be among the oldest stars in the Milky Way galaxy.")
    
    addShowcase(925, "P", "Milky Way Galaxy",
        love.graphics.newImage("images/milkyway.png"),
        "Our home galaxy is 925,000,000,000,000,000 km across. The Sun does not lie near the center of our Galaxy. It lies about 8 kiloparsecs from the center on what is known as the Sagittarius arm of the Milky Way.")
    
    addShowcase(0.1267774, "Y", "GN-z11 Galaxy",
        love.graphics.newImage("images/GN-z11-galaxy.png"), 
        "On March 3, 2016 NASA’s Hubble Space Telescope shattered the cosmic distance record by measuring the farthest galaxy ever seen in the universe. GN-z11, is seen as it was 13.4 billion years in the past, a time when the universe was only three percent of its current age.")
    
    --addShowcase(0.1296157, "Y", "Age of the Universe")
    
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
   elseif unit == "ly" then
       -- light year
       return size * (9.4607 * 10^15)
   end
   
   -- Uncalculated for unknown units of measure
   return size
    
end


-- gets the current unit of measure name
function getScaleUnitName()
    for _, lookup in ipairs(scaleLookup) do
        if scopescale > lookup.value then
            return tostring(round(scopescale / lookup.factor)) .. lookup.name
        end
    end
    return ""
end


-- returns the nearest visible showcase
function getNearestShowcase(x, y)
    local nearest = nil
    local nearestDist = 1000
    for _, item in pairs(visibleShowcases) do
        local thisDist = dist(x, y, item.x, item.y)
        if thisDist < nearestDist then
            nearest = item
            nearestDist = thisDist
        end
    end
    return nearest
end


function addShowcase(size, unit, name, image, description)
    
    local imageW, imageH = 0, 0
    
    if image then
        imageW, imageH = image:getDimensions()
    end
    
    local textWidth = infoboxWidth * 1.1
    local textLines = 0
    local textHeight = smallFont:getHeight()
    
    if description then
        _, textLines = infoFont:getWrap(description, infoboxWidth)
        textHeight = textHeight + textLines * infoFont:getHeight()
        -- padding
        textHeight = textHeight * 1.2
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
            offsetX=0,
            offsetY=0,
            clickedX=0,
            clickedY=0,
            ox=imageW / 2,
            oy=imageH / 2,
            r=#showcase % 6,
            infoX=0,
            infoY=0,
            infoW=textWidth,
            infoH=textHeight
            })
    
end

-- Limit value to a range of min and max
function clamp(min, value, max)
    return math.max(min, math.min(max, value))
end