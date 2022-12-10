-- mpv osc element templetes
-- by maoiscat
-- github/maoiscat

require 'extra'
local assdraw = require 'mp.assdraw'

-- # element templates
-- logo
-- shows a logo in the center
local ne = newElement('logo')
ne.init = function(self)
        self.geo.x = player.geo.width / 2
        self.geo.y = player.geo.height / 2
        local ass = assdraw.ass_new()    
        ass:new_event()
        ass:pos(self.geo.x, self.geo.y)
        ass:append('{\\1c&H8E348D&\\3c&H0&\\3a&H60&\\blur1\\bord0.5}')
        ass:draw_start()
        assDrawCirCW(ass, 0, 0, 100)
        ass:draw_stop()

        ass:new_event()
        ass:pos(self.geo.x, self.geo.y)
        ass:append('{\\1c&H632462&\\bord0}')
        ass:draw_start()
        assDrawCirCW(ass, 6, -6, 75)
        ass:draw_stop()

        ass:new_event()
        ass:pos(self.geo.x, self.geo.y)
        ass:append('{\\1c&HFFFFFF&\\bord0}')
        ass:draw_start()
        assDrawCirCW(ass, -4, 4, 50)
        ass:draw_stop()

        ass:new_event()
        ass:pos(self.geo.x, self.geo.y)
        ass:append('{\\1c&H632462&\\bord0&}')
        ass:draw_start()
        ass:move_to(-20, -20)
        ass:line_to(23.3, 5)
        ass:line_to(-20, 35)
        ass:draw_stop()
        
        self.pack[4] = ass.text
    end
ne.responder['resize'] = function(self)
        self:init()
    end

-- msg
-- display a message in the screen
ne = newElement('message')
ne.geo.x = 40
ne.geo.y = 20
ne.geo.an = 7
ne.layer = 1000
ne.visible = false
ne.text = ''
ne.startTime = 0
ne.duration = 0
ne.style.color = {'ffffff', '0', '0', '333333'}
ne.style.border = 1
ne.style.shadow = 1
ne.render = function(self)    
        self.pack[4] = self.text
    end
ne.tick = function(self)
        if not self.visible then return '' end
        if player.now-self.startTime >= self.duration then
            self.visible = false
        end
        return table.concat(self.pack)
    end
ne.display = function(self, text, duration)
        if not duration then duration = 1 end
        self.duration = duration
        -- text too long may be slow
        text = string.sub(text, 0, 2000)
        text = string.gsub(text, '\\', '\\\\')
        self.text = text
        self:render()
        self.startTime = player.now
        self.visible = true
    end

-- box
-- draw a simple box, usually used as backgrounds
ne = newElement('box')
ne.render = function(self)
        local ass = assdraw.ass_new()
        ass:new_event()
        ass:draw_start()
        assDrawRectCW(ass, 0, 0, self.geo.w, self.geo.h)
        ass:draw_stop()
        self.pack[4] = ass.text
    end
-- circle
-- draw a simple circle
ne = newElement('circle')
ne.geo.r = 1        -- radius
ne.render = function(self)
        local ass = assdraw.ass_new()
        local r, d = self.geo.r, 2*self.geo.r
        ass:draw_start()
        ass:round_rect_cw(0, 0, d, d, r)
        ass:draw_stop()
        self.pack[4] = ass.text
    end

-- button
-- display some content, also respond to mouse button
ne = newElement('button')
ne.enabled = true
ne.text = ''
ne.styleNormal = nil
ne.styleActive = nil
ne.styleDisabled = nil
-- responder active area, left top right bottom
ne.hitBox = {x1 = 0, y1 = 0, x2 = 0, y2 = 0}
ne.init = function(self)
        self:setPos()
        self:enable()
        self:render()
        self:setHitBox()
    end
ne.render = function(self)
        self.pack[4] = self.text
    end
ne.enable = function(self)
        self.enabled = true
        self.style = self.styleNormal
        self:setStyle()
    end
ne.disable = function(self)
        self.enabled = false
        self.style = self.styleDisabled
        self:setStyle()
    end
ne.setHitBox = function(self)
        local x1, y1, x2, y2 = getBoxPos(self.geo)
        self.hitBox = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
    end
-- check if mouse event happens inside hitbox
ne.isInside = isInside
ne.responder['mouse_move'] = function(self, pos)
        if not self.enabled then return false end
        local check = self:isInside(pos)
        if check and not self.active then
            self.active = true
            self.style = self.styleActive
            self:setStyle()
        elseif not check and self.active then
            self.active = false
            self.style = self.styleNormal
            self:setStyle()
        end
    end
ne.responder['mouse_leave'] = function(self)
        if self.active then
            self.active = false
            self.style = self.styleNormal
            self:setStyle()
        end
    end

-- button2
-- button with circle background
ne = newElement('button2')
ne.geo = {x = 0, y = 0, r = 0, an = 5}  -- do not change an
ne.enabled = true
ne.text = ''
ne.scale = 1    -- draw scale
ne.styleNormal = nil
ne.styleActive = nil
ne.styleDisabled = nil
ne.styleCircle = nil
ne.name = ''
ne.init = function(self)
        self:setPos()
        self:enable()
        self:render()
        self.name2 = self.name .. '_bg'
        local bg = newElement(self.name .. '_bg', 'circle')
        bg.layer = self.layer - 1
        bg.geo = self.geo
        bg.visible = false
        bg.style = self.styleCircle
        bg:init()
        self.circle = bg
    end
ne.addToLayout = function(self, layout)
        addToLayout(layout, self.name)
        addToLayout(layout, self.name2)
    end
ne.render = function(self)
        self.pack[4] = self.text
    end
