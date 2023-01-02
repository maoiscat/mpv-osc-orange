-- mpv-osc-orange
-- by maoiscat
-- github/maoiscat/mpv-osc-orange

require 'elements'
local assdraw = require 'mp.assdraw'
local utils = require 'mp.utils'

-- user options
opts = {
    scale = 1,              -- osc render scale
    fixedHeight = false,    -- true to allow osc scale with window
    hideTimeout = 1,        -- seconds untile osc hides, negative means never
    fadeDuration = 0.5,     -- seconds during fade out, negative means never
    }

mp.commandv('set', 'keepaspect', 'yes')
mp.commandv('set', 'border', 'no')
mp.commandv('set', 'keepaspect-window', 'no')
setVisibility('always')
-- margins: left, right, top, bottom
local margins = {l = 1, r = 1, t = 26, b = 50}

-- logo
local ne
ne = addToIdleLayout('logo')
ne:init()

-- message
local msg = addToIdleLayout('message')
msg:init()

-- styles
styles = {
    tooltip = {
        color = {'FFFFFF', '0', '0', '0'},
        border = 1,
        blur = 2,
        fontsize = 16,
        wrap = 2,
        },
    outline = {
        color = {'171717', '0', '0', '0'},
        alpha = {0, 255, 255, 255},
        blur = 0,
        border = 0,
        },
    title = {
        color = {'222222', '0', '0', '0'},
        alpha = {0, 255, 255, 255},
        blur = 0,
        border = 0,
        },
    panel = {
        color = {'222222', '0', '0', '0'},
        alpha = {0, 255, 255, 255},
        blur = 0,
        border = 0,
        },
    orange = {
        color = {'003eff', '0', '0', '0'},
        alpha = {0, 255, 255, 255},
        blur = 0,
        border = 0,
        font = 'mpv-osd-symbols',
        fontsize = 16,
        },
    orange2 = {
        color = {'003eff', '0', '0020b0', '0'},
        alpha = {0, 255, 0, 255},
        blur = 1,
        border = 1,
        font = 'mpv-osd-symbols',
        fontsize = 16,
        },
    white = {
        color = {'ffffff', '0', '0', '0'},
        alpha = {0, 255, 255, 255},
        blur = 0,
        border = 0,
        font = 'mpv-osd-symbols',
        fontsize = 16
        },
    pale = {
        color = {'9b9b9b', '0', '0', '0'},
        alpha = {0, 255, 255, 255},
        blur = 0,
        border = 0,
        font = 'mpv-osd-symbols',
        fontsize = 16
        },		
    dark = {
        color = {'1a1519', '0', '0', '0'},
        alpha = {0, 255, 255, 255},
        blur = 0,
        border = 0,
        },
    down = {
        color = {'3c3c3c', '0', '0', '0'},
        alpha = {0, 255, 255, 255},
        blur = 0,
        border = 0,
        font = 'mpv-osd-symbols',
        fontsize = 16
        },
    down2 = {
        color = {'1b2852', '0', '0', '0'},
        alpha = {0, 255, 255, 255},
        blur = 0,
        border = 0,
        font = 'mpv-osd-symbols',
        fontsize = 16
        },
    empty = {
        alpha = {255, 255, 255, 255}
        },
    }

-- to update enviromental variables
ne = newElement('updater')
ne.layer = 1000
ne.geo = nil
ne.style = nil
ne.visible = false
ne.init = function(self)
        -- event generators
        mp.register_event('file-loaded',
            function()
                player.tracks = getTrackList()
                player.playlist = getPlaylist()
                player.chapters = getChapterList()
                player.playlistPos = getPlaylistPos()
                player.duration = mp.get_property_number('duration')
                dispatchEvent('file-loaded')
            end)
        mp.register_event('video-reconfig',
            function()
                player.videoParams = getVideoParams()
                -- dispatchEvent('video-reconfig')
            end)
        mp.observe_property('pause', 'bool',
            function(name, val)
                player.paused = val
                dispatchEvent('pause')
            end)
        mp.observe_property('fullscreen', 'bool',
            function(name, val)
                player.fullscreen = val
                dispatchEvent('fullscreen')
            end)
        mp.observe_property('current-tracks/audio/id', 'number',
            function(name, val)
                if val then player.audioTrack = val
                    else player.audioTrack = 0
                        end
                dispatchEvent('audio-changed')
            end)
        mp.observe_property('current-tracks/sub/id', 'number',
            function(name, val)
                if val then player.subTrack = val
                    else player.subTrack = 0
                        end
                dispatchEvent('sub-changed')
            end)
        mp.observe_property('loop-playlist', 'string',
            function(name, val)
                player.loopPlaylist = val
                dispatchEvent('loop-playlist')
            end)
        mp.observe_property('volume', 'number',
            function(name, val)
                player.volume = val
                dispatchEvent('volume')
            end)
        mp.observe_property('mute', 'bool',
            function(name, val)
                player.muted = val
                dispatchEvent('mute')
            end)
    end
