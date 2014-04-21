--
-- Author: Ace
-- Date: 2014-03-23 22:04:56
--
local GameModel = class("GameModel",cc.mvc.ModelBase)

GameModel.FLASH_EVENT	= "FLASH_EVENT"
GameModel.WIN_EVENT		= "WIN_EVENT"
GameModel.LOST_EVENT	= "LOST_EVENT"
GameModel.MOVE_EVENT	= "MOVE_EVENT"
GameModel.MERGE_EVENT	= "MERGE_EVENT"
GameModel.NOMOVE_EVENT	= "NOMOVE_EVENT"

function GameModel:ctor(properties)
	self.bestScore = 0
end

--重新开始游戏要刷新的数据放这里，不刷新的放在ctor中。
function GameModel:startGame()
	self.currId = 0
	self.currScore = 0
	-- 生成模型表，注意tag是坐标绑定的，永远不变
	-- 这样无论矩阵怎么旋转，对应的目标tag不变。
	self.map = {
		{{v=0,tag=1},{v=0,tag=2},{v=0,tag=3},{v=0,tag=4}},
		{{v=0,tag=5},{v=0,tag=6},{v=0,tag=7},{v=0,tag=8}},
		{{v=0,tag=9},{v=0,tag=10},{v=0,tag=11},{v=0,tag=12}},
		{{v=0,tag=13},{v=0,tag=14},{v=0,tag=15},{v=0,tag=16}}
	}

	self.update = false

	self:flash()
	self:flash()
end

-- 生成id：用于给每个cell一个唯一的id，tag只能用于定位，
-- 由于move、merge和动画延迟执行等原因，getChildByTag是不可靠的。
function GameModel:getId()
	self.currId = self.currId + 1
	--用文本型id方便view采用hash表存储
	return "id"..tostring(self.currId)
end

--创建空位表，用于随机抽取新的cell的位置。
function GameModel:createEmptyPosTable()
	local t = {}
	for i=1,4 do
		for j=1,4 do
			if self.map[i][j].v == 0 then
				table.insert(t,self.map[i][j].tag)
			end
		end
	end
	return t
end