ne.enable = function(self)
        self.enabled = true
        self.style = self.styleNormal
        self:setStyle()
    end
ne.disable = function(self)
        self.enabled = false
        self.active = false
        self.style = self.styleDisabled
        self:setStyle()
        self.circle.visible = false
    end
-- check if mouse event happens inside hitCircle
ne.isInside = function(self, pos)
        local x, y = pos[1], pos[2]
        if (self.geo.x-x)^2 + (self.geo.y-y)^2 <= self.geo.r^2 then
            return true
        else
            return false
        end
    end
ne.responder['mouse_move'] = function(self, pos)
        if not self.enabled then return false end
        local check = self:isInside(pos)
        if check and not self.active then
            self.active = true
            self.style = self.styleActive
            self:setStyle()
            self.circle.visible = true
        elseif not check and self.active then
            self.active = false
            self.style = self.styleNormal
            self:setStyle()
            self.circle.visible = false
        end
    end
ne.responder['mouse_leave'] = function(self)
        if self.active then
            self.active = false
            self.style = self.styleNormal
            self:setStyle()
            self.circle.visible = false
        end
    end

-- tooltip
ne = newElement('tooltip')
ne.visible = false
-- key is optional
-- pos is in '{x, y}' format
ne.show = function(self, text, pos, key)
        self.geo.x = pos[1]
        self.geo.y = pos[2] - 6
        self.pack[4] = text
        self.key = key
        if self.geo.x < player.geo.width*0.03 then
            self.geo.an = 1
            self.geo.x = self.geo.x
        elseif self.geo.x > player.geo.width*0.97 then
            self.geo.an = 3
            self.geo.x = self.geo.x
        else
            self.geo.an = 2
        end
        if self.geo.y < player.geo.height * 0.05 then
            self.geo.an = self.geo.an + 6
            self.geo.y = self.geo.y + 12
        end
        self:setPos()
        self.visible = true
    end
-- update tooltip content regardless of visible status if key matches
ne.update = function(self, text, key)
        if self.key == key then
            self.pack[4] = text
            return true
        end
        return false
    end
-- only hides when key matches, maybe useful for shared tooltip
-- return true if key match
ne.hide = function(self, key)
        if self.key == key then
            self.visible = false
            return true
        end
        return false
    end
ne.responder['mouse_leave'] = function(self)
        self.visible = false
    end
    
-- slider
ne = newElement('slider')
ne.barHeight = 0
ne.barRadius = 0
ne.nobRadius = 0
ne.geo.gap = 0
ne.geo.bar = {x1 = 0, y1 = 0, x2 = 0, y2 = 0, r = 0} -- relative pos
ne.geo.nob = {x = 0, y = 0, r = 0}  -- will be flushed by setParam
ne.value = 0        -- 0~100
ne.xMin = 0
ne.xMax = 0         -- min/max x pos
ne.xLength = 0      -- xMax - xMin
ne.xValue = 0       -- value/100 * xLength
ne.style.color1 = {}   -- color1 for enabled
ne.style.color2 = {}   -- color2 for disabled
ne.enabled = true
ne.hitBox = {}
ne.markers = {}
-- get corresponding slider value at a position
ne.getValueAt = function(self, pos)
        local x = pos[1]
        local val = (x - self.xMin)*100 / self.xLength
        if val < 0 then val = 0
            elseif val > 100 then val = 100 end
        return val
    end
ne.setParam = function(self)
        local x1, y1, x2, y2 = getBoxPos(self.geo)
        local bar, nob = self.geo.bar, self.geo.nob
        self.hitBox = {x1 = x1, y1 = y1, x2 = x2, y2 = y2}
        
        self.geo.x = x1
        self.geo.y = y1
        self.geo.an = 7       -- help drawing
        
        local gap = math.max(self.barRadius, self.nobRadius)
        self.xMin = x1 + gap
        self.xMax = x2 - gap
        self.xLength = self.xMax - self.xMin
        self.xValue = self.value/100 * self.xLength
        
        bar.r = self.barRadius
        bar.x1 = gap - bar.r
        bar.y1 = (self.geo.h - self.barHeight) / 2
        bar.x2 = bar.x1 + self.xValue + 2*bar.r
        bar.y2 = bar.y1 + self.barHeight
        
        nob.x = gap + self.xValue
        nob.y = self.geo.h / 2
        nob.r = self.nobRadius
        
        self.geo.gap = gap
    end
ne.init = function(self)
        self:setParam()
        self:setPos()
        self:enable()
        self:render()
    end
ne.render = function(self)
        local bar, nob = self.geo.bar, self.geo.nob
        bar.x2 = bar.x1 + self.xValue + 2*self.barRadius
        nob.x = self.geo.gap + self.xValue
        local ass = assdraw.ass_new()
        ass:new_event()
        ass:draw_start()
        -- bar
        assDrawRectCW(ass, bar.x1, bar.y1, bar.x2, bar.y2, bar.r)
        -- nob
        assDrawCirCW(ass, nob.x, nob.y, nob.r)
        -- markers
        for i, v in ipairs(self.markers) do
            local x = v/100 * self.xLength + self.geo.gap
            local r = self.barHeight + 2
            local y = (self.geo.bar.y1 + self.geo.bar.y2) / 2
            ass:round_rect_cw(x-r, y-r, x+r, y+r, r)
        end
        ass:draw_stop()
        self.pack[4] = ass.text
    end
ne.enable = function(self)
        self.enabled = true
        self.style = self.styleNormal
        self:setStyle()
    end
ne.disable = function(self)
        self.enabled = false
        self.style= self.styleDisabled
        self:setStyle()
    end
ne.isInside = isInside