ne.tick = function(self)
        player.percentPos = mp.get_property_number('percent-pos')
        player.timePos = mp.get_property_number('time-pos')
        player.timeRem = mp.get_property_number('time-remaining')
        dispatchEvent('time')
        return ''
    end
ne.setMargin = function(self, mr)
        mp.commandv('set', 'video-margin-ratio-left', mr.l)
        mp.commandv('set', 'video-margin-ratio-top', mr.t)
        mp.commandv('set', 'video-margin-ratio-bottom', mr.b)
        mp.commandv('set', 'osd-margin-x', margins.l+10)
        utils.shared_script_property_set("osc-margins", string.format("%f,%f,%f,%f",
            mr.l, mr.r, mr.t, mr.b))
    end
ne.responder['resize'] = function(self)
        if not player.fullscreen then
            local mr = {
                l = margins.l / player.geo.width,
                r = margins.r / player.geo.width,
                t = margins.t / player.geo.height,
                b = margins.b / player.geo.height,
                }
            self:setMargin(mr)
            setVisibility('always')
        end
        -- common vars
        player.refX = player.geo.width / 2
        player.refY1 = margins.t / 2 + 1
        player.refY2 = player.geo.height - margins.b / 2 - 1
        player.refW = player.geo.width * 2
        -- active areas
        if player.fullscreen then
            setIdleActiveArea('title', 0, 0, player.geo.width, margins.t)
            setPlayActiveArea('title', 0, 0, player.geo.width, margins.t)
        else
            setIdleActiveArea('title', player.geo.width-100, 0, player.geo.width, margins.t)
            setPlayActiveArea('title', player.geo.width-100, 0, player.geo.width, margins.t)
        end
        setIdleActiveArea('panel', 0, player.geo.height-margins.b, player.geo.width, player.geo.height)
        setPlayActiveArea('panel', 0, player.geo.height-margins.b, player.geo.width, player.geo.height)
        return false
    end
ne.responder['fullscreen'] = function(self)
        if player.fullscreen then
            local mr = {l = 0, r = 0, t = 0, b = 0}
            self:setMargin(mr)
            setVisibility('normal')
        end
        return false
    end
ne:init()
local update = ne
addToIdleLayout('updater')
addToPlayLayout('updater')

-- a shared tooltip
ne = newElement('tip', 'tooltip')
ne.layer = 50
ne.style = clone(styles.tooltip)
ne:init()
addToIdleLayout('tip')
addToPlayLayout('tip')
local tooltip = ne


-- a outline box
ne = newElement('outline')
ne.layer = 20
ne.style = clone(styles.outline)
ne.geo.x = 0
ne.geo.y = 0
ne.geo.an = 7
ne.geo.border = 1
ne.render = function(self)
        local ass = assdraw.ass_new()
        ass:draw_start()
        ass:rect_cw(0, 0, self.geo.w, self.geo.h)
        ass:rect_ccw(self.geo.border, self.geo.border, self.geo.w-self.geo.border, self.geo.h-self.geo.border)
        ass:draw_stop()
        self.pack[4] = ass.text
    end
ne.responder['resize'] = function(self)
        self.geo.w = player.geo.width
        self.geo.h = player.geo.height
        self:render()
    end
ne:init()
addToIdleLayout('outline')
addToPlayLayout('outline')

