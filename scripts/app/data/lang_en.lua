--
-- Author: Ace
-- Date: 2014-03-29 00:22:37
--
local Language = {}

Language.info = {
	start 	= " Welcome to Crystal 2048 ",
	guide 	= " Sliding on the board to move ",
	clicked = "Moving is expected ...",
	pressed = "There's a secret I don't want to tell you",
	moved 	= {
		" Go ahead! ",
		" The more crystal, the more exciting ",
		" Let's merge more bigger numbers ",
		" Crystal, coming soon coming more! ",
		" Keep the biggest number in corner ",
		" If ystday once more, or game can undo ",
		" Regret doing, or regret to do? ",
		" Playing is easy, developing is difficult ",
		" Touch Best board to switch Best-Mode",
	},
	merged = {
		" Good job! ",
		" Well done! ",
		" Do you be excited with destorying? ",
		" Crystal is fascinating, defacing is crime! ",
		" It's a wonderful game, do you think so? ",
		" To get 4096 is quite an accomplishment ",
		" Nobody can get to 8192, except rainman ",
		" It's more dangerous when close to win ",
		" Don't put all your crystals in one box ",
	},

	lost 		= " You are lost, try again? ",
	nomoved 	= " You cannot move to this direction! ",
	win2048 	= " Congratulations, You've got 2048! ",
	win4096	 	= " You are crazy, I don't believe my eyes ",
	win8192 	= " Eeverybody, come here to see the God! ",
	undoHint	= " Undo is better than refuse to repent ",
	undoed 		= " My pleasure as long as you like it ",
	notUndo		= " Sorry, there is not any more undo ",
	restartHint = "Press the button for 1s to restart game",
	exitHint	= " Tap again to exit game",
	saved 		= " The Game State Is Saved ",
	restored 	= " Continue or tap [New] for new game ",
}

Language.title = {
	newgame		= " New ",
	exit 		= " Exit ",
	text 		= "Merge and get to \n2048 or more ...",
	currScore 	= "Score",
	bestScore 	= "BestSc.",
	bestCell 	= "BestCell",
}

return Language
