-- Author: Ace
-- Date: 2014-03-03 21:03:34--
--
-- 自动项目排列 (最初设计是用于菜单的项目排列，所以下面说明中有关于菜单的说法)
-- 根据提供的项目组(Sprite集合)，将项目自动排列位置。
-- 可选参数：
-- 1.mode 模式
-- 		= 1: 自动图案背景(用backPic做背景,根据计算出来的尺寸scale9缩放)
-- 		= 2: 自动透明背景(包容所有items的透明背景，不遮挡菜单外其他消息，实质为node)
-- 		= 3: 全屏透明背景(遮挡除菜单外的所有消息，设置全屏响应，实质为node)
-- 		= 4：固定图案背景(用backPic做背景，不缩放。)
--		= 5: 固定宽度透明背景(根据fixedW参数做固定宽度的排列，项目位置可部分重叠)
-- 2.cols 列数，根据此列数和项目总数可以算出行数，进而得出整个菜单尺寸。
-- 3.spacing 选项间距(行距和列距)
-- 4.border  边距(左、右、上、下边距，只有模式1-2需要)
-- 5.scale 项目图片的总缩放系数（项目图片需要自己做scale，但是缩放的系数要传入）
-- 6.x,y 在模式1-2为菜单坐标(项目区域的中心位置)，模式3-5为第一个item的坐标
-- 7.backPic 模式1,4用的图案背景的文件名
-- 8.fixedW 模式5用的固定宽度

-- 用于项目排列的时候调用AutoItems.create(params)即可
-- 用于创建菜单，调用AutoItems.initItems(params)，原参数中的items会自动排列好位置。
-- 如果菜单需要背景，创建好的背景在params.menuBk中，位置已对准，自己加上即可。
-- 计算出来的一些参数也追加到params中，调用者可以通过回传的params获得需要的一些信息
-- 例如项目的位置信息params.pos，整体的宽度params.width,高度params.height等等。

local AutoItems = {}

function AutoItems.create(params)
	AutoItems.initItems(params)
	for k,v in ipairs(params.items) do
		params.menuBk:addChild(v)
	end
	return params.menuBk
end

function AutoItems.initItems(params)
	-- set default params
	params.x 		= params.x or display.cx
	params.y 		= params.y or display.cy
	params.mode 	= params.mode or 2
	params.cols 	= params.cols or 1
	params.spacing 	= params.spacing or 1
	params.border 	= params.border or 0
	params.scale 	= params.scale or 1
	params.rows 	= math.ceil(#params.items/params.cols)
	local size = params.items[1]:getContentSize()
	params.itemW = size.width * params.scale
	params.itemH = size.height * params.scale
	AutoItems.createMenuBack(params)
	AutoItems.posMenuItems(params)
end

function AutoItems.createMenuBack(params)
	local bk
	if params.mode == 5 and params.fixedW then
		params.width = params.fixedW
		--间距可能为负数
		if params.itemW * params.cols > params.width+ params.cols - 1 and params.cols>1 then
			params.spacing = (params.width - params.itemW * params.cols) / (params.cols - 1)
		else
			params.spacing = 1
		end
	else
		params.width  = params.cols * params.itemW + (params.cols - 1) * params.spacing + 2 * params.border
	end

    params.height = params.rows * params.itemH + (params.rows - 1) * params.spacing + 2 * params.border

	if params.mode == 1 then
		bk = display.newScale9Sprite(params.backPic, params.x, params.y, CCSize(params.width,params.height))
	elseif params.mode == 2 then
		bk = display.newNode():pos(params.x - params.width/2,params.y - params.height/2)
		-- 用node的缺点是锚点在整个项目区域的左下角。
		-- 可以在打包图片的时候加入一个很小的全透明png，不会占用图片空间。然后用下面命令创建背景
		-- bk = display.newScale9Sprite("透明png文件名", params.x, params.y, CCSize(params.width,params.height))
		-- 这样背景是一个sprite，方便addChild时对位置，其锚点在项目区域中心位置。
	elseif params.mode == 3 then
		bk = display.newNode()
		bk:setCascadeBoundingBox(CCRect(0,0,display.width,display.height))
	elseif params.mode == 4 then
		bk = display.newSprite(params.backPic)
	elseif params.mode == 5 then
		bk = display.newNode() 		--直接用ccnode,位置在默认0,0位置，方便排版。
	end

	params.menuBk = bk
end

function AutoItems.posMenuItems(params)
	local i,j = 0,0
	-- 用params.pos记录并回传计算出来的items的位置供其他需求。
	params.pos = {}
	
	for k,v in ipairs(params.items) do
		if params.mode ==1 or params.mode == 2 then
			x = params.border + (i + 0.5) * params.itemW + i * params.spacing
			y = params.height - (j + 0.5) * params.itemH  - j * params.spacing - params.border
		else
			x = params.x + i * (params.itemW + params.spacing)
			y = params.y - j * (params.itemH + params.spacing)
		end

        v:setPosition(x,y)
        params.pos[k] = {x=x,y=y}

		i = i + 1
		if (i == params.cols) then
			i = 0
			j = j+1
		end 
	end
end

return AutoItems