-- title bar on the top
ne = newElement('titlebar', 'box')
ne.layer = 5
ne.style = clone(styles.title)
ne.geo.y = 0
ne.geo.h = margins.t
ne.geo.an = 8
ne.responder['resize'] = function(self)
        self.geo.x = player.refX
        self.geo.w = player.refW
        self:render()
    end
ne:init()
addToIdleLayout('titlebar')
addToPlayLayout('titlebar')

-- control panel on the bottom
ne = newElement('panel', 'box')
ne.layer = 5
ne.style = clone(styles.panel)
ne.geo.h = margins.b
ne.geo.an = 2
ne.responder['resize'] = function(self)
        self.geo.y = player.geo.height
        self.geo.x = player.refX
        self.geo.w = player.refW
        self:setPos()
        self:render()
    end
ne:init()
addToIdleLayout('panel')
addToPlayLayout('panel')

-- close button on title bar
ne = newElement('winClose', 'button')
ne.layer = 10
ne.geo.w = 20
ne.geo.h = 20
ne.geo.an = 5
ne.styleNormal = clone(styles.pale)
ne.styleActive = clone(styles.white)
ne.styleDisabled = clone(styles.down)
ne.text = '\238\132\149'
ne.responder['resize'] = function(self)
        self.geo.x = player.geo.width - 20
        self.geo.y = player.refY1
        self:setPos()
        self:setHitBox()
        return false
    end
ne.responder['mbtn_left_up'] = function(self, pos)
        if self:isInside(pos) then
            mp.commandv('quit')
        end
        return false
    end
ne:init()
addToIdleLayout('winClose')
addToPlayLayout('winClose')

-- max/restore button on title bar
ne = newElement('winMax', 'winClose')
ne.responder['resize'] = function(self)
        self.geo.x = player.geo.width - 50
        self.geo.y = player.refY1
        if player.fullscreen then
            self.text = '\238\132\148'
        else
            self.text = '\238\132\147'
        end
        self:render()
        self:setPos()
        self:setHitBox()
        return false
    end
ne.responder['mbtn_left_up'] = function(self, pos)
        if self:isInside(pos) then
            mp.commandv('cycle', 'fullscreen')
            return true
        end
        return false
    end
ne:init()
addToIdleLayout('winMax')
addToPlayLayout('winMax')

-- minimize button
ne = newElement('winMin', 'winClose')
ne.text = '\238\132\146'
ne.responder['resize'] = function(self)
        self.geo.x = player.geo.width - 75
        self.geo.y = player.refY1
        self:setPos()
        self:setHitBox()
        return false
    end
ne.responder['mbtn_left_up'] = function(self, pos)
        if self:isInside(pos) then
            mp.commandv('cycle', 'window-minimized')
            return true
        end
        return false
    end
ne:init()
addToIdleLayout('winMin')
addToPlayLayout('winMin')

-- orange orb
ne = newElement('orb', 'circle')
ne.layer = 10
ne.style = clone(styles.orange2)
ne.geo.r = 6
ne.geo.x = 16
ne.geo.y = margins.t/2 + 1
ne.geo.an = 5
ne:init()
addToIdleLayout('orb')
addToPlayLayout('orb')

-- title
ne = newElement('title')
ne.layer = 10
ne.style = clone(styles.pale)
ne.geo.y = margins.t/2 + 1
ne.geo.an = 5
ne.title = 'MPV - Drop Files Here to Play'
ne.render = function(self)
        local maxchars = (player.geo.width - 120) / 8
        local text = self.title
        -- 估计1个中文字符约等于1.5个英文字符
        local charcount = (text:len() + select(2, text:gsub('[^\128-\193]', ''))*2) / 3
        if not (maxchars == nil) and (charcount > maxchars) then
            local limit = math.max(0, maxchars - 3)
            if (charcount > limit) then
                while (charcount > limit) do
                    text = text:gsub('.[\128-\191]*$', '')
                    charcount = (text:len() + select(2, text:gsub('[^\128-\193]', ''))*2) / 3
                end
                text = text .. '...'
            end
        end
        self.pack[4] = text
    end
ne.responder['resize'] = function(self)
        self.geo.x = player.refX - 30
        self:setPos()
        self:render()
    end
