--
-- Author: Ace
-- Date: 2014-02-21 18:12:06
--[[
    TouchNode类（触摸Node类）说明：
    作为一个生成node触摸管理的类，维护一个名为eventNodeList的列表。
    凡需触摸事件的子节点，在创建子节点时,将节点node以及回调函数"前插入"列表即可。
    如果作为基类，继承类初始化时将自身作为一个ROOT（tag=0）节点用addListener加入列表;
    或者用局部函数作为listener传入。因为类初始化时不能用self定义。
    如果是正常创建，可以在创建时就将listener作为参数传入，在此类初始化时建立ROOT。
    
    优先级：最后创建的节点优先级别最高，响应事件后不再下传后续节点。
    可很简单地改为按zorder排优先级，目前暂无需求。

    如果一个根sprite包含多个子sprite，显示区域根sprite包容所有子sprite,一定先把根sprite最先加入。
    否则根节点优先响应，其他子节点就没有响应的机会了。如按zorder排优先级则可任意顺序。

    --返回事件ID (eventId)
	点击 = TOUCH_CLICKED
    双击 = TOUCH_DOUBLE_CLICKED
	长按 = TOUCH_PRESSED
    左移 = TOUCH_MOVED_LEFT
    右移 = TOUCH_MOVED_RIGHT
    上移 = TOUCH_MOVED_UP
    下移 = TOUCH_MOVED_DOWN

    调用格式：TouchNode.new(node,[listener])
    回调函数格式：listener(eventId,eventTag,eventObj) 
]]
--
local TouchNode = class("TouchNode",function(node)
    return node
end)

function TouchNode:ctor(_,listener)
    self.timer = require("app.utils.Timer").new()
    self:setTouchEnabled(true)
    self:addTouchEventListener(handler(self,self.onTouch_))    
    self.eventNodeList = {}
    if listener then
        self:addListener(self, listener, 0)
    end
end

function TouchNode:addListener(node,listener,tag)
    local newEventNode = {
        node = node,
        listener = listener,
        tag = tag
    }
    table.insert(self.eventNodeList,1,newEventNode)   --前插
end

function TouchNode:removeListener(node)
    local idx
    for k,v in ipairs(self.eventNodeList) do
        if v.node == node then
            idx = k
            break
        end
    end
 
    if idx then
        table.remove(self.eventNodeList,idx)
    end
    --清除当前为标记双击选定的activeNode。
    -- 严格的做法应检查是否有activeNode并比较.node是否等于此node,但无必要。
    self.activeNode = nil
end

function TouchNode:inEventNode(point)
    for k,v in ipairs(self.eventNodeList) do
        if v.node:getCascadeBoundingBox():containsPoint(point) then
            return v
        end
    end
    return nil
end

function TouchNode:changeActiveNode(curNode)
    --注意：当前激活node仅由"began"事件获取，除非另外一次点击began，否则不会改变。
    --移动到另外一个事件node上并不会改变当前事件node。
    --长按计时也以此开始，只要不放手，最后不管移动到任何地方都不影响长按事件。
    self.doubleClk = false
    if self.activeNode then
        if self.activeNode == curNode then
            -- 设置双击事件标记
            self.doubleClk = true          
        -- else
        --     self.activeNode.node:setColor(display.COLOR_WHITE)
        end
    end

    self.activeNode = curNode
    -- curNode.node:setColor(ccc3(255,192,128))
    --定义长按事件
    local callback = function()
        curNode.listener(TOUCH_PRESSED,curNode.tag,curNode.node)   
    end
    --长按事件定时器开启
    self.timerId = self.timer:runWithDelay(callback,1)
    --设移动事件初始状态
    self.preX,self.preY = nil,nil
    --设置移动事件处理标记
    self.isMoved = false
 end

function TouchNode:inEvent()
    return self.isMoved or not(self.timer:exists(self.timerId))
end

function TouchNode:onMoved_(x,y)
    local xOffset = x - self.preX
    local yOffset = y - self.preY
    local distance = math.sqrt(xOffset*xOffset + yOffset*yOffset)
    local event
    if distance < 40 then
        event = 0  --防手滑
    else
        if math.abs(xOffset) >= math.abs(yOffset) then
            if xOffset > 0 then
                event = TOUCH_MOVED_RIGHT
            else
                event = TOUCH_MOVED_LEFT
            end
        else
            if yOffset > 0 then
                event = TOUCH_MOVED_UP
            else
                event = TOUCH_MOVED_DOWN
            end
        end
    end
    return event
end

function TouchNode:onTouch_(event,x,y)
    local point = CCPoint(x,y)
    local curNode = self:inEventNode(point)
 
    --能产生began事件，一定是touch到范围内的，curNode不会为nil
	if event == "began" then   
        self:changeActiveNode(curNode)
		return true -- catch touch event, stop event dispatching
	end

    if event == "moved" then
        --如果在touch范围内并且当前尚未激活移动事件
    	if curNode and not(self:inEvent()) then
            if not self.preX then
                self.preX = x
                self.preY = y
            end
      		local movedEvent = self:onMoved_(x,y)
            if movedEvent > 0 then
                --关闭长按事件
    			self.timer:kill(self.timerId)
                --设置移动事件处理标记
    			self.isMoved = true
                --开启移动事件
                self.activeNode.listener(movedEvent,curNode.tag,curNode.node)
    		end
        else           
            --当前正在事件中，或者出界(超出整个sprite，不在当前任意节点范围)
            --暂不做处理
    	end
    elseif event == "ended" then
        -- self.activeNode.node:setColor(ccc3(255,255,255))

        if self:inEvent() then
            -- 取消活动node(中止双击统计)
            self.activeNode = nil
        else
            --中止延时任务计时
            self.timer:kill(self.timerId)
            --结束时依然在范围内
            if curNode then
                if self.doubleClk then
                    self.activeNode.listener(TOUCH_DOUBLE_CLICKED,curNode.tag,curNode.node)
                    self.activeNode = nil
                else
                    self.activeNode.listener(TOUCH_CLICKED,curNode.tag,curNode.node)
                end
            end
        end
    end
end

-- 怀疑框架在removeChild的时候不能自动删除Listener
-- 所以在remove一个TouchNode前建议手动运行release来释放。
function TouchNode:release()
    self:removeTouchEventListener()
    self:setTouchEnabled(false)
    self.timer = nil
end

return TouchNode