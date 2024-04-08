; TO USE:
; Install AutHotKey (https://www.autohotkey.com/)
; Download this file (Balatro Legendary Finder.ahk)
; Open Balatro
; Run Balatro Legendary Finder.ahk


; -----------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------
; Defining Constants and Vars
; -----------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------

HexMegArcana 				:= 0xE0607D
HexMegArcanaGreyedOut 			:= 0x9B585C
HexMegArcanaSkip 			:= 0x67634C
HexSoulCard 				:= 0xB9C9CF
HexCanio 				:= 0xDFD2BF
HexTriboulet				:= 0xE6C284
HexYorick 				:= 0x55B1E8
HexChicot 				:= 0x8083EF
HexPerkeo 				:= 0xA8B87B
HexDesiredJoker				:= 0x000000
HexUseButton				:= 0x404CFF

TempFoundX				:= 0
TempFoundY				:= 0
FoundX					:= 0
FoundY					:= 0
BalatroX				:= 0
BalatroY				:= 0
BalatroW				:= 0
BalatroH				:= 0
PacksOpened				:= 0
UserChoiceJoker				:= "Any Legendary"

; -----------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------
; GUI
; -----------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------

#SingleInstance force

Gui, font, s12 bold, Verdana
Gui, Add, Text,, Welcome to the Balatro Legendary Finder!
Gui, font, s8 norm, Verdana
Gui, Add, Text,, - Make sure Balatro is in Windowed Mode
Gui, Add, Text,, - Set Settings > Graphics > CRT to 0
Gui, Add, Text,, - Set Settings > Game > Game Speed to 4
Gui, Add, Text,, - Start a Balatro run on desired deck, stake, or challenge.
Gui, Add, Text,, - Run and check back in a few hours.
Gui, Add, Text,,

Gui, font, s16 bold, Verdana
Gui, Add, Text,, Pick a Legendary Joker:
Gui, font, s8 norm, Verdana
Gui, Add, Text,, Specific Joker will be found on average 2-3 hours. Any Legendary will take about 1 hour. RNG willing.
Gui, Add, Text,,


Gui, font, s12 norm, Verdana
Gui, Add, Radio, vAnyLegendary Checked, Any Legendary
Gui, Add, Radio, vCanio, Canio
Gui, Add, Radio, vTriboulet, Triboulet
Gui, Add, Radio, vYorick, Yorick
Gui, Add, Radio, vChicot, Chicot
Gui, Add, Radio, vPerkeo, Perkeo

Gui, font, s16 bold, Verdana
Gui, Add, Text,,
Gui, Add, Text,, Pick Blinds:
Gui, font, s8 norm, Verdana
Gui, Add, Text,, Considering the second blind will decrease search time, but you might skip the first round.
Gui, Add, Text,,

Gui, font, s12 norm, Verdana
Gui, Add, Radio, vFirstBlind Checked, Consider First Blind Only
Gui, Add, Radio, vSecondBlind, Consider First and Second Blind


Gui, Add, Text,,
Gui, Add, Button, gButtonRun, Run  
Gui, Show,, BLF - Balatro Legendary Finder

return

; -----------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------
; Functions
; -----------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------

;press and hold R to restart Balatro run, wait for animation
restartBalatroRun()
{
	Send, {r down}
    Sleep, 2000
    Send, {r up}
	Sleep, 2000

	return
}

; Look for Soul Card/Legendary Joker, if found ExitApp
LookForLegendary(Width, Height, HexSoul, HexJoker, AnyLegend, HexUse)
{
	PixelSearch, FoundX, FoundY, 0, 0, Width, Height, HexSoul, 0, Fast RGB
	if ErrorLevel = 0
	{
		if (AnyLegend = 1)
		{
			; Click Soul Card to Select it
			ClickThis(FoundX, FoundY)
			Sleep, 250
			
			SetTimer, UpdateElapsedTime, OFF
			MsgBox, Soul Card Found.
			ExitApp
		}
		
		if (AnyLegend != 1)
		{
			; Click Soul Card to Select it
			ClickThis(FoundX, FoundY)
			Sleep, 250

			; Click "Use" under the Soul Card
			TempFoundX := FoundX
			TempFoundY := FoundY
			PixelSearch, FoundX, FoundY, (TempFoundX-100), TempFoundY, (TempFoundX+100), Height, HexUse, 0, Fast
			if ErrorLevel = 0
			{
				ClickThis((FoundX-5), (FoundY+5))
				Sleep, 250
			}
			
			; Check if Legendary is correct one
			PixelSearch, FoundX, FoundY, 0, 0, Width, (Height/2), HexJoker, 0, Fast
			if ErrorLevel = 0
			{
				SetTimer, UpdateElapsedTime, OFF
				MsgBox, Legendary Joker Found.
				ExitApp
			}
		}
	}
	
	return
}

; Find and click the skip button after you open a Mega Arcana Pack
MegaArcanaPackSkip(Width, Height, HexSkip)
{
	PixelSearch, FoundX, FoundY, 0, 0, Width, Height, HexSkip, 0, Fast
	if !ErrorLevel
	{
		ClickThis((FoundX+50), (FoundY+50))
		ResetMousePosition()
		Sleep 500
	}
	
	return
}

; Clicks on the coordinates given
ClickThis(LocX,LocY)
{
	MouseMove, LocX, LocY
	Sleep, 250
	Click
	Sleep, 250
	
	return
}

; Reset Mouse position to arbitrary out of the way value
ResetMousePosition()
{
	MouseMove, 300, 300
	return
}

; When you click run on the first GUI, it will start the timer and start looking for legendaries
ButtonRun: 
	Gui, Submit, NoHide  ; Save each control's contents to its associated variable.
	startTime := A_TickCount
	RunBalatroLegendaryFinder(AnyLegendary, Canio, Triboulet, Yorick, Chicot, Perkeo, FirstBlind, SecondBlind, HexMegArcana, HexMegArcanaGreyedOut, HexMegArcanaSkip, HexSoulCard, HexCanio, HexTriboulet, HexYorick, HexChicot, HexPerkeo, HexDesiredJoker, HexUseButton, PacksOpened)
return

; Timer Functionality
UpdateElapsedTime:
    elapsedTime := (A_TickCount - startTime) / 1000
    hours := Floor(elapsedTime / 3600)
    minutes := Floor((elapsedTime - hours * 3600) / 60)
    seconds := Floor(elapsedTime - hours * 3600 - minutes * 60)
    elapsedTimeDisplay := Format("{:02}:{:02}:{:02}", hours, minutes, seconds)
    GuiControl, Second:Text, ElapsedTime, %elapsedTimeDisplay%
return

; Update Packs Opened Counter
UpdatePacksOpened:
	UpdatePacksFunction()
return

; Increase Packs Opened counter when called
UpdatePacksFunction()
{
	global PacksOpened
	PacksOpened++
	GuiControl, Second:Text, PacksOpened, %PacksOpened%
}

; Pressing the X in the top right will exit the script
GuiClose:
	ExitApp
return

; Pressing Quit will exit the script
Button_Quit:
	ExitApp
return


; -----------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------
; Main Legendary Searching Function
; -----------------------------------------------------------------------------------
; -----------------------------------------------------------------------------------
 
; Listen. This is crazy long but I don't want to deal with arrays right now.
RunBalatroLegendaryFinder(VarAnyLegendary, VarCanio, VarTriboulet, VarYorick, VarChicot, VarPerkeo, VarFirstBlind, VarSecondBlind, VarHexMegArcana, VarHexMegArcanaGreyedOut, VarHexMegArcanaSkip, VarHexSoulCard, VarHexCanio, VarHexTriboulet, VarHexYorick, VarHexChicot, VarHexPerkeo, VarHexDesiredJoker, VarHexUseButton, VarPacksOpened)
{
	
	; -----------------------------------------------------------------------------------
	; Get Balatro's window dimensions and make active window
	; -----------------------------------------------------------------------------------
	
	if !WinExist("Balatro")
	{
		MsgBox, Please open Balatro before running.
		ExitApp
	}

	if WinExist("Balatro")
		WinActivate ;

	WinGetPos, BalatroX, BalatroY, BalatroW, BalatroH, Balatro

	; -----------------------------------------------------------------------------------
	; If the user selected a specific Joker, track the correct color
	; -----------------------------------------------------------------------------------
	
	if (VarAnyLegendary = 1)
	{
		UserChoiceJoker := "Any Legendary"
	}
	else if (VarCanio = 1)
	{
		UserChoiceJoker := "Canio"
		VarHexDesiredJoker := VarHexCanio
	}
	else if (VarTriboulet = 1) 	
	{
		UserChoiceJoker := "Triboulet"
		VarHexDesiredJoker := VarHexTriboulet
	}
	else if (VarYorick = 1) 	
	{
		UserChoiceJoker := "Yorick"
		VarHexDesiredJoker := VarHexYorick
	}
	else if (VarChicot = 1) 	
	{
		UserChoiceJoker := "Chicot"
		VarHexDesiredJoker := VarHexChicot
	}
	else if (VarPerkeo = 1) 	
	{
		UserChoiceJoker := "Perkeo"
		VarHexDesiredJoker := VarHexPerkeo
	}
	if (VarFirstBlind = 1)
	{
		UserChoiceBlinds := "First Blind Only"
	}
	else if (VarSecondBlind = 1)
	{
		UserChoiceBlinds := "Both Blinds"
	}

	; -----------------------------------------------------------------------------------
	; Second Gui
	; -----------------------------------------------------------------------------------
	
	;Destroys first Window
	Gui, Destroy
	
	;Opens Second Timer Window
	Gui, Second:New
	Gui, Second:font, s8 norm, Verdana
	Gui, Second:Add, Text,, Looking for:
	Gui, Second:font, s12 Bold, Verdana
	Gui, Second:Add, Text,, %UserChoiceJoker%
	Gui, Second:font, s8 norm, Verdana
	Gui, Second:Add, Text,, Considering:
	Gui, Second:font, s12 Bold, Verdana
	Gui, Second:Add, Text,, %UserChoiceBlinds%
	Gui, Second:font, s8 norm, Verdana
	Gui, Second:Add, Text,, Packs Opened:
	Gui, Second:font, s12 Bold, Verdana
	Gui, Second:Add, Text, w150 vPacksOpened, 0
	Gui, Second:font, s8 norm, Verdana
	Gui, Second:Add, Text,, Elapsed Time:
	Gui, Second:font, s12 Bold, Verdana
	Gui, Second:Add, Text, vElapsedTime, 00:00:00
	Gui, Second:Add, Button, x120 y260 w70 gButton_Quit, Quit
	Gui, Second:+AlwaysOnTop
	Gui, Second:Show, x%BalatroX% y%BalatroY% w200 h300, BLF - Balatro Legendary Finder

    SetTimer, UpdateElapsedTime, 1000
	
	; -----------------------------------------------------------------------------------
	;Begin looking for Legendaries.
	; -----------------------------------------------------------------------------------
	
	if WinExist("Balatro")
		WinActivate ;
	
	Loop
	{
		; Look for Mega Arcana Pack on first blind, if found, open it
		PixelSearch, FoundX, FoundY, 0, (BalatroH / 2), BalatroW, BalatroH, VarHexMegArcana, 0, Fast
		if !ErrorLevel
		{			
			; Click Skip Blind
			ClickThis((FoundX+100),FoundY)
			
			;Increase PacksOpened Counter
			UpdatePacksFunction()
			
			;Wait for animation
			Sleep, 3000

			; Look for Soul Card/Legendary Joker, if found exit app
			LookForLegendary(BalatroW, BalatroH, VarHexSoulCard, VarHexDesiredJoker, VarAnyLegendary, VarHexUseButton)
			
			; Skip Pack if no Soul Card
			MegaArcanaPackSkip(BalatroW, BalatroH, VarHexMegArcanaSkip)
		}
		
		;Only run these if the user approved using the second blind
		if (VarSecondBlind = 1)
		{
			; Look for Mega Arcana Pack on second blind (assuming you DID find one the first time)
			PixelSearch, FoundX, FoundY, 0, (BalatroH / 2), BalatroW, BalatroH, VarHexMegArcana, 0, Fast
			if !ErrorLevel
			{
			
				;Skip Second Blind (The Mega Arcana)
				ClickThis((FoundX+100), FoundY)
				
				;Increase PacksOpened Counter
				UpdatePacksFunction()
				
				;Wait for animation
				Sleep, 3000
				
				; Look for Soul Card/Legendary Joker, if found break loop
				LookForLegendary(BalatroW, BalatroH, VarHexSoulCard, VarHexDesiredJoker, VarAnyLegendary, VarHexUseButton)
				
				; Skip Pack if no Soul Card
				MegaArcanaPackSkip(BalatroW, BalatroH, VarHexMegArcanaSkip)
			}
			
			; Look for Mega Arcana Pack on second blind (assuming you DID NOT find one the first time)
			PixelSearch, FoundX, FoundY,  0, (BalatroH / 2), BalatroW, BalatroH, VarHexMegArcanaGreyedOut, 0, Fast
			if !ErrorLevel
			{
				
				;skip first blind (don't care what it is)
				ClickThis((FoundX-(BalatroW/10)), (FoundY-(BalatroH/20)))
				
				;Wait for animation
				Sleep, 1000

				;skip second blind (the mega arcana)
				ClickThis((FoundX+100), (FoundY-50))
				
				;Increase PacksOpened Counter
				UpdatePacksFunction()
				
				;Wait for animation
				Sleep, 3000
				
				; Look for Soul Card/Legendary Joker, if found break loop
				LookForLegendary(BalatroW, BalatroH, VarHexSoulCard, VarHexDesiredJoker, VarAnyLegendary, VarHexUseButton)
				
				; Skip Pack if no Soul Card
				MegaArcanaPackSkip(BalatroW, BalatroH, VarHexMegArcanaSkip)
				
				; TODO: Edge case - the first blind was a double tag and now you have two packs to open
				; TODO: Right now we are just ignoring this second pack when it happens 
			}
		}
		
		; If nothing was found, restart run
		restartBalatroRun()
	}
	
	return
}