ne.responder['file-loaded'] = function(self)
        local title = mp.command_native({'expand-text', '${media-title}'})
        title = title:gsub('\\n', ' '):gsub('\\$', ''):gsub('{','\\{')
        self.title = title
        self:render()
        self.visible = true
        return false
    end
ne:init()
addToIdleLayout('title')
addToPlayLayout('title')

-- previous file
ne = newElement('btnPrev', 'button2')
ne.layer = 10
ne.geo.r = 16
ne.geo.x = 30
ne.name = 'btnPrev'
ne.scale = 15
ne.styleNormal = clone(styles.pale)
ne.styleActive = clone(styles.white)
ne.styleDisabled = clone(styles.down)
ne.styleCircle = clone(styles.dark)
ne.render = function(self)
        local s, w = self.scale, 2
        local w1, w2, w3 = 3, 4, 7
        local ass = assdraw.ass_new()
        ass:draw_start()
        -- rect
        ass:rect_cw(0, s*0.1, w, s*0.9)
        -- triangle1
        ass:move_to(w2, s/2)
        ass:line_to(s, 0)
        ass:line_to(s, s)
        ass:line_to(w2, s/2)
        -- triangle2
        ass:move_to(w3, s/2)
        ass:line_to(s-w, s-w1)
        ass:line_to(s-w, w1)
        ass:line_to(w3, s/2)
        ass:draw_stop()
        self.pack[4] = ass.text
    end
ne.responder['resize'] = function(self)
        self.geo.y = player.refY2
        self:setPos()
        self.circle:setPos()
    end
ne.responder['file-loaded'] = function(self)
        if not player.playlist then return false end
        if player.playlistPos <= 1 and player.loopPlaylist == 'no' then
            self:disable()
        else
            self:enable()
        end
        return false
    end
ne.responder['loop-playlist'] = ne.responder['file-loaded']
ne.responder['mbtn_left_up'] = function(self, pos)
        if self.enabled and self:isInside(pos) then
            mp.commandv('playlist-prev', 'weak')
            return true
        end
        return false
    end
ne:init()
ne:disable()
ne:addToLayout('idle')
ne:addToLayout('play')

-- play
ne = newElement('btnPlay', 'button2')
ne.layer = 10
ne.geo.r = 20
ne.geo.x = 70
ne.name = 'btnPlay'
ne.scale = 26
ne.styleNormal = clone(styles.orange)
ne.styleActive = clone(styles.orange)
ne.styleDisabled = clone(styles.down2)
ne.styleCircle = clone(styles.dark)
ne.render = function(self)
        local ass = assdraw.ass_new()
        if player.paused or player.idle then
            local s, w = self.scale, 2
            local s1, s2 = s*0.15, s*1
            local w1 = 3
            ass:draw_start()
            -- triangle 1
            ass:move_to(s1, 0)
            ass:line_to(s2, s/2)
            ass:line_to(s1, s)
            ass:line_to(s1, 0)
            -- triangle 2
            ass:move_to(s1+w, w1)
            ass:line_to(s1+w, s-w1)
            ass:line_to(s2-w1, s/2)
            ass:line_to(s1+w, w1)
        else
            local s = self.scale
            local w = 0.2*s
            local s1, w1 = 0.7*s, w
            ass:draw_start()
            ass:rect_cw(0, 0, w, s1)
            ass:rect_cw(w+w1, 0, w+w1+w, s1)
            ass:draw_stop()
        end
        self.pack[4] = ass.text
    end
ne.responder['resize'] = function(self)
        self.geo.y = player.refY2
        self:setPos()
        self.circle:setPos()
    end
ne.responder['mbtn_left_up'] = function(self, pos)
        if self.enabled and self:isInside(pos) then
            mp.commandv('cycle', 'pause')
            return true
        end
        return false
    end
ne.responder['pause'] = function(self)
        self:render()
        return false
    end
ne.responder['idle'] = function(self)
        if player.idle then
            self:disable()
        else
            self:enable()
            self:render()
        end
        return false
    end
ne:init()
ne:addToLayout('idle')
ne:addToLayout('play')