function GameModel:creatNewCell()
	--创建当前空位表
	self.empty = self:createEmptyPosTable()
	--随机在空位表中找个位置
	local idx = math.random(#self.empty)
	local tag = table.remove(self.empty,idx)
	--生成新的数值
	local num = math.random(8)
	num =  num < 8 and 2 or 4  -- 1/8的概率为4
	--获得id
	local id = self:getId()
	return  {id=id,tag=tag,num=num}
end

-- 刷新，增加cell。初始放2个cell时running=false
-- 游戏开始后，running= true，开始记录等
function GameModel:flash(running)
	self.cell = self:creatNewCell()

	if 	self.currScore > self.bestScore then
		self.bestScore = self.currScore
	end
	--分发事件，通知view显示新的cell
	self:dispatchEvent({
		name = GameModel.FLASH_EVENT,
		id = self.cell.id,
		tag = self.cell.tag,
		num = self.cell.num,
		curr=self.currScore,init=not running
	})

	--同步维护self.map表
	self:fillMap()

	--检查失败条件
	self:checkLost()
end

-- 将flash生成的id、num按tag的位置填入self.map表
function GameModel:fillMap()
	local tag = self.cell.tag
	local row = math.floor((tag - 1)/4) + 1
	local col = math.mod(tag - 1, 4) + 1
	self.map[row][col].v = self.cell.num
	self.map[row][col].id = self.cell.id
end

--检查失败条件
function GameModel:checkLost()
	if #self.empty > 0 then return end
	for i = 1,4 do
		for j = 1,4 do
			if j<4 and self.map[i][j].v == self.map[i][j+1].v
			or i<4 and self.map[i][j].v == self.map[i+1][j].v then
				return
			end
		end
	end
	self:dispatchEvent({name=GameModel.LOST_EVENT})
end

-- 矩阵变换，用于上移，行列互换
function GameModel:upMap(srcMap)
	local map = {}
	for i=1,4 do
		map[i] = {}
		for j=1,4 do
			map[i][j] = srcMap[j][i]
		end
	end
	return map
end

-- 矩阵变换，用于右移，左右互换(水平镜像)
function GameModel:rightMap(srcMap)
	local map = {}
	for i=1,4 do
		map[i] = {}
		for j=1,4 do
			map[i][j] = srcMap[i][5-j]
		end
	end
	return map
end

-- 矩阵变换，用于下移，旋转180度(中心对称)
function GameModel:downMap(srcMap)
	local map = {}
	for i=1,4 do
		map[i] = {}
		for j=1,4 do
			map[i][j] = srcMap[5-j][5-i]
		end
	end
	return map
end

-- 响应View中玩家的移动事件
function GameModel:move(eventId)
	--由self.map变换成对应map
	local map =	eventId == TOUCH_MOVED_UP and self:upMap(self.map)
		or eventId == TOUCH_MOVED_DOWN and self:downMap(self.map)
		or eventId == TOUCH_MOVED_RIGHT and self:rightMap(self.map)
		or self.map

	self.update = false --开始一次新的move前设置，用于检查是否有移动或合并
	for i=1,4 do
		--单行合并，左移算法。所以其他移动方向要变换矩阵。
		self:lineMerge(map[i])
	end

	--再把map变换回来,存储到self.map
	self.map =	eventId == TOUCH_MOVED_UP and self:upMap(map)
		or eventId == TOUCH_MOVED_DOWN and self:downMap(map)
		or eventId == TOUCH_MOVED_RIGHT and self:rightMap(map)
		or map

	if self.isWin then
		-- 分发win事件，显示相应动画
		self:dispatchEvent({
			name=GameModel.WIN_EVENT,
			id = self.winId, num=self.winNum
		})
		self.isWin = false
	end

	if self.update then
		self:flash(true)
	else
		-- 分发nomove事件，显示不能移动信息
		self:dispatchEvent({name = GameModel.NOMOVE_EVENT})
	end
end

-- 表内移动算法，dis为移动的距离(格子数)，用于控制View中动画时间。
function  GameModel:moveInMap(des,src,dis)
	self.moveEventParams = {
		name=GameModel.MOVE_EVENT,
		srcId=src.id,desTag=des.tag,dis=dis
	}
	des.v = src.v
	des.id = src.id
	src.v = 0
	src.id = nil
end
  
-- 表内合并算法  
function GameModel:mergeInMap(des,src)
	des.v = des.v * 2
	des.hot = true  --设置热点，防止在同一次移动中被两次merge

	self.currScore = self.currScore + des.v
	self.mergeEventParams = {
		name=GameModel.MERGE_EVENT,
		src=src.id,des=des.id,num=des.v,dis=1
	}
	if self.moveEventParams then --如果有move事件，则合并两个事件
		self.mergeEventParams.dis = self.moveEventParams.dis + 1
		self.moveEventParams = nil
	end

	src.v = 0
	src.id = nil

	if des.v >= 2048 then --2048,4096,8192均触发胜利条件
		self.isWin = true
		self.winId = des.id
		self.winNum = des.v
	end
end

--单行移动、合并的算法
function GameModel:lineMerge(arr)
	for cur =2,4 do
		if arr[cur].v ~=0 then
			--从第一个位置开始找当前位置左边的首个空位,并移动过去
			local k = 1
			while k < cur do
				if arr[k].v == 0 then
					self:moveInMap(arr[k],arr[cur],cur-k)
					break
				end
				k=k+1
			end
			--看是否能和左边位置的单元合并
			if k > 1 and arr[k].v == arr[k-1].v and not arr[k-1].hot then
				self:mergeInMap(arr[k-1], arr[k])
			end

			if self.mergeEventParams then
				-- 分发事件，显示移动+合并动画
				self:dispatchEvent(self.mergeEventParams)
				self.update = true
				self.mergeEventParams = nil
			elseif self.moveEventParams then
				-- 分发事件，显示移动动画
				self:dispatchEvent(self.moveEventParams)
				self.update = true
				self.moveEventParams = nil
			end
		end
	end
	--清除热点
	for i=1,4 do
		arr[i].hot = nil
	end
end

return GameModel
 