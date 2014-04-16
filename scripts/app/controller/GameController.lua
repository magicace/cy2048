--
-- Author: Ace
-- Date: 2014-03-24 23:50:28
--

local GameController = class("GameController", function ()
	return display.newNode()
end)

function GameController:ctor()
    self.backCnt = 0
    self.view = require("app.views.GameView").new(handler(self,self.callViewEvent)):addTo(self)
end

function GameController:startGame()
    if not app:isObjectExists("myGameDonotNeedObj") then
        self.game = require("app.models.GameModel").new({id="myGameDonotNeedId"})
        app:setObject("myGameDonotNeedObj",self.game)
    end

    self.view:startGame(self.game)
    self.game:startGame()
end

function GameController:callViewEvent(eventId)
    if eventId == TOUCH_RESTART_EVENT then
        self:removeChild(self.view, true)
        self.view = require("app.views.GameView").new(handler(self,self.callViewEvent)):addTo(self)
        -- 开始新游戏时，先清除游戏进度
        self.game:saveGameData()
        self:startGame()
    elseif eventId == TOUCH_UNDO_EVENT then
        self.game:undo()
    elseif eventId == TOUCH_EXIT_EVENT then
        self:onExitTouched("back")
    end
end

function GameController:onExitTouched(event)
    local lockSt
    if event == "back" then
        lockSt = self.view:exitHint(true)
        self.backCnt = self.backCnt + 1
        if self.backCnt == 2 then
            self.view:exitHint(false)   
            self.game:saveGameData(not lockSt)
            -- app.exit()
            CCDirector:sharedDirector():endToLua()
        else
            self:performWithDelay(function ()
                self.backCnt = 0
                self.view:exitHint(false)
            end, 1.5)
        end
    end
end

return GameController