-- next file
ne = newElement('btnNext', 'button2')
ne.layer = 10
ne.geo.r = 16
ne.geo.x = 110
ne.name = 'btnNext'
ne.scale = 15
ne.styleNormal = clone(styles.pale)
ne.styleActive = clone(styles.white)
ne.styleDisabled = clone(styles.down)
ne.styleCircle = clone(styles.dark)
ne.render = function(self)
        local s, w = self.scale, 2
        local w1, w2, w3 = 3, 4, 7
        local ass = assdraw.ass_new()
        ass:draw_start()
        -- rect
        ass:rect_cw(s-w, s*0.1, s, s*0.9)
        -- triangle1
        ass:move_to(0, 0)
        ass:line_to(s-w2, s/2)
        ass:line_to(0, s)
        ass:line_to(0, 0)
        -- triangle2
        ass:move_to(w, w1)
        ass:line_to(w, s-w1)
        ass:line_to(s-w3, s/2)
        ass:line_to(w, w1)
        ass:draw_stop()
        self.pack[4] = ass.text
    end
ne.responder['resize'] = function(self)
        self.geo.y = player.refY2
        self:setPos()
        self.circle:setPos()
    end
ne.responder['file-loaded'] = function(self)
        if not player.playlist then return false end
        if player.playlistPos >= #player.playlist
            and player.loopPlaylist == 'no' then
            self:disable()
        else
            self:enable()
        end
        return false
    end
ne.responder['loop-playlist'] = ne.responder['file-loaded']
ne.responder['mbtn_left_up'] = function(self, pos)
        if self.enabled and self:isInside(pos) then
            mp.commandv('playlist-next', 'weak')
            return true
        end
        return false
    end
ne:init()
ne:disable()
ne:addToLayout('idle')
ne:addToLayout('play')

-- time display
ne = newElement('time1', 'button')
ne.layer = 10
ne.styleNormal = clone(styles.orange)
ne.styleActive = ne.styleNormal
ne.styleDisabled = clone(styles.down2)
ne.geo.w = 64
ne.geo.h = 20
ne.geo.an = 4
ne.responder['resize'] = function(self)
        self.geo.x = 140
        self.geo.y = player.refY2
        if player.geo.width < 400 then
            self.visible = false
        else
            self.visible = true
        end
        self:setPos()
    end
ne.responder['time'] = function(self)
        if player.timePos then
            self.pack[4] = mp.format_time(player.timePos)
        else
            self.pack[4] = '--:--:--'
        end
    end
ne.responder['idle'] = function(self)
        if player.idle then
            self:disable()
        else
            self:enable()
        end
        return false
    end
ne:init()
addToIdleLayout('time1')
addToPlayLayout('time1')

-- seekbar bg
ne = newElement('seekbarBg', 'box')
ne.layer = 9
ne.styleNormal = clone(styles.pale)
ne.styleDiabled = clone(styles.down)
ne.geo.r = 0
ne.geo.h = 2
ne.geo.an = 4
ne.responder['resize'] = function(self)
        self.geo.x = 218
        self.geo.y = player.refY2
        self.geo.w = player.geo.width - 218 - 288
        if self.geo.w <= 34 then
            self.visible = false
        else
            self.visible = true
        end
        self:init()
    end
ne.responder['idle'] = function(self)
        if player.idle then
            self.style = self.styleDiabled
        else
            self.style = self.styleNormal
        end
        self:setStyle()
        return false
    end
ne:init()
addToIdleLayout('seekbarBg')
addToPlayLayout('seekbarBg')

-- seekbar
ne = newElement('seekbar', 'slider')
ne.layer = 10
ne.styleNormal = clone(styles.orange)
ne.styleDisabled = clone(styles.down2)
ne.geo.an = 4
ne.geo.h = 20
ne.barHeight = 2
ne.barRadius = 0
ne.nobRadius = 8
ne.allowDrag = false
ne.lastSeek = nil
ne.responder['resize'] = function(self)
        self.geo.an = 4
        self.geo.x = 210
        self.geo.y = player.refY2
        self.geo.w = player.geo.width - 210 - 280
        if self.geo.w <= 50 then
            self.visible = false
        else
            self.visible = true
        end
        self:setParam()     -- setParam may change geo settings
        self:setPos()
        self:render()
    end
ne.responder['time'] = function(self)
        local val = player.percentPos
        if val then
            self.value = val
            self.xValue = val/100 * self.xLength
            self:render()
        end
        return false
    end
