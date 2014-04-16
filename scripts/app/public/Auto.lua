--
-- Author: Ace
-- Date: 2014-03-10 05:12:43
--
-- 用于对图片(Sprite)进行预处理，包括加边框，加背景，调尺寸等

local Auto = {}

-- --重设背景尺寸，保证横向满屏，纵向不管。
-- function Auto.rescaleSceneBack(spt)
-- 	local size = spt:getContentSize()
-- 	local scaleX = display.width / size.width
-- 	if scaleX ~= 1 then spt:setScale(scaleX) end
-- 	return spt
-- end

--将图片缩放到指定尺寸
function Auto.rescale(spt,size)
	local sptSize = spt:getContentSize()
	local scaleX = size.width / sptSize.width
	local scaleY = size.height / sptSize.height
	if scaleX ~= 1 then spt:setScaleX(scaleX) end
	if scaleY ~= 1 then spt:setScaleY(scaleY) end
	return spt
end

--加边框(默认为绿色双线框)
function Auto.addBox(spt,boxName,border)
	boxName = boxName or "#vFrame.png"
	local size = spt:getContentSize()
	local x,y = size.width/2,size.height/2
	if border then
		size = CCSize(size.width+border,size.height+border)
	end

	local box = display.newScale9Sprite(boxName,0, 0, size)
	spt:pos(size.width/2,size.height/2):addTo(box,-1)
	return box
end

-- 加背景
function Auto.addBack(spt,color,opacity,isComb)
	local size = spt:getContentSize()
	local bk = display.newScale9Sprite("#whiteback.png", size.width/2, size.height/2, size)
	if color then bk:setColor(color) end
	if opacity then bk:setOpacity(opacity) end
	if isComb then
		-- 调用combSprite类来包装两个sprite，可以分别设置颜色
		spt = require("api.utils.CombSprite").new(bk,spt)
	else
		spt:addChild(bk,-10,-10)
	end
	return spt
end

-- 加透明度背景
function Auto.addOpacityBack(spt,opcity,color)
	opcity = opcity or 192
	color = color or ccc3(0,0,0)
	return Auto.addBack(spt,color,opcity)
end

-- -- 加透明度背景组合
-- function Auto.addOpacityComb(spt,opcity,color)
-- 	opcity = opcity or 192
-- 	return Auto.addBack(spt,color,opcity,true)
-- end

-- 加遮罩,默认半透明、隐藏，返回遮罩
function Auto.addMask(spt,color,opacity,zorder,maskSpt)
	-- body
	color = color or ccc3(128,128,128)
	opacity = opacity or 128
	zorder = zorder or 1000
	local size = spt:getContentSize()
	local mask = maskSpt or Auto.rescale(display.newSprite("#whiteback.png"),size)
	mask:setColor(color)
	mask:pos(size.width/2,size.height/2):opacity(opacity):addTo(spt,zorder):hide()
	return mask
end

-- 创建ttf文字按钮的Sprite (再加上TouchNode就是按钮)
-- 必要参数：文字内容或者Sprite。
		-- 如果是string，用CCLabelTTF创建文字标签。
		-- 如果是Sprite，直接使用。(用于其他图案或直排文字做按钮)
-- 可选参数：
		-- 文字尺寸：默认32
		-- 文字颜色：默认白色
		-- 边框尺寸：默认自动调整为文字TTF大小
		-- 边框文件名：默认使用vFrame.png (绿色双线框)
		-- 背景透明度：默认192
		-- 背景颜色：默认黑色ccc3(0,0,0)
function Auto.ttfButton(str,size,color,boxSize,boxName,opcity,bkColor)
	--创建按钮文字Sprite
	local label
	if type(str) == "string" then
		size = size or 32 --这个size是字体大小
	 	label = CCLabelTTF:create(str,ui.DEFAULT_TTF_FONT,size)
		CCNodeExtend.extend(label)
		if color then label:setColor(color) end
	elseif type(str) == "userdata" then
		label = str
	else
		--print ("need string or sprite")
		return display.newNode()
	end

	--创建按钮边框
	boxName = boxName or "#vFrame.png"
	local box
	if boxSize then
		--如果指定了边框尺寸，按此尺寸生成边框和背景
		box = display.newScale9Sprite(boxName,0,0,boxSize)
		local size = box:getContentSize()  --前面size用完了，这里借名用
		label:pos(size.width/2,size.height/2):addTo(box)
	else
	 	box = Auto.addBox(label,boxName,10) --加10点边距
	end

	--加上半透明背景
	return Auto.addOpacityBack(box,opcity,bkColor)
end

-- 竖排文字标签
-- function Auto.verticalLabel(str,size,color,spacing)
-- 	--注意这里str里面的文字只适用于utf-8中文字，不能包含符号、英文字符或其他编码汉字。
-- 	size = size or 24
-- 	local len = string.len(str)
-- 	local items = {}
-- 	for i=1,math.floor(len/3) do
-- 		local s = string.sub(str, i*3-2, i*3)
-- 		local label = CCLabelTTF:create(s,ui.DEFAULT_TTF_FONT,size)
-- 		CCNodeExtend.extend(label)
-- 		if color then label:setColor(color) end
-- 		items[i] = label
-- 	end
-- 	local params = {
-- 		items = items,
-- 		mode = 2,
-- 		spacing = spacing or 0
-- 	}
-- 	return require("app.public.AutoItems").create(params)
-- end

-- -- atlas类型文字标签
-- function Auto.newAtlasLabel(str,x,y,color)
-- 	color = color or ccc3(255,255,0)
-- 	label = CCLabelAtlas:create(str,"digit.png",12,24,47)
-- 	--对比ttf数字的效果：
-- 	--label = CCLabelTTF:create(str,ui.DEFAULT_TTF_FONT,24)
-- 	label:setColor(color)
-- 	if x and y then
-- 		label:setPosition(x,y)
-- 	end
-- 	return label
-- end
  
return Auto