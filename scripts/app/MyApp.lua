
require("config")
require("framework.init")
require("framework.shortcodes")
require("framework.cc.init")
GameState = require("framework.api.GameState")

local MyApp = class("MyApp", cc.mvc.AppBase)

function MyApp:ctor()
    MyApp.super.ctor(self)
    self.objects_ = {}
    GameData = {}
    GameState.init(handler(self, self.initGameState),"data.txt","@kd3")
    if io.exists(GameState.getGameStatePath()) then
        GameData = GameState.load()
    end
    GameData.bestScore =  GameData.bestScore or 0
    GameData.bestCell = GameData.bestCell or 0
    if device.platform == "windows" and device.language == "cn" then
        ui.DEFAULT_TTF_FONT = "Microsoft YaHei"
    end
end

function MyApp:run()
    CCFileUtils:sharedFileUtils():addSearchPath("res/")
    display.addSpriteFramesWithFile("default.plist","default.png")
    self:enterScene("MainScene")
end

function MyApp:setObject(id, object)
    assert(self.objects_[id] == nil, string.format("MyApp:setObject() - id \"%s\" already exists", id))
    self.objects_[id] = object
end

function MyApp:getObject(id)
    assert(self.objects_[id] ~= nil, string.format("MyApp:getObject() - id \"%s\" not exists", id))
    return self.objects_[id]
end

function MyApp:isObjectExists(id)
    return self.objects_[id] ~= nil
end

function MyApp:initGameState(params)
    local returnValue
    if params.errorCode then
        echo ("error")
    else
        if params.name == "save" then
            local str = json.encode(params.values)
            str = crypto.encryptXXTEA(str, "my2048")
            returnValue = {data=str}
        elseif params.name == "load" then
            local str = crypto.decryptXXTEA(params.values.data, "my2048")
            returnValue = json.decode(str)
        end
        return returnValue
    end
end

return MyApp
