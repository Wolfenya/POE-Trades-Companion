﻿Class GUI_Trades_V2 {

	; Gui.ImageButtonChangeCaption(GuiTrades[_buyOrSell]["Slot1_Controls"]["hBTN_SmallButton" btnNum], "TEXT", GuiTrades[_buyOrSell].Styles.SmallButton_Test, PROGRAM.FONTS[GuiTrades[_buyOrSell].Font], GuiTrades[_buyOrSell].Font_Size, "")

	CreateButtonImage(assets, width, height) {
		global SKIN

		; Variables about paths
		leftPic := assets.Left
		rightPic := assets.Right
		fillPic := assets.Fill
		; Getting image sizes
		leftimgSizes := GetImageSize(leftPic)
		fillimgSizes := GetImageSize(fillPic)
		rightimgSizes := GetImageSize(rightPic)
		; Positions variables
			; Left
		leftImg_h_mult := height / leftimgSizes.H
		leftImgW := Ceil(leftimgSizes.W * leftImg_h_mult), leftImgH := Ceil(leftimgSizes.H * leftImg_h_mult)
			; Right
		rightImg_h_mult := height / rightimgSizes.H
		rightImgW := Ceil(rightimgSizes.W * rightImg_h_mult), rightImgH := Ceil(rightimgSizes.H * rightImg_h_mult)
			; Fill
		fillImg_h_mult := height / fillimgSizes.H
		fillImgW := Ceil(fillimgSizes.W), fillImgH := Ceil(fillimgSizes.H * fillImg_h_mult)
			; All
		leftImgX := 0, leftImgY := 0
		rightImgX := width-rightImgW, rightImgY := 0
		fillImgX := 0, fillImgY := 0

		; Gdip functions
		pBitmapNew := Gdip_CreateBitmap(width, height)
		G := Gdip_GraphicsFromImage(pBitmapNew)
		Gdip_SetSmoothingMode(G, 4)
		Gdip_SetInterpolationMode(G, 7)

		pBitmapFileLeft := Gdip_CreateBitmapFromFile(leftPic)
		pBitmapFileLeft := Gdip_ResizeBitmap(pBitmapFileLeft, "w" leftImgW " h" leftImgH, smooth:=False)

		pBitmapFileRight := Gdip_CreateBitmapFromFile(rightPic)
		pBitmapFileRight := Gdip_ResizeBitmap(pBitmapFileRight, "w" rightImgW " h" rightImgH, smooth:=False)
		
		pBitmapFilefill := Gdip_CreateBitmapFromFile(fillPic)
		pBitmapFilefill := Gdip_ResizeBitmap(pBitmapFilefill, "w" fillImgW " h" fillImgH, smooth:=False)

		Loop % width / fillimgSizes.W {
			imgX := A_Index=1?fillImgX: fillImgX+(fillImgW*(A_Index-1))
			Gdip_DrawImage(G, pBitmapFilefill, imgX, fillImgY, fillImgW, fillImgH, 0, 0, fillImgW, fillImgH)
		}
		Gdip_DrawImage(G, pBitmapFileLeft,  leftImgX, leftImgY, leftImgW, leftImgH, 0, 0, leftImgW, leftImgH)
		Gdip_DrawImage(G, pBitmapFileRight, rightImgX, fillImgX, rightImgW, rightImgH, 0, 0, rightImgW, rightImgH)

		hBitmap := Gdip_CreateHBITMAPFromBitmap(pBitmapNew)
		
		Gdip_DisposeImage(pBitmapNew), Gdip_DisposeImage(pBitmapFileLeft), Gdip_DisposeImage(pBitmapFileRight), Gdip_DisposeImage(pBitmapFilefill)
		Gdip_DeleteGraphics(G)

		;  Gui, Add, Picture,0xE hwndhMyPic
		;  SetImage(hMyPic, hBitmap)
		;  Gui, Show, AutoSize
		;  Sleep 9999999999999

		return hBitmap
	}

	Get_ButtonsRowsCount() {
		global PROGRAM

		customBtnBiggestSlot := 0
		Loop 9 {
			customBtnSettings := PROGRAM.SETTINGS["SETTINGS_CUSTOM_BUTTON_" A_Index]
			if (customBtnSettings.Enabled = "True") {
				customBtnBiggestSlot := customBtnSettings.Slot > customBtnBiggestSlot ? customBtnSettings.Slot : customBtnBiggestSlot
			}
		}

		specialsBtnRowsCount := 0
		Loop 5 {
			specialBtnSettings := PROGRAM.SETTINGS["SETTINGS_SPECIAL_BUTTON_" A_Index]
			if (specialBtnSettings.Enabled = "True") {
				specialsBtnRowsCount := 1
			}
		}
		
		customBtnsRowsCount := customBtnBiggestSlot = 0 ? "0"
			: IsIn(customBtnBiggestSlot, "1,2,3") ? 1
			: IsIn(customBtnBiggestSlot, "4,5,6") ? 2
			: IsIn(customBtnBiggestSlot, "7,8,9") ? 3
			: "ERROR"
		specialsBtnRowsCount := specialsBtnRowsCount

		Return {Custom:customBtnsRowsCount, Special:specialsBtnRowsCount}
	}

	Preview_AddSmallButtonToSlot(_buyOrSell, slotNum) {
		global GuiTrades, GuiTrades_Controls
		guiName := "Trades" _buyOrSell "_Slot1"

		GuiControl, %guiName%:Hide,% GuiTrades[_buyOrSell]["Slot1_Controls"]["hBTN_SmallSlot" slotNum]
		GuiControl, %guiName%:Show,% GuiTrades[_buyOrSell]["Slot1_Controls"]["hBTN_SmallButton" slotNum]
	}
	Preview_CustomizeThisSmallButton(_buyOrSell, btnNum)  {
		global PROGRAM, SKIN
		global GuiTrades, GuiTrades_Controls
		guiName := "Trades" _buyOrSell "_Slot1"

		try Menu, RMenu, DeleteAll
		Loop 5
			Menu, RMenu, Add, %A_Index%, Preview_CustomizeThisSmallButton_ChangeButtonStyle
		Menu, RMenu, Add, Remove this button, Preview_CustomizeThisSmallButton_RemoveThisButton
		Menu, RMenu, Show
		return

		Preview_CustomizeThisSmallButton_ChangeButtonStyle:
			ctrlPos := ControlGetPos(GuiTrades[_buyOrSell]["Slot1_Controls"]["hBTN_SmallButton" btnNum])
		return

		Preview_CustomizeThisSmallButton_RemoveThisButton:
			GuiControl, %guiName%:Hide,% GuiTrades[_buyOrSell]["Slot1_Controls"]["hBTN_SmallButton" btnNum]
			GuiControl, %guiName%:Show,% GuiTrades[_buyOrSell]["Slot1_Controls"]["hBTN_SmallSlot" btnNum]
		return
	}

	Preview_AddCustomButtonsToRow(_buyOrSell, rowNum) {
		global GuiTrades, GuiTrades_Controls
		guiName := "Trades" _buyOrSell "_Slot1"

		; Hiding the row button
		GuiControl, %guiName%:Hide,% GuiTrades[_buyOrSell]["Slot1_Controls"]["hBTN_CustomRowSlot" rowNum]
		; Showing the 5 new buttons
		Loop 5
			GuiControl, %guiName%:Show,% GuiTrades[_buyOrSell]["Slot1_Controls"]["hBTN_CustomButtonRow" rowNum "Max" 5 "Num" A_Index]
	}

	Preview_CustomizeThisCustomButton(_buyOrSell, rowNum, btnsCount, btnNum) {
		global GuiTrades, GuiSettings
		static prevBtn
		guiName := "Trades" _buyOrSell "_Slot1"
		thisBtn := "hBTN_CustomButtonRow" rowNum "Max" btnsCount "Num" btnNum

		GuiControl, %guiName%:,% GuiTrades[_buyOrSell]["Slot1_Controls"][thisBtn], EZEZ
		
		if (prevBtn) {
			GuiControl, %guiName%:-Disabled,% GuiTrades[_buyOrSell]["Slot1_Controls"][prevBtn]
			GUI_Settings.Customization_Interface_SaveAllCurrentButtonActions()
		}
		GuiControl, %guiName%:+Disabled,% GuiTrades[_buyOrSell]["Slot1_Controls"][thisBtn]
		prevBtn := thisBtn

		GuiSettings.CUSTOM_BUTTON_SELECTED_ROW := rowNum
		GuiSettings.CUSTOM_BUTTON_SELECTED_MAX := btnsCount
		GuiSettings.CUSTOM_BUTTON_SELECTED_NUM := btnNum
		GUI_Settings.Customization_Interface_LoadButtonActions(rowNum, btnNum)

		GUI_Trades_V2.RemoveButtonFocus(_buyOrSell) 
	}
	
	Create(_tabsToRender=50, _buyOrSell="", _tabsOrSlots="", _preview=False) {
		global PROGRAM, GAME, SKIN
        global GuiTrades, GuiTrades_Controls
        global GuiTradesBuy, GuiTradesBuy_Controls
        global GuiTradesSell, GuiTradesSell_Controls
		static guiCreated, borderSize ; TO_DO_V2 useless?
        scaleMult := PROGRAM.SETTINGS.SETTINGS_CUSTOMIZATION_SKINS.ScalingPercentage / 100
        windowsDPI := Get_DpiFactor()
        _guiMode := _tabsOrSlots
        _tabsToRender := IsNum(_tabsToRender)?_tabsToRender:50
        if !IsIn(_buyOrSell, "Buy,Sell") {
            MsgBox(4096, "", "ERROR NOT Buy OR Sell: " _buyOrSell)
            return
        }
        if !IsIn(_tabsOrSlots, "Tabs,Slots") {
            MsgBox(4096, "", "ERROR NOT Tabs OR Slots: " _tabsOrSlots)
            return
        }

        if (PROGRAM.SETTINGS.SETTINGS_MAIN.DisableBuyInterface="True")
			return

        ; = = Init GUI Obj
		if (_preview)
			_buyOrSell .= "Preview"
        guiName := "Trades" _buyOrSell
        GUI_Trades_V2.Destroy(guiName)
		if (_preview=True)
			Gui.New(guiName, "+AlwaysOnTop +ToolWindow +LastFound -SysMenu -Caption -Border +LabelGUI_Trades_V2_ +ParentSettings +HwndhGui" guiName, "POE TC - Trades " _buyOrSell)
		else Gui.New(guiName, "+AlwaysOnTop +ToolWindow +LastFound -SysMenu -Caption -Border +E0x08000000 +LabelGUI_Trades_V2_ +HwndhGui" guiName, "POE TC - Trades " _buyOrSell)
        Gui.SetDefault(guiName)
        Gui%guiName%.Windows_DPI := windowsDPI

        ; = = Define font name and size
        settingsSkinPreset := PROGRAM.SETTINGS.SETTINGS_CUSTOMIZATION_SKINS.Preset, useRecommendedFontSettings := PROGRAM.SETTINGS.SETTINGS_CUSTOMIZATION_SKINS.UseRecommendedFontSettings
        userDefinedCopy := ObjFullyClone(PROGRAM.SETTINGS.SETTINGS_CUSTOMIZATION_SKINS_UserDefined)
        guifontName := settingsSkinPreset="User Defined" && useRecommendedFontSettings!="1" ? userDefinedCopy.Font : SKIN.Settings.FONT.Name
        guifontSize := settingsSkinPreset="User Defined" && useRecommendedFontSettings!="1" ? userDefinedCopy.FontSize : SKIN.Settings.FONT.Size
        guifontQual := settingsSkinPreset="User Defined" && useRecommendedFontSettings!="1" ? userDefinedCopy.FontQuality : SKIN.Settings.FONT.Quality
        Gui.Font(guiName, guifontName, guifontSize, guifontQual) 
        Gui.Color(guiName, SKIN.Assets.Misc.Transparency_Color)
        Gui.Margin(guiName, 0, 0)
        guifontName := guifontSize := guifontQual := useRecommendedFontSettings := useRecommendedFontSettings := userDefinedCopy := ""

        ; = = Define general gui size
        borderSize := Floor(1*scaleMult), borderSize := borderSize >= 1 ? borderSize : 1
        oneTextLineSize := Get_TextCtrlSize("SomeText", Gui%guiName%.Font, Gui%guiName%.Font_Size, "", "R1").H
        twoTextLineSize := oneTextLineSize*2
        ; twoTextLineSize += ((10+12)*scaleMult) ; 10+12, based on ctrl pacing - TO_DO_V2 see if need change
		TabContentSlot_H_Temp := twoTextLineSize+(20*borderSize) ; 20 = spacing

        if (_tabsOrSlots="Slots") {
            Gui%guiName%.Height_NoRow 		:= guiHeight_NoRow      := borderSize + (30*scaleMult) + borderSize ; 30=header
            Gui%guiName%.Height_OneRow	 	:= guiHeight_OneRow     := guiHeight_NoRow + (22*scaleMult) + TabContentSlot_H_Temp + (borderSize) ; 22=header2
			Gui%guiName%.Height_TwoRow	 	:= guiHeight_TwoRow     := guiHeight_OneRow + TabContentSlot_H_Temp + (borderSize*2)
            Gui%guiName%.Height_ThreeRow 	:= guiHeight_ThreeRow   := guiHeight_TwoRow + TabContentSlot_H_Temp + (borderSize*2)
            Gui%guiName%.Height_FourRow 	:= guiHeight_FourRow    := guiHeight_ThreeRow + TabContentSlot_H_Temp + (borderSize*2)

			Gui%guiName%.OneButtonsRow 		:= oneButtonsRow 		:= (25*scaleMult)
			Gui%guiName%.TwoButtonsRow 		:= twoButtonsRow 		:= (oneButtonsRow*2)+(5*scaleMult)
			Gui%guiName%.ThreeButtonsRow 	:= threeButtonsRow 		:= (twoButtonsRow*2)+((5*scaleMult)*2)

            guiFullHeight := guiHeight_FourRow+threeButtonsRow+(5*scaleMult), guiFullWidth := scaleMult*(398+(2*borderSize))
            guiHeight := guiFullHeight-(2*borderSize), guiWidth := guiFullWidth-(2*borderSize)
            guiMinimizedHeight := (30+(borderSize*2))*scaleMult ; 30=Header
            leftMost := borderSize, rightMost := guiWidth+borderSize ; +bordersize bcs of left border
            upMost := borderSize, downMost := guiHeight+borderSize

			
        }
        else if (_tabsOrSlots="Tabs") {
            Gui%guiName%.Height_NoRow 		:= guiHeight_NoRow      := borderSize + (30*scaleMult) + borderSize ; 30=header
            Gui%guiName%.Height_OneRow	 	:= guiHeight_OneRow     := guiHeight_NoRow + (22*scaleMult) + TabContentSlot_H_Temp + (borderSize) ; 22=header2

			Gui%guiName%.OneButtonsRow 		:= oneButtonsRow 		:= (25*scaleMult)
			Gui%guiName%.TwoButtonsRow 		:= twoButtonsRow 		:= oneButtonsRow+(25*scaleMult)+(5*scaleMult)
			Gui%guiName%.ThreeButtonsRow 	:= threeButtonsRow 		:= twoButtonsRow+(25*scaleMult)+(5*scaleMult)+(5*scaleMult)

            guiFullHeight := guiHeight_OneRow+threeButtonsRow+(5*scaleMult), guiFullWidth := scaleMult*(398+(2*borderSize))
            guiHeight := guiFullHeight-(2*borderSize), guiWidth := guiFullWidth-(2*borderSize)
            guiMinimizedHeight := (30+(borderSize*2))*scaleMult ; 30=Header
            leftMost := borderSize, rightMost := guiWidth+borderSize ; +bordersize bcs of left border
            upMost := borderSize, downMost := guiHeight+borderSize

			TabContentSlot_H := guiHeight_OneRow + threeButtonsRow
        }
		TabContentSlot_W := guiWidth

        ; = = Define general gui slots
        if (_guiMode="Slots") {
            maxSlotsToShow := 4
        }
        else if (_guiMode="Tabs") {
            maxTabsToShow := 8
        }

        ; = = Define general gui elements positioning
            ; Header
		Header_X := leftMost, Header_Y := upMost, Header_W := guiWidth, Header_H := 30*scaleMult
        ToolBar_Button1_X := 5*scaleMult, ToolBar_Button1_Y := 5*scaleMult, ToolBar_Button1_W := 30*scaleMult, ToolBar_Button1_H := 22*scaleMult
		MinMax_X := rightMost-((22*scaleMult)+(3*scaleMult)), MinMax_Y := Header_Y+(4*scaleMult), MinMax_W := 22*scaleMult, MinMax_H := 22*scaleMult
		Title_X := "_CUSTOM_", Title_Y := Header_Y, Title_W := "_CUSTOM_", Title_H := Header_H
        ToolBar_SpaceBetweenButtons := 8*scaleMult

            ; Second bar
        if (_guiMode="Slots") {
            Header2_X := leftMost, Header2_Y := Header_Y+Header_H, Header2_H := 22*scaleMult
            RightArrow_W := 25*scaleMult, RightArrow_H := Header2_H
            LeftArrow_W := RightArrow_W, LeftArrow_H := RightArrow_H       

            LeftArrow_X := rightMost-LeftArrow_W-RightArrow_W, LeftArrow_Y := Header2_Y
            RightArrow_X := LeftArrow_X+LeftArrow_W, RightArrow_Y := Header2_Y
            
            Header2_W := Header_W-LeftArrow_W-RightArrow_W

            SearchBox_X := Header2_X+(10*scaleMult), SearchBox_Y := Header2_Y, SearchBox_W := (139*scaleMult), SearchBox_H := Header2_H
        }
        else if (_guiMode="Tabs") {
            TabsBackground_X := leftMost, TabsBackground_Y := Header_Y+Header_H, TabsBackground_H := 22*scaleMult
            RightArrow_W := 25*scaleMult, RightArrow_H := TabsBackground_H
            LeftArrow_W := RightArrow_W, LeftArrow_H := RightArrow_H     
            CloseTab_W := RightArrow_W, CloseTab_H := RightArrow_H

            LeftArrow_X := rightMost-CloseTab_W-LeftArrow_W-RightArrow_W, LeftArrow_Y := TabsBackground_Y
            RightArrow_X := LeftArrow_X+LeftArrow_W, RightArrow_Y := TabsBackground_Y
            CloseTab_X := RightArrow_X+RightArrow_W, CloseTab_Y := TabsBackground_Y
            
            TabsBackground_W := Header_W-LeftArrow_W-RightArrow_W-CloseTab_W

            TabButton1_Y := TabsBackground_Y, TabButton1_W := 39*scaleMult, TabButton1_H := TabsBackground_H
            Loop % maxTabsToShow
                Gui%guiName%["TabButton" A_Index "_X"] := xpos := TabButton%A_Index%_X := A_Index=1 ? TabsBackground_X : xpos+TabButton1_W+1
        }

            ; Tabs content
        Loop 10 { ; from 0 to 9, for time slot width
			num := (A_Index=10)?("0"):(A_Index)
			txtCtrlSize := Get_TextCtrlSize(num num ":" num num, Gui%guiName%.Font, Gui%guiName%.Font_Size)
			Time_W := (Time_W > txtCtrlSize.W)?(Time_W):(txtCtrlSize.W)
		}

        BackgroundImg_X := 0, BackgroundImg_Y := 0, BackgroundImg_W := Ceil(TabContentSlot_W*windowsDPI)*scaleMult, BackgroundImg_H := Ceil(TabcontentSlot_H*windowsDPI)*scaleMult

        CloseTabVertical_W := 15*scaleMult, CloseTabVertical_H := TabcontentSlot_H, CloseTabVertical_X := rightMost-CloseTabVertical_W, CloseTabVertical_Y := 0

        firstRowX := leftMost+(5*scaleMult), firstRowY := upMost+(5*scaleMult), firstRowW := (guiWidth/2)-(5*scaleMult)-CloseTabVertical_W ; 5= spacing
        secondRowX := firstRowX, secondRowY := firstRowY+oneTextLineSize+(5*scaleMult) ; 5= spacing
        firstColX := firstRowX, firstColY := upMost+(5*scaleMult) ; 5= spacing
        secondColX := (guiWidth/2)+firstRowX+(5*scaleMult), secondColY := firstColY ; 5= spacing  
        
        ItemName_X := firstRowX, ItemName_Y := firstRowY, ItemName_W := ( (guiWidth-CloseTabVertical_W)/2 )-(5*scaleMult) ; ItemName_W: 5=spacing
        SellerName_X := ItemName_X+ItemName_W+(10*scaleMult), SellerName_Y := ItemName_Y, SellerName_W := ItemName_W ; SellerName_X: 10=spacing*2
        CurrencyImg_X := secondRowX, CurrencyImg_Y := secondRowY, CurrencyImg_W := 20*scaleMult, CurrencyImg_H := 20*scaleMult
        PriceCount_X := CurrencyImg_X+CurrencyImg_W, PriceCount_Y := CurrencyImg_Y, PriceCount_W := 50
        AdditionalMsg_X := PriceCount_X+PriceCount_W, AdditionalMsg_Y := PriceCount_Y, AdditionalMsg_W := 200
        SmallButton_X := SellerName_X, SmallButton_Y := secondRowY, SmallButton_W := 35*scaleMult, SmallButton_H := 25*scaleMult, SmallButton_Space := 5*scaleMult, SmallButton_Count := 4
        if (_guiMode="Slots")
            Time_X := CloseTabVertical_X-Time_W-(3*scaleMult), Time_Y := 0 ; 3=spacing
        else if (_guiMode="Tabs")
            Time_X := rightMost-Time_W-(3*scaleMult), Time_Y := 0 ; 3=spacing

        SmallButton1_X := CloseTabVertical_X-(SmallButton_Count* (SmallButton1_W+SmallButton_Space))-(15*scaleMult), SmallButton1_Y := "_CUSTOM_"

		CustomButtonOneThird_W := Ceil( (guiWidth)/3 )-(5*scaleMult) , CustomButtonTwoThird_W := (CustomButtonOneThird_W*2)+(5*scaleMult), CustomButtonThreeThird_W := (CustomButtonOneThird_W*3)+(10*scaleMult)
		CustomButtonLeft_X := leftMost+(5*scaleMult), CustomButtonMiddle_X := CustomButtonLeft_X+CustomButtonOneThird_W+(5*scaleMult), CustomButtonRight_X := CustomButtonMiddle_X+CustomButtonOneThird_W+(5*scaleMult)
		CustomButton_H := 25*scaleMult

        TradeVerify_W := 10*scaleMult, TradeVerify_H := TradeVerify_W, TradeVerify_X := TimeSlot_X-5-TradeVerify_W, TradeVerify_Y := TimeSlot_Y+3

        ; = = Getting ready to create the GUI
		Gui%guiName%.Active_Tab := 0
		Gui%guiName%.Tabs_Count := 0
		Gui%guiName%.Tabs_Limit := _tabsToRender
		Gui%guiName%.Max_Tabs_Per_Row := maxTabsToShow
		Gui%guiName%.Is_Created := False
		Gui%guiName%.Height := guiMinimizedHeight
        Gui%guiName%.Height_Maximized := guiFullHeight
		Gui%guiName%.Height_Minimized := guiMinimizedHeight
		Gui%guiName%.Width := guiFullWidth
        Gui%guiName%.Is_Tabs := _guiMode="Tabs"?True:False
        Gui%guiName%.Is_Slots := _guiMode="Slots"?True:False

        styles := GUI_Trades_V2.Get_Styles() ; TO_DO

        ; = = Borders
        if (_guiMode="Slots")
            borders := [ {Name:"Top", X:0, Y:0, W:guiFullWidth, H:borderSize}
                        ,{Name:"Left", X:0, Y:0, W:borderSize, H:guiFullHeight}
                        ,{Name:"Right", X:guiFullWidth-borderSize, Y:0, W:borderSize, H:guiFullHeight}
                        ,{Name:"Bottom_Minimized", X:0, Y:Header_Y+Header_H, W:guiFullWidth, H:borderSize}
                        ,{Name:"Bottom_OneSlot", X:0, Y:guiHeight_OneRow-borderSize, W:guiFullWidth, H:borderSize}
                        ,{Name:"Bottom_TwoSlots", X:0, Y:guiHeight_TwoRow-borderSize, W:guiFullWidth, H:borderSize}
                        ,{Name:"Bottom_ThreeSlots", X:0, Y:guiHeight_ThreeRow-borderSize, W:guiFullWidth, H:borderSize}
                        ,{Name:"Bottom_FourSlots", X:0, Y:guiHeight_FourRow-borderSize, W:guiFullWidth, H:borderSize} ]
        else if (_guiMode="Tabs")
            borders := [ {Name:"Top", X:0, Y:0, W:guiFullWidth, H:borderSize}
                        ,{Name:"Left", X:0, Y:0, W:borderSize, H:guiFullHeight}
                        ,{Name:"Right", X:guiFullWidth-borderSize, Y:0, W:borderSize, H:guiFullHeight}
                        ,{Name:"Bottom_Minimized", X:0, Y:Header_Y+Header_H, W:guiFullWidth, H:borderSize}
                        ,{Name:"Bottom_OneSlot", X:0, Y:guiHeight_OneRow-borderSize, W:guiFullWidth, H:borderSize} ]

        Loop % borders.Count()
            Gui.Add(guiName, "Progress", "x" borders[A_Index]["X"] " y" borders[A_Index]["Y"] " w" borders[A_Index]["W"] " h" borders[A_Index]["H"] " Background" SKIN.Settings.COLORS.Border " c" SKIN.Settings.COLORS.Border " hwndhPROGRESS_Border" borders[A_Index].Name, 100)

        ; = = Header
		Gui.Add(guiName, "Picture", "x" Header_X " y" Header_Y " w" Header_W " h" Header_H " hwndhIMG_Header BackgroundTrans", SKIN.Assets.Misc.Header)
		Gui.Add(guiName, "ImageButton", "x" MinMax_X " y" MinMax_Y " w" MinMax_W " h" MinMax_H " BackgroundTrans hwndhBTN_Minimize", "", styles.Minimize, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size)
		Gui.Add(guiName, "ImageButton", "x" MinMax_X " y" MinMax_Y " w" MinMax_W " h" MinMax_H " BackgroundTrans hwndhBTN_Maximize Hidden", "", styles.Maximize, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size)
		Gui.Add(guiName, "ImageButton", "x" ToolBar_Button1_X " y" ToolBar_Button1_Y " w" ToolBar_Button1_W " h" ToolBar_Button1_H " BackgroundTrans hwndhBTN_Hideout", "", Styles.Toolbar_Hideout, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size)
		Gui.Add(guiName, "ImageButton", "x+" ToolBar_SpaceBetweenButtons " yp wp hp BackgroundTrans hwndhBTN_LeagueHelp", "", styles.Toolbar_Sheet, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size)
		Gui.Add(guiName, "ImageButton", "x+" ToolBar_SpaceBetweenButtons " yp wp hp BackgroundTrans hwndhBTN_What2 Hidden", "", styles.Toolbar_Hideout, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size)
		Gui.Add(guiName, "ImageButton", "x+" ToolBar_SpaceBetweenButtons " yp wp hp BackgroundTrans hwndhBTN_What3 Hidden", "", styles.Toolbar_Hideout, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size)
        Gui.Add(guiName, "Text", "x" Header_X " y" Header_Y " w" Header_W " h" Header_H " hwndhTXT_HeaderGhost BackgroundTrans", "") ; Empty text ctrl to allow moving the gui by dragging the title bar

        minBtnPos := Gui.GetControlPos(guiName, "hBTN_Minimize"), lastToolBtnPos := Gui.GetControlPos(guiName, "hBTN_What3")
        Title_X := lastToolBtnPos.X+lastToolBtnPos.W+(3*scaleMult), Title_W := Header_W-(lastToolBtnPos.X+lastToolBtnPos.W+(3*scaleMult))-(Header_W-(minBtnPos.X-minBtnPos.W))
        ; Gui.Add(guiName, "Text", "x" Title_X " y" Title_Y " w" Title_W " h" Title_H " hwndhTEXT_Title Center BackgroundTrans +0x200 c" SKIN.Settings.COLORS.Title_No_Trades, PROGRAM.NAME)
	
        Gui.BindFunctionToControl("GUI_Trades_V2", guiName, "hTXT_HeaderGhost", "OnGuiMove", _buyOrSell) 
        Gui.BindFunctionToControl("GUI_Trades_V2", guiName, "hBTN_Minimize", "Minimize", _buyOrSell) 
        Gui.BindFunctionToControl("GUI_Trades_V2", guiName, "hBTN_Maximize", "Maximize", _buyOrSell) 
        
        Gui.BindFunctionToControl("GUI_Trades_V2", guiName, "hBTN_Hideout", "HotBarButton", _buyOrSell, "Hideout")
        Gui.BindFunctionToControl("GUI_Trades_V2", guiName, "hBTN_LeagueHelp", "HotBarButton", _buyOrSell, "LeagueHelp")
        Gui.BindFunctionToControl("GUI_Trades_V2", guiName, "hBTN_What2", "HotBarButton", _buyOrSell, "What")
        Gui.BindFunctionToControl("GUI_Trades_V2", guiName, "hBTN_What3", "HotBarButton", _buyOrSell, "What")

        ; = = Header 2
		/*	Due to the fact that we want to use a skinned search box, we have to simulate it by:
			- Creating a child gui with the edit box, and set the transparency 1
			- Add a text control on the same exact location on the parent gui

			( this part only matters if using the +E0x08000000 style for parent gui)
			- Compare the control size for an edit box and a text control with the same text 
			  (an edit box and a text control will have difference in sizes due to the edit box borders which the text control doesnt have)
			  Based on the size difference, move the text control a bit

			- Due to the +E0x08000000 style, we can't focus the search box
			  We work around it by creating yet another gui (not child) with an edit box, which will be hidden
			- Using WM_LButtonDown and WM_LButtonUp, we detect when the user is clicking the child gui search box
			  and we focus our hidden gui edit box so we can type in
			- Anything typed in the hidden edit box will be reflected on our parent gui text control
		*/

        if (_guiMode="Slots") {
            global GuiTradesBuySearch, GuiTradesBuySearch_Controls
            global GuiTradesSellSearch, GuiTradesSellSearch_Controls
			if (_preview)
            	Gui.New(guiName "Search", "-Caption -Border +ToolWindow -SysMenu +AlwaysOnTop +LastFound +Parent" guiName " +HwndhGui" guiName "Search")
			else Gui.New(guiName "Search", "-Caption -Border +ToolWindow -SysMenu +AlwaysOnTop +LastFound +Parent" guiName " +E0x08000000 +HwndhGui" guiName "Search")
            Gui.SetDefault(guiName "Search")
            Gui.Margin(guiName "Search", 0, 0)
            Gui.Color(guiName "Search", "White")
            Gui.Font(guiName "Search", Gui%guiName%.Font, Gui%guiName%.Font_Size, Gui%guiName%.Font_Quality)
            Gui.Add(guiName "Search", "Edit", "x" 0 " y" 0 " w" SearchBox_W " h" SearchBox_H " FontQuality5 BackgroundTrans hwndhEDIT_SearchBar cWhite Limit1")
            WinSet, Transparent, 1
            
            global GuiTradesBuySearchHidden, GuiTradesBuySearchHidden_Controls
            global GuiTradesSellSearchHidden, GuiTradesSellSearchHidden_Controls
			if (_preview)
            	Gui.New(guiName "SearchHidden", "-Caption -Border +ToolWindow -SysMenu +AlwaysOnTop +LastFound +HwndhGui" guiName "SearchHidden")
			else Gui.New(guiName "SearchHidden", "-Caption -Border +ToolWindow -SysMenu +AlwaysOnTop +E0x08000000 +LastFound +HwndhGui" guiName "SearchHidden")
            Gui.SetDefault(guiName "SearchHidden")
            Gui.Margin(guiName "SearchHidden", 0, 0)
            Gui.Color(guiName "SearchHidden", "White")
            Gui.Font(guiName "SearchHidden", Gui%guiName%.Font, Gui%guiName%.Font_Size, Gui%guiName%.Font_Quality)
            Gui.Add(guiName "SearchHidden", "Edit", "x" 0 " y" 0 " w" SearchBox_W " h" SearchBox_H " FontQuality5 BackgroundTrans hwndhEDIT_HiddenSearchBar")

            Gui%guiName%_Controls["Gui" guiName "SearchHandle"] := Gui%guiName%Search.Handle
            Gui%guiName%_Controls["Gui" guiName "SearchHiddenHandle"] := Gui%guiName%SearchHidden.Handle
            Gui%guiName%_Controls.hEDIT_SearchBar := Gui%guiName%Search_Controls.hEDIT_SearchBar
            Gui%guiName%_Controls.hEDIT_HiddenSearchBar := Gui%guiName%SearchHidden_Controls.hEDIT_HiddenSearchBar

            Gui.BindFunctionToControl("GUI_Trades_V2", guiName "SearchHidden", "hEDIT_HiddenSearchBar", "SetFakeSearch", _buyOrSell, makeEmpty:=False) 

            Gui.SetDefault(guiName)
        }

        if (_guiMode="Slots") {
            sample1 := Get_TextCtrlSize("EXTREMELY_UNNECESSARILY_LONG_SAMPLE_TEXT", PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size, maxWidth:="", params="R1", ctrlType:="Text").W
            sample2 := Get_TextCtrlSize("EXTREMELY_UNNECESSARILY_LONG_SAMPLE_TEXT", PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size, maxWidth:="", params="R1", ctrlType:="Edit").W
            Gui.Add(guiName, "Picture", "x" Header2_X " y" Header2_Y " w" Header2_W " h" Header2_H " hwndhIMG_Header2 BackgroundTrans", SKIN.Assets.Misc.Header2) ; Title bar
            Gui.Add(guiName, "Text", "x" SearchBox_X+( (sample2-sample1)/2 ) " y" SearchBox_Y " w" SearchBox_W-( (sample2-sample1)/2 ) " h" SearchBox_H " FontQuality5 BackgroundTrans +0x200 c" SKIN.Settings.COLORS.SearchBar_Empty " hwndhTEXT_SearchBarFake", "...")
        }
        if (_guiMode="Tabs") {
            Gui.Add(guiName, "Picture", "x" TabsBackground_X " y" TabsBackground_Y " w" TabsBackground_W " h" TabsBackground_H " hwndhIMG_TabsBackground BackgroundTrans", SKIN.Assets.Misc.Tabs_Background) ; Title bar
        }
            
        Gui.Add(guiName, "ImageButton", "x" LeftArrow_X " y" LeftArrow_Y " w" LeftArrow_W " h" LeftArrow_H " hwndhBTN_LeftArrow", "", styles.Arrow_Left, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size)
        Gui.Add(guiName, "ImageButton", "x" RightArrow_X " y" RightArrow_Y " w" RightArrow_W " h" RightArrow_H " hwndhBTN_RightArrow", "", styles.Arrow_Right, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size)
        if (_guiMode="Tabs")
            Gui.Add(guiName, "ImageButton", "x" CloseTab_X " y" CloseTab_Y " w" CloseTab_W " h" CloseTab_H " hwndhBTN_CloseTab", "", styles.Close_Tab, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size)

        Gui.BindFunctionToControl("GUI_Trades_V2", guiName, "hBTN_LeftArrow", "ScrollUp", _buyOrSell) 
        Gui.BindFunctionToControl("GUI_Trades_V2", guiName, "hBTN_RightArrow", "ScrollDown", _buyOrSell)
        if (_guiMode="Tabs")
            Gui.BindFunctionToControl("GUI_Trades_V2", guiName, "hBTN_CloseTab", "RemoveTab", _buyOrSell, tabNum:=0, massRemove:=False)

        if (_guiMode="Tabs") {
            Loop % _tabsToRender {
                xpos := IsBetween(A_Index, 1, maxTabsToShow) ? TabButton%A_Index%_X : TabButton%maxTabsToShow%_X
                Gui.Add(guiName, "ImageButton", "x" xpos " y" TabButton1_Y " w" TabButton1_W " h" TabButton1_H " hwndhBTN_TabDefault" A_Index " Hidden", A_Index, Styles.Tab, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size)
                Gui.Add(guiName, "ImageButton", "x" xpos " y" TabButton1_Y " w" TabButton1_W " h" TabButton1_H " hwndhBTN_TabJoined" A_Index " Hidden", A_Index, Styles.Tab_Joined, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size)
                Gui.Add(guiName, "ImageButton", "x" xpos " y" TabButton1_Y " w" TabButton1_W " h" TabButton1_H " hwndhBTN_TabWhisper" A_Index " Hidden", A_Index, Styles.Tab_Whisper, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size)

                Gui.BindFunctionToControl("GUI_Trades_V2", guiName, "hBTN_TabDefault" A_Index, "SetActiveTab", _buyOrSell, tabName:=A_Index, autoScroll:=True, skipError:=False, styleChanged:=False)
                Gui.BindFunctionToControl("GUI_Trades_V2", guiName, "hBTN_TabJoined" A_Index, "SetActiveTab", _buyOrSell, tabName:=A_Index, autoScroll:=True, skipError:=False, styleChanged:=False)
                Gui.BindFunctionToControl("GUI_Trades_V2", guiName, "hBTN_TabWhisper" A_Index, "SetActiveTab", _buyOrSell, tabName:=A_Index, autoScroll:=True, skipError:=False, styleChanged:=False)

                Gui%guiName%["Tab_" A_Index] := Gui%guiName%_Controls["hBTN_TabDefault" A_Index]
            }            
        }

        Loop % _tabsToRender {
			tabNum := A_Index, slotGuiName := guiName "_Slot" tabNum
            Gui.New(slotGuiName, "-Caption -Border +AlwaysOnTop +Parent" guiName " +LabelGUI_Trades_V2_Slot_ +HwndhGui" slotGuiName, "POE TC - Item Slot " tabNum)
            Gui.SetDefault(slotGuiName)
			Gui.Margin(slotGuiName, 0, 0)
			Gui.Color(slotGuiName, SKIN.Assets.Misc.Transparency_Color)
			Gui.Font(slotGuiName, Gui%guiName%.Font, Gui%guiName%.Font_Size, Gui%guiName%.Font_Quality)

			Gui.Add(slotGuiName, "Text", "x0 y0 w0 h0 BackgroundTrans Hidden hwndhTEXT_HiddenInfos", "")

			Gui.Add(slotGuiName, "Picture", "x" BackgroundImg_X " y" BackgroundImg_Y " hwndhIMG_Background BackgroundTrans", SKIN.Assets.Misc.Background)
			TilePicture(slotGuiName, Gui%guiName%_Slot%tabNum%_Controls.hIMG_Background, BackgroundImg_W, BackgroundImg_H) ; Fill the background
			
			Gui.Add(slotGuiName, "Text", "x" ItemName_X " y" ItemName_Y " w" ItemName_W " R1 BackgroundTrans hwndhTEXT_ItemName c" SKIN.Settings.COLORS.Trade_Info_2)
			Gui.Add(slotGuiName, "Text", "x" SellerName_X " y" SellerName_Y " w" SellerName_W " R1 BackgroundTrans hwndhTEXT_SellerName c" SKIN.Settings.COLORS.Trade_Info_2)
			Gui.Add(slotGuiName, "Picture", "x" CurrencyImg_X " y" CurrencyImg_Y " w" CurrencyImg_W " h" CurrencyImg_H " 0xE BackgroundTrans  hwndhIMG_CurrencyIMG")
			Gui.Add(slotGuiName, "Text", "x" PriceCount_X " y" PriceCount_Y " w" PriceCount_W " R1 BackgroundTrans hwndhTEXT_PriceCount c" SKIN.Settings.COLORS.Trade_Info_2)
			Gui.Add(slotGuiName, "Text", "x" AdditionalMsg_X " y" AdditionalMsg_Y " w" AdditionalMsg_W " R1 BackgroundTrans  hwndhTEXT_AdditionalMessage c" SKIN.Settings.COLORS.Trade_Info_2)
			Gui.Add(slotGuiName, "Text", "x" Time_X " y" Time_Y " w" Time_W " R1 BackgroundTrans hwndhTEXT_TimeSent c" SKIN.Settings.COLORS.Trade_Info_2)
            if (_guiMode="Slots")
			    Gui.Add(slotGuiName, "ImageButton", "x" CloseTabVertical_X " y" CloseTabVertical_Y " w" CloseTabVertical_W " h" CloseTabVertical_H " hwndhBTN_CloseTab", "", Styles.Close_Tab_Vertical, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size)

            itemNamePos := Gui.GetControlPos(slotGuiName, "hTEXT_ItemName")
			if (_buyOrSell = "Buy") {
				Gui.Add(slotGuiName, "ImageButton", "x" SmallButton_X " y" SmallButton_Y " w" SmallButton_W " h" SmallButton_H " hwndhBTN_WhisperSeller", "", Styles.Button_Whisper, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size) ; write to seller
				Gui.Add(slotGuiName, "ImageButton", "x+" SmallButton_Space " yp wp hp hwndhBTN_HideoutSeller", "", Styles.Button_Hideout, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size) ; hideout seller
				Gui.Add(slotGuiName, "ImageButton", "x+" SmallButton_Space " yp wp hp hwndhBTN_KickSelfSeller", "", Styles.Button_Kick, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size) ; thanks seller
				Gui.Add(slotGuiName, "ImageButton", "x+" SmallButton_Space " yp wp hp hwndhBTN_ThankSeller", "", Styles.Button_Thanks, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size) ; kick self
			}
			if (_preview=True) {
				Loop 5 {
					xpos := A_Index=1?SmallButton_X:"+" SmallButton_Space, ypos := SmallButton_Y
					if !IsObject(Styles.SmallButton_Test) {
						GUI_Trades_V2.Create_Style(styles, "SmallButton_Test"
							,{Left: SKIN.Assets.Button_Generic.Left, Right: SKIN.Assets.Button_Generic.Right, Fill: SKIN.Assets.Button_Generic.Fill, Color: SKIN.Settings.Colors.Button_Normal
							,LeftHover: SKIN.Assets.Button_Generic.Left_Hover, RightHover: SKIN.Assets.Button_Generic.Right_Hover, FillHover: SKIN.Assets.Button_Generic.Fill_Hover, ColorHover: SKIN.Settings.Colors.Button_Hover
							,LeftPress: SKIN.Assets.Button_Generic.Left_Press, RightPress: SKIN.Assets.Button_Generic.Right_Press, FillPress: SKIN.Assets.Button_Generic.Fill_Press, ColorPress: SKIN.Settings.Colors.Button_Press
							,LeftDefault: SKIN.Assets.Button_Generic.Left_Hover, RightDefault: SKIN.Assets.Button_Generic.Right_Hover, FillDefault: SKIN.Assets.Button_Generic.Fill_Hover, Color_Default: SKIN.Settings.Colors.Button_Hover
							,Width:SmallButton_W, Height:SmallButton_H})
					}
					Gui.Add(slotGuiName, "ImageButton", "x" xpos " y" ypos " w" SmallButton_W " h" SmallButton_H " hwndhBTN_SmallSlot" A_Index " c" SKIN.Settings.COLORS.Trade_Info_2, "[ + ]", Styles.SmallButton_Test, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size)
					Gui.Add(slotGuiName, "ImageButton", "xp yp wp hp hwndhBTN_SmallButton" A_Index " c" SKIN.Settings.COLORS.Trade_Info_2 " Hidden", "[ " A_Index " ]", Styles.SmallButton_Test, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size)
					Gui.BindFunctionToControl("GUI_Trades_V2", slotGuiName, "hBTN_SmallSlot" A_Index, "Preview_AddSmallButtonToSlot", _buyOrSell, A_Index) 
					Gui.BindFunctionToControl("GUI_Trades_V2", slotGuiName, "hBTN_SmallButton" A_Index, "Preview_CustomizeThisSmallButton", _buyOrSell, A_Index) 
				}

				Loop 3 { ; Max 3 rows of buttons
					rowNum := A_Index, rowX := 6, rowH := SmallButton_H, rowW := TabContentSlot_W-(5+5)
					row1Y := SmallButton_Y+rowH+5, row2Y := row1Y+rowH+5, row3Y := row2Y+rowH+5, rowY := row%rowNum%Y

					if !IsObject(Styles.CustomButtonRow_Test) {
						GUI_Trades_V2.Create_Style(styles, "CustomButtonRow_Test"
							,{Left: SKIN.Assets.Button_Generic.Left, Right: SKIN.Assets.Button_Generic.Right, Fill: SKIN.Assets.Button_Generic.Fill, Color: SKIN.Settings.Colors.Button_Normal
							,LeftHover: SKIN.Assets.Button_Generic.Left_Hover, RightHover: SKIN.Assets.Button_Generic.Right_Hover, FillHover: SKIN.Assets.Button_Generic.Fill_Hover, ColorHover: SKIN.Settings.Colors.Button_Hover
							,LeftPress: SKIN.Assets.Button_Generic.Left_Press, RightPress: SKIN.Assets.Button_Generic.Right_Press, FillPress: SKIN.Assets.Button_Generic.Fill_Press, ColorPress: SKIN.Settings.Colors.Button_Press
							,LeftDefault: SKIN.Assets.Button_Generic.Left_Hover, RightDefault: SKIN.Assets.Button_Generic.Right_Hover, FillDefault: SKIN.Assets.Button_Generic.Fill_Hover, Color_Default: SKIN.Settings.Colors.Button_Hover
							,Width:rowW, Height:rowH})
					}
					Gui.Add(slotGuiName, "ImageButton", "x" rowX " y" rowY " w" rowW " h" rowH " hwndhBTN_CustomRowSlot" rowNum " c" SKIN.Settings.COLORS.Trade_Info_2, "[ + ]", Styles.CustomButtonRow_Test, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size)
					Gui.BindFunctionToControl("GUI_Trades_V2", slotGuiName, "hBTN_CustomRowSlot" rowNum, "Preview_AddCustomButtonsToRow", _buyOrSell, rowNum)
					Loop 10 { ; Max 10 buttons per row
						btnsCount := A_Index, spaceBetweenBtns := 0
						btnWidth := (rowW/btnsCount), btnHeight := rowH

						if !IsObject(Styles["CustomButtonRow" rowNum "Max" btnsCount]) {
							GUI_Trades_V2.Create_Style(styles, "CustomButtonRow" rowNum "Max" btnsCount
								,{Left: SKIN.Assets.Button_Generic.Left, Right: SKIN.Assets.Button_Generic.Right, Fill: SKIN.Assets.Button_Generic.Fill, Color: SKIN.Settings.Colors.Button_Normal
								,LeftHover: SKIN.Assets.Button_Generic.Left_Hover, RightHover: SKIN.Assets.Button_Generic.Right_Hover, FillHover: SKIN.Assets.Button_Generic.Fill_Hover, ColorHover: SKIN.Settings.Colors.Button_Hover
								,LeftPress: SKIN.Assets.Button_Generic.Left_Press, RightPress: SKIN.Assets.Button_Generic.Right_Press, FillPress: SKIN.Assets.Button_Generic.Fill_Press, ColorPress: SKIN.Settings.Colors.Button_Press
								,LeftDefault: SKIN.Assets.Button_Generic.Left_Hover, RightDefault: SKIN.Assets.Button_Generic.Right_Hover, FillDefault: SKIN.Assets.Button_Generic.Fill_Hover, Color_Default: SKIN.Settings.Colors.Button_Hover
								,Width:btnWidth, Height:btnHeight})
						}
						Loop %btnsCount% {
							btnX := A_Index=1?rowX:"+" spaceBetweenBtns, btnY := rowY
							Gui.Add(slotGuiName, "ImageButton", "x" btnX " y" btnY " w" btnWidth " h" btnHeight " hwndhBTN_CustomButtonRow" rowNum "Max" btnsCount "Num" A_Index " c" SKIN.Settings.COLORS.Trade_Info_2 " Hidden", "[ " A_Index " ]", Styles["CustomButtonRow" rowNum "Max" btnsCount], PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size)
							Gui.BindFunctionToControl("GUI_Trades_V2", slotGuiName, "hBTN_CustomButtonRow" rowNum "Max" btnsCount "Num" A_Index, "Preview_CustomizeThisCustomButton", _buyOrSell, rowNum, btnsCount, A_Index)
						}
					}
				}
				
			}
			/*
			else if (_buyOrSell = "Sell") && (_tabsOrSlots="Tabs") {
				; Adding special buttons
				Loop 5 {
					speX := A_Index=1?SmallButton_X:"+" SmallButton_Space, speY := SmallButton_Y
					Gui.Add(slotGuiName, "Button", "x" speX " y" speY " w" SmallButton_W " h" SmallButton_H " hwndhBTN_FakeSpecialBtn" A_Index " Hidden")
					spe%A_Index%X := Gui.GetControlPos(slotGuiName, "hBTN_FakeSpecialBtn" A_Index).X
				}
				if (GUI_Trades_V2.Get_ButtonsRowsCount().Special > 0) {
					Loop 5 { ; Max num of special btns
						speIndex := A_Index
						speSettings := INI.Get(PROGRAM.INI_FILE, "SETTINGS_SPECIAL_BUTTON_" speIndex,,1)
						speSlot := speSettings.Slot, speType := speSettings.Type, speEnabled := speSettings.Enabled="True"?True:False
						speStyle := Styles["Button_" speType]

						if (speEnabled) {
							speNum := speNum?speNum+1:1
							speX := spe%speSlot%X, speY := "p"
							
							Gui.Add(slotGuiName, "ImageButton", "x" speX " y" speY " w" SmallButton_W " h" SmallButton_H " hwndhBTN_Special" speIndex, "", speStyle, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size)
							; Gui.BindFunctionToControl("GUI_Trades_V2", slotGuiName, "hBTN_Special" speIndex, "DoTradeButtonAction", _buyOrSell, speIndex, "Special") 
						}
					}
				}
				; Adding custom buttons
				Loop 3 {
					Gui.Add(slotGuiName, "Button", "x0 y+5 w0 h" CustomButton_H " hwndhBTN_FakeCustomBtn" A_Index " Hidden")
				}
				custTopY := Gui.GetControlPos(slotGuiName, "hBTN_FakeCustomBtn1").Y
				custMidY := Gui.GetControlPos(slotGuiName, "hBTN_FakeCustomBtn2").Y
				custBotY := Gui.GetControlPos(slotGuiName, "hBTN_FakeCustomBtn3").Y
				if (GUI_Trades_V2.Get_ButtonsRowsCount().Custom > 0) {
					Loop 9 { ; Max num of custom btns
						custIndex := A_Index
						custSettings := INI.Get(PROGRAM.INI_FILE, "SETTINGS_CUSTOM_BUTTON_" custIndex,,1)
						custSlot := custSettings.Slot, custSize := custSettings.Size, custName := custSettings.Name, custEnabled := custSettings.Enabled="True"?True:False
						custStyle := custSize="Small"?Styles.Button_OneThird : custSize="Medium"?Styles.Button_TwoThird : custSize="Large"?Styles.Button_ThreeThird : ""

						if (custEnabled) {
							custNum := custNum?custNum+1:1
							custX := IsIn(custSlot, "1,4,7")?CustomButtonLeft_X : IsIn(custSlot, "2,5,8")?CustomButtonMiddle_X : IsIn(custSlot, "3,6,9")?CustomButtonRight_X : ""
							custY := IsIn(custSlot, "1,2,3")?custTopY : IsIn(custSlot, "4,5,6")?custMidY : IsIn(custSlot, "7,8,9")?custBotY : ""
							custW := custSize="Small"?CustomButtonOneThird_W : custSize="Medium"?CustomButtonTwoThird_W : custSize="Large"?CustomButtonThreeThird_W : ""

							Gui.Add(slotGuiName, "ImageButton", "x" custX " y" custY " w" custW " h" CustomButton_H " hwndhBTN_Custom" custSlot, custName, custStyle, PROGRAM.FONTS[Gui%guiName%.Font], Gui%guiName%.Font_Size)
							; Gui.BindFunctionToControl("GUI_Trades_V2", slotGuiName, "hBTN_Custom" custSlot, "DoTradeButtonAction", _buyOrSell, custIndex, "Custom") 
						}
					}
				}
			}
			*/
			
            ; TO_DO_V2 add TradeVerify 
            ; Gui.Add(guiName, "Picture", "x" TradeVerify_X " y" TradeVerify_Y " w" TradeVerify_W " h" TradeVerify_H " hwndhIMG_TradeVerify" tabNum " BackgroundTrans", SKIN.Assets.Trade_Verify.Grey)
			; Gui.Add(guiName, "Picture", "x" TradeVerify_X " y" TradeVerify_Y " w" TradeVerify_W " h" TradeVerify_H " hwndhIMG_TradeVerifyGrey" tabNum " Hidden BackgroundTrans", SKIN.Assets.Trade_Verify.Grey)
			; Gui.Add(guiName, "Picture", "x" TradeVerify_X " y" TradeVerify_Y " w" TradeVerify_W " h" TradeVerify_H " hwndhIMG_TradeVerifyOrange" tabNum " Hidden BackgroundTrans", SKIN.Assets.Trade_Verify.Orange)
			; Gui.Add(guiName, "Picture", "x" TradeVerify_X " y" TradeVerify_Y " w" TradeVerify_W " h" TradeVerify_H " hwndhIMG_TradeVerifyGreen" tabNum " Hidden BackgroundTrans", SKIN.Assets.Trade_Verify.Green)
			; Gui.Add(guiName, "Picture", "x" TradeVerify_X " y" TradeVerify_Y " w" TradeVerify_W " h" TradeVerify_H " hwndhIMG_TradeVerifyRed" tabNum " Hidden BackgroundTrans", SKIN.Assets.Trade_Verify.Red)
			
			Gui%guiName%["Slot" tabNum] := Gui%guiName%_Slot%tabNum% ; adding gui array to our main gui array as a sub array
			Gui%guiName%["Slot" tabNum "_Controls"] := Gui%guiName%_Slot%tabNum%_Controls

            if (_guiMode="Slots")
                Gui.BindFunctionToControl("GUI_Trades_V2", slotGuiName, "hBTN_CloseTab", "RemoveTab", _buyOrSell, tabNum) 
            Gui.BindFunctionToControl("GUI_Trades_V2", slotGuiName, "hBTN_WhisperSeller", "DoTradeButtonAction", _buyOrSell, tabNum, "WhisperSeller") 
            Gui.BindFunctionToControl("GUI_Trades_V2", slotGuiName, "hBTN_HideoutSeller", "DoTradeButtonAction", _buyOrSell, tabNum, "HideoutSeller") 
            Gui.BindFunctionToControl("GUI_Trades_V2", slotGuiName, "hBTN_KickSelfSeller", "DoTradeButtonAction", _buyOrSell, tabNum, "KickSelfSeller") 
            Gui.BindFunctionToControl("GUI_Trades_V2", slotGuiName, "hBTN_ThankSeller", "DoTradeButtonAction", _buyOrSell, tabNum, "ThankSeller") 

			; Gui.Show(slotGuiName, "x0 y0 w" guiWidth+borderSize " h" TabContentSlot_H " Hide")	
			Gui.Show(slotGuiName, "AutoSize Hide")	

            Gui%guiName%.ImageButton_Errors .= Gui%guiName%["Slot" tabNum].ImageButton_Errors
        }

        if (_guiMode="Slots") {
            ; calculate slot positions
            Gui%guiName%["Slot1_Pos"] := (Header2_Y+Header2_H)*windowsDPI
            Gui%guiName%["Slot2_Pos"] := Gui%guiName%["Slot1_Pos"] + (Gui%guiName%.Slot1.Height*windowsDPI)
            Gui%guiName%["Slot3_Pos"] := Gui%guiName%["Slot2_Pos"] + (Gui%guiName%.Slot1.Height*windowsDPI)
            Gui%guiName%["Slot4_Pos"] := Gui%guiName%["Slot3_Pos"] + (Gui%guiName%.Slot1.Height*windowsDPI)
        }
        else if (_guiMode="Tabs")
            Gui%guiName%["Slot1_Pos"] := (TabsBackground_Y+TabsBackground_H)*windowsDPI

        if (Gui%guiName%.ImageButton_Errors) {
			Gui, ErrorLog:New, +AlwaysOnTop +ToolWindow +hwndhGuiErrorLog
			Gui, ErrorLog:Add, Text, x10 y10,% "One or multiple error(s) occured while creating the Trades GUI imagebuttons."
			. "`nIn case you are getting ""Couldn't get button's font"" errors, restarting your computer should fix it."
			Gui, ErrorLog:Add, Edit, xp y+5 w500 R15 ReadOnly,% Gui%guiName%.ImageButton_Errors
			Gui, ErrorLog:Add, Link, xp y+5,% "If you need assistance, you can contact me on: "
			. "<a href=""" PROGRAM.LINK_GITHUB """>GitHub</a> - <a href=""" PROGRAM.LINK_REDDIT """>Reddit</a> - <a href=""" PROGRAM.LINK_GGG """>PoE Forums</a> - <a href=""" PROGRAM.LINK_DISCORD """>Discord</a>"
			Gui, ErrorLog:Show,xCenter yCenter,% PROGRAM.NAME " - Trades GUI Error log"
			WinWait, ahk_id %hGuiErrorLog%
            ; WinClose, ahk_id %hGuiErrorLog%
			WinWaitClose, ahk_id %hGuiErrorLog%
		}

        if !IsObject(GuiTrades)
            GuiTrades := {}
        if !IsObject(GuiTrades_Controls)
            GuiTrades_Controls := {}
	    GuiTrades[_buyOrSell] := Gui%guiName%, GuiTrades_Controls[_buyOrSell] := Gui%guiName%_Controls
		GuiTrades[_buyOrSell].Styles := styles

        savedXPos := PROGRAM.SETTINGS.SETTINGS_MAIN[_buyOrSell "_Pos_X"], savedYPos := PROGRAM.SETTINGS.SETTINGS_MAIN[_buyOrSell "_Pos_Y"]
        savedXPos := IsNum(savedXPos) ? savedXPos : 0, savedYPos := IsNum(savedYPos) ? savedYPos : 0
		if (_preview)
        	Gui.Show(guiName, "x0 y0 h" guiFullHeight " w" guiFullWidth " Hide")
		else Gui.Show(guiName, "x" savedXPos " y" savedXPos " h" guiFullHeight " w" guiFullWidth)
        if (_guiMode="Slots") { 
            Gui.Show(guiName "Search", "x" SearchBox_X " y" SearchBox_Y " Hide")
            Gui.Show(guiName "SearchHidden", "x0 y0 w0 h0 NoActivate") ; Not hidden on purpose so it can work with ShellMessage to empty on click
        }
        Gui%guiName%.Is_Created := True		

        ; GUI_Trades_V2.Minimize(guiName)

		if !(_preview) {
			OnMessage(0x200, "WM_MOUSEMOVE")
			OnMessage(0x20A, "WM_MOUSEWHEEL")
			OnMessage(0x201, "WM_LBUTTONDOWN")
			OnMessage(0x202, "WM_LBUTTONUP")

			GUI_Trades_V2.SetTransparency_Inactive(_buyOrSell)
			if (PROGRAM.SETTINGS.SETTINGS_MAIN.AllowClicksToPassThroughWhileInactive = "True")
				GUI_Trades_V2.Enable_ClickThrough(_buyOrSell)

			GUI_Trades_V2.ResetPositionIfOutOfBounds(_buyOrSell)

			GUI_Trades_V2.EnableHotkeys(_buyOrSell)
		}

		if (_preview) {
			GuiTrades[_buyOrSell].Preview := True
			OnMessage(0x201, "WM_LBUTTONDOWN_MOVE")
			GUI_Trades_V2.SetTransparencyPercent(_buyOrSell, 100)
		}
		Return

		GUI_Trades_V2_ContextMenu:
			_buyOrSell := IsContaining(A_Gui, "Buy") ? "Buy" : "Sell"
			_buyOrSell .= IsContaining(A_Gui, "Preview") ? "Preview" : ""

			ctrlHwnd := Get_UnderMouse_CtrlHwnd()
			GuiControlGet, ctrlName, %A_Gui%:Name,% ctrlHwnd
			GUI_Trades_V2.ContextMenu(ctrlName, _buyOrSell)
		Return

        GUI_Trades_V2_Slot_Size:
			; So we can know the Slot gui height
			if (A_Gui)
				Gui%A_Gui%["Height"] := A_GuiHeight, Gui%A_Gui%["Width"] := A_GuiWidth
		Return

		GUI_Trades_V2_Slot_ContextMenu:
			_buyOrSell := IsContaining(A_Gui, "Buy") ? "Buy" : "Sell"
			_buyOrSell .= IsContaining(A_Gui, "Preview") ? "Preview" : ""

			ctrlHwnd := Get_UnderMouse_CtrlHwnd()
			GuiControlGet, ctrlName, %A_Gui%:Name,% ctrlHwnd
			GUI_Trades_V2.ContextMenu(ctrlName, _buyOrSell)
		return
    }

    ContextMenu(CtrlName, _buyOrSell) {
		global PROGRAM, GuiTrades, GuiTrades_Controls, GuiSettings
		iniFile := PROGRAM.INI_FILE
		isSlot := GuiTrades[_buyOrSell].Is_Slots
		isTabs := GuiTrades[_buyOrSell].Is_Tabs
		if (isSlot) {
			if RegExMatch(A_Gui, "iO)Trades" _buyOrSell "_Slot(\d+)", slotIDPat)
				thisSlotID := slotIDPat.1
		}
		else if (isTabs) {
			thisSlotID := GuiTrades[_buyOrSell].Active_Tab
		}

		if IsContaining(A_Gui, "Preview") {
			if RegExMatch(CtrlName, "iO)hBTN_CustomButtonRow(\d+?)Max(\d+)Num(\d+)", custonBtnPat) {
				; msgbox % GuiTrades[_buyOrSell]["Slot1_Controls"]["hBTN_CustomButtonRow" 1 "Max" 5 "Num" 1]
				rowNum := custonBtnPat.1, btnsCount := custonBtnPat.2, btnNum := custonBtnPat.3
				guiName := "Trades" _buyOrSell "_Slot1"

				try Menu, RMenu, DeleteAll
				Menu, RMenu, Add, Add another button, GUI_Trades_V2_ContextMenu_AddOneButton
				Menu, RMenu, Add, Remove one button, GUI_Trades_V2_ContextMenu_RemoveOneButton
				Menu, RMenu, Show
				return
			}
		}
		else {
			; Creating the menu
			try Menu, RClickMenu, DeleteAll
			Menu, RClickMenu, Add,% PROGRAM.TRANSLATIONS.TrayMenu.LockPosition, GUI_Trades_V2_ContextMenu_LockPosition
			if (_buyOrSell)
				Menu, RClickMenu, Add, Expand upwards?, GUI_Trades_V2_ContextMenu_ExpandUpwardsToggle
			Menu, RClickMenu, Add
			Menu, RClickMenu, Add,% PROGRAM.TRANSLATIONS.GUI_Trades.RMENU_CloseAllTabs, GUI_Trades_V2_ContextMenu_CloseAllTabs
			Menu, RClickMenu, Add,% PROGRAM.TRANSLATIONS.GUI_Trades.RMENU_CloseOtherTabsForSameItem, GUI_Trades_V2_ContextMenu_CloseOtherTabsWithSameItem
			Menu, RClickMenu, Add
			Menu, RClickMenu, Add,% "Settings", GUI_Trades_V2_ContextMenu_OpenTrayMenu
			; Check - Disable - etc
			if (PROGRAM.SETTINGS.SETTINGS_MAIN.TradesGUI_Locked = "True")
				Menu, RClickMenu, Check,% PROGRAM.TRANSLATIONS.TrayMenu.LockPosition
			if (!GuiTrades[_buyOrSell].Tabs_Count)
				Menu, RClickMenu, Disable,% PROGRAM.TRANSLATIONS.GUI_Trades.RMENU_CloseAllTabs
			if (!GuiTrades[_buyOrSell].Tabs_Count) || (isSlot && !thisSlotID)
				Menu, RClickMenu, Disable,% PROGRAM.TRANSLATIONS.GUI_Trades.RMENU_CloseOtherTabsForSameItem
			; Show
			Menu, RClickMenu, Show		
		}
		Return

		GUI_Trades_V2_ContextMenu_AddOneButton:
			if (btnsCount=10)
				return

			Loop % btnsCount ; Hiding previous buttons
				GuiControl, %guiName%:Hide,% GuiTrades[_buyOrSell]["Slot1_Controls"]["hBTN_CustomButtonRow" rowNum "Max" btnsCount "Num" A_Index]
			Loop % btnsCount+1 ; Showing new ones
				GuiControl, %guiName%:Show,% GuiTrades[_buyOrSell]["Slot1_Controls"]["hBTN_CustomButtonRow" rowNum "Max" btnsCount+1 "Num" A_Index]

			; Make sure new button is chosen
			GUI_Trades_V2.Preview_CustomizeThisCustomButton(_buyOrSell, rowNum, btnsCount+1, GuiSettings.CUSTOM_BUTTON_SELECTED_NUM)
		return

		GUI_Trades_V2_ContextMenu_RemoveOneButton:
			Loop % btnsCount ; Hiding previous buttons
				GuiControl, %guiName%:Hide,% GuiTrades[_buyOrSell]["Slot1_Controls"]["hBTN_CustomButtonRow" rowNum "Max" btnsCount "Num" A_Index]

			if (btnsCount=1) ; Show the row button bcs no buttons left
				GuiControl, %guiName%:Show,% GuiTrades[_buyOrSell]["Slot1_Controls"]["hBTN_CustomRowSlot" rowNum]
			else ; Show new buttons
				Loop % btnsCount-1
					GuiControl, %guiName%:Show,% GuiTrades[_buyOrSell]["Slot1_Controls"]["hBTN_CustomButtonRow" rowNum "Max" btnsCount-1 "Num" A_Index]

			; Make sure new button is chosen
			if (btnsCount-1 >= GuiSettings.CUSTOM_BUTTON_SELECTED_NUM) ; We can still choose same one, bcs num still exists
				GUI_Trades_V2.Preview_CustomizeThisCustomButton(_buyOrSell, rowNum, btnsCount-1, GuiSettings.CUSTOM_BUTTON_SELECTED_NUM)
			else ; Choose last button, bcs our button doesn't exist anymore
				GUI_Trades_V2.Preview_CustomizeThisCustomButton(_buyOrSell, rowNum, btnsCount-1, btnsCount-1)
		return

		GUI_Trades_V2_ContextMenu_OpenTrayMenu:
			Menu,Tray,Show
		return

		GUI_Trades_V2_ContextMenu_ExpandUpwardsToggle:
			TrayNotifications.Show("""Expand upwards""", "Feature not added yet")
			SetTimer, RemoveToolTip, -2000
		return

		GUI_Trades_V2_ContextMenu_LockPosition:
			Tray_ToggleLockPosition(_buyOrSell)
		Return

		GUI_Trades_V2_ContextMenu_CloseAllTabs:
			GUI_Trades_V2.CloseAllTabs(_buyOrSell)
		return

		GUI_Trades_V2_ContextMenu_CloseOtherTabsWithSameItem:
			GUI_Trades_V2.CloseOtherTabsForSameItem(_buyOrSell, thisSlotID)
		return
	}
	
    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
     *
     * NEEDS ADAPTATION OR CHANGE
     *
     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
    */

    DoTradeButtonAction(_buyOrSell, slotNum, btnType) {
		global PROGRAM
		global GuiTrades, GuiTrades_Controls
		static uniqueNum

		if !IsNum(slotNum)
			Return
			
		slotContent := GUI_Trades_V2.GetTabContent(_buyOrSell, slotNum)
		tabPID := slotContent.PID

		if WinExist("ahk_group POEGameGroup ahk_pid " tabPID) {
			uniqueNum := !uniqueNum
			keysState := GetKeyStateFunc("Ctrl,LCtrl,RCtrl")

			actionType := btnType="WhisperSeller" ? "WRITE_MSG"
				: btnType="HideoutSeller" ? "SEND_MSG"
				: btnType="KickSelfSeller" ? "KICK_MYSELF"
				: btnType="ThankSeller" ? "SEND_MSG"
				: ""
			
			actionContent := btnType="WhisperSeller" ? "@%seller% "
				: btnType="HideoutSeller" ? "/hideout %seller%"
				: btnType="KickSelfSeller" ? "/kick %myself%"
				: btnType="ThankSeller" ? "@%seller% ty!"
				: ""

			actionContent := StrReplace(actionContent, "%seller%", slotContent.Seller)

			if (actionType)
				Do_Action(actionType, actionContent)
			SetKeyStateFunc(keysState)

			if (btnType="ThankSeller") {
				GUI_Trades_V2.SaveStats(slotNum)
				GUI_Trades_V2.RemoveTab(slotNum)
			}
			
			
		}
		else { ; Instance doesn't exist anymore, replace and do btn action
			runningInstances := Get_RunningInstances()
			if !(runningInstances.Count) {
				TrayNotifications.Show(PROGRAM.TRANSLATIONS.TrayNotifications.NoGameInstanceFound_Title, PROGRAM.TRANSLATIONS.TrayNotifications.NoGameInstanceFound_Msg)
				Return
			}
            else if (runningInstances.Count = 1)
                newInstancePID := runningInstances.1.PID
            else
			    newInstancePID := GUI_ChooseInstance.Create(runningInstances, "PID").PID

			Loop % GuiTrades[_buyOrSell].Tabs_Count {
				loopTabContent := GUI_Trades_V2.GetTabContent(_buyOrSell, A_Index)
				loopTabPID := loopTabContent.PID

				if (loopTabPID = tabPID)
					GUI_Trades_V2.UpdateSlotContent(_buyOrSell, A_Index, "PID", newInstancePID)
			}
			GUI_Trades_V2.DoTradeButtonAction(_buyOrSell, slotNum, btnType)
		}
	}

    SaveStats(_buyOrSell, slotNum) {
		global PROGRAM, DEBUG
        if (_buyOrSell="Buy")
		    iniFile := PROGRAM.TRADES_HISTORY_BUY_FILE

		slotContent := GUI_Trades_V2.GetTabContent(_buyOrSell, slotNum)

		; if (DEBUG.settings.use_chat_logs || slotContent.Seller = "iSellStuff") {
		; 	TrayNotifications.Show(PROGRAM.TRANSLATIONS.TrayNotifications.iSellStuffNotSaved_Title, PROGRAM.TRANSLATIONS.TrayNotifications.iSellStuffNotSaved_Msg)
		; 	Return
		; }

		index := INI.Get(iniFile, "GENERAL", "Index")
		index := IsNum(index) ? index : 0

		index++
		; existsAlready := INI.Get(iniFile, index, "Buyer")
		; existsAlready := existsAlready = "ERROR" || existsAlready = "" ? False : True
		; if (existsAlready = True) {
		; 	trayTxt := StrReplace(PROGRAM.TRANSLATIONS.TrayNotifications.ErrorSavingStatsSameIDExists_Msg, "%number%", index)
		; 	TrayNotifications.Show(PROGRAM.TRANSLATIONS.TrayNotifications.ErrorSavingStatsSameIDExists_Title, trayTxt)
		; 	Loop {
		; 		index++
		; 		existsAlready := INI.Get(iniFile, index, "Buyer")
		; 		if (existsAlready = "ERROR" || existsAlready = "")
		; 			Break
		; 	}
		; 	TrayNotifications.Show(PROGRAM.TRANSLATIONS.TrayNotifications.ErrorSavingStatsSameIDExists_Solved_Title, PROGRAM.TRANSLATIONS.TrayNotifications.ErrorSavingStatsSameIDExists_Solved_Msg)
		; }
		INI.Set(iniFile, "GENERAL", "Index", index)

		value := StrReplace(value, "`n", "\n"), value := StrReplace(value, "`r", "\n")
		INI.Set(iniFile, index, key, value)
	}

    PushNewTab(_buyOrSell, infos) {
        ; FINISHED_V2
		global PROGRAM, SKIN
		global GuiTrades, GuiTrades_Controls
		static doOnlyOnce
        tabsLimit       := GuiTrades[_buyOrSell].Tabs_Limit
		tabsCount       := GuiTrades[_buyOrSell].Tabs_Count
        maxTabsToShow   := GuiTrades[_buyOrSell].Max_Tabs_Per_Row
        isSlots         := GuiTrades[_buyOrSell].Is_Slots
        isTabs          := GuiTrades[_buyOrSell].Is_Tabs
		isFirstTab      := tabsCount=0 ? True : False

		; if (PROGRAM.SETTINGS.SETTINGS_MAIN.DisableBuyInterface="True") ; TO_DO_V2
			; return
		
        ; Comparing if we already have a tab with same exact infos
		existingTabID := GUI_Trades_V2.IsTabAlreadyExisting(_buyOrSell, infos)
		if (existingTabID)
			Return "TabAlreadyExists"
		
        ; If tabs limit is close, allocate more slots
		if (tabsCount+1 >= tabsLimit) && !IsContaining(_buyOrSell, "Preview")
			GUI_Trades_V2.IncreaseTabsLimit(_buyOrSell)

        ; Putting infos to slot
        newTabsCount := (tabsCount <= 0) ? 1 : tabsCount+1
		GUI_Trades_V2.SetSlotContent(_buyOrSell, tabsCount+1, infos)
        if (isSlots)
		    GUI_Trades_V2.SetSlotPosition(_buyOrSell, tabsCount+1, tabsCount+1)
        else if (isTabs) {
            if IsBetween(newTabsCount, 1, maxTabsToShow) { ; Show new tab btn if its in the row
                GuiControl, Trades%_buyOrSell%:Show,% GuiTrades[_buyOrSell]["Tab_" newTabsCount]
            }
            GUI_Trades_V2.SetSlotPosition(_buyOrSell, tabsCount+1, 1)
		}
		GuiTrades[_buyOrSell]["Tab" tabsCount+1 "Content"] := infos
        GuiTrades[_buyOrSell].Tabs_Count := newTabsCount

        ; Maximize if setting is enabled
		if (isFirstTab) {
            GUI_Trades_V2.SetActiveTab(_buyOrSell, 1)
			GUI_Trades_V2.SetTransparency_Active(_buyOrSell)
            ; if (PROGRAM.SETTINGS.SETTINGS_MAIN.AutoMaximizeOnFirstNewTab = "True")
			    GUI_Trades_V2.Maximize(_buyOrSell)
		}

        ; TO_DO is this needed?
		if (doOnlyOnce != False) {
			Gui, Trades%_buyOrSell%Search:Show, NoActivate
			doOnlyOnce := True
		}

        ; Update the title text with new tabs count
		if (newTabsCount > 0) {
			GuiControl,Trades%_buyOrSell%:,% GuiTrades_Controls[_buyOrSell]["hTEXT_Title"],% PROGRAM.NAME " (" newTabsCount ")"
			; GuiControl,TradesMinimized:,% GuiTradesMinimized_Controls["hTEXT_Title"],% "(" GuiTrades.Tabs_Count ")"
			GuiControl,% "Trades" _buyOrSell ": +c" SKIN.Compact.Settings.COLORS.Title_Trades,% GuiTrades_Controls[_buyOrSell]["hTEXT_Title"]
			; GuiControl,% "TradesMinimized: +c" SKIN.Compact.Settings.COLORS.Title_Trades,% GuiTradesMinimized_Controls["hTEXT_Title"]
			GUI_Trades_V2.SetTransparency_Active(_buyOrSell)
			GUI_Trades_V2.Disable_ClickThrough(_buyOrSell)
			GUI_Trades_V2.Redraw(_buyOrSell)
		}

        ; Update the GUI height if the mode is slots
        if (isSlots) {
            GuiTrades[_buyOrSell].Height_Maximized := guiHeight := newTabsCount = 0 ? GuiTrades[_buyOrSell].Height_NoRow
                : newTabsCount = 1 ? GuiTrades[_buyOrSell].Height_OneRow
                : newTabsCount = 2 ? GuiTrades[_buyOrSell].Height_TwoRow
                : newTabsCount = 3 ? GuiTrades[_buyOrSell].Height_ThreeRow
                : newTabsCount >= 4 ? GuiTrades[_buyOrSell].Height_FourRow
                : GuiTrades[_buyOrSell].Height_FourRow

            Gui.Show("Trades" _buyOrSell, "h" guiHeight " NoActivate")
        }
	}

	SetSlotContent(params*) {
		return GUI_Trades_V2.SetTabContent(params*)
	}

    SetTabContent(_buyOrSell, slotNum, tabInfos, isNewlyPushed=False, updateOnly=False) {
		; Set the content of the Slot gui, increase tab count
		global PROGRAM
		global GuiTrades, GuiTrades_Controls
		windowsDPI := GuiTrades[_buyOrSell].Windows_DPI

        ; Get current tab content + merge current and new content keys
		cTabCont := GUI_Trades_V2.GetTabContent(_buyOrSell, slotNum)
		merged := ObjMerge(cTabCont, tabInfos), allSlots := ""
		for key, value in merged
			allSlots .= "," key
		if ( SubStr(allSlots, 1, 1) = "," )
			StringTrimLeft, allSlots, allSlots, 1

        ; Creating the new content obj
		newContent := {}
		Loop, Parse, allSlots,% ","
		{
			loopedKey := A_LoopField
			currentValue := cTabCont[loopedKey]
			newValue := tabInfos[loopedKey]

			finalValue := updateOnly && !newValue ? currentValue : newValue
			AutoTrimStr(finalValue)
			newContent[loopedKey] := finalValue
		}
		if (newContent.AdditionalMessageFull) { 
			newAdditionalMsgFull := StrReplace(newContent.AdditionalMessageFull, "`n", "\n"), newAdditionalMsgFull := StrReplace(newAdditionalMsgFull, "`r", "\n")
			numberOfMsgs := 0
			additionalMsgSplit := StrSplit(newAdditionalMsgFull, "\n"), numberOfMsgs := additionalMsgSplit.MaxIndex()
			if (numberOfMsgs = 0 || numberOfMsgs=1 || numberOfMsgs="")
				RegExMatch( StrSplit(newAdditionalMsgFull, "\n").1 , "O)\[\d+\:\d+\] \@(?:To|From)\: (.*)", outPat), newAdditionalMsg := outPat.1
			else
				newAdditionalMsg := numberOfMsgs " total messages. Click here to see."

			AutoTrimStr(newAdditionalMsgFull, newAdditionalMsg)
			newContent.AdditionalMessageFull := newAdditionalMsgFull, newContent.AdditionalMessage := newAdditionalMsg
		}

        ; Setting default visible text
		visibleSeller := newContent.Seller ? newContent.Seller : newContent.Buyer
		visibleItem := newContent.GemLevel && newContent.GemQuality ? newContent.Item " Lvl " newContent.GemLevle " " newContent.GemQuality "%)"
			: newContent.GemLevel && !newContent.GemQuality ? newContent.Item " (Lvl " newContent.GemLevel ")"
			: !newContent.GemLevel && newContent.GemQuality ? newContent.Item " (" newContent.GemQuality "%)"
			: newContent.Item
		visiblePrice := newContent.PriceCount
		visibleStash := newContent.StashTab ? newContent.StashTab " (" newContent.StashX "," newContent.tradeStashY ")"
		visibleTime := newContent.TimeSent ? newContent.TimeSent : newContent.TimeReceived
		visibleAdditionalMsg := newContent.AdditionalMessage

		; Trim strings based on size
		itemSlotSizeMax := Get_ControlCoords("Trades" _buyOrSell "_Slot" slotNum, GuiTrades[_buyOrSell]["Slot" slotNum "_Controls"].hTEXT_ItemName).W
		newItemTxtSize := Get_TextCtrlSize(txt:=visibleItem, fontName:=GuiTrades[_buyOrSell].Font, fontSize:=GuiTrades[_buyOrSell].Font_Size).W
		sellerSlotSizeMax := Get_ControlCoords("Trades" _buyOrSell "_Slot" slotNum, GuiTrades[_buyOrSell]["Slot" slotNum "_Controls"].hTEXT_SellerName).W
		newSellerTxtSize := Get_TextCtrlSize(txt:=visibleSeller, fontName:=GuiTrades[_buyOrSell].Font, fontSize:=GuiTrades[_buyOrSell].Font_Size).W
        addMsgSlotSizeMax := Get_ControlCoords("Trades" _buyOrSell "_Slot" slotNum, GuiTrades[_buyOrSell]["Slot" slotNum "_Controls"].hTEXT_AdditionalMessage).W
		newAddMsgTxtSize := Get_TextCtrlSize(txt:=visibleAdditionalMsg, fontName:=GuiTrades[_buyOrSell].Font, fontSize:=GuiTrades[_buyOrSell].Font_Size).W

		if (newItemTxtSize >= itemSlotSizeMax-10) {	
			cutStr := visibleItem
			Loop % Ceil( StrLen(visibleItem)/3 ) {
				StringTrimRight, cutStr, cutStr, 3
				newSize := Get_TextCtrlSize(txt:=cutStr "...", fontName:=GuiTrades[_buyOrSell].Font, fontSize:=GuiTrades[_buyOrSell].Font_Size).W
				if !(newSize >= itemSlotSizeMax-10)
					Break
			}
			visibleItem := cutStr "..."
			hiddenInfosWall .= "`n" "ItemIsCut:"		A_Tab True
		}
		else
			hiddenInfosWall .= "`n" "ItemIsCut:"		A_Tab False

		if (newSellerTxtSize >= sellerSlotSizeMax) {	
			cutStr := visibleSeller
			Loop % Ceil( StrLen(visibleSeller)/3 ) {
				StringTrimRight, cutStr, cutStr, 3
				newSize := Get_TextCtrlSize(txt:=cutStr "...", fontName:=GuiTrades[_buyOrSell].Font, fontSize:=GuiTrades[_buyOrSell].Font_Size).W
				if !(newSize >= sellerSlotSizeMax)
					Break
			}
			visibleSeller := cutStr "..."
			hiddenInfosWall .= "`n" "SellerIsCut:"		A_Tab True
		}
		else
			hiddenInfosWall .= "`n" "SellerIsCut:"		A_Tab False

		if (newAddMsgTxtSize >= addMsgSlotSizeMax) {	
			cutStr := visibleAdditionalMsg
			Loop % Ceil( StrLen(visibleAdditionalMsg)/3 ) {
				StringTrimRight, cutStr, cutStr, 3
				newSize := Get_TextCtrlSize(txt:=cutStr "...", fontName:=GuiTrades[_buyOrSell].Font, fontSize:=GuiTrades[_buyOrSell].Font_Size).W
				if !(newSize >= addMsgSlotSizeMax)
					Break
			}
			visibleAdditionalMsg := cutStr "..."
		}

        ; Creating the block of txt containing all infos
		hiddenInfosWall := ""
		for key, value in newContent
			hiddenInfosWall .= "`n" key ":" value
		if ( SubStr(hiddenInfosWall, 1, 1) = "`n" )
			StringTrimLeft, hiddenInfosWall, hiddenInfosWall, 1

		; Setting content to controls
		GuiControl, ,% GuiTrades[_buyOrSell]["Slot" slotNum "_Controls"].hTEXT_HiddenInfos,% hiddenInfosWall
		GuiControl, ,% GuiTrades[_buyOrSell]["Slot" slotNum "_Controls"].hTEXT_ItemName,% visibleItem
		GuiControl, ,% GuiTrades[_buyOrSell]["Slot" slotNum "_Controls"].hTEXT_SellerName,% visibleSeller
		GuiControl, ,% GuiTrades[_buyOrSell]["Slot" slotNum "_Controls"].hTEXT_PriceCount,% visiblePrice
		GuiControl, ,% GuiTrades[_buyOrSell]["Slot" slotNum "_Controls"].hTEXT_AdditionalMessage,% visibleAdditionalMsg
		GuiControl, ,% GuiTrades[_buyOrSell]["Slot" slotNum "_Controls"].hTEXT_TimeSent,% visibleTime
		
		; Reduce some controls size based on their content + move them to make it look better
            ; PriceCount - Cutting control size
        priceCountW := Get_TextCtrlSize(visiblePrice, GuiTrades[_buyOrSell].Font, GuiTrades[_buyOrSell].Font_Size, "", "R1").W
		GuiControl, Move,% GuiTrades[_buyOrSell]["Slot" slotNum "_Controls"].hTEXT_PriceCount,% "w" priceCountW*windowsDPI ; TO_DO_V2
		    ; Move AdditionalMessage next to PriceCount
        priceCountPos := ControlGetPos(GuiTrades[_buyOrSell]["Slot" slotNum "_Controls"].hTEXT_PriceCount)
        whisperSeller := ControlGetPos(GuiTrades[_buyOrSell]["Slot" slotNum "_Controls"].hBTN_WhisperSeller)
		GuiControl, Move,% GuiTrades[_buyOrSell]["Slot" slotNum "_Controls"].hTEXT_AdditionalMessage,% "x" (priceCountPos.x+priceCountPos.w+10)/windowsDPI " w" (whisperSeller.x-( priceCountPos.x+priceCountPos.w+10 )-10)/windowsDPI

		; Set currency IMG 
		if (newContent.PriceCurrency != cTabCont.PriceCurrency) {
			if (newContent.PriceCurrency = "") {
				GuiControl, ,% GuiTrades[_buyOrSell]["Slot" slotNum "_Controls"].hIMG_CurrencyIMG,% newContent.PriceCurrency
			}
			else {
				if FileExist(PROGRAM.CURRENCY_IMGS_FOLDER "\" newContent.PriceCurrency ".png")
					currencyPngFile := PROGRAM.CURRENCY_IMGS_FOLDER "\" newContent.PriceCurrency ".png"
				else 
					currencyPngFile := PROGRAM.CURRENCY_IMGS_FOLDER "\Unknown.png"

                imgSlotPos := ControlGetPos(GuiTrades[_buyOrSell]["Slot" slotNum "_Controls"].hIMG_CurrencyIMG)				
				hBitMap := Gdip_CreateResizedHBITMAP_FromFile(currencyPngFile, imgSlotPos.W*windowsDPI, imgSlotPos.H*windowsDPI, PreserveAspectRatio:=False)
				SetImage(GuiTrades[_buyOrSell]["Slot" slotNum "_Controls"].hIMG_CurrencyIMG, hBitmap)
			}
			GuiControl, Hide,% GuiTrades[_buyOrSell]["Slot" slotNum "_Controls"].hIMG_CurrencyIMG ; basically "redraw", fixes old pic still there behind
			GuiControl, Show,% GuiTrades[_buyOrSell]["Slot" slotNum "_Controls"].hIMG_CurrencyIMG
		}
	}  

    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
     *
     * WILL NEED SOME REVIEWING
     *
     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
    */

    HotBarButton(_buyOrSell, btnType) {
		global PROGRAM
		global LASTACTIVATED_GAMEPID

		
		if (btnType="Hideout") {
			keysState := GetKeyStateFunc("Ctrl,LCtrl,RCtrl")
			Send_GameMessage("WRITE_SEND", "/hideout", LASTACTIVATED_GAMEPID)
			SetKeyStateFunc(keysState)
		}
		else if (btnType="LeagueHelp") {
			try Menu, HelpMenu, DeleteAll
			Menu, HelpMenu, Add, Betrayal, GUI_Trades_V2_LeagueHelpMenu
			Menu, HelpMenu, Add, Delve, GUI_Trades_V2_LeagueHelpMenu
			Menu, HelpMenu, Add, Essence, GUI_Trades_V2_LeagueHelpMenu
			Menu, HelpMenu, Add, Incursion, GUI_Trades_V2_LeagueHelpMenu
			Menu, HelpMenu, Show
		}
		else {
			ShowToolTip("This button isn't implemented yet.")
			SetTimer, RemoveToolTip, -2000
		}		
		return

		GUI_Trades_V2_LeagueHelpMenu:
			which := A_ThisMenuItem="Betrayal"?"Betrayal"
				: A_ThisMenuItem="Delve"?"Delve"
				: A_ThisMenuItem="Essence"?"Essence"
				: A_ThisMenuItem="Incursion"?"Incursion"
				: ""
			if (!which)
				return
 
			GUI_CheatSheet.Show(which)
		return
	}

    Minimize(_buyOrSell) {
		global GuiTrades, GuiTrades_Controls
		global PROGRAM

		Detect_HiddenWindows("On")
		WinMove,% "ahk_id " GuiTrades[_buyOrSell].Handle, , , , ,% GuiTrades[_buyOrSell].Height_Minimized * GuiTrades[_buyOrSell].Windows_DPI
		Detect_HiddenWindows()

		GuiControl, Trades%_buyOrSell%:Show,% GuiTrades_Controls[_buyOrSell].hBTN_Maximize
		GuiControl, Trades%_buyOrSell%:Hide,% GuiTrades_Controls[_buyOrSell].hBTN_Minimize

		GuiControl, Trades%_buyOrSell%:Show,% GuiTrades_Controls[_buyOrSell].hPROGRESS_BorderBottom_Minimized
		; GuiControl, Trades%_buyOrSell%:Hide,% GuiTrades_Controls[_buyOrSell].hPROGRESS_BorderBottom

		GuiTrades[_buyOrSell].Is_Maximized := False
		GuiTrades[_buyOrSell].Is_Minimized := True

        GUI_ItemGrid.Hide()

		GUI_Trades_V2.ResetPositionIfOutOfBounds(_buyOrSell)
		; GUI_Trades_V2.ToggleTabSpecificAssets("Off")
		; TO_DO Possibly hide tabs to avoid overlap on border?
	}

    Maximize(_buyOrSell) {
		global GuiTrades, GuiTrades_Controls
		global PROGRAM

        Detect_HiddenWindows("On")
		WinMove,% "ahk_id " GuiTrades[_buyOrSell].Handle, , , , ,% GuiTrades[_buyOrSell].Height_Maximized * GuiTrades[_buyOrSell].Windows_DPI
		Detect_HiddenWindows()

		GuiControl, Trades%_buyOrSell%:Show,% GuiTrades_Controls[_buyOrSell].hBTN_Minimize
		GuiControl, Trades%_buyOrSell%:Hide,% GuiTrades_Controls[_buyOrSell].hBTN_Maximize

		; GuiControl, Trades%_buyOrSell%:Show,% GuiTrades_Controls[_buyOrSell].hPROGRESS_BorderBottom
		GuiControl, Trades%_buyOrSell%:Hide,% GuiTrades_Controls[_buyOrSell].hPROGRESS_BorderBottom_Minimized

		GuiTrades_Controls[_buyOrSell].Is_Maximized := True
		GuiTrades_Controls[_buyOrSell].Is_Minimized := False

		GUI_Trades_V2.ResetPositionIfOutOfBounds(_buyOrSell)
		; GUI_Trades_V2.ToggleTabSpecificAssets("On")
	}

    SetFakeSearch(_buyOrSell, makeEmpty=False) {
		global SKIN, GuiTrades, GuiTrades_Controls

		GuiControlGet, search, Trades%_buyOrSell%SearchHidden:,% GuiTrades_Controls[_buyOrSell].hEDIT_HiddenSearchBar
		if (search!="") {
			GuiControl,% "Trades" _buyOrSell ": +c" SKIN.Compact.Settings.COLORS.SearchBar_NotEmpty,% GuiTrades_Controls[_buyOrSell].hTEXT_SearchBarFake
			GuiControl, Trades%_buyOrSell%:,% GuiTrades_Controls[_buyOrSell].hTEXT_SearchBarFake,% search
		}
		else {
			GuiControl,% "Trades" _buyOrSell ": +c" SKIN.Compact.Settings.COLORS.SearchBar_Empty,% GuiTrades_Controls[_buyOrSell].hTEXT_SearchBarFake
			GuiControl, Trades%_buyOrSell%:,% GuiTrades_Controls[_buyOrSell].hTEXT_SearchBarFake,% "..."
		}

		if (makeEmpty=True) {
			GuiControl,% "Trades" _buyOrSell ": +c" SKIN.Compact.Settings.COLORS.SearchBar_Empty,% GuiTrades_Controls[_buyOrSell].hTEXT_SearchBarFake
			GuiControl, Trades%_buyOrSell%SearchHidden:,% GuiTrades_Controls[_buyOrSell].hEDIT_HiddenSearchBar,% ""
			GuiControl, Trades%_buyOrSell%:,% GuiTrades_Controls[_buyOrSell].hTEXT_SearchBarFake,% "..."
		}

		SetTimer, GUI_Trades_V2_Search, -500
	}

	Search(_buyOrSell) {
		/*	Starting a search will look through tabs to find match
			Any matching tab will be added to the list
			Once done, replace all tabs with matches

			TO_DO solution when sending whisper with search box still with text
		*/
		global GuiTrades, GuiTrades_Controls

		GuiControlGet, search, ,% GuiTrades[_buyOrSell].hEDIT_HiddenSearchBar
		
		matches := 0
		if (search != "") {		
			contents := {}
			Loop % GuiTrades[_buyOrSell].Tabs_Count {
				content := GuiTrades[_buyOrSell]["Tab" A_Index "Content"]
				if IsContaining(content.Seller, search) || IsContaining(content.Item, search)
					contents[matches+1] := content, matches++
			}
			if (matches) {
				ShowToolTip("""" search """`n" matches " matches found")
				SetTimer, RemoveToolTip, -2000
				Loop % GuiTrades[_buyOrSell].Tabs_Count
					GUI_Trades_V2.SetSlotContent(_buyOrSell, A_Index, "")
				
                
                Loop % matches
					GUI_Trades_V2.SetSlotContent(_buyOrSell, A_Index, contents[A_Index])
			}
			else {
				ShowToolTip("""" search """`nNo matches found")
				SetTimer, RemoveToolTip, -2000
			}
		}
		else {
			Loop % GuiTrades[_buyOrSell].Tabs_Count {
				GUI_Trades_V2.SetSlotContent(_buyOrSell, A_Index, GuiTrades[_buyOrSell]["Tab" A_Index "Content"])
			}
		}
		GUI_Trades_V2.Redraw(_buyOrSell)
	}

    IsTabAlreadyExisting(_buyOrSell, contentInfos) {
		global GuiTrades, GuiTrades_Controls

		Loop % GuiTrades[_buyOrSell]Tabs_Count {
			loopedcontentInfos := GUI_Trades_V2.GetTabContent(_buyOrSell, A_Index)
			if ( (contentInfos.Seller = loopedcontentInfos.Seller && _buyOrSell="Buy") || (contentInfos.Buyer = loopedcontentInfos.Buyer && _buyOrSell="Sell") )
			&& (contentInfos.Item = loopedcontentInfos.Item)
			&& (contentInfos.PriceCurrency = loopedcontentInfos.PriceCurrency)
			&& (contentInfos.PriceCount = loopedcontentInfos.PriceCount)
			&& (contentInfos.League = loopedcontentInfos.League)
			&& (contentInfos.StashTab = loopedcontentInfos.StashTab)
			&& (contentInfos.StashX = loopedcontentInfos.StashX)
			&& (contentInfos.StashY = loopedcontentInfos.StashY)
				Return A_Index
		}
	}

	tradeInfos := {Seller:tradeBuyerName, Item:tradeItem, Price:tradePrice, AdditionalMessageFull:tradeOther
				,PriceCurrency:currencyName, PriceCount:currencyCount
				,League:tradeLeague, StashTab:tradeStashTab, StashX:tradeStashLeft, StashY:tradeStashTop
				,Guild:tradeBuyerGuild
				,GemLevel:tradeItemLevel, GemQuality:tradeItemQual
				,TimeSent:A_Hour ":" A_Min, TimeStamp:A_YYYY A_MM A_DD A_Hour A_Min A_Sec
				,WhisperRegEx:tradeRegExName, WhisperLanguage:whisperLang
				,GamePID:instancePID
				,UniqueID:GUI_Trades_V2.GenerateUniqueID()}

    ResetPosition(_buyOrSell, dontWrite=False) {
		global PROGRAM, GuiTrades
		iniFile := PROGRAM.INI_FILE

		gtPos := GUI_Trades_V2.GetPosition(_buyOrSell)	
		; gtmPos := GUI_TradesMinimized.GetPosition()

		try {
			; if (GuiTrades.Is_Minimized)
			; 	if (PROGRAM.SETTINGS.SETTINGS_MAIN.MinimizeInterfaceToBottomLeft)
			; 		Gui, TradesMinimized:Show,% "NoActivate x" Ceil(A_ScreenWidth-gtPos.W) " y"  Ceil(0+gtPos.H-gtmPos.H)
			; 	else
			; 		Gui, TradesMinimized:Show,% "NoActivate x" Ceil(A_ScreenWidth-gtmPos.W) " y0"
			; else 
			Gui, Trades%_buyOrSell%:Show,% "NoActivate x" Ceil(A_ScreenWidth-gtPos.W) " y0"
			
			if !(dontWrite) {
				; if (GuiTrades.Is_Minimized)
					; Gui_TradesMinimized.SavePosition()
				; else 
					GUI_Trades_V2.SavePosition(_buyOrSell)
			}
		}
		catch e {
			AppendToLogs(A_ThisFunc "(dontWrite=" dontWrite "): Failed to set GUI pos based on screen width. Setting to 0,0.")
			; if (GuiTrades.Is_Minimized)
				; Gui, TradesMinimized:Show,% "NoActivate x0 y0"
			; else
			Gui, TradesBuyCompact:Show,% "NoActivate x0 y0"
			
			if !(dontWrite) {
				INI.Set(iniFile, "SETTINGS_MAIN", _buyOrSell "_Pos_X", 0)
				INI.Set(iniFile, "SETTINGS_MAIN", _buyOrSell "_Pos_Y", 0)
			}
		}
	}

    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
     *
     * SHOULD BE OK FOR V2
     *
     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
    */

	ScrollUp(_buyOrSell) {
		; Tabs: Re-arrange the tabs buttons to simulate scrolling left
		; Slots: Re-arrange the slots to simulate scrolling up
		global GuiTrades, GuiTrades_Controls
		tabsRange := GUI_Trades_V2.GetTabsRange(_buyOrSell)
		isSlots := GuiTrades[_buyOrSell].Is_Slots
		isTabs := GuiTrades[_buyOrSell].Is_Tabs

		if !(tabsRange.1 > 1) ; We can't scroll further
			return

		if (isTabs) {
			newFistTab := tabsRange.1-1, tabMoving := newFistTab
			While (tabMoving != tabsRange.2) {
				tabX := GuiTrades[_buyOrSell]["TabButton" A_Index "_X"] ; Get tab slot X pos
				GuiControl, Trades%_buyOrSell%:Move,% GuiTrades_Controls[_buyOrSell]["hBTN_TabDefault" tabMoving],% "x" tabX ; Move tab to said pos
				GuiControl, Trades%_buyOrSell%:Move,% GuiTrades_Controls[_buyOrSell]["hBTN_TabJoinedArea" tabMoving],% "x" tabX
				GuiControl, Trades%_buyOrSell%:Move,% GuiTrades_Controls[_buyOrSell]["hBTN_TabWhisperReceived" tabMoving],% "x" tabX

				tabMoving++ ; Move onto the next tab to move
			}
			GuiControl, Trades%_buyOrSell%:Show,% GuiTrades[_buyOrSell]["Tab_" newFistTab] ; Show new tab on left most
			GuiControl, Trades%_buyOrSell%:Hide,% GuiTrades[_buyOrSell]["Tab_" tabsRange.2] ; Hide previous tab on right most
		}
        else if (isSlots) {
			slotNum := tabsRange.1
			GUI_Trades_V2.SetSlotPosition(_buyOrSell, slotNum-1, 1) ; Show new first slot
			Loop 4 { ; Handle the other slots
				GUI_Trades_V2.SetSlotPosition(_buyOrSell, slotNum, A_Index+1)
				slotNum++
			}	
        }
	}

	ScrollDown(_buyOrSell) {
		; Tabs: Re-arrange the tabs buttons to simulate scrolling right
		; Slots: Re-arrange the slots to simulate scrolling down
		global GuiTrades, GuiTrades_Controls
		tabsRange := GUI_Trades_V2.GetTabsRange(_buyOrSell)
		tabsCount := GuiTrades[_buyOrSell].Tabs_Count
		isSlots := GuiTrades[_buyOrSell].Is_Slots
		isTabs := GuiTrades[_buyOrSell].Is_Tabs

		if !(tabsCount > tabsRange.2) ; We can't scroll further
			return

		if (isTabs) {
			newFistTab := tabsRange.1+1, newLastTab := tabsRange.2+1, tabMoving := newFistTab
			While (tabMoving != newLastTab) {
				tabX := GuiTrades[_buyOrSell]["TabButton" A_Index "_X"] ; Get tab slot X pos
				GuiControl, Trades%_buyOrSell%:Move,% GuiTrades_Controls[_buyOrSell]["hBTN_TabDefault" tabMoving],% "x" tabX ; Move tab to said pos
				GuiControl, Trades%_buyOrSell%:Move,% GuiTrades_Controls[_buyOrSell]["hBTN_TabJoinedArea" tabMoving],% "x" tabX
				GuiControl, Trades%_buyOrSell%:Move,% GuiTrades_Controls[_buyOrSell]["hBTN_TabWhisperReceived" tabMoving],% "x" tabX

				tabMoving++ ; Move onto the next tab to move
			}

			GuiControl, Trades%_buyOrSell%:Show,% GuiTrades[_buyOrSell]["Tab_" newLastTab] ; Show new tab on right most
			GuiControl, Trades%_buyOrSell%:Hide,% GuiTrades[_buyOrSell]["Tab_" tabsRange.1] ; Hide previous tab on left most
		}
        else if (isSlots) {
			slotNum := tabsRange.1
			Loop 4 { ; Handle the other slots
				GUI_Trades_V2.SetSlotPosition(_buyOrSell, slotNum, A_Index-1)
				slotNum++
			}
			GUI_Trades_V2.SetSlotPosition(_buyOrSell, slotNum, 4) ; Show new last slot
		}
	}

	RemoveTab(_buyOrSell, tabNum, massRemove=False) {
		global PROGRAM, SKIN
		global GuiTrades, GuiTrades_Controls
		tabsCount := GuiTrades[_buyOrSell].Tabs_Count
		tabsRange := GUI_Trades_V2.GetTabsRange(_buyOrSell)
		isSlots := GuiTrades[_buyOrSell].Is_Slots
		isTabs := GuiTrades[_buyOrSell].Is_Tabs
		activeTab := GuiTrades[_buyOrSell].Active_Tab

		tabNum := isTabs && !tabNum ? activeTab : tabNum
		; Removing tab and adjusting others if needed
		if (tabNum < tabsCount) {
			tabIndex := tabNum+1
			Loop % tabsCount-tabNum {
				tabContent := GUI_Trades_V2.GetTabContent(_buyOrSell, tabIndex)
				GuiTrades[_buyOrSell]["Tab" tabIndex-1 "Content"] := ObjFullyClone(tabContent) ; Used for search feature
				GUI_Trades_V2.SetSlotContent(_buyOrSell, tabIndex-1, tabContent) ; Set tab content to previous tab
				tabIndex++
			}
			GUI_Trades_V2.SetSlotContent(_buyOrSell, tabIndex-1, "") ; Make last tab empty
			GuiTrades[_buyOrSell]["Tab" tabIndex-1 "Content"] := {}
			GUI_Trades_V2.SetTabStyleDefault(_buyOrSell, tabIndex-1)
		}
		else if (tabNum = tabsCount) {
			GUI_Trades_V2.SetSlotContent(_buyOrSell, tabNum, "")
			GuiTrades[_buyOrSell]["Tab" tabNum "Content"] := {}
		}
		
		; Scroll up if needed
		if (tabsRange.2 = tabsCount)
			GUI_Trades_V2.ScrollUp(_buyOrSell)
		; Change active tab if needed
		if (activeTab = tabsCount) && (tabsCount != 1)
			GUI_Trades_V2.SetActiveTab(_buyOrSell, tabsCount-1, False) ; autoScroll=False
		; Hide tab assets is required
		else if (tabsCount = 1) {
			; GUI_Trades_V2.ToggleTabSpecificAssets("OFF") ; TO_DO_V2
			; GUI_Trades_V2.SetActiveTab("No Trades On Queue")
		}
		else if (tabsCount > tabNum) && (massRemove=False) ; Re-activate same
			GUI_Trades_V2.SetActiveTab(_buyOrSell, tabNum)

		; Hide last tab
		if (isTabs)
			GuiControl, Trades%_buyOrSell%:Hide,% GuiTrades[_buyOrSell]["Tab_" tabsCount]
		; Updating tab count var
		GuiTrades[_buyOrSell].Tabs_Count := GuiTrades[_buyOrSell].Tabs_Count <= 0 ? 0 : GuiTrades[_buyOrSell].Tabs_Count-1
		; Updating height var if is slots
		if (isSlots) {
			GuiTrades[_buyOrSell].Height_Maximized := GuiTrades[_buyOrSell].Tabs_Count = 0 ? GuiTrades[_buyOrSell].Height_NoRow
				: GuiTrades[_buyOrSell].Tabs_Count = 1 ? GuiTrades[_buyOrSell].Height_OneRow
				: GuiTrades[_buyOrSell].Tabs_Count = 2 ? GuiTrades[_buyOrSell].Height_TwoRow
				: GuiTrades[_buyOrSell].Tabs_Count = 3 ? GuiTrades[_buyOrSell].Height_ThreeRow
				: GuiTrades[_buyOrSell].Tabs_Count >= 4 ? GuiTrades[_buyOrSell].Height_FourRow
				: GuiTrades[_buyOrSell].Height_FourRow
		}
		; Do stuff if tabs count is zero
		if (GuiTrades[_buyOrSell].Tabs_Count = 0) {
			GuiControl,Trades%_buyOrSell%:,% GuiTrades_Controls[_buyOrSell]["hTEXT_Title"],% PROGRAM.NAME
			GuiControl,% "Trades" _buyOrSell ": +c" SKIN.Compact.Settings.COLORS.Title_No_Trades,% GuiTrades_Controls[_buyOrSell]["hTEXT_Title"]
			; GuiControl,TradesMinimized:,% GuiTradesMinimized_Controls["hTEXT_Title"],% "(0)"
			; GuiControl,% "TradesMinimized: +c" SKIN.Compact.Settings.COLORS.Title_No_Trades,% GuiTradesMinimized_Controls["hTEXT_Title"]
			if (PROGRAM.SETTINGS.SETTINGS_MAIN.AllowClicksToPassThroughWhileInactive = "True")
				GUI_Trades_V2.Enable_ClickThrough(_buyOrSell)
			if (PROGRAM.SETTINGS.SETTINGS_MAIN.AutoMinimizeOnAllTabsClosed = "True")
				GUI_Trades_V2.Minimize(_buyOrSell)
			GUI_Trades_V2.SetTransparency_Inactive(_buyOrSell)
			GUI_Trades_V2.Redraw(_buyOrSell)
		}
		; Do stuff if tabs count is not zero
		else {
			GuiControl,Trades%_buyOrSell%:,% GuiTrades_Controls[_buyOrSell]["hTEXT_Title"],% PROGRAM.NAME " (" GuiTrades[_buyOrSell].Tabs_Count ")"
			if (isSlots)
				Gui.Show("Trades" _buyOrSell, "h" GuiTrades[_buyOrSell].Height_Maximized " NoActivate")
			; GuiControl,TradesBuyCompact:,% GuiTradesMinimized_Controls["hTEXT_Title"],% "(" GuiTrades.Tabs_Count ")"
		}
	}

	SetActiveTab(_buyOrSell, tabName, autoScroll=True, skipError=False, styleChanged=False) {
		global PROGRAM, GuiTrades, GuiTrades_Controls
        prevActiveTab   := GuiTrades[_buyOrSell].Active_Tab
		tabsCount       := GuiTrades[_buyOrSell].Tabs_Count
        tabsLimit       := GuiTrades[_buyOrSell].Tabs_Limit
        tabsRange        := GUI_Trades_V2.GetTabsRange(_buyOrSell)

        ; Invalid tab name
		if IsNum(tabName) && !IsBetween(tabName, 1, tabsCount) {
			if (skipError=False)
				MsgBox(48, "", "Cannot select tab """ tabName """ because it exceed the tabs count (" tabsCount ")")
			return
		}

        ; Need to scroll to make tab visible
		if ( autoScroll && IsNum(tabName) && !IsBetween(tabName, tabsRange.1, tabsRange.2) ) {
			if (tabName < tabsRange.1) {
				diff := tabsRange.1-tabName
				Loop % diff
					GUI_Trades_V2.ScrollLeft(_buyOrSell)
			}
			else if (tabName > tabsRange.2) {
				diff := tabName-tabsRange.2
				Loop % diff
					GUI_Trades_V2.ScrollRight(_buyOrSell)
			}
		}

        ; Setting "Active" tab style, and removing it from any other tab
        ; + Make sure that the slot is on the first position, show it, and hide any other slot
		Loop % tabsLimit {
            slotGuiName := "Trades" _buyOrSell "_Slot" A_Index
			if (A_Index = tabName) {
				GuiControl, Trades%_buyOrSell%:+Disabled,% GuiTrades[_buyOrSell]["Tab_" A_Index]
                GUI_Trades_V2.SetSlotPosition(_buyOrSell, tabName, 1)
                Gui.Show(slotGuiName, "x0 y" GuiTrades[_buyOrSell]["Slot1_Pos"]  " NoActivate")
            }
			else {
				GuiControl, Trades%_buyOrSell%:-Disabled,% GuiTrades[_buyOrSell]["Tab_" A_Index]
                Gui, %slotGuiName%:Hide
            }
		}
        GuiTrades[_buyOrSell].Active_Tab := tabName

        ; Showing item grid as long as interface is maximized
		if (GuiTrades[_buyOrSell].Is_Maximized = True)
			GUI_Trades_V2.ShowActiveTabItemGrid()

		; Don't do these if only the tab style changed.
		; Avoid an issue where upon removing a tab, it would copy the item infos again due to the tab style func re-activating the tab
		if (styleChanged=False) {
			if (PROGRAM.SETTINGS.SETTINGS_MAIN.CopyItemInfosOnTabChange = "True" && IsNum(tabName)) {
				GoSub, GUI_Trades_CopyItemInfos_CurrentTab_Timer
			}
		}
	}

    RecreateGUI(_buyOrSell, tabsLimit="") {
		global PROGRAM, GuiTrades
		tabsCount := GuiTrades[_buyOrSell].Tabs_Count
		maxTabsPerRow := GuiTrades[_buyOrSell].Max_Tabs_Per_Row
		tabsRange := GUI_Trades_V2.GetTabsRange(_buyOrSell)
        tabsOrSlot := GuiTrades[_buyOrSell].Is_Slots ? "Slots" : "Tabs"

		if (tabsLimit = "")
			tabsLimit := GuiTrades[_buyOrSell].Tabs_Limit

		firstRangeTab := tabsRange.1
		Loop % tabsCount { ; Get all tabs content
			tabInfos%A_Index% := GUI_Trades_V2.GetTabContent(_buyOrSell, A_Index)
		}
		
		if (tabsLimit)
			GUI_Trades_V2.Create(tabsLimit, _buyOrSell, tabsOrSlot) ; Recreate GUI with more tabs
		else
			GUI_Trades_V2.Create("", _buyOrSell, tabsOrSlot) ; No limit specific, just use default limit
		Loop % tabsCount { ; Set tabs content
			GUI_Trades_V2.PushNewTab(_buyOrSell, tabInfos%A_Index%)
		}

		Loop % tabsRange.2-maxTabsPerRow
			GUI_Trades_V2.ScrollDown(_buyOrSell)

		if (tabsCount) {
			GUI_Trades_V2.SetTransparency_Active(_buyOrSell)
			GUI_Trades_V2.Disable_ClickThrough(_buyOrSell)
		}
		else  {
			GUI_Trades_V2.SetTransparency_Inactive(_buyOrSell)
			if (PROGRAM.SETTINGS.SETTINGS_MAIN.AllowClicksToPassThroughWhileInactive = "True")
				GUI_Trades_V2.Enable_ClickThrough(_buyOrSell)
		}
	}

    /* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
     *
     * FINISHED FOR V2
     *
     * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
    */

	RemoveButtonFocus(_buyOrSell) {
		global GuiTrades
		ControlFocus,,% "ahk_id " GuiTrades[_buyOrSell].Handle ; Remove focus
		Loop % GuiTrades[_buyOrSell].Tabs_Count
			ControlFocus,,% "ahk_id " GuiTrades[_buyOrSell]["Slot" A_Index].Handle
	}

	ScrollLeft(params*) {
        return GUI_Trades_V2.ScrollUp(params*)
    }
    ScrollRight(params*) {
        return GUI_Trades_V2.ScrollDown(params*)
    }

	GetTabsRange(_buyOrSell) {
		; Gets the first and last visible tabs, based on control visibility
		global GuiTrades

		Loop % GuiTrades[_buyOrSell].Tabs_Count {
			if (GuiTrades[_buyOrSell].Is_Slots) {
				guiName := "Trades" _buyOrSell "_Slot" A_Index
				GuiControlGet, isVisible, %guiName%:Visible,% GuiTrades[_buyOrSell]["Slot" A_Index "_Controls"].hTEXT_TimeSent
			}
			else if (GuiTrades[_buyOrSell].Is_Tabs) {
				GuiControlGet, isVisible, Trades%_buyOrSell%:Visible,% GuiTrades[_buyOrSell]["Tab_" A_Index]
			}

			if (firstVisibleTab = "" && isVisible)
				firstVisibleTab := A_Index
			if (isVisible)
				lastVisibleTab := A_Index

			if (firstVisibleTab && lastVisibleTab && !isVisible)
				Break
		}
		Return [firstVisibleTab, lastVisibleTab]
	}

	GetTabContent(_buyOrSell, tabName) {
		; Parse the hidden infos wall to return an obj with the whole tab content
		global GuiTrades

		GuiControlGet, hiddenInfosWall, ,% GuiTrades[_buyOrSell]["Slot" tabName "_Controls"]["hTEXT_HiddenInfos"]

		tabInfos := {}
		Loop, Parse, hiddenInfosWall, `n, `r
		{
			if RegExMatch(A_LoopField, "O)(.*?):(.*)", matchPat) {
				matchKey := matchPat.1, matchValue := matchPat.2
				AutoTrimStr(matchKey, matchValue)
				tabInfos[matchKey] := matchValue
			}
		}

		return tabInfos
    }

	GetSlotContent(params*) {
       return GUI_Trades_V2.GetTabContent(params*)
	}

	SetSlotPosition(_buyOrSell, slotNum, slotPos) {
        ; Only used with the Slots gui mode
		; Set the position of the Slot gui
		; If position is higher than the allocated slot count, it will be hidden
		global GuiTrades

		guiName := "Trades" _buyOrSell "_Slot" slotNum
        guiSlot := GuiTrades[_buyOrSell]["Slot" slotPos "_Pos"] 
		if (guiSlot)
			Gui.Show(guiName, "x0 y" guiSlot " NoActivate")
		else Gui, %guiName%:Hide
	}

	CloseOtherTabsForSameItem(_buyOrSell, tabNum) {
		global GuiTrades
		isSlots := GuiTrades[_buyOrSell].Is_Slots
		isTabs := GuiTrades[_buyOrSell].Is_Tabs
		tabsCount := GuiTrades[_buyOrSell].Tabs_Count

		
		activeTab := GuiTrades[_buyOrSell].Active_Tab
		activeTabInfos := GUI_Trades_V2.GetTabContent(_buyOrSell, activeTab)
		tabsToLoop := tabsCount, tabsToGoBack := 0

		; Parse every tab, from highest to lowest so when we close it, it doesn't affect tab order
		Loop % tabsCount {
			loopedTab := tabsToLoop
			if (loopedTab != activeTab) {
				tabInfos := GUI_Trades_V2.GetTabContent(_buyOrSell, loopedTab)
				if (_buyOrSell = "Buy")
					isSameItem := tabInfos.Item = activeTabInfos.Item ? True : False
				else if (_buyOrSell = "Sell") {
					isSameItem := (tabInfos.Item = activeTabInfos.Item)
					&& (tabInfos.PriceCurrency = activeTabInfos.PriceCurrency)
					&& (tabInfos.PriceCount = activeTabInfos.PriceCount)
					&& (tabInfos.League = activeTabInfos.League)
					&& (tabInfos.StashTab = activeTabInfos.StashTab)
					&& (tabInfos.StashX = activeTabInfos.StashX)
					&& (tabInfos.StashY = activeTabInfos.StashY) ? True : False
				}
				if (isSameItem) {
					if (loopedTab > activeTab)
						tabsToGoBack++
					GUI_Trades_V2.RemoveTab(_buyOrSell, loopedTab, massRemove:=True)
					AppendToLogs(A_ThisLabel ": Removed tab " loopedTab)
				}
			}
			tabsToLoop--
		}
		if (isTabs)
			GUI_Trades_V2.SetActiveTab(_buyOrSell, activeTab-tabsToGoBack)
	}

	IncreaseTabsLimit(_buyOrSell) {
		global GuiTrades
		static prevLimit
		tabsLimit := GuiTrades[_buyOrSell].Tabs_Limit

		limits := [50,100,251]
		nextLimit := IsBetween(tabsLimit, 0, limits.1) ? limits.2
			: IsBetween(tabsLimit, limits.1, limits.1) ? limits.3
			: limits.3

		prevLimit := nextLimit
           
		if (nextLimit = limits.3) && (prevLimit != limits.3) {
			MsgBox(4096, "", "You have reached the maximal tabs limit: " limits.3
			. "`nNew tabs will not be able to be created.")
		}

		TrayNotifications.Show("Increasing tabs limit to " limits.3)
		
		GUI_Trades_V2.RecreateGUI(_buyOrSell, nextLimit)
	}


    Exists(_buyOrSell) {
		global GuiTrades
		hw := A_DetectHiddenWindows
		DetectHiddenWindows, On
		hwnd := WinExist("ahk_id " GuiTrades[_buyOrSell].Handle)
		DetectHiddenWindows, %hw%

		return hwnd
	}

	Enable_ClickThrough(_buyOrSell) {
		global GuiTrades
		Gui, Trades%_buyOrSell%: +LastFound
		WinSet, ExStyle, +0x20
	}

	Disable_ClickThrough(_buyOrSell) {
		global GuiTrades
		Gui, Trades%_buyOrSell%: +LastFound
		WinSet, ExStyle, -0x20
	}

	SetTransparencyPercent(_buyOrSell, transPercent) {
		global GuiTrades

		if !IsNum(transPercent) {
			AppendToLogs(A_ThisFunc "(transPercent=" transPercent "): Not a number. Setting transparency to max.")
			transValue := 255
		}
		else
			transValue := (255/100)*transPercent

		Gui, Trades%_buyOrSell%:+LastFound
		WinSet, Transparent,% transValue
	}

	SetTransparency_Automatic(_buyOrSell) {
		global GuiTrades
		if (GuiTrades[_buyOrSell].Tabs_Count = 0)
			GUI_Trades_V2.SetTransparency_Inactive(_buyOrSell)
		else
			GUI_Trades_V2.SetTransparency_Active(_buyOrSell)
	}

	SetTransparency_Inactive(_buyOrSell) {
		global PROGRAM, GuiTrades
		transPercent := PROGRAM.SETTINGS.SETTINGS_MAIN.NoTabsTransparency
		GUI_Trades_V2.SetTransparencyPercent(_buyOrSell, transPercent)
		if (transPercent = 0)
			GUI_Trades_V2.Enable_ClickThrough(_buyOrSell)
	}

	SetTransparency_Active(_buyOrSell) {
		global PROGRAM, GuiTrades
		transPercent := PROGRAM.SETTINGS.SETTINGS_MAIN.TabsOpenTransparency
		GUI_Trades_V2.SetTransparencyPercent(_buyOrSell, transPercent)
	}

	CloseAllTabs(_buyOrSell) {
		global GuiTrades

		Loop % GuiTrades[_buyOrSell].Tabs_Count {
			GUI_Trades_V2.RemoveTab(_buyOrSell, A_Index)
		}
	}

    GenerateUniqueID() {
		return RandomStr(l := 24, i := 48, x := 122)
	}

    UpdateSlotContent(_buyOrSell, slotNum, slotName, newContent) {
        ; FINISHED_V2
		global GuiTrades_Controls

		if !IsNum(slotNum) {
			AppendToLogs(A_ThisFunc "(slotNum=" tabID ")): tabID is not a number.")
			return
		}

		slotContent := GUI_Trades_V2.GetTabContent(_buyOrSell, slotNum)
		if (slotName = "AdditionalMessageFull") {
			mergedCurrendAndNew := slotContent.AdditionalMessageFull?slotContent.AdditionalMessageFull "\n" newContent : newContent
			GUI_Trades_V2.SetSlotContent(_buyOrSell, slotNum, {AdditionalMessageFull:mergedCurrendAndNew}, isNewlyPushed:=False, updateOnly:=True)
		}
        else {
            obj := {}, obj[slotName] := newContent
            GUI_Trades_V2.SetSlotContent(_buyOrSell, slotNum, obj, isNewlyPushed:=False, updateOnly:=True)
        }
	}

	Create_Style(ByRef styles, styleName, styleInfos) {
		global SKIN
		
		normalImg 	:= GUI_Trades_V2.CreateButtonImage({Left:styleInfos.Left, Right:styleInfos.Right, Fill:styleInfos.Fill}, styleInfos.Width, styleInfos.Height)
		hoverImg 	:= GUI_Trades_V2.CreateButtonImage({Left:styleInfos.LeftHover, Right:styleInfos.RightHover, Fill:styleInfos.FillHover}, styleInfos.Width, styleInfos.Height)
		ressImg 	:= GUI_Trades_V2.CreateButtonImage({Left:styleInfos.LeftPress, Right:styleInfos.RightPress, Fill:styleInfos.FillPress}, styleInfos.Width, styleInfos.Height)
		defaultimg 	:= GUI_Trades_V2.CreateButtonImage({Left:styleInfos.LeftDefault, Right:styleInfos.RightDefault, Fill:styleInfos.FillDefault}, styleInfos.Width, styleInfos.Height)		
		
		styles[styleName] := [ [0, normalImg, "", styleInfos.Color, "", styleInfos.ColorTransparency]
						, [0, hoverImg, "", styleInfos.ColorHover, "", styleInfos.ColorTransparency]
						, [0, ressImg, "", styleInfos.ColorPress, "", styleInfos.ColorTransparency]
						, [0, defaultimg, "", styleInfos.ColorDefault, "", styleInfos.ColorTransparency] ]
	}

    Get_Styles() {
        ; FINISHED_V2
		global PROGRAM, SKIN

		skinSettings := SKIN.Settings
		skinAssets := SKIN.Assets
		skinColors := skinSettings.COLORS

		styles := {}
		for sect, nothing in skinAssets {
			if (skinAssets[sect].Normal && skinAssets[sect].Hover && skinAssets[sect].Press) {
				if (skinAssets[sect].Default) {
					%sect% := [ [0, skinAssets[sect].Normal, "", skinColors[sect "_Normal"], "", skinAssets.Misc.Transparency_Color]
							, [0, skinAssets[sect].Hover, "", skinColors[sect "_Hover"], "", skinAssets.Misc.Transparency_Color]
							, [0, skinAssets[sect].Press, "", skinColors[sect "_Press"], "", skinAssets.Misc.Transparency_Color]
							, [0, skinAssets[sect].Default, "", skinColors[sect "_Default"], "", skinAssets.Misc.Transparency_Color] ]
				}
				else {
					%sect% := [ [0, skinAssets[sect].Normal, "", skinColors.Button_Normal, "", skinAssets.Misc.Transparency_Color]
							, [0, skinAssets[sect].Hover, "", skinColors.Button_Hover, "", skinAssets.Misc.Transparency_Color]
							, [0, skinAssets[sect].Press, "", skinColors.Button_Press, "", skinAssets.Misc.Transparency_Color] ]
				}
			}
			else {
				%sect% := {}
				for key, value in skinAssets[sect] 
					%sect%[key] := value
			}
			styles[sect] := %sect%
		}

		Return styles
	}

	DestroyBtnImgList(_buyOrSell) {
		global GuiTrades, GuiTrades_Controls

		for key, value in GuiTrades_Controls[_buyOrSell]
			if IsContaining(key, "hBTN_")
				try ImageButton.DestroyBtnImgList(value)
		
		Loop % GuiTrades[_buyOrSell].Tabs_Limit
			for key, value in GuiTrades[_buyOrSell]["Slot" A_Index "_Controls"]
				if IsContaining(key, "hBTN_")
					try ImageButton.DestroyBtnImgList(value)
	}

	Destroy(_buyOrSell) {
		global GuiTrades
		
		GUI_Trades_V2.DestroyBtnImgList(_buyOrSell)
        if (GuiTrades[_buyOrSell].Is_Slots) {
            Gui.Destroy("Trades" _buyOrSell "Search")
            Gui.Destroy("Trades" _buyOrSell "SearchHidden")
        }
		Loop % GuiTrades[_buyOrSell].Tabs_Limit
			Gui.Destroy("Trades" _buyOrSell "_Slot" A_Index)
		Gui.Destroy(_buyOrSell)
	}

	Submit(_buyOrSell, CtrlName="") {
		global GuiTrades, GuiTrades_Controls
		Gui.Submit(_buyOrSell)

		if (CtrlName) {
			Return GuiTrades_Submit[_buyOrSell][ctrlName]
		}
	}

    OnGuiMove(_buyOrSell) {
        ; FINISHED_V2
		/*	Allow dragging the GUI
		*/
		global PROGRAM, GuiTrades
		if IsContaining(_buyOrSell, "Preview")
			return

		if ( PROGRAM.SETTINGS.SETTINGS_MAIN.TradesGUI_Mode = "Window" && PROGRAM.SETTINGS.SETTINGS_MAIN.TradesGUI_Locked = "False" ) {
			PostMessage, 0xA1, 2,,,% "ahk_id " GuiTrades[_buyOrSell].Handle
		}
		KeyWait, LButton, Up
		GUI_Trades_V2.SavePosition(_buyOrSell)
		GUI_Trades_V2.RemoveButtonFocus(_buyOrSell)
		GUI_Trades_V2.ResetPositionIfOutOfBounds(_buyOrSell)
	}

	SavePosition(_buyOrSell) {
		global PROGRAM, GuiTrades

		gtPos := GUI_Trades_V2.GetPosition(_buyOrSell)
		if !IsNum(gtPos.X) || !IsNum(gtPos.Y)
			Return

		INI.Set(PROGRAM.INI_FILE, "SETTINGS_MAIN", _buyOrSell "_Pos_X", gtPos.X)
		INI.Set(PROGRAM.INI_FILE, "SETTINGS_MAIN", _buyOrSell "_Pos_Y", gtPos.Y)
	}

	GetPosition(_buyOrSell) {
		global GuiTrades
		DetectHiddenWindows("On")
		WinGetPos, x, y, w, h,% "ahk_id " GuiTrades[_buyOrSell].Handle
        DetectHiddenWindows()
		
		return {x:x,y:y,w:w,h:h}
	}

	ResetPositionIfOutOfBounds(_buyOrSell) {
		global PROGRAM, GuiTrades

		if ( !GUI_Trades_V2.Exists(_buyOrSell) )
			return

		; winHandle := GuiTrades.Is_Minimized ? GuiTradesMinimized.Handle : GuiTrades.Handle
		winHandle := GuiTrades[_buyOrSell].Handle
		
		if !IsWindowInScreenBoundaries(_win:="ahk_id " winHandle, _screen:="All", _adv:=False) {
			bounds := IsWindowInScreenBoundaries(_win:="ahk_id " winHandle, _screen:="All", _adv:=True)
			appendTxtFinal := "Win_X: " bounds[index].Win_X " | Win_Y: " bounds[index].Win_Y " - Win_W: " bounds[index].Win_W " | Win_H: " bounds[index].Win_H
			for index, nothing in bounds {
				appendTxt := "Monitor ID: " index
				. "`nMon_L: " bounds[index].Mon_L " | Mon_T: " bounds[index].Mon_T " | Mon_R: " bounds[index].Mon_R " | Mon_B: " bounds[index].Mon_B
				. "`nIsInBoundaries_H: " bounds[index].IsInBoundaries_H " | IsInBoundaries_V: " bounds[index].IsInBoundaries_V
				appendTxtFinal := appendTxtFinal ? appendTxtFinal "`n" appendTxt : appendTxt
			}
			AppendToLogs("Reset GUI Trades" _buyOrSell " position due to being deemed out of bounds."
			. "`n" appendTxtFinal)
			GUI_Trades_V2.ResetPosition(_buyOrSell)
			
			TrayNotifications.Show(PROGRAM.TRANSLATIONS.TrayNotifications.PositionHasBeenReset_Title, PROGRAM.TRANSLATIONS.TrayNotifications.PositionHasBeenReset_Msg)
		}
	}

    Show(_buyOrSell) {
		global GuiTrades, PROGRAM
        tabsOrSlot := GuiTrades[_buyOrSell].Is_Slots ? "Slots" : "Tabs"
		
		if (PROGRAM.SETTINGS.SETTINGS_MAIN.DisableBuyInterface="True")
			return

		DetectHiddenWindows("On")
		foundHwnd := WinExist("ahk_id " GuiTrades[_buyOrSell].Handle)
		DetectHiddenWindows()

		if (foundHwnd) {
			Gui, Trades%_buyOrSell%:Show, NoActivate
		}
		else {
			AppendToLogs("GUI_Trades_V2.Show(" _buyOrSell "): Non existent. Recreating.")
			GUI_Trades_V2.Create("", _buyOrSell, tabsOrSlot)
			Gui, Trades%_buyOrSell%:Show, NoActivate
		}
	}

	Redraw(_buyOrSell) {
		Gui, Trades%_buyOrSell%:+LastFound
		WinSet, Redraw
	}
}

GUI_Trades_V2_Search:
	GUI_Trades_V2.Search(_buyOrSell)
return
