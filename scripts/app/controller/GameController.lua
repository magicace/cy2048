--
-- Author: Ace
-- Date: 2014-03-24 23:50:28
--

local GameController = class("GameController", function ()
	return display.newNode()
end)

function GameController:ctor()
    self.backCnt = 0
    self.view = require("app.views.GameView").new(handler(self,self.viewCallBack)):addTo(self):hide()
end

function GameController:startGame()
    -- self.view = require("app.views.GameView").new(handler(self,self.viewCallBack)):addTo(self)
    if not app:isObjectExists("myGameDonotNeedObj") then
        self.game = require("app.models.GameModel").new({id="myGameDonotNeedId"})
        app:setObject("myGameDonotNeedObj",self.game)
        self.view:show()
        self.view:startGame(self.game)
    else
        self.view:restart()
    end
    self.game:startGame()
end

function GameController:viewCallBack(eventId)
    if eventId == TOUCH_RESTART_EVENT then
        --self:removeChild(self.view, true)
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
    local lockSt = self.view.boardLocked
    if event == "back" then
        self.view:exitHint(true)
        self.backCnt = self.backCnt + 1
        if self.backCnt == 2 then
            self.view:exitHint(false)   
            self.game:saveGameData(not lockSt)
            -- app.exit 有问题，其中的os.exit会导致三星等机型长时间无响应。
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