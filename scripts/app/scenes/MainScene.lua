--把Lang做成全局变量,view里面要用
if device.language == "cn" then
    Lang = require("app.data.lang_cn")
else
    Lang = require("app.data.lang_en")
end

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

function MainScene:ctor()
    -- self.backCnt = 0
    self.bg = display.newColorLayer(ccc4(240,228,210,255)):addTo(self):hide()
    self.gameCtrl = require("app.controller.GameController").new():addTo(self)
    local spt = display.newSprite("#2048.png")
    self.logoSpt = spt
    spt:addTo(self):pos(display.cx,display.cy)
    spt:runAction(transition.sequence({
        CCScaleTo:create(0.8,1.5),
        CCScaleTo:create(0.7,1.0),
        CCCallFunc:create(handler(self, self.startGame))
    }))
    self:performWithDelay(function ()
        spt:rotateBy(0.8,360)
    end, 0.8)
 
end

function MainScene:startGame()
    self.logoSpt:fadeOut(0.3)
    self.bg:show()
    self.gameCtrl:startGame()
    self:performWithDelay(function ()
        self.logoSpt:removeSelf()
    end, 0.5)
end

function MainScene:onEnter()
    if device.platform == "android" then 
        -- avoid unmeant back
        self:performWithDelay(function()
            -- keypad layer, for android
            local layer = display.newLayer()
            layer:addKeypadEventListener(handler(self.gameCtrl, self.gameCtrl.onExitTouched))
            self:addChild(layer)
            layer:setKeypadEnabled(true)
        end, 0.5)
    end
end

function MainScene:onExit()
end

return MainScene
