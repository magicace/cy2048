--
-- Author: Ace
-- Date: 2014-03-29 02:08:45
--
local Language = {}

Language.info = {
	start 	= " 欢迎来到水晶2048的世界 ",
	guide 	= " 手指触摸屏幕并向你希望的方向滑动 ",
	clicked = " 需要在屏幕上滑动... ",
	pressed = " 有一个秘密，但是我不想告诉你 ",
	moved 	= {
		" 继续…… ",
		" 水晶越多越刺激！",
		" 合并一些更大的数吧！",
		" 让水晶来得更猛烈一些吧！ ",
		" 最大的数放在角落里更安全 ",
		" 能屈能伸真豪杰，落子无悔大豆腐 ",
		" 鄙视悔棋的家伙，这游戏还能玩？",
		" 游戏虽易，开发不易，且玩且珍惜 ",
		" 按最高分板可切换最高分或最高成就 ",
	},
	merged = {
		" 干得漂亮！ ",
		" 干得不错！ ",
		" 牛！你是来自2048的水晶超人吗？",
		" 水晶让人着迷，破坏令人发指！ ",
		" 这是最牛的2048，你信不信反正我信了 ",
		" 据说2048上面还有4096？作者疯了！",
		" 我不信有人能玩到8192，除非悔棋 ",
		" 行百里路者半九十，越到最后越要小心 ",
		" 不要把所有水晶都放在一个框子里面 ",
	},

	lost 		= " 你输了, 再来一次？ ",
	nomoved 	= " 你不能向这个方向移动！ " ,
	win2048 	= " 恭喜, 你成功地达到了2048！ ",
	win4096	 	= " 你太疯狂了, 我不能相信自己的眼睛 ",
	win8192 	= " 所有人都过来，过来看上帝！",
	undoHint	= " 比反悔更无耻的事是死不改悔！ ",
	undoed		= " 好吧，如你所愿…… ",
	notUndo		= " 世上没有那么多后悔药啊 ",
	restartHint = " 按住按钮保持1秒，以确认开始新游戏 ",
	exitHint	= " 再按一次退出游戏 ",
	saved 		= " 当前游戏进度已保存 ", 
	restored 	= " 继续游戏或者点新游戏重新开始 ",
}

Language.title = {
	newgame 	= " 新游戏 ",
	exit 		= " 退出 ",
	text 		= "合并数字并达到 \n2048 或更多 ...",
	currScore 	= "分数",
	bestScore 	= "最高分",
	bestCell 	= "最高成就",
}


return Language
