--
-- Author: Ace
-- Date: 2014-02-21 15:37:31
--
--定时器类
local Timer = class("Timer")

function Timer:ctor()
    self._scheduler = CCDirector:sharedDirector():getScheduler()
    self._timers = {}
end

function Timer:start(callback,interval,runCount)
    local timerId
    local onTick = function(dt)
        callback(dt)
        if runCount ~= nil then
            runCount = runCount - 1;
            if runCount <= 0 then -- 达到指定运行次数,杀掉
                self:kill(timerId)
            end
        end
    end
    timerId = self._scheduler:scheduleScriptFunc(onTick, interval, false)
    self._timers[timerId] = true;
    return timerId
end

function Timer:runWithDelay(callback,delay)
	local timerId
	local ticks = 0
	local onTick = function()
		ticks = ticks + 1
		if ticks == 1 then
            callback()
            self:kill(timerId)
		end
	end
	timerId = self._scheduler:scheduleScriptFunc(onTick, delay, false)
    self._timers[timerId] = true;
    return timerId
end

function Timer:runOnce(callback)
    self:start(callback,0,1)
end

function Timer:exists(timerId)
	return self._timers[timerId]
end

function Timer:kill(timerId)
    self._scheduler:unscheduleScriptEntry(timerId)
    self._timers[timerId] = nil;
end

function Timer:killAll()
    for timerId, flag in pairs(self._timers) do
        self:kill(timerId)
    end
end

return Timer
  