ne.responder['mouse_move'] = function(self, pos)
        if not self.enabled then return false end
        local seekTo = self:getValueAt(pos)
        if self.allowDrag then
            mp.commandv('seek', seekTo, 'absolute-percent')
        end
        if self:isInside(pos) then
            local tipText
            if player.duration then
                local seconds = seekTo/100 * player.duration
                if #player.chapters > 0 then
                    local ch = #player.chapters
                    for i, v in ipairs(player.chapters) do
                        if seconds < v.time then
                            ch = i - 1
                            break
                        end
                    end
                    if ch == 0 then
                        tipText = string.format('[0/%d][unknown]\\N%s',
                            #player.chapters, mp.format_time(seconds))
                    else
                        local title = player.chapters[ch].title
                        if not title then title = 'unknown' end
                        tipText = string.format('[%d/%d][%s]\\N%s',
                            ch, #player.chapters, title,
                            mp.format_time(seconds))
                    end
                else
                    tipText = mp.format_time(seconds)
                end
            else
                tipText = '--:--:--'
            end
            tooltip:show(tipText, {pos[1], self.geo.y+3}, self)
            return true
        else
            tooltip:hide(self)
            return false
        end
    end
ne.responder['mbtn_left_down'] = function(self, pos)
        if not self.enabled then return false end
        if self:isInside(pos) then
            self.allowDrag = true
            local seekTo = self:getValueAt(pos)
            if seekTo then
                mp.commandv('seek', seekTo, 'absolute-percent')
                return true
            end
        end
        return false
    end
ne.responder['mbtn_left_up'] = function(self, pos)
        self.allowDrag = false
        self.lastSeek = nil
    end
ne.responder['file-loaded'] = function(self)
        -- update chapter markers
        self.markers = {}
        if player.duration then
            for i, v in ipairs(player.chapters) do
                self.markers[i] = (v.time*100 / player.duration)
            end
            self:render()
        end
        ptb(self.markers)
        return false
    end
ne.responder['idle'] = function(self)
        if player.idle then
            self:disable()
        else
            self:enable()
        end
        return false
    end
ne:init()
addToIdleLayout('seekbar')
addToPlayLayout('seekbar')

-- duration
ne = newElement('time2', 'time1')
ne.styleNormal = clone(styles.pale)
ne.styleActive = ne.styleNormal
ne.styleDisabled = clone(styles.down)
ne.style = clone(styles.pale)
ne.isDuration = true
ne.responder['resize'] = function(self)
        self.geo.x = player.geo.width - 270
        self.geo.y = player.refY2
        if player.geo.width < 475 then
            self.visible = false
        else
            self.visible = true
        end
        self:setPos()
        self:setHitBox()
    end
ne.responder['time'] = function(self)
        if self.isDuration then
            val = player.duration
        else
            val = -player.timeRem
        end
        if val then
            self.pack[4] = mp.format_time(val)
        else
            self.pack[4] = '--:--:--'
        end
    end
ne.responder['mbtn_left_up'] = function(self, pos)
        if self:isInside(pos) then
            self.isDuration = not self.isDuration
            self.responder['time'](self)
            return true
        end
        return false
    end
ne:init()
addToIdleLayout('time2')
addToPlayLayout('time2')

-- audio
ne = newElement('btnAudio', 'button2')
ne.layer = 10
ne.an = 5
ne.geo.r = 16
ne.text = ''
ne.name = 'btnAudio'
ne.styleNormal = clone(styles.pale)
ne.styleNormal.fontsize = 24
ne.styleActive = clone(styles.white)
ne.styleActive.fontsize = 24
ne.styleDisabled = clone(styles.down)
ne.styleDisabled.fontsize = 24
ne.styleCircle = clone(styles.dark)
ne.responder['resize'] = function(self)
        self.geo.x = player.geo.width - 180
        self.geo.y = player.refY2
        if player.geo.width < 320 then
            self.visible = false
        else
            self.visible = true
        end
        self:setPos()
        self.circle:setPos()
    end
ne.responder['file-loaded'] = function(self)
        if #player.tracks.audio > 0 then
            self:enable()
        else
            self:disable()
        end
        return false
    end
ne.responder['mbtn_left_up'] = function(self, pos)
        if self.enabled and self:isInside(pos) then
            cycleTrack('audio')
            return true
        end
        return false
    end
ne.responder['mbtn_right_up'] = function(self, pos)
        if self.enabled and self:isInside(pos) then
            cycleTrack('audio', 'prev')
            return true
        end
        return false
    end
ne.responder['audio-changed'] = function(self)
        if player.tracks then
            local lang
            if player.audioTrack == 0 then
                lang = 'OFF'
            else
                lang = player.tracks.audio[player.audioTrack].lang
            end
            if not lang then lang = 'unknown' end
            self.tipText = string.format('[%s/%s][%s]',
            player.audioTrack, #player.tracks.audio, lang)
            tooltip:update(self.tipText, self)
        end
        return false
    end
ne.responder['mouse_move'] = function(self, pos)
        if not self.enabled then return false end
        local check = self:isInside(pos)
        if check and not self.active then
            self.active = true
            self.style = self.styleActive
            self:setStyle()
            self.circle.visible = true
            tooltip:show(self.tipText, {self.geo.x, self.geo.y-8}, self)
        elseif not check and self.active then
            self.active = false
            self.style = self.styleNormal
            self:setStyle()
            self.circle.visible = false
            tooltip:hide(self)
        end
    end
ne:init()
ne:disable()
ne:addToLayout('idle')
ne:addToLayout('play')

-- sub
ne = newElement('btnSub', 'button2')
ne.layer = 10
ne.an = 5
ne.geo.r = 16
ne.text = ''
ne.name = 'btnSub'
ne.styleNormal = clone(styles.pale)
ne.styleNormal.fontsize = 24
ne.styleActive = clone(styles.white)
ne.styleActive.fontsize = 24
ne.styleDisabled = clone(styles.down)
ne.styleDisabled.fontsize = 24
ne.styleCircle = clone(styles.dark)
ne.responder['resize'] = function(self)
        self.geo.x = player.geo.width - 150
        self.geo.y = player.refY2
        if player.geo.width < 290 then
            self.visible = false
        else
            self.visible = true
        end
        self:setPos()
        self.circle:setPos()
    end
ne.responder['file-loaded'] = function(self)
        if #player.tracks.sub > 0 then
            self:enable()
        else
            self:disable()
        end
        return false
    end
ne.responder['mbtn_left_up'] = function(self, pos)
        if self.enabled and self:isInside(pos) then
            cycleTrack('sub')
            return true
        end
        return false
    end
ne.responder['mbtn_right_up'] = function(self, pos)
        if self.enabled and self:isInside(pos) then
            cycleTrack('sub', 'prev')
            return true
        end
        return false
    end
ne.responder['sub-changed'] = function(self)
        if player.tracks then
            local title
            if player.subTrack == 0 then
                title = 'OFF'
            else
                title = player.tracks.sub[player.subTrack].title
            end
            if not title then title = 'unknown' end
            self.tipText = string.format('[%s/%s][%s]',
                player.subTrack, #player.tracks.sub, title)
                tooltip:update(self.tipText, self)
        end
        return false
    end
ne.responder['mouse_move'] = function(self, pos)
        if not self.enabled then return false end
        local check = self:isInside(pos)
        if check and not self.active then
            self.active = true
            self.style = self.styleActive
            self:setStyle()
            self.circle.visible = true
            tooltip:show(self.tipText, {self.geo.x, self.geo.y-8}, self)
        elseif not check and self.active then
            self.active = false
            self.style = self.styleNormal
            self:setStyle()
            self.circle.visible = false
            tooltip:hide(self)
        end
    end
ne:init()
ne:disable()
ne:addToLayout('idle')
ne:addToLayout('play')

-- mute
ne = newElement('btnMute', 'button2')
ne.layer = 10
ne.an = 5
ne.geo.r = 16
ne.text = ''
ne.name = 'btnMute'
ne.style1 = clone(styles.pale)
ne.style1.fontsize = 24
ne.style2 = clone(styles.orange)
ne.style2.fontsize = 24
ne.style3 = clone(styles.white)
ne.style3.fontsize = 24
ne.styleNormal = ne.style1
ne.styleActive = ne.style3
ne.styleDisabled = clone(styles.down)
ne.styleDisabled.fontsize = 24
ne.styleCircle = clone(styles.dark)
ne.responder['resize'] = function(self)
        self.geo.x = player.geo.width - 120
        self.geo.y = player.refY2
        if player.geo.width < 260 then
            self.visible = false
        else
            self.visible = true
        end
        self:setPos()
        self.circle:setPos()
    end
ne.responder['file-loaded'] = function(self)
        if #player.tracks.audio > 0 then
            self:enable()
        else
            self:disable()
        end
        return false
    end
ne.responder['mbtn_left_up'] = function(self, pos)
        if self.enabled and self:isInside(pos) then
            mp.commandv('cycle', 'mute')
            return true
        end
        return false
    end
ne.responder['mute'] = function(self)
        if player.muted then
            self.styleNormal = self.style2
            self.styleActive = self.style2
            if self.enabled then
                self.style = self.style2
            end
        else
            self.styleNormal = self.style1
            self.styleActive = self.style3
            if self.enabled then
                self.style = self.style1
            end
        end
        self:setStyle()
        return false
    end
ne:init()
ne:disable()
ne:addToLayout('idle')
ne:addToLayout('play')

-- volumebar bg
ne = newElement('volumebarBg', 'box')
ne.layer = 9
ne.styleNormal = clone(styles.pale)
ne.styleDiabled = clone(styles.down)
ne.geo.r = 0
ne.geo.h = 2
ne.geo.w = 68
ne.geo.an = 6
ne.responder['resize'] = function(self)
        self.geo.x = player.geo.width - 26
        self.geo.y = player.refY2
        if player.geo.width < 220 then
            self.visible = false
        else
            self.visible = true
        end
        self:init()
    end
ne.responder['idle'] = function(self)
        if player.idle then
            self.style = self.styleDiabled
        else
            self.style = self.styleNormal
        end
        self:setStyle()
        return false
    end
ne:init()
addToIdleLayout('volumebarBg')
addToPlayLayout('volumebarBg')

-- volumebar
ne = newElement('volumebar', 'slider')
ne.layer = 10
ne.styleNormal = clone(styles.pale)
ne.styleDisabled = clone(styles.down)
ne.geo.an = 6
ne.geo.h = 16
ne.geo.w = 80
ne.barHeight = 2
ne.barRadius = 0
ne.nobRadius = 6
ne.allowDrag = false
ne.lastSeek = nil
ne.responder['resize'] = function(self)
        self.geo.an = 6
        self.geo.x = player.geo.width - 20
        self.geo.y = player.refY2
        if player.geo.width < 220 then
            self.visible = false
        else
            self.visible = true
        end
        self:setParam()     -- setParam may change geo settings
        self:setPos()
        self:render()
    end
ne.responder['volume'] = function(self)
        local val = player.volume
        if val then
            if val > 100 then val = 100 end
            self.value = val
            self.xValue = val/100 * self.xLength
            self:render()
        end
        return false
    end
ne.responder['file-loaded'] = function(self)
        if #player.tracks.audio > 0 then
            self:enable()
        else
            self:disable()
        end
        return false
    end
ne.responder['mouse_move'] = function(self, pos)
        if not self.enabled then return false end
        local seekTo = self:getValueAt(pos)
        if self.allowDrag then
            mp.commandv('set', 'volume', seekTo)
        end
        if self:isInside(pos) then
            local tipText = math.floor(seekTo+0.5)
            tooltip:show(tipText, {pos[1], self.geo.y+5}, self)
            return true
        else
            tooltip:hide(self)
            return false
        end
    end
ne.responder['mbtn_left_down'] = function(self, pos)
        if not self.enabled then return false end
        if self:isInside(pos) then
            self.allowDrag = true
            local seekTo = self:getValueAt(pos)
            if seekTo then
                mp.commandv('set', 'volume', seekTo)
                return true
            end
        end
        return false
    end
ne.responder['mbtn_left_up'] = function(self, pos)
        self.allowDrag = false
        self.lastSeek = nil
    end
ne:init()
ne:disable()
addToIdleLayout('volumebar')
addToPlayLayout('volumebar')
