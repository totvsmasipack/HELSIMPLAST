#INCLUDE "PROTHEUS.CH"
#INCLUDE "COLORS.CH"
#INCLUDE "FRTA271D.CH"

#define _PICTURE 13


/*±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±³Fun‡ao	 ³Fr271D050 ³ Autor ³ Edney Soares de Souza ³ Data ³ 26/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Efetua Sangria/Entrada de Troco no Front Loja			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Front Loja			   								  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Analista  ³ Data   ³ Bops ³Manutencao Efetuada                         ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ
±±³Erik W.B  ³19/04/07³124560³Alterada a utilização da chamada            ³±±
±±³          ³        ³      ³SubStr(cUsuario,7,15) por cUserName         ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Fr271D050(nCheck)             
Local oDlgSangr, oCheck, oBtnAct, oBtnEnd, oGroup1, oGroup2, oGroup3
Local oCodOrigem, oCodDestin
Local oMoeda
Local cCodOrigem := xNumCaixa()
Local cCodDestin := Space(Len(cCodOrigem))
Local cMoedaCorr := GetMv("MV_MOEDA1")
Local cCampo     := ""
Local oDinheir, oCheques, oCartao, oVlrDebi, oFinanc, oConveni, oVales, oOutros, oPgtoDigit, oPgtoPix
Local nDinheir  := 0
Local nCheques  := 0
Local nCartao   := 0
Local nVlrDebi  := 0
Local nFinanc   := 0
Local nConveni  := 0
Local nVales    := 0
Local nOutros   := 0        
Local nAltura   := 0
Local nAltura2  := 0
Local nX
Local nPosCampo := 0
Local aRet      := {} // Retorno do Ponto de Entrada
Local aMoedas   := {}
Local aSimbs    := {}
Local lRet      := .F.
Local cCaixaSup := Space(15)
Local lTouch := ( LJGetStation("TIPTELA") == "2" )
Local nKeyALeft
Local nKeyATop
Local nKeyNLeft
Local nKeyNTop
Local oKeyboard
Local lHabilita := SuperGetMV("MV_LJ350MV",, 2) <> 1 //Parametro que habilita alteracao de campos na sangria 1 = Somente dinheiro, 2 = Todos
Local cMvCxLoja	:= SuperGetMV("MV_CXLOJA",.F.,"")			//Parâmetro MV_CXLOJA
Local nTamSA6	:= Fr271A6Bco(cMvCxLoja)					//Tamanho do codigo do caixa

Local nLinha 	:= 40
Local lL1VLRPGDG:= SL1->(ColumnPos("L1_VLRPGDG")) > 0 .AND. SL1->(ColumnPos("L1_VLRPGPX")) > 0 //Verifica se existe o campo onde é gravado o valor da venda paga em Pagamento Digital e PIX
Local nVlrPagDig:= 0
Local nVlrPagPix:= 0

Private nMoedaCorr := 1   // Moeda Corrente

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica Permissao "Sangria/Entrada de Troco" - #5 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If !LjProfile(5, @cCaixaSup)
    //"Usuario sem permissao para realizar Sangria / Entrada de Troco. Atencao" 				
	MsgStop(STR0022 + AllTrim(cUserName) + STR0023, STR0024)
	Return(NIL)
EndIf

If lL1VLRPGDG
   nAltura   += 70
   nAltura2  += 35 
EndIf

If cPaisLoc != "BRA"
   nAltura   += 40
   nAltura2  += 15
   SM2->(DbSetOrder(1))
   SM2->(DbSeek(dDatabase))
   For nX := 1 To MoedFin()             
      If !Empty(&("MV_MOEDA"+LTrim(Str(nX))))                          
         cCampo  := "M2_MOEDA"+Str(nX,1)
         nPosCampo := SM2->(ColumnPos(cCampo))
         If IIf(nX > 1,SM2->(Found()) .And. SM2->(FieldGet(nPosCampo)) > 0,.T.)
	        AAdd(aMoedas,GetMv("MV_MOEDA"+LTrim(Str(nX))))			   
	        AAdd(aSimbs,GetMv("MV_SIMB"+LTrim(Str(nX))))			   	     	     
	     Else
	        MsgAlert(STR0025,STR0024) //"Por favor, preencher as cotacoes do dia de todas as moedas que estao sendo usadas no sistema!"###"Atencao"
	        Return(Nil)
	     EndIf   
	  EndIf   
   Next nX   
EndIf

nCheck := if(nCheck ==NIl,0,nCheck)

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se Troco o caixa destino sempre eh o operador atual³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nCheck = 2
	cCodDestin := xNumCaixa()
	cCodOrigem := Substr(cMvCxLoja,1,nTamSA6)
Else
	cCodDestin := Substr(cMvCxLoja,1,nTamSA6)
	cCodOrigem := xNumCaixa()
EndIf

If lGaveta
	If (!Empty(LJGetStation("PORTGAV"))) .And. (LJGetStation("PORTIF") <> LJGetStation("PORTGAV"))
		GavetaAci(nHdlGaveta, LJGetStation("PORTGAV"))
	Else
		IFGaveta(nHdlECF)
	EndIf
EndIf

If ExistBlock("FRT050SA")
	aRet := ExecBlock("FRT050SA",.F.,.F.,{nCheck,cCodOrigem,cCodDestin})
	nCheck		:= aRet[1]
	cCodOrigem	:= aRet[2]
	cCodDestin	:= aRet[3]
	nDinheir	:= aRet[4]
	nCheques	:= aRet[5]
	nCartao		:= aRet[6]
	nVlrDebi	:= aRet[7]
	nFinanc		:= aRet[8]
	nConveni	:= aRet[9]
	nVales		:= aRet[10]
	nOutros		:= aRet[11]

	If Len(aRet) > 11
		nVlrPagDig := aRet[12]
		nVlrPagPix := aRet[13]
	EndIf

EndIf

SX5->(dbSetOrder(1)) // Primeiro indice para validacao do caixa digitado
SA6->(dbSetOrder(1)) // Primeiro indice para obtencao da Agencia/Conta para geracao do SE5

nKeyALeft := 4
nKeyATop  := 120 + nAltura
nKeyNLeft := 4
nKeyNTop  := 120 + nAltura

If !lTouch

	DEFINE MSDIALOG ODlgSangr FROM 1,1 TO 388+nAltura,345 TITLE STR0001 PIXEL OF GetWndDefault()
	
	@ 005,010 GROUP oGroup1 TO 043,057 LABEL STR0002 COLOR CLR_HBLUE OF oDlgSangr PIXEL // " Tipo "
	
	@ 015,015 RADIO oCheck VAR nCheck 3D SIZE 47,10 PROMPT STR0003,STR0004 ON CHANGE Fr271D050Enab(nCheck,@cCodOrigem,@cCodDestin,oCodOrigem,oCodDestin) OF ODlgSangr PIXEL // "Sangria" // "Troco"
	
	If ! nCheck == 0
		oCheck:Disable()
	Else
		nCheck := 1
	EndIf
	
	@ 005,066 GROUP oGroup2 TO 043,162 LABEL STR0005 COLOR CLR_HBLUE OF oDlgSangr PIXEL // " Origem/Destino "
	
	@ 014,071 SAY STR0006 SIZE 50,10 OF ODlgSangr PIXEL // "Do Caixa:"
	@ 012,120 MSGET oCodOrigem VAR cCodOrigem F3 "23" WHEN nCheck == 2 SIZE 30,10 OF ODlgSangr PIXEL ;
	VALID SX5->(dbSeek(xFilial("SX5")+"23"+Substr(cCodOrigem,1,3))) .and. SA6->(dbSeek(xFilial("SA6")+cCodOrigem) .And. Substr(cCodOrigem,1,3) <> xNumCaixa())
	oCodOrigem:cSx1Hlp:=""
	
	@ 028,071 SAY STR0007 SIZE 50,10 OF ODlgSangr PIXEL // "Para o Caixa:"
	@ 027,120 MSGET oCodDestin VAR cCodDestin F3 "23" WHEN nCheck == 1  SIZE 30,10 OF ODlgSangr PIXEL ;
	VALID SX5->(dbSeek(xFilial("SX5")+"23"+Substr(cCodDestin,1,3))) .and. SA6->(dbSeek(xFilial("SA6")+cCodDestin) .AND. Alltrim(SA6->A6_BLOCKED) <> '1' .And. Substr(cCodDestin,1,3) <> xNumCaixa())
	oCodDestin:cSx1Hlp:="" 
	 
	@ 046,010 GROUP oGroup3 TO 176+nAltura2,162 LABEL STR0008 COLOR CLR_HBLUE OF oDlgSangr PIXEL // " Numerários "
	
	nLinha += 15
	@ nLinha,020 SAY STR0009 SIZE 60,10 OF ODlgSangr PIXEL // "Dinheiro:"
	@ nLinha,080 MSGET oDinheir VAR nDinheir Picture PesqPict("SL1","L1_DINHEIR",_PICTURE,nMoedaCorr) SIZE 70,10 OF ODlgSangr PIXEL RIGHT ;
	VALID FR271VLDSA(nDinheir)
	oDinheir:cSx1Hlp:="L1_DINHEIR" 
	
	nLinha += 15
	@ nLinha,020 SAY STR0010 SIZE 60,10 OF ODlgSangr PIXEL // "Cheques:"
	@ nLinha,080 MSGET oCheques VAR nCheques Picture PesqPict("SL1","L1_CHEQUES",_PICTURE,nMoedaCorr) WHEN (nCheck == 1 .And. lHabilita) SIZE 70,10 OF ODlgSangr PIXEL RIGHT ;
	VALID FR271VLDSA(nCheques)
	oCheques:cSx1Hlp:="L1_CHEQUES"
	
	nLinha += 15
	@ nLinha,020 SAY STR0011 SIZE 60,10 OF ODlgSangr PIXEL // "Cartão de Crédito:"
	@ nLinha,080 MSGET oCartao VAR nCartao Picture PesqPict("SL1","L1_CARTAO",_PICTURE,nMoedaCorr) WHEN (nCheck == 1 .And. lHabilita) SIZE 70,10 OF ODlgSangr PIXEL RIGHT ;
	VALID FR271VLDSA(nCartao)
	oCartao:cSx1Hlp:="L1_CARTAO"
	
	nLinha += 15
	@ nLinha,020 SAY STR0012 SIZE 60,10 OF ODlgSangr PIXEL // "Cartão de Débito:"
	@ nLinha,080 MSGET oVlrDebi VAR nVlrDebi Picture PesqPict("SL1","L1_VLRDEBI",_PICTURE,nMoedaCorr) WHEN (nCheck == 1 .And. lHabilita) SIZE 70,10 OF ODlgSangr PIXEL RIGHT ;
	VALID FR271VLDSA(nVlrDebi)
	oVlrDebi:cSx1Hlp:="L1_VLRDEBI"
	
	nLinha += 15
	@ nLinha,020 SAY STR0013 SIZE 60,10 OF ODlgSangr PIXEL // "Financiado:"
	@ nLinha,080 MSGET oFinanc VAR nFinanc Picture PesqPict("SL1","L1_FINANC",_PICTURE,nMoedaCorr) WHEN (nCheck == 1 .And. lHabilita) SIZE 70,10 OF ODlgSangr PIXEL RIGHT ;
	VALID FR271VLDSA(nFinanc)
	oFinanc:cSx1Hlp:="L1_FINANC"
	
	nLinha += 15
	@ nLinha,020 SAY STR0014 SIZE 60,10 OF ODlgSangr PIXEL // "Convênio:"
	@ nLinha,080 MSGET oConveni VAR nConveni Picture PesqPict("SL1","L1_CONVENI",_PICTURE,nMoedaCorr) WHEN (nCheck == 1 .And. lHabilita) SIZE 70,10 OF ODlgSangr PIXEL RIGHT ;
	VALID FR271VLDSA(nConveni)
	oConveni:cSx1Hlp:="L1_CONVENI"
	
	nLinha += 15
	@ nLinha,020 SAY STR0015 SIZE 60,10 OF ODlgSangr PIXEL // "Vales:"
	@ nLinha,080 MSGET oVales VAR nVales Picture PesqPict("SL1","L1_VALES",_PICTURE,nMoedaCorr) WHEN (nCheck == 1 .And. lHabilita) SIZE 70,10 OF ODlgSangr PIXEL RIGHT ;
	VALID FR271VLDSA(nVales)
	oVales:cSx1Hlp:="L1_VALES"
	
	nLinha += 15
	@ nLinha,020 SAY STR0016 SIZE 60,10 OF ODlgSangr PIXEL // "Outros:"
	@ nLinha,080 MSGET oOutros VAR nOutros Picture PesqPict("SL1","L1_OUTROS",_PICTURE,nMoedaCorr) WHEN (nCheck == 1 .And. lHabilita) SIZE 70,10 OF ODlgSangr PIXEL RIGHT ;
	VALID FR271VLDSA(nOutros)
	oOutros:cSx1Hlp:="L1_OUTROS"

	If lL1VLRPGDG
		nLinha += 15
		@ nLinha,020 SAY STR0055 SIZE 60,10 OF ODlgSangr PIXEL // "Pagamento Digital"
		@ nLinha,080 MSGET oPgtoDigit VAR nVlrPagDig Picture PesqPict("SL1","L1_OUTROS",_PICTURE,nMoedaCorr) WHEN (nCheck == 1 .And. lHabilita) SIZE 70,10 OF ODlgSangr PIXEL RIGHT ;
		VALID FR271VLDSA(nVlrPagDig)
		oPgtoDigit:cSx1Hlp:="L1_VLRPGDG"

		nLinha += 15
		@ nLinha,020 SAY STR0056 SIZE 60,10 OF ODlgSangr PIXEL // "PIX"
		@ nLinha,080 MSGET oPgtoPix VAR nVlrPagPix Picture PesqPict("SL1","L1_OUTROS",_PICTURE,nMoedaCorr) WHEN (nCheck == 1 .And. lHabilita) SIZE 70,10 OF ODlgSangr PIXEL RIGHT ;
		VALID FR271VLDSA(nVlrPagPix)
		oPgtoPix:cSx1Hlp:="L1_VLRPGPX"
	EndIf
	
	If cPaisLoc != "BRA"
		nLinha += 15
	   	@ nLinha,020 SAY STR0026 SIZE 60,10 OF ODlgSangr PIXEL  //"Moeda: " 		
	   	@ nLinha,080 MSCOMBOBOX oMoeda VAR cMoedaCorr ITEMS aMoedas ON CHANGE (nMoedaCorr:=oMoeda:nAt);
	             SIZE 70,10 OF ODlgSangr PIXEL 
	EndIf
	
	DEFINE SBUTTON oBtnAct FROM 180+nAltura2,105 TYPE 1 ENABLE ACTION ;
			Fr271D050Conf(	nCheck		,cCaixaSup	,cCodOrigem	,cCodDestin,;
							nDinheir	,nCheques	,nCartao	,nVlrDebi,;
							nFinanc		,nConveni	,nVales		,nOutros,;
							aSimbs		,ODlgSangr	,nVlrPagDig ,nVlrPagPix ) OF ODlgSangr
	DEFINE SBUTTON oBtnEnd FROM 180+nAltura2,135 TYPE 2 ENABLE ACTION ODlgSangr:End() OF ODlgSangr	
	
Else // Touch Screen
	DEFINE MSDIALOG ODlgSangr FROM 1,1 TO 450+nAltura,480 TITLE STR0001 PIXEL OF GetWndDefault()


	@ 005,004 GROUP oGroup1 TO 043,057 LABEL STR0002 COLOR CLR_HBLUE OF oDlgSangr PIXEL

	@ 013,007 RADIO oCheck VAR nCheck 3D SIZE 47,10 PROMPT STR0003,STR0004 ON CHANGE Fr271D050Enab(nCheck,@cCodOrigem,@cCodDestin,oCodOrigem,oCodDestin) OF ODlgSangr PIXEL

	If ! nCheck == 0
		oCheck:Disable()
	Else
		nCheck := 1
	EndIf

	@ 005,061 GROUP oGroup2 TO 043,162 LABEL STR0005 COLOR CLR_HBLUE OF oDlgSangr PIXEL

	@ 012,065 SAY STR0006 SIZE 50,10 OF ODlgSangr PIXEL
	@ 012,120 MSGET oCodOrigem VAR cCodOrigem F3 "23" WHEN nCheck == 2 SIZE 30,10 OF ODlgSangr PIXEL;
	VALID SX5->(dbSeek(xFilial("SX5")+"23"+cCodOrigem)) .and. SA6->(dbSeek(xFilial("SA6")+cCodOrigem) .And. cCodOrigem <> xNumCaixa())
	oCodOrigem:bGotFocus := { || oKeyboard := TKeyboard():New( nKeyATop, nKeyALeft, 2, oDlgSangr ), oKeyboard:SetVars( oCodOrigem, 30 ),;
		  oKeyboard:bEsc:={|| oDlgSangr:End()},;
		  oKeyboard:SetEnter({|| Fr271D050Conf(nCheck		,cCaixaSup	,cCodOrigem	,cCodDestin,;
  	 	  			  		                 nDinheir	,nCheques	,nCartao	,nVlrDebi,;
										     nFinanc		,nConveni	,nVales		,nOutros,;
										     aSimbs		,ODlgSangr)}) }
	oCodOrigem:bLostFocus := { || oKeyboard := nil }
	oCodOrigem:cSx1Hlp:=""

	@ 027,065 SAY STR0007 SIZE 50,10 OF ODlgSangr PIXEL
	@ 027,120 MSGET oCodDestin VAR cCodDestin F3 "23" WHEN nCheck == 1 SIZE 30,10 OF ODlgSangr PIXEL ;
	VALID SX5->(dbSeek(xFilial("SX5")+"23"+cCodDestin)) .and. SA6->(dbSeek(xFilial("SA6")+cCodDestin) .And. cCodDestin <> xNumCaixa())
	oCodDestin:bGotFocus := { || oKeyboard := TKeyboard():New( nKeyNTop, nKeyNLeft, 2, oDlgSangr ), oKeyboard:SetVars( oCodDestin, 30 ),;
  		     oKeyboard:bEsc:={|| oDlgSangr:End()},;
		     oKeyboard:SetEnter({|| Fr271D050Conf(nCheck		,cCaixaSup	,cCodOrigem	,cCodDestin,;
  	 	  	  		  		                    nDinheir	,nCheques	,nCartao	,nVlrDebi,;
										        nFinanc		,nConveni	,nVales		,nOutros,;
										        aSimbs		,ODlgSangr)})}
	oCodDestin:bLostFocus := { || oKeyboard := nil }
	oCodDestin:cSx1Hlp:=""
	
	@ 047,004 GROUP oGroup3 TO 116+nAltura2, 226 LABEL STR0008 COLOR CLR_HBLUE OF oDlgSangr PIXEL
	
	@ 055,008 SAY STR0009 SIZE 50,10 OF ODlgSangr PIXEL
	@ 055,060 MSGET oDinheir VAR nDinheir Picture PesqPict("SL1","L1_DINHEIR",_PICTURE,nMoedaCorr) SIZE 50,10 OF ODlgSangr PIXEL RIGHT
	oDinheir:bGotFocus := { || oKeyboard := TKeyboard():New( nKeyNTop, nKeyNLeft, 1, ODlgSangr ), oKeyboard:SetVars( oDinheir, 30 ),;
	       oKeyboard:bEsc:={|| oDlgSangr:End()},;
		   oKeyboard:SetEnter({|| Fr271D050Conf(nCheck		,cCaixaSup	,cCodOrigem	,cCodDestin,;
  	 	    		  		                  nDinheir	,nCheques	,nCartao	,nVlrDebi,;
										      nFinanc		,nConveni	,nVales		,nOutros,;
										      aSimbs		,ODlgSangr)})}
	oDinheir:bLostFocus := { || oKeyboard := nil }
	oDinheir:cSx1Hlp:="L1_DINHEIR"
	
	@ 070,008 SAY STR0010 SIZE 50,10 OF ODlgSangr PIXEL
	@ 070,060 MSGET oCheques VAR nCheques Picture PesqPict("SL1","L1_CHEQUES",_PICTURE,nMoedaCorr) WHEN (nCheck == 1 .And. lHabilita) SIZE 50,10 OF ODlgSangr PIXEL RIGHT
	oCheques:bGotFocus := { || oKeyboard := TKeyboard():New( nKeyNTop, nKeyNLeft, 1, ODlgSangr ), oKeyboard:SetVars( oCheques, 30 ),;
           oKeyboard:bEsc:={|| oDlgSangr:End()},;
	       oKeyboard:SetEnter({|| Fr271D050Conf(nCheck		,cCaixaSup	,cCodOrigem	,cCodDestin,;
  	 	   		  		                      nDinheir	,nCheques	,nCartao	,nVlrDebi,;
										      nFinanc		,nConveni	,nVales		,nOutros,;
										      aSimbs		,ODlgSangr)})}
	oCheques:bLostFocus := { || oKeyboard := nil }
	oCheques:cSx1Hlp:="L1_CHEQUES"
	
	@ 085,008 SAY STR0011 SIZE 50,10 OF ODlgSangr PIXEL
	@ 085,060 MSGET oCartao VAR nCartao Picture PesqPict("SL1","L1_CARTAO",_PICTURE,nMoedaCorr) WHEN (nCheck == 1 .And. lHabilita) SIZE 50,10 OF ODlgSangr PIXEL RIGHT
	oCartao:bGotFocus := { || oKeyboard := TKeyboard():New( nKeyNTop, nKeyNLeft, 1, ODlgSangr ), oKeyboard:SetVars( oCartao, 30 ),;
  		     oKeyboard:bEsc:={|| oDlgSangr:End()},;
		     oKeyboard:SetEnter({|| Fr271D050Conf(nCheck		,cCaixaSup	,cCodOrigem	,cCodDestin,;
  	 	  	  		  		                    nDinheir	,nCheques	,nCartao	,nVlrDebi,;
										        nFinanc		,nConveni	,nVales		,nOutros,;
										        aSimbs		,ODlgSangr)})}
	oCartao:bLostFocus := { || oKeyboard := nil }
	oCartao:cSx1Hlp:="L1_CARTAO"
	
	@ 100,008 SAY STR0012 SIZE 50,10 OF ODlgSangr PIXEL
	@ 100,060 MSGET oVlrDebi VAR nVlrDebi Picture PesqPict("SL1","L1_VLRDEBI",_PICTURE,nMoedaCorr) WHEN (nCheck == 1 .And. lHabilita) SIZE 50,10 OF ODlgSangr PIXEL RIGHT
	oVlrDebi:bGotFocus := { || oKeyboard := TKeyboard():New( nKeyNTop, nKeyNLeft, 1, ODlgSangr ), oKeyboard:SetVars( oVlrDebi, 30 ),;
  		     oKeyboard:bEsc:={|| oDlgSangr:End()},;
		     oKeyboard:SetEnter({|| Fr271D050Conf(nCheck		,cCaixaSup	,cCodOrigem	,cCodDestin,;
  	 	  	  		  		                    nDinheir	,nCheques	,nCartao	,nVlrDebi,;
										        nFinanc		,nConveni	,nVales		,nOutros,;
										        aSimbs		,ODlgSangr)})}
	oVlrDebi:bLostFocus := { || oKeyboard := nil }
	oVlrDebi:cSx1Hlp:="L1_VLRDEBI"
	
	@ 055,120 SAY STR0013 SIZE 50,10 OF ODlgSangr PIXEL
	@ 055,172 MSGET oFinanc VAR nFinanc Picture PesqPict("SL1","L1_FINANC",_PICTURE,nMoedaCorr) WHEN (nCheck == 1 .And. lHabilita) SIZE 50,10 OF ODlgSangr PIXEL RIGHT
	oFinanc:bGotFocus := { || oKeyboard := TKeyboard():New( nKeyNTop, nKeyNLeft, 1, ODlgSangr ), oKeyboard:SetVars( oFinanc, 30 ),;
  		     oKeyboard:bEsc:={|| oDlgSangr:End()},;
		     oKeyboard:SetEnter({|| Fr271D050Conf(nCheck		,cCaixaSup	,cCodOrigem	,cCodDestin,;
  	 	  	  		  		                    nDinheir	,nCheques	,nCartao	,nVlrDebi,;
										        nFinanc		,nConveni	,nVales		,nOutros,;
										        aSimbs		,ODlgSangr)})}
	oFinanc:bLostFocus := { || oKeyboard := nil }
	oFinanc:cSx1Hlp:="L1_FINANC"
	
	@ 070,120 SAY STR0014 SIZE 50,10 OF ODlgSangr PIXEL
	@ 070,172 MSGET oConveni VAR nConveni Picture PesqPict("SL1","L1_CONVENI",_PICTURE,nMoedaCorr) WHEN (nCheck == 1 .And. lHabilita) SIZE 50,10 OF ODlgSangr PIXEL RIGHT
	oConveni:bGotFocus := { || oKeyboard := TKeyboard():New( nKeyNTop, nKeyNLeft, 1, ODlgSangr ), oKeyboard:SetVars( oConveni, 30 ),;
  		     oKeyboard:bEsc:={|| oDlgSangr:End()},;
		     oKeyboard:SetEnter({|| Fr271D050Conf(nCheck		,cCaixaSup	,cCodOrigem	,cCodDestin,;
  	 	  	  		  		                    nDinheir	,nCheques	,nCartao	,nVlrDebi,;
										        nFinanc		,nConveni	,nVales		,nOutros,;
										        aSimbs		,ODlgSangr)})}
	oConveni:bLostFocus := { || oKeyboard := nil }
	oConveni:cSx1Hlp:="L1_CONVENI"
	
	@ 085,120 SAY STR0015 SIZE 50,10 OF ODlgSangr PIXEL
	@ 085,172 MSGET oVales VAR nVales Picture PesqPict("SL1","L1_VALES",_PICTURE,nMoedaCorr) WHEN (nCheck == 1 .And. lHabilita) SIZE 50,10 OF ODlgSangr PIXEL RIGHT
	oVales:bGotFocus := { || oKeyboard := TKeyboard():New( nKeyNTop, nKeyNLeft, 1, ODlgSangr ), oKeyboard:SetVars( oVales, 30 ),;
  		     oKeyboard:bEsc:={|| oDlgSangr:End()},;
		     oKeyboard:SetEnter({|| Fr271D050Conf(nCheck		,cCaixaSup	,cCodOrigem	,cCodDestin,;
  	 	  	  		  		                    nDinheir	,nCheques	,nCartao	,nVlrDebi,;
										        nFinanc		,nConveni	,nVales		,nOutros,;
										        aSimbs		,ODlgSangr)})}
	oVales:bLostFocus := { || oKeyboard := nil }
	oVales:cSx1Hlp:="L1_VALES"
	
	@ 100,120 SAY STR0016 SIZE 50,10 OF ODlgSangr PIXEL
	@ 100,172 MSGET oOutros VAR nOutros Picture PesqPict("SL1","L1_OUTROS",_PICTURE,nMoedaCorr) WHEN (nCheck == 1 .And. lHabilita) SIZE 50,10 OF ODlgSangr PIXEL RIGHT
	oOutros:bGotFocus := { || oKeyboard := TKeyboard():New( nKeyNTop, nKeyNLeft, 1, ODlgSangr ), oKeyboard:SetVars( oOutros, 30 ),;
  		     oKeyboard:bEsc:={|| oDlgSangr:End()},;
		     oKeyboard:SetEnter({|| Fr271D050Conf(nCheck		,cCaixaSup	,cCodOrigem	,cCodDestin,;
  	 	  	  		  		                    nDinheir	,nCheques	,nCartao	,nVlrDebi,;
										        nFinanc		,nConveni	,nVales		,nOutros,;
										        aSimbs		,ODlgSangr)})}
	oOutros:bLostFocus := { || oKeyboard := nil }
	oOutros:cSx1Hlp:="L1_OUTROS"

	If cPaisLoc != "BRA"
	   @ 115,120 SAY STR0026 SIZE 50,10 OF ODlgSangr PIXEL  //"Moeda: " 		
	   @ 115,172 MSCOMBOBOX oMoeda VAR cMoedaCorr ITEMS aMoedas ON CHANGE (nMoedaCorr:=oMoeda:nAt);
	             SIZE 50,10 OF ODlgSangr PIXEL 
	EndIf   
	If nCheck == 1 
		oCodDestin:SetFocus()
	Else
		oCodOrigem:SetFocus()
	Endif

EndIf

ACTIVATE MSDIALOG ODlgSangr CENTER

RETURN NIL
             
/*ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Fr271D050C³ Autor ³ Cleber Martinez       ³ Data ³ 06/10/05 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descri‡ao ³ Confirma a gravacao dos valores informados (Botao OK)   	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Sintaxe   ³ ExpL1 := Fr271D050Conf(ExpN1, ExpC2, ExpC3, ExpC4,         ³±±
±±³			 ³ 					  ExpN5, ExpN6, ExpN7, ExpN8,             ³±±
±±³			 ³ 					  ExpN9, ExpN10, ExpN11, ExpN12,          ³±±
±±³  		 ³ 					  ExpA13, ExpO14)			              ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Parametros³ ExpN1 - Indica se eh Troco ou Sangria                      ³±±
±±³          ³ ExpC2 - Codigo do Caixa logado                             ³±±
±±³          ³ ExpC3 - Codigo do caixa (De)                               ³±±
±±³          ³ ExpC4 - Codigo do caixa (Ate)                              ³±±
±±³          ³ ExpN5 - Valor em dinheiro                                  ³±±
±±³          ³ ExpN6 - Valor em cheques                                   ³±±
±±³          ³ ExpN7 - Valor em cartao                                    ³±±
±±³          ³ ExpN8 - Valor em debitos 	                              ³±±
±±³          ³ ExpN9 - Valor financiado                                   ³±±
±±³          ³ ExpN10 - Valor em Convenios                                ³±±
±±³          ³ ExpN11 - Valor em Vales                                    ³±±
±±³          ³ ExpN12 - Outros valores                                    ³±±
±±³          ³ ExpA13 - array de Simbolos de Moeda                        ³±±
±±³          ³ ExpO14 - Objeto dialog                                     ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Front Loja			   								  	  ³±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Fr271D050Conf(nCheck		,cCaixaSup	,cCodOrigem	,cCodDestin	,;
						nDinheir	,nCheques	,nCartao	,nVlrDebi	,;
						nFinanc		,nConveni	,nVales		,nOutros	,;
						aSimbs		,ODlgSangr	,nVlrPagDig	,nVlrPagPix )

Local lFrt050SB := ExistBlock("FRT050SB")	//indica se existe o PE
Local lVldPE	:= .T.						//retorno da validacao executada no PE
Local lRet		:= .F.						//retorno da funcao
Local cRotCompr	:= SuperGetMV("MV_LJIMPCO",,"LOJR950") // Nome da rotina para impressao do comprovante Não Fiscal
Local lCompNFis	:= ExistBlock(cRotCompr)	// Indica se existe PE
Local nTotal	:= 0 

Default nVlrPagDig := 0
Default nVlrPagPix := 0

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada (antes da gravacao do SE5) ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lFrt050SB
	lVldPE := ExecBlock("FRT050SB",.F.,.F.,{nCheck,cCaixaSup,nDinheir,nCheques,nCartao,nVlrDebi,nFinanc,nConveni,nVales,nOutros,cCodOrigem,cCodDestin,nVlrPagDig,nVlrPagPix})
	If Valtype(lVldPE) != "L"
		lVldPE := .T.
	Endif	
Endif	

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Se o PE retornar .T., continua a gravacao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lVldPE                                                 
	LjMsgRun(STR0017,,{|| lRet := Fr271D050SE5(nCheck,cCodOrigem,cCodDestin,nDinheir,nCheques,nCartao,nVlrDebi,nFinanc,nConveni,nVales,nOutros,aSimbs,Nil,nVlrPagDig,nVlrPagPix)})

	If lRet .And. lCompNFis .And. cPaisLoc $ "COL|CHI"
		ExecBlock(cRotCompr,.F.,.F.,{nCheck,cCodOrigem,cCodDestin,nDinheir,nCheques,nCartao,nVlrDebi,nFinanc,nConveni,nVales,nOutros,aSimbs,nVlrPagDig,nVlrPagPix})
	Endif 
	
	If (lRet .And. LJProfile(3) .And. ExistBlock("Frt050ST"))
		ExecBlock("Frt050ST",.F.,.F.,{nCheck,cCaixaSup,nDinheir,nCheques,nCartao,nVlrDebi,nFinanc,nConveni,nVales,nOutros,nVlrPagDig,nVlrPagPix})
	Endif
	
	ODlgSangr:End()
	
	nTotal := nDinheir
	
	If LjNfPafEcf(SM0->M0_CGC)
		//Sobrescreve mesmo os valores quando eh PAF
		nTotal := nDinheir+nCheques+nCartao+nVlrDebi+nFinanc+nConveni+nVales+nOutros+nVlrPagDig+nVlrPagPix
	
		If nCheck == 2 
			LjxGrvMdz("CN",nTotal,STR0029)				//Suprimento
		EndIf	
	
		If nCheck == 1  
			LjxGrvMdz("CN",nTotal,Upper(STR0003)) 		//Sangria
		EndIf
		
		LjxGrvMdz("PV", 0, "REGPAF", "", "") //Registra o primeiro movimento, caso exista não grava duas vezes 
	EndIf
Endif
                    
Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Fr271D050E³ Autor ³ Edney Soares de Souza ³ Data ³ 26/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Ativa/Desativa os campos conforme a escolha do Radio Btn	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³Fr271D050				   								  	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Fr271D050Enab(nCheck,cCodOrigem,cCodDestin,oCodOrigem,oCodDestin)
If nCheck == 1
	cCodOrigem := xNumCaixa()
	oCodOrigem:Refresh()
	oCodDestin:SetFocus()
Else
	cCodDestin := xNumCaixa()
	oCodDestin:Refresh()
	oCodOrigem:SetFocus()
EndIf
Return NIL

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³Fr271D050S³ Autor ³ Edney Soares de Souza ³ Data ³ 26/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Gera o SE5 Conforme os campos digitados na tela			  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fr271D050			   								  	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³Data      | Analista | Bops  | Descricao                               |±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³18/11/2005| Marcos R.|088079 | Detalhamento da Sangria no CUPOM        |±± 
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function Fr271D050SE5(nCheck,cCodOrigem,cCodDestin,nDinheir,nCheques,nCartao,nVlrDebi,nFinanc,nConveni,nVales,nOutros,aSimbs,lMensa,nVlrPagDig,nVlrPagPix )

Local aNumerarios, nNum
Local nTotal 		:= 0
Local cSimb 		:= GetMV("MV_SIMB"+LTrim(Str(nMoedaCorr)))
Local nRet			:= 0   
Local lSup      	:= SuperGetMV("MV_FORMSUP", ,.F.)
Local cFormSup		:= '' 								// Contem a descricao das formas de Suprimentos que saira no cupom
Local cCupom		:= "" 								//Numero do cupom
Local lRet			:= .T.
Local lFrt050ST 	:= ExistBlock("Frt050ST")
Local nPicture		:= (_PICTURE) +1
Local cMvCxLoja		:= SuperGetMV("MV_CXLOJA",.F.,"")	//Parâmetro MV_CXLOJA
Local cCxLoja		:= "" 								//Parâmetro agência/conta caixa central 
Local aCupom 		:={}								//Guarda as informações de Cupom e Serie
//Importante: as variáveis lEmitNfce, lFtvdVer12 tiveram seu escopo alterado para variável locais, pois o cliente pode mudar de modulo para o SigaFAT através do SIGAADV
Local lEmitNfce		:= LjEmitNFCe()						// Sinaliza se utiliza NFC-e
Local lFtvdVer12	:= LjFTVD()							//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local nTamSA6		:= Fr271A6Bco(cMvCxLoja)			//Tamanho do codigo do caixa
Local cCodSA6		:= ""								//Caixa padrão no parametro MV_CXLOJA
Local cAgenSA6		:= ""								//Agência no parâmetro MV_CXLOJA
Local cContSA6		:= ""								//Conta no parâmetro MV_CXLOJA
Local cPrefixo		:= ""								//Prefixo para gravação do movimento na SE5

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Estaremos utilizando esta função de outros programas             ³
//³portanto em determinadas ocasiões não deverei exibir mensagens   ³
//³parando o processo. Atualmente teremos no fonte LOJA340 e LOJA350³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Default lMensa		:= .T.
Default nVlrPagDig	:= 0
Default nVlrPagPix	:= 0

nTotal 		:= nDinheir + nCheques + nCartao + nVlrDebi + nFinanc + nConveni + nVales + nOutros + nVlrPagDig + nVlrPagPix

cCodSA6		:= Substr(cMvCxLoja,1,nTamSA6)		// Caixa padrão no parametro MV_CXLOJA
cMvCxLoja	:= Substr(cMvCxLoja,At("/", cMvCxLoja)+1,len(cMvCxLoja)) 
cAgenSA6	:= Substr(cMvCxLoja,1,At("/", cMvCxLoja)-1)
cMvCxLoja	:= Substr(cMvCxLoja,At("/", cMvCxLoja)+1,len(cMvCxLoja))
cContSA6	:= Substr(cMvCxLoja,1,len(cMvCxLoja))
cCxLoja		:= cCodSA6 + cAgenSA6 + cContSA6 	//Parâmetro agência/conta caixa central 

If nTotal == 0 .And. lMensa
	MsgStop(STR0018,STR0024)  //"Nenhum valor foi informado, nenhuma movimentação será gerada." ### "Atenção"
	lRet := .F.
EndIf

If lRet .AND. lMensa
	//"Confirma gravação da(s) movimentação(ões) referente(s) a quantia de: "
	If !MsgYesNo(STR0019+cSimb+" "+Transform(nTotal,PesqPict("SL1","L1_DINHEIR",nPicture,nMoedaCorr)) )
		lRet := .F.
	EndIf
EndIf

If lRet
	aNumerarios := {{cSimb,nDinheir},;
					{"CH",nCheques},;
					{"CC",nCartao},;
					{"CD",nVlrDebi},;
					{"FI",nFinanc},;
					{"CO",nConveni},;
					{"VA",nVales},;
					{"OU",nOutros}}

	If SL1->(ColumnPos("L1_VLRPGDG")) > 0 .AND. SL1->(ColumnPos("L1_VLRPGPX")) > 0
		aAdd( aNumerarios, {"PD",nVlrPagDig} )
		aAdd( aNumerarios, {"PX",nVlrPagPIX} )
	EndIf

	If lSup         
		If nDinheir > 0
			cFormSup	:= "DINHEIRO|" + STRZERO(nDinheir, 10,2)+"|"
		EndIf
		If nCheques > 0			     
			cFormSup := cFormSup + "CHEQUE|" + STRZERO(nCheques, 10,2)+"|"
		EndIf	
		If nCartao > 0			     
			cFormSup := cFormSup + "CARTAO CREDITO|" + STRZERO(nCartao, 10,2)+"|"
		EndIf	
		If nVlrDebi > 0			     
			cFormSup := cFormSup + "CARTAO DEBITO|" + STRZERO(nVlrDebi, 10,2)+"|"
		EndIf	
		If nFinanc > 0			     
			cFormSup := cFormSup + "FINANCIADO|" + STRZERO(nFinanc, 10,2)+"|"
		EndIf	
		If nConveni > 0			     
			cFormSup := cFormSup + "CONVENIO|" + STRZERO(nConveni, 10,2)+"|"
		EndIf
		If nVales > 0			     
			cFormSup := cFormSup + "VALES|" + STRZERO(nVales, 10,2)+"|"
		EndIf

		If nVlrPagDig > 0
			cFormSup := cFormSup + "PAGTO DIGITAL|" + STRZERO(nVlrPagDig, 10,2)+"|"
		EndIf

		If nVlrPagPix > 0
			cFormSup := cFormSup + "PAGTO PIX|" + STRZERO(nVlrPagPix, 10,2)+"|"
		EndIf

		If nOutros > 0			     
			cFormSup := cFormSup + "OUTROS|" + STRZERO(nOutros, 10,2)+"|"
		EndIf
	EndIf

EndIf	

If lRet .And. !lEmitNfce .And. !lFtvdVer12
	nRet := IfPegCupom( nHdlECF, @cCupom)
	AADD(aCupom,{LjGetStation("LG_SERIE"),cCupom})
	If !(nRet == 0)
		// "Não foi possível registrar " ### "Sangria","Troco" ### " no ECF. Operação não efetuada." ### "Atenção"
		MsgStop(STR0027 + If(nCheck==1,STR0003,STR0004) + STR0028, STR0024)
		lRet := .F.
	Else
		If cPaisLoc == "MEX"
			LjImplCOO( @nRet ) //quando utilizado ECFEMUL e o IBM4610 do Mexico é necessário incrementar este número - função do LojxEcf
		EndIf
	EndIf
ElseIf lRet .AND. (lEmitNfce .Or. lFtvdVer12)
	//Quando regime NFC-e, SAT ou Venda Direta, considera a serie não fiscal do campo LG_SERNFIS 
	//como prefixo (E5_PREFIXO) para incluir o registro de movimento de sangria na tabela SE5.
	//Validação para não deixar prosseguir, caso o campo LG_SERNFIS não estiver preenchido.
	cPrefixo := LjGetStation("SERNFIS")
	If Empty(cPrefixo) 
		MsgStop(STR0057,STR0058) //"Não é possível continuar! Para realizar essa operação é obrigatório o preenchimento do campo 'Serie não Fiscal' no cadastro de estação (LG_SERNFIS)."###"Operação não realizada"
		lRet := .F.
	ElseIf !LjxDNota( cPrefixo, 3, .F., 1, @aCupom )  
		lRet := .F.
	EndIf
EndIf

If lRet

	//Se for caixa geral, passo o parâmetro igual ao que está em MV_CXLOJA
	If Substr(cCodOrigem,1,nTamSA6) = Substr(cCxLoja,1,nTamSA6)
		cCodOrigem := cCxLoja
	EndIf
	If Substr(cCodDestin,1,nTamSA6) = Substr(cCxLoja,1,nTamSA6)
		cCodDestin := cCxLoja
	EndIf
	//Gravacao da SE5
	For nNum := 1 to If(nCheck==1,Len(aNumerarios),1)
		If !aNumerarios[nNum][2] == 0

			// Verifica a existencia dos bancos de Origem e Destino antes de enviar para gravação

			If !SA6->(dbSeek( xFilial("SA6") + cCodOrigem ))
				MSGAlert(STR0051 			  + CHR(13) + CHR(10) +;					
						 STR0050 + cCodOrigem + CHR(13) + CHR(10) +;
						 					    CHR(13) + CHR(10) +;
						 STR0052 )										
				/*
				"Código de caixa origem não encontrado, verifique o cadastro de bancos!"		
				"Código: "

				"Este movimento não será gravado!"
				*/ 

				lRet := .F.

				LjGrvLog("Sangria"," Código de caixa origem não encontrado, codigo: " + cCodOrigem )

			EndIf

			If !( lRet .AND. SA6->(dbSeek( xFilial("SA6") + cCodDestin )) )
				MSGAlert(STR0053 			  + CHR(13) + CHR(10) +;
						 STR0050 + cCodDestin + CHR(13) + CHR(10) +;
						 					    CHR(13) + CHR(10) +;
						 STR0052 			  + CHR(13) + CHR(10) +;
						 					    CHR(13) + CHR(10) +;
						 STR0054 )

				/*
				"Código de Banco/Agente/Conta destino não encontrado, verifique a configuração do parâmetro MV_CXLOJA!"
				"Código: XXXXXXXXXXXXXX"

				"Este movimento não será gravado!"

				"O Banco/Agente/Conta contido no parâmetro MV_CXLOJA será criado no proximo acesso ao sistema."
				*/

				lRet := .F.

				LjGrvLog("Sangria"," Código de caixa destino não encontrado, codigo: " + cCodDestin )

			EndIf

			If lRet
			
				FR271D050Grv(cCodOrigem, nCheck, "P", aNumerarios[nNum], aSimbs, aCupom)				

				//Gera FKs com base na SE5 gerada
				LjSE5ToFKs()

				FR271D050Grv(cCodDestin, nCheck, "R", aNumerarios[nNum], aSimbs, aCupom)				

				//Gera FKs com base na SE5 gerada
				LjSE5ToFKs()

			Else
				LjGrvLog("Sangria"," Movimento não foi gravado." )	
				LjGrvLog("Sangria"," Caixa informado no parametro MV_CXLOJA nao existe e sera criado no proximo acesso ao sistema." )
				Exit		
			EndIf				 

		EndIf
	Next nNum

	If (lFiscal .Or. lFtvdVer12) .And. nTotal > 0 .And. !lFrt050ST .AND. lRet

		nRet := IFSupr( nHdlECF, If(nCheck=1,3,nCheck), StrZero(nTotal,14,2), "","",, cFormSup )

		If !(nRet == 0)
			// "Não foi possível registrar " ### "Sangria","Troco" ### " no ECF. Operação não efetuada." ### "Atenção"
			MsgStop(STR0027 + If(nCheck==1,STR0003,STR0004) + STR0028, STR0024)
			lRet := .F.
		EndIf
	EndIf
	
	If lFiscal .AND. nTotal > 0 .AND. LjUpd70Ok() .And. !lFrt050ST .AND. lRet
		//Fazer a chamada da funcao para impressao do complemento da sangria (relatorio gerencial)
		Fr271CSan(nCheck==1,iIf(nCheck==1,cCodDestin,cCodOrigem), , , , iIf(nCheck==1,"SANGRIA","TROCO"))
	Endif

EndIf

Return lRet

/*
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÚÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÂÄÄÄÄÄÄÂÄÄÄÄÄÄÄÄÄÄ¿±±
±±³Fun‡ao	 ³FR271D050G³ Autor ³ Edney Soares de Souza ³ Data ³ 26/09/00 ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄ´±±
±±³Descricao ³ Grava o Registro no SE5 conforme os parametros recebidos	  ³±±
±±ÃÄÄÄÄÄÄÄÄÄÄÅÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ´±±
±±³ Uso		 ³ Fr271D050  			 								  	  ³±±
±±ÀÄÄÄÄÄÄÄÄÄÄÁÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FR271D050Grv (cCodigo	, nCheck, cRecPag, aNum, ;
					   aSimbs	, aCupom)

Local cNatureza	:= ""
Local cHistor	:= If(nCheck == 1,STR0020,STR0021)+xNumCaixa()  //"SANGRIA DO CAIXA ","TROCO PARA O CAIXA "
Local cAgencia	:= ""
Local cConta	:= ""
Local nDecs1	:= MsDecimais(1)
Local cPrefixo	:= aCupom[1][1]					//Numero de serie do PDV
Local cCupom	:= aCupom[1][2]					//Numero do Cupom do PDV
Local nSequencia:= 0							//Proxima sequecia a ser gravada
Local cSTEstacao:= LjInfoCxAt(1,.F.,.T.)[2][1]	//[1]-CAIXA [2]-ESTACAO [3]-SERIE [4]-PDV
Local nRecnoSA6	:= Nil 							// Recno SA6

If nCheck == 1
	If ExistFunc("LjMExeParam")
		cNatureza	:= LjMExeParam("MV_NATSANG",.F.,"SANGRIA")
	Else
		cNatureza	:= SuperGetMv("MV_NATSANG",.F.,"SANGRIA")
	EndIf

Else
	If ExistFunc("LjMExeParam")
		cNatureza	:= LjMExeParam("MV_NATTROC",.F.,"TROCO")
	Else	
		cNatureza	:= SuperGetMv("MV_NATTROC",,"TROCO")
	EndIf
EndIf
DbSelectArea("SE5")

DbSetOrder(2)

If DbSeek(xFilial("SE5") + "TR" + PadR(cPrefixo, TamSX3("E5_PREFIXO")[1]) + PadR(cCupom, TamSX3("E5_NUMERO")[1]) + space(TamSX3("E5_PARCELA")[1]) + space(TamSX3("E5_TIPO")[1]) + DTOS(dDatabase))
   While !Eof() .AND. xFilial("SE5") + "TR" + PadR(cPrefixo, TamSX3("E5_PREFIXO")[1]) + PadR(cCupom, TamSX3("E5_NUMERO")[1]) + space(TamSX3("E5_PARCELA")[1]) + space(TamSX3("E5_TIPO")[1]) + DTOS(dDatabase) == SE5->E5_FILIAL + SE5->E5_TIPODOC + SE5->E5_PREFIXO + SE5->E5_NUMERO + SE5->E5_PARCELA + SE5->E5_TIPO + DTOS(SE5->E5_DATA)
	   nSequencia  := Val(SE5->E5_SEQ)
	   DbSkip()
   End 
EndIf

SA6->(dbSeek(xFilial("SA6")+cCodigo))
nRecnoSA6 := SA6->(RECNO()) // Salva o RECNO da SA6 pois na função LjNumMov ele é desposicionado

//Busca o Caixa da moeda correspondente a sangria                          
If cPaisLoc != "BRA" .And. nMoedaCorr > 1                      
	cConta	 := SA6->A6_NUMCON	      //Conta do Caixa na moeda 1                            
	cAgencia  := aSimbs[nMoedaCorr]	  //Agencia do Caixa na moeda da sangria/troco     
	LjxDVerCx(nMoedaCorr,cCodigo,cAgencia,cConta)   //Verifica se existe o Caixa na moeda da sangria/troco. Se nao existir,cria.           
	SA6->(dbSeek(xFilial("SA6")+cCodigo+cAgencia))  //Posiciona no Caixa da moeda da sangria/troco	
EndIf	

Reclock("SE5",.T.)
SE5->E5_FILIAL	:= xFilial("SE5")
SE5->E5_DATA	:= dDataBase
SE5->E5_BANCO	:= SA6->A6_COD
SE5->E5_AGENCIA	:= SA6->A6_AGENCIA
SE5->E5_CONTA	:= SA6->A6_NUMCON
SE5->E5_RECPAG	:= cRecPag
SE5->E5_HISTOR	:= AllTrim(cHistor)+"/"+cSTEstacao
SE5->E5_TIPODOC	:= "TR"
SE5->E5_MOEDA	:= If(nCheck=1, aNum[1], "TC")
SE5->E5_VALOR	:= aNum[2]
SE5->E5_DTDIGIT	:= dDataBase
SE5->E5_BENEF	:= Space(15)
SE5->E5_DTDISPO	:= SE5->E5_DATA
SE5->E5_NATUREZ	:= cNatureza
SE5->E5_SITUA	:= "00" // Criar esse campo para instalacao do Front Loja
SE5->E5_PREFIXO := cPrefixo
SE5->E5_NUMERO  := cCupom
SE5->E5_SEQ     := StrZero(nSequencia + 1, TamSX3("E5_SEQ")[1])
SE5->E5_NUMMOV	:= LjNumMov()

If cPaisLoc != "BRA"  //Para compatibilizar com o Resumo de Caixa
	SE5->E5_VLMOED2	:= Round(xMoeda(SE5->E5_VALOR,nMoedaCorr,1,dDatabase,nDecs1+1),nDecs1)
	SE5->E5_TIPO     := aNum[1]	   
EndIf   

SE5->E5_FILORIG := cFilAnt
SE5->(dbCommit())                   
SE5->(MsUnLock())

If ExistBlock("FRTDGRE5")	// PE apos a gravacao porem antes de subir para a RET
	ExecBlock("FRTDGRE5",.F.,.F.,{ SE5->(Recno()) })  //  A ideia desse PE e a gravacao de campos customizados
EndIf	                                                       

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Esta geração deve ser efetuada somente qdo chamada do Front Loja             ³
//³pois a tabela SLI tem como única função subir os movimentos para a retaguarda|
//³                                                                             ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If Alltrim(Upper(FunName())) $ "FRTA010|FRTA271"
	FR271BGerSLI("    ", "050", Str(SE5->(Recno()),17,0), "NOVO")
EndIf

// Atualiza o saldo bancário na SA6 e SE8
SA6->( dbGoTo( nRecnoSA6 ) )
AtuSalBco(	SA6->A6_COD	,SA6->A6_AGENCIA				, SA6->A6_NUMCON, dDataBase,;
			aNum[2]		, If(cRecPag == "P", "-","+")	,	Nil			, Nil)

Return NIL


/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Fr271CSan  ºAutor  ³Vendas Clientes       º Data ³  10/08/10   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para impressao de um complemento de informacoes a       º±±
±±º          ³respeito da sangria, atraves do relatorio gerencial.           º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³lSanParc : Determina se trata-se de uma oper. sangria parcial  º±±
±±º          ³cCxDest  : Caixa de destino, quando nao for o caixa geral      º±±
±±º          ³dAbert   : Data de abertura do movimento                       º±±
±±º          ³cNumMov  : Numero do movimento                                 º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³                                                               º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Function Fr271CSan(lSanParc,cCxDest,dAbert,cNumMov,aID,cOperacao)
Local aArea				:= GetArea()
Local lImpComp			:= SuperGetMV("MV_LJICMSA",.F.,.F.)	//Imprimir complemento da sangria?
Local lImpAF			:= SuperGetMV("MV_LJDESM",.F.,.F.)		//Imprimir complemento detalhado por adm. financeira?
Local lContMovSE5		:= .T.
Local ni				:= 0
Local nx				:= 0
Local nPos				:= 0
Local nLeiaute			:= IIf(lSanParc .OR. !lImpComp,1,IIf(!lImpAF,2,3))
Local aNumerario		:= {}	//Tabela que armanezara toda a somatoria das entradas de : 1.troco 2.sangria 3.vendas 4.valores digitados na conferencia
Local cChave			:= ""
Local aCxDest			:= {}
Local aTotAF			:= {} 	//Aplicavel apenas para vendas e conferencia,armazena : 1.Forma pagto 2.Adm 3.Valor 4.Valor conferencia 5.Quantidade
Local cLinSep			:= ""
Local lQry				:= .F.
Local cQry				:= ""
Local cAlias			:= GetNextAlias()
Local lHabTroco     	:= SuperGetMV("MV_LJTROCO",,.F.)
Local nTotCanc			:= 0	//Total de cancelamento
Local aFPADM			:= {}	//Array que armazena as formas de pagamento utilizadas pelas administradoras financeiras
Local cCodAF			:= ""	//Codigo da adm. financeira
Local lCanc				:= .F.
Local nValFP			:= 0
Local lTabAtual			:= .F.	//Determina se as tabelas de movimento e conferencia foram atualizadas
Local nValTMP			:= 0
Local nValTMP02			:= 0
Local cMasc				:= "@E 999,999,999.99"
Local cFiltro			:= ""
Local lInsLinha			:= .F.
Local lSXOk				:= LjUpd70Ok()	//Verifica se o dicionario de dados esta preparado para o uso da funcionalidade
Local lLjFLDispo		:= ExistFunc("LOJA0053")
Local cSimbC			:= SuperGetMV("MV_SIMB1",.F.,"")	//Moeda corrente
Local oFrm
Local nTamCADM			:= TamSX3("AE_COD")[1]		//Tamanho do codigo da administradora financeira
Local aLstFPQ			:= {}	//Lista de controle de forma de pagto. + admin por orcamento, para evitar a soma de qtde. em venda parcelada
Local lSomaQtde			:= .T.	//Variavel de controle de soma das quantidades de vendas
Local aFormExtra		:= {}
Local aFrt272bAss		:= {}
Local aBkAdmUsada		:= {}
Local cTcGetDb			:= TcGetDb()
Local cMvCxLoja	 		:= SuperGetMV("MV_CXLOJA",.F.,"")			//Parâmetro MV_CXLOJA
Local nTamSA6			:= Fr271A6Bco(cMvCxLoja)				//Calcula o tamanho de A6_COD
Local nOpcConf			:= SuperGetmv("MV_LJOPCON",,2)		//1-Conferencia por forma e totalizador (Recebimentos/SANGRIA/SUPRIMENTEO); 2-Conferencia por forma de pagamento 
Local nPosTc			:= 0

Static nCols			:= IIf(!Empty(LJGetStation("LG_LARGCOL")),LJGetStation("LG_LARGCOL"),40)
Static nColsUtil		:= nCols - 2
Static cCol				:= "-"
Static cLin				:= "|"

Default lSanParc		:= .T.
Default cCxDest	   		:= Substr(AllTrim(cMvCxLoja),1,Fr271A6Bco(cMvCxLoja))
Default dAbert			:= Date()
Default cNumMov	  		:= AllTrim(LjNumMov())
Default aID 			:= LjInfoCxAt(1,.F.,.T.)		//[1]-CAIXA [2]-ESTACAO [3]-SERIE [4]-PDV
Default cOperacao		:= ""

//Se nao imprime complemento de sangria, os parametros forem indevidos ou se o dicionario nao estiver atualizado, sair
If !lImpComp .OR. Empty(cCxDest) .OR. ValType(dAbert) # "D" .OR. Empty(cNumMov) .OR. ValType(cNumMov) # "C" .OR. ;
	ValType(aID) # "A" .OR. !(Len(aID) == 4 .OR. Len(aID) == 5) .OR. !lSXOk .OR. !lLjFLDispo
	
	Return Nil
Endif
oFrm := LJCFrmtLay():New(4,nCols,,cCol,cLin)
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definir estruturas de leiaute de impressao ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
oFrm:AddStruct(2,,,,{30,70})  															//Cabecalho da sangria
oFrm:AddStruct(3,,,,{45,65},{"L","R"})												//Entrada de troco
oFrm:AddStruct(4,,.T.,,{45,15,40},{"L","L","R"},{"VENDAS","QTDE.","VALOR"})			//Vendas
oFrm:AddStruct(5,,,,{45,65},{"L","R"})												//Sangrias (retiradas)
oFrm:AddStruct(6,,.T.,,{45,27,28},{"L","R","R"},{"DIGITADO","APURADO","DIFERENCA"})	//Conferencia

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Definir array com dados do caixa de destino³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If AllTrim(cCxDest) == AllTrim(cMvCxLoja)
	aAdd(aCxDest,Substr(AllTrim(cCxDest),1										,nTamSA6))
	aAdd(aCxDest,Substr(AllTrim(cCxDest),nTamSA6 + 2							,TamSX3("A6_AGENCIA")[1]))
	aAdd(aCxDest,Substr(AllTrim(cCxDest),nTamSA6 + TamSX3("A6_AGENCIA")[1] + 3	,TamSX3("A6_NUMCON")[1]))
Else
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Por alguma razao desconhecida, a pesquisa do caixa geral ³
	//³pode falhar atraves do dbseek, por conta disso foi       ³
	//³criado um filtro. Nao alterar!                           ³ 
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	dbSelectArea("SA6")
	SA6->(dbSetOrder(1))
	cFiltro := "A6_FILIAL = '" + xFilial("SA6") + "' .AND. A6_COD = '" + PadR(cCxDest,TamSX3("A6_COD")[1]) + "'"
	SA6->(dbSetFilter({|| &cFiltro},cFiltro))
	SA6->(dbGoTop())
	If !SA6->(Eof())
		aAdd(aCxDest,AllTrim(SA6->A6_COD))
		aAdd(aCxDest,AllTrim(SA6->A6_AGENCIA))
		aAdd(aCxDest,AllTrim(SA6->A6_NUMCON))
		aAdd(aCxDest,AllTrim(SA6->A6_NOME))
	Else
		//Caixa de destino sugerido nao encontrado, sair
		SA6->(dbClearFilter())
		Return Nil		
	Endif
	SA6->(dbClearFilter())
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montar a array de formas de pagamento ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cChave := xFilial("SX5") + "24"
dbSelectArea("SX5")
SX5->(dbSetOrder(1))
SX5->(dbSeek(cChave))
If SX5->(Found())
	Do While !SX5->(Eof()) .AND. RTrim(SX5->(X5_FILIAL + X5_TABELA)) == cChave
		If !SX5->(Deleted())
			/*
			1. Forma pagto reduzido 
			2. Troco,Sangria,Vendas,Valores digitados na conferencia (valor , quantidade)
			3. Forma pagto completo
			*/
			aAdd(aNumerario,{SX5->X5_CHAVE,{{0,0},{0,0},{0,0},{0,0}},SX5->X5_DESCRI})
		Endif
		SX5->(dbSkip())
	EndDo

	aAdd(aFormExtra, {"SG" , STR0030}) //"SANGRIA"
	aAdd(aFormExtra, {"TC" , STR0031}) //"ENTRADA DE TROCO"
	
	If nOpcConf == 1
		aAdd(aFormExtra, {"REC", STR0032}) //"RECEBIMENTOS"
		aAdd(aFormExtra, {"CB" , STR0033}) //"CORRESPONDENTES BANCARIOS"
		aAdd(aFormExtra, {"RCE", STR0034}) //"RECARGA DE CELULAR"
	EndIf

	For nI := 1 To Len(aFormExtra)
		aAdd(aNumerario,{aFormExtra[nI][1],{{0,0},{0,0},{0,0},{0,0}},aFormExtra[nI][2]})
	Next 

Else
	Return Nil
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Montar array de formas de pagamento utilizadas pelas ³
//³administradoras financeiras                          ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If lImpAF
	dbSelectArea("SAE")
	SAE->(dbGoTop())
	Do While !SAE->(Eof())
		If aScan(aFPADM,{|x| x == AllTrim(SAE->AE_TIPO)}) == 0
			aAdd(aFPADM,AllTrim(SAE->AE_TIPO))
		Endif
		SAE->(dbSkip())
	EndDo
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procurar movimentos de entrada de troco no SE5³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cChave := RTrim(xFilial("SE5") + DtoS(dAbert) + aID[1][1])
dbSelectArea("SE5")
SE5->(dbSetOrder(1))	//E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ
SE5->(dbSeek(cChave))
Do While !SE5->(Eof()) .AND. RTrim(SE5->(E5_FILIAL + DTOS(E5_DATA) + E5_BANCO)) == cChave
	//Se o movimento nao for de recebimento, se estiver cancelado ou se nao for um movimento de transferencia, saltar
	If SE5->E5_RECPAG # "R" .OR. SE5->E5_SITUACA == "C" .OR. SE5->E5_TIPODOC # "TR" .OR. SE5->E5_MOEDA # "TC" //Troco
		SE5->(dbSkip())
		Loop
	Endif
	//Caso exista controle de numero de movimento, validar
	If lContMovSE5
		If !Empty(SE5->E5_NUMMOV) .AND. AllTrim(SE5->E5_NUMMOV) # cNumMov
			SE5->(dbSkip())
			Loop
		Endif
	Endif		
	If (nPos := aScan(aNumerario,{|x| AllTrim(x[1]) == AllTrim(SE5->E5_MOEDA)})) > 0
		aNumerario[nPos][2][1][1] += SE5->E5_VALOR
		aNumerario[nPos][2][1][2] += 1
	Endif
	If (nOpcConf == 1 .OR. ExistCpo("SX5","24TC",,,.F.)) .AND. (nPos := aScan(aNumerario,{|x| AllTrim(x[1]) == "TC"})) > 0	//ENTRADA DE TROCO
		aNumerario[nPos][2][3][1] += SE5->E5_VALOR
		aNumerario[nPos][2][3][2] += 1
	Endif	
		
	SE5->(dbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procurar movimentos de Recebimentos no SE5 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cChave := RTrim(xFilial("SE5") + DtoS(dAbert) + aID[1][1])
dbSelectArea("SE5")
SE5->(dbSetOrder(1))	//E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ
SE5->(dbSeek(cChave))
Do While !SE5->(Eof()) .AND. RTrim(SE5->(E5_FILIAL + DTOS(E5_DATA) + E5_BANCO)) == cChave
	//Se o movimento nao for de recebimento, se estiver cancelado ou se nao for um movimento de transferencia, saltar
	If SE5->E5_RECPAG <> "R" .OR. SE5->E5_TIPO <> "FI" .OR. SE5->E5_TIPODOC # "VL"
		SE5->(dbSkip())
		Loop
	Endif
	//Caso exista controle de numero de movimento, validar
	If lContMovSE5
		If !Empty(SE5->E5_NUMMOV) .AND. AllTrim(SE5->E5_NUMMOV) # cNumMov
			SE5->(dbSkip())
			Loop
		Endif
	Endif
	If nOpcConf == 1	
		If (nPos := aScan(aNumerario,{|x| AllTrim(x[1]) == "REC" })) > 0
			aNumerario[nPos][2][3][1] += SE5->E5_VALOR
			aNumerario[nPos][2][3][2] += 1
		Endif   
	Else
		If (nPos := aScan(aNumerario,{|x| AllTrim(x[1]) == AllTrim(SE5->E5_MOEDA)})) > 0
			aNumerario[nPos][2][3][1] += SE5->E5_VALOR
			aNumerario[nPos][2][3][2] += 1	
		EndIf
	EndIf	
	SE5->(dbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procurar movimentos de Recarca de Cel. no SE5 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cChave := RTrim(xFilial("SE5") + DtoS(dAbert) + aID[1][1])
dbSelectArea("SE5")
SE5->(dbSetOrder(1))	//E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ
SE5->(dbSeek(cChave))
Do While !SE5->(Eof()) .AND. RTrim(SE5->(E5_FILIAL + DTOS(E5_DATA) + E5_BANCO)) == cChave
	//Se o movimento nao for de recebimento, se estiver cancelado ou se nao for um movimento de transferencia, saltar

	If Upper(AllTrim(SE5->E5_HISTOR)) <> Upper("RECARGA DE CELULAR") .OR. SE5->E5_TIPODOC # "VL"
		SE5->(dbSkip())
		Loop
	Endif
	//Caso exista controle de numero de movimento, validar
	If lContMovSE5
		If !Empty(SE5->E5_NUMMOV) .AND. AllTrim(SE5->E5_NUMMOV) # cNumMov
			SE5->(dbSkip())
			Loop
		Endif
	Endif
	If (nPos := aScan(aNumerario,{|x| AllTrim(x[1]) == "RCE" })) > 0
		aNumerario[nPos][2][3][1] += SE5->E5_VALOR
		aNumerario[nPos][2][3][2] += 1
	Endif
	SE5->(dbSkip())
EndDo

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Procurar movimentos de sangria (saida) no SE5 ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
cChave := RTrim(xFilial("SE5") + DtoS(dAbert) + aID[1][1])
dbSelectArea("SE5")
SE5->(dbSetOrder(1))	//E5_FILIAL+DTOS(E5_DATA)+E5_BANCO+E5_AGENCIA+E5_CONTA+E5_NUMCHEQ
SE5->(dbSeek(cChave))
Do While !SE5->(Eof()) .AND. RTrim(SE5->(E5_FILIAL + DTOS(E5_DATA) + E5_BANCO)) == cChave
	//Se o movimento nao for de recebimento, se estiver cancelado ou se nao for um movimento de transferencia, saltar
	If SE5->E5_RECPAG # "P" .OR. SE5->E5_SITUACA == "C" .OR. SE5->E5_TIPODOC # "TR"
		SE5->(dbSkip())
		Loop
	Endif
	//Caso exista controle de numero de movimento, validar
	If lContMovSE5
		If !Empty(SE5->E5_NUMMOV) .AND. AllTrim(SE5->E5_NUMMOV) # cNumMov
			SE5->(dbSkip())
			Loop
		Endif
	Endif	
	If (nPos := aScan(aNumerario,{|x| AllTrim(x[1]) == AllTrim(SE5->E5_MOEDA)})) > 0
		aNumerario[nPos][2][2][1] += SE5->E5_VALOR
		aNumerario[nPos][2][2][2] += 1
	Endif 
	If (nOpcConf == 1 .OR. ExistCpo("SX5","24SG",,,.F.)) .AND. (nPos := aScan(aNumerario,{|x| AllTrim(x[1]) == "SG"})) > 0		//Sangria
		aNumerario[nPos][2][3][1] += SE5->E5_VALOR
		aNumerario[nPos][2][3][2] += 1
	Endif	
	SE5->(dbSkip())
EndDo

//Diferença de entrada de troco e Sangria - Quando dinheiro e quando totaliza por forma de pagamento (MV_LJOPCON = 2)
If	nOpcConf == 2 .AND.;
	(nPosTc := aScan(aNumerario,{|x| AllTrim(x[1]) == "TC"})) > 0 .AND.;
	(nPos := aScan(aNumerario,{|x| AllTrim(x[1]) == "R$"})) > 0

	aNumerario[nPos][2][3][1] += (aNumerario[nPosTc][2][1][1] - aNumerario[nPos][2][2][1])
EndIF

If !cModulo $ "FRT"
	#IFDEF TOP
		lQry := .T.
	#ENDIF
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Levantamento das vendas ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nLeiaute # 1
	If lQry
		//NAO CANCELADAS
		cQry := "SELECT DISTINCT A.L1_FILIAL, A.L1_NUM, ('N') CANC, B.L4_FORMA, B.L4_ADMINIS, B.L4_MOEDA, "
		If lHabTroco
			cQry += "SUM(B.L4_VALOR) TOTAL "
		Else
			cQry += "SUM(B.L4_VALOR - B.L4_TROCO) TOTAL " 
		Endif
		cQry += "FROM " + RetSQLName("SL1") + " A INNER JOIN " + RetSQLName("SL4") + " B ON (A.L1_FILIAL = B.L4_FILIAL) AND (A.L1_NUM = B.L4_NUM) "
		cQry += "WHERE A.D_E_L_E_T_ <> '*' AND B.D_E_L_E_T_ <> '*' "
		cQry += "AND A.L1_FILIAL = '" + xFilial("SL1") + "' "	
		cQry += "AND A.L1_EMISSAO = '" + DtoS(dAbert) + "' "
		cQry += "AND A.L1_STORC NOT IN ('C','E') "
		cQry += "AND A.L1_SITUA <> '07' "
		cQry += "AND B.L4_ORIGEM = '' "
		cQry += "AND A.L1_OPERADO = '" + aID[1][1] + "' "	
		cQry += "AND A.L1_SERIE = '" + aID[3][1] + "' "
		cQry += "AND A.L1_PDV = '" + aID[4][1] + "' "
		cQry += "AND A.L1_ESTACAO = '" + aID[2][1] + "' "
		cQry += "AND A.L1_NUMMOV = '" + cNumMov + "' "
		cQry += "GROUP BY A.L1_FILIAL, A.L1_NUM, B.L4_FORMA, B.L4_ADMINIS, B.L4_MOEDA "
		//CANCELADAS	
		cQry += "UNION ALL "
		cQry += "SELECT DISTINCT A.L1_FILIAL, A.L1_NUM, ('S') CANC, B.L4_FORMA, B.L4_ADMINIS, B.L4_MOEDA, "
		If lHabTroco
			cQry += "SUM(B.L4_VALOR) TOTAL "
		Else
			cQry += "SUM(B.L4_VALOR - B.L4_TROCO) TOTAL " 
		Endif	
		cQry += "FROM " + RetSQLName("SL1") + " A INNER JOIN " + RetSQLName("SL4") + " B ON (A.L1_FILIAL = B.L4_FILIAL) AND (A.L1_NUM = B.L4_NUM) "
		cQry += "WHERE A.D_E_L_E_T_ <> '*' AND B.D_E_L_E_T_ <> '*' "
		cQry += "AND A.L1_FILIAL = '" + xFilial("SL1") + "' "
		cQry += "AND A.L1_EMISSAO = '" + DtoS(dAbert) + "' "
		cQry += "AND (A.L1_STORC = 'C' OR A.L1_SITUA = '07') "
		cQry += "AND B.L4_ORIGEM = '' "
		cQry += "AND A.L1_OPERADO = '" + aID[1][1] + "' "	
		cQry += "AND A.L1_SERIE = '" + aID[3][1] + "' "
		cQry += "AND A.L1_PDV = '" + aID[4][1] + "' "
		cQry += "AND A.L1_ESTACAO = '" + aID[2][1] + "' "	
		cQry += "AND A.L1_NUMMOV = '" + cNumMov + "' "
		cQry += "GROUP BY A.L1_FILIAL, A.L1_NUM, B.L4_FORMA, B.L4_ADMINIS, B.L4_MOEDA "
		//CREDITOS
		cQry += "UNION ALL "
		cQry += "SELECT DISTINCT A.L1_FILIAL, A.L1_NUM, ('N') CANC, ('CR') L4_FORMA, ('') L4_ADMINIS, (" + RetMoeda(cSimbC,1,2,.F.) + ") L4_MOEDA, (A.L1_CREDITO) TOTAL  "
		cQry += "FROM " + RetSQLName("SL1") + " A "
		cQry += "WHERE A.D_E_L_E_T_ <> '*' "
		cQry += "AND A.L1_FILIAL = '" + xFilial("SL1") + "' "	
		cQry += "AND A.L1_EMISSAO = '" + DtoS(dAbert) + "' "
		cQry += "AND A.L1_STORC NOT IN ('C','E') "
		cQry += "AND A.L1_SITUA <> '07' "
		cQry += "AND A.L1_OPERADO = '" + aID[1][1] + "' "	
		cQry += "AND A.L1_SERIE = '" + aID[3][1] + "' "
		cQry += "AND A.L1_PDV = '" + aID[4][1] + "' "
		cQry += "AND A.L1_ESTACAO = '" + aID[2][1] + "' "
		cQry += "AND A.L1_NUMMOV = '" + AllTrim(cNumMov) + "' "
		cQry += "AND A.L1_CREDITO > 0 "		
		
		If AllTrim(cTcGetDb) == "POSTGRES"
			cQry += "ORDER BY 1 ASC, 2 ASC"
		ElseIf !(AllTrim(cTcGetDb) $ "DB2|DB2/400|ORACLE")
			cQry += "ORDER BY A.L1_FILIAL ASC, A.L1_NUM ASC"			
		Else
			//- O DB2 nao aceita nome de colunas qualificados na clausula ORDER BY 
			//em querys que utilizem os operadores : UNION, EXCEPT e INTERSECT
			cQry += "ORDER BY L1_FILIAL ASC, L1_NUM ASC"
		Endif
		
		If !(AllTrim(cTcGetDb) $ "DB2|DB2/400")
			cQry := ChangeQuery(cQry)
		EndIf

		dbUseArea(.T.,__cRDD,TcGenQry(,,cQry),cAlias,.T.,.F.)
		TcSetField(cAlias,"TOTAL","N",TamSX3("L4_VALOR")[1],TamSX3("L4_VALOR")[2])
		TcSetField(cAlias,"L4_MOEDA","N",TamSX3("L4_MOEDA")[1],0)
		(cAlias)->(dbGoTop())
		Do While !(cAlias)->(Eof())
			nValFP := (cAlias)->TOTAL
			cCodAF := Substr((cAlias)->L4_ADMINIS,1,nTamCADM)
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Verificar se a quantidade da venda jah nao foi registrada ³
			//³pela ORC + FP + ADM + MOEDA, se foi, nao somar.           ³
			//³Isso visa evitar que FP desdobradas aumentem a qtde. de   ³
			//³venda por FP de acordo com o seu numero de parcelas.      ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If aScan(aLstFPQ,{|x| x[1] == AllTrim((cAlias)->L1_FILIAL) .AND. x[2] == AllTrim((cAlias)->L1_NUM) .AND. ;
				x[3] == AllTrim((cAlias)->L4_FORMA) .AND. x[4] == AllTrim(cCodAF) .AND. x[5] == AllTrim((cAlias)->L4_MOEDA)}) == 0
							
				aAdd(aLstFPQ,{AllTrim((cAlias)->L1_FILIAL),AllTrim((cAlias)->L1_NUM),AllTrim((cAlias)->L4_FORMA),AllTrim(cCodAF),AllTrim((cAlias)->L4_MOEDA)})
				lSomaQtde := .T.
			Else	
				lSomaQtde := .F.
			Endif
			//Verificar se o pagamento foi realizado em moeda estrangeira e necessita conversao
			If (cAlias)->L4_MOEDA > 1
				nValFP := xMoeda(nValFP,(cAlias)->L4_MOEDA,1,dAbert)
			Endif
			If (cAlias)->CANC == "N"
				If (nPos := aScan(aNumerario,{|x| AllTrim(x[1]) == AllTrim((cAlias)->L4_FORMA)})) > 0
					aNumerario[nPos][2][3][1] += nValFP
					aNumerario[nPos][2][3][2] += IIf(lSomaQtde,1,0)
					//Se configurado para impressao por adm. financeira
					If lImpAF
						//Caso a forma de pagamento seja uma utilizada pelos cadastros de adm. financeira (SAE), gravar
						If aScan(aFPADM,{|x| x == AllTrim((cAlias)->L4_FORMA)}) > 0
							If (nPos := aScan(aTotAF,{|x| x[1] == (cAlias)->L4_FORMA .AND. x[2] == cCodAF})) == 0
								aAdd(aTotAF,{(cAlias)->L4_FORMA,cCodAF,nValFP,0,1})
							Else
								aTotAF[nPos][3] += nValFP
								aTotAF[nPos][5] += IIf(lSomaQtde,1,0)
							Endif
							
							//Efetua o backup do conteudo inserido aqui pela SL4,
							//para não somar valor duplicado na SLT
							nPos := aScan(aBkAdmUsada,{|x| x[1] + x[2] == AllTrim((cAlias)->L4_FORMA) + AllTrim(cCodAF)})
							If nPos == 0
								aAdd(aBkAdmUsada,{AllTrim((cAlias)->L4_FORMA),AllTrim(cCodAF)})
							EndIf
						Endif
					Endif
				Endif
			Else
				nTotCanc += nValFP
			Endif
			(cAlias)->(dbSkip())
		EndDo
	Else
		cChave := xFilial("SL1") + PadR(aID[1][1],aID[1][2]) + DtoS(dAbert)
		dbSelectArea("SL1")
		SL1->(dbSetOrder(5))	//L1_FILIAL+L1_OPERADO+Dtos(L1_EMISSAO)
		SL1->(dbSeek(cChave))
		Do While !SL1->(Eof()) .AND. SL1->(L1_FILIAL + L1_OPERADO) + DtoS(L1_EMISSAO) == cChave
			lCanc := .F.
			//Se o orcamento nao pertencer a serie, PDV e estacao em uso, saltar
			If ( !Empty(SL1->L1_SERIE) .And. AllTrim(SL1->L1_SERIE) # AllTrim(aID[3][1]) ) .OR.;
			 		AllTrim(SL1->L1_PDV) # AllTrim(aID[4][1]) .OR. AllTrim(SL1->L1_ESTACAO) # AllTrim(aID[2][1])

				SL1->(dbSkip())
				Loop				
			Endif
			//Se for de movimento diferente, saltar
			If !Empty(SL1->L1_NUMMOV) .AND. !Empty(cNumMov) .AND. AllTrim(SL1->L1_NUMMOV) # AllTrim(cNumMov)
				SL1->(dbSkip())
				Loop			
			Endif			
			//Se o orcamento estiver cancelado
			If SL1->L1_SITUA == "07"
				lCanc := .T.
			Endif
			If SL1->(ColumnPos("L1_STORC")) > 0
				If SL1->L1_STORC $ "C|E"
					lCanc := .T.
				Endif
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Se houver valor de credito (NCC), tratar  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If SL1->L1_CREDITO > 0 .AND. !lCanc
				nValFP := SL1->L1_CREDITO
				If SL1->L1_MOEDA > 1 .AND. cPaisLoc == "BRA"
					nValFP := xMoeda(nValFP,SL1->L1_MOEDA,1,SL1->L1_EMISSAO)
				Endif
				If (nPos := aScan(aNumerario,{|x| AllTrim(x[1]) == "CR"})) > 0
					aNumerario[nPos][2][3][1] += nValFP
					aNumerario[nPos][2][3][2] += 1	
				Endif
			Endif
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³Processar as formas de pagamento associadas  ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			nValFP := 0
			dbSelectArea("SL4")
			SL4->(dbSetOrder(1))
			SL4->(dbSeek(xFilial("SL4") + SL1->L1_NUM + Space(TamSX3("L4_ORIGEM")[1])))
			Do While !SL4->(Eof()) .AND. RTrim(SL4->(L4_FILIAL + L4_NUM)) == RTrim(xFilial("SL4") + SL1->L1_NUM) .AND. Empty(SL4->L4_ORIGEM)
				If lHabTroco 
					nValFP := SL4->L4_VALOR
				Else
					nValFP := SL4->(L4_VALOR - L4_TROCO)
				Endif
				cCodAF := Substr(SL4->L4_ADMINIS,1,nTamCADM)
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Verificar se a quantidade da venda jah nao foi registrada ³
				//³pela ORC + FP + ADM + MOEDA, se foi, nao somar.           ³
				//³Isso visa evitar que FP desdobradas aumentem a qtde. de   ³
				//³venda por FP de acordo com o seu numero de parcelas.      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aScan(aLstFPQ,{|x| x[1] == AllTrim(SL4->L4_FILIAL) .AND. x[2] == AllTrim(SL4->L4_NUM) .AND. ;
					x[3] == AllTrim(SL4->L4_FORMA) .AND. x[4] == AllTrim(cCodAF) .AND. x[5] == AllTrim(SL4->L4_MOEDA)}) == 0
								
					aAdd(aLstFPQ,{AllTrim(SL4->L4_FILIAL),AllTrim(SL4->L4_NUM),AllTrim(SL4->L4_FORMA),AllTrim(cCodAF),AllTrim(SL4->L4_MOEDA)})
					lSomaQtde := .T.
				Else
					lSomaQtde := .F.
				Endif				
				
				//Verificar se o pagamento foi realizado em moeda estrangeira e necessita conversao
				If SL4->L4_MOEDA > 1
					nValFP := xMoeda(nValFP,SL4->L4_MOEDA,1,SL1->L1_EMISSAO)
				Endif
				
				If !lCanc
					If (nPos := aScan(aNumerario,{|x| AllTrim(x[1]) == AllTrim(SL4->L4_FORMA)})) > 0
						aNumerario[nPos][2][3][1] += nValFP
						aNumerario[nPos][2][3][2] += IIf(lSomaQtde,1,0)
						//Se configurado para impressao por adm. financeira
						If lImpAF
							//Caso a forma de pagamento seja uma utilizada pelos cadastros de adm. financeira (SAE), gravar
							If aScan(aFPADM,{|x| x == AllTrim(SL4->L4_FORMA)}) > 0
								If (nPos := aScan(aTotAF,{|x| x[1] == SL4->L4_FORMA .AND. x[2] == cCodAF})) == 0
									aAdd(aTotAF,{SL4->L4_FORMA,cCodAF,nValFP,0,1})
								Else
									aTotAF[nPos][3] += nValFP
									aTotAF[nPos][5] += IIf(lSomaQtde,1,0)
								Endif
								
								//Efetua o backup do conteudo inserido aqui pela SL4,
								//para não somar valor duplicado na SLT
								nPos := aScan(aBkAdmUsada,{|x| x[1] + x[2] == AllTrim(SL4->L4_FORMA) + AllTrim(cCodAF)})
								If nPos == 0
									aAdd(aBkAdmUsada,{AllTrim(SL4->L4_FORMA),AllTrim(cCodAF)})
								EndIf
							Endif
						Endif
					Endif
				Else
					nTotCanc += nValFP
				Endif
				SL4->(dbSkip())
			EndDo
			SL1->(dbSkip())
		EndDo
	Endif
Endif
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Levantamento das conferencias³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If nLeiaute # 1
	dbSelectArea("SLW")
	SLW->(dbSetOrder(3))
	If AliasInDic("SLT")
		#IFDEF TOP
			If !TcCanOpen(RetSQLName("SLT"))
				ChkFile("SLT",.F.)
			Endif
		#ELSE
			ChkFile("SLT",.F.)
		#ENDIF	
		dbSelectArea("SLT")
		//Determinar se as tabelas envolvidas sofreram atualizacoes do update do pacote
		lTabAtual := .T.
	Else
		lTabAtual := .F.
	Endif

	If lTabAtual
		//LW_FILIAL+LW_PDV+LW_OPERADO+DTOS(LW_DTABERT)+LW_ESTACAO+LW_NUMMOV
		cChave := xFilial("SLW") + PadR(aID[4][1],aID[4][2]) + PadR(aID[1][1],aID[1][2]) + DtoS(dAbert) + PadR(aID[2][1],aID[2][2]) + PadR(cNumMov,TamSX3("LW_NUMMOV")[1])
		If SLW->(dbSeek(cChave))
			If SLW->LW_SITUA # "01" .AND. !Empty(SLW->LW_DTFECHA)
				cChave := xFilial("SLT") + PadR(aID[1][1],aID[1][2]) + DtoS(SLW->LW_DTFECHA)
				SLT->(dbSetOrder(1))	//LT_FILIAL+LT_OPERADO+DTOS(LT_DTFECHA)+LT_FORMPG
				SLT->(dbSeek(cChave))
				Do While !SLT->(Eof()) .AND. RTrim(SLT->(LT_FILIAL+LT_OPERADO+DTOS(LT_DTFECHA))) == cChave
					//Se a conferencia for de movimento diferente, saltar
					If !Empty(SLT->LT_NUMMOV) .AND. !Empty(cNumMov) .AND. AllTrim(SLT->LT_NUMMOV) # AllTrim(cNumMov)
						SLT->(dbSkip())
						Loop			
					Endif
					If SLT->LT_DTMOV <>  SLW->LW_DTABERT
						SLT->(dbSkip())
						Loop
					EndIf
					
					nValApur:= SLT->LT_VLRAPU
					nValFP	:= SLT->LT_VLRDIG
					
					//Verificar se o pagamento foi realizado em moeda estrangeira e necessita conversao
					If SLT->LT_MOEDA > 1
						nValFP	:= xMoeda(nValFP,SLT->LT_MOEDA,1,dAbert)
						nValApur:= xMoeda(nValApur,SLT->LT_MOEDA,1,dAbert)
					Endif
					
					If (nPos := aScan(aNumerario,{|x| AllTrim(x[1]) == AllTrim(SLT->LT_FORMPG)})) > 0

						//Valor Digitado
						aNumerario[nPos][2][4][1] += nValFP
						If nValFP # 0
							aNumerario[nPos][2][4][2] += 1
						EndIf

						//Se configurado para impressao por adm. financeira
						If lImpAF
							//Caso a forma de pagamento seja uma utilizada pelos cadastros de adm. financeira (SAE), gravar
							If aScan(aFPADM,{|x| x == AllTrim(SLT->LT_FORMPG)}) > 0
								cCodAF := Substr(SLT->LT_ADMIFIN,1,TamSX3("AE_COD")[1])
								If (nPos := aScan(aTotAF,{|x| AllTrim(x[1]) == AllTrim(SLT->LT_FORMPG) .AND. AllTrim(x[2]) == AllTrim(cCodAF)})) == 0
									aAdd(aTotAF,{SLT->LT_FORMPG,cCodAF,nValApur,nValFP,0})
								Else
									//Efetua a busca do conteudo inserido aqui pela SL4,para não somar valor duplicado da SLT (LT_VLRAPU)
									If aScan(aBkAdmUsada,{|x| x[1] + x[2] == AllTrim(SLT->LT_FORMPG) + AllTrim(cCodAF)}) == 0
										aTotAF[nPos][3] += nValApur
									EndIf
									
									//Para alimentacao de valores de conferencia, nao alimentar a quantidade, que deve ser alimentado pelas vendas
									aTotAF[nPos][4] += nValFP
								Endif
							Endif
						Endif
					Endif

					SLT->(dbSkip())				
				EndDo
			Endif
		Endif				
	Endif			
Endif
cLinSep := "+" + Replicate("-",nColsUtil) + "+"
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Cabecalho - para todos os modelos³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
//Alinhar a primeira estrutura ao centro e usar delimitadores
oFrm:SetAlign(1,{"C"},1)
oFrm:ReplStru(1,.T.,"DELIMIT")
//Iniciar area de impressao
oFrm:PrintLineWD()
If cOperacao == "SANGRIA"
	oFrm:PrintText(STR0020 + " " + STR0044) //#"SANGRIA DE CAIXA" ##(Acumulado)
ELseIf cOperacao == "TROCO"
	oFrm:PrintText(STR0037 + " " + STR0044) //#"SUPRIMENTO DE CAIXA" ##(Acumulado)
Else
	oFrm:PrintText(STR0038) //#"FECHAMENTO DE CAIXA"
EndIf
oFrm:PrintBlaWD()
oFrm:Add(2,{"DATA" ,DtoC(Date())})
oFrm:Add(2,{Iif(cOperacao=="TROCO", STR0039,STR0040) ,aID[1][1]  + "-" + GetAdvfVal("SA6","A6_NOME",xFilial("SA6") + RTrim(aID[1][1]),1)}) //#"CX.DESTINO" ##"CX.ORIGEM"
oFrm:Add(2,{Iif(cOperacao=="TROCO", STR0040,STR0039) ,aCxDest[1] + "-" + aCxDest[4]}) //#"CX.ORIGEM" ##"CX.DESTINO"
oFrm:Add(2,{STR0041	,aID[2][1]})//#"ESTACAO"
oFrm:Add(2,{"PDV"	,aID[4][1]})
oFrm:Add(2,{STR0042	,cNumMov})	//#"NUM.MOV."
oFrm:PrintLineWD()
/*
ARRAY COM NUMERARIO E DETALHES
aNumerario = Elemento 2
[1] Troco 								(Valor , Quantidade)
[2] Sangria 							(Valor , Quantidade)
[3] Vendas 								(Valor , Quantidade)
[4] Valores digitados na conferencia 	(Valor , Quantidade)

ARRAY COM NUMERARIO DE TOTAIS POR ADM. FINANCEIRA (VENDAS E CONFERENCIA)
aTotAF
[1] Forma pagto 
[2] Adm 
[3] Valor 
[4] Conferencia 
[5] Quantidade
*/
Do Case
	Case cOperacao == "SANGRIA"		//Sangria
		Eval({|| nValTMP := 0, aEval(aNumerario,{|x| nValTMP += x[2][2][1]})})
		oFrm:Add(5,{STR0043,Transform(nValTMP,cMasc)}) //#"RETIRADAS : "
		oFrm:PrintLineWD()
		For ni := 1 to Len(aNumerario)
			If aNumerario[ni][2][2][1] > 0
				oFrm:Add(5,{aNumerario[ni][3],Transform(aNumerario[ni][2][2][1],cMasc)})
			Endif
		Next ni
		
	Case cOperacao == "TROCO"		//Suprimento
		Eval({|| nValTMP := 0, aEval(aNumerario,{|x| nValTMP += x[2][1][1]})})
		oFrm:Add(3,{STR0031,Transform(nValTMP,cMasc)}) //#"ENTRADA DE TROCO"
		oFrm:PrintLineWD()
		For ni := 1 to Len(aNumerario)
			If aNumerario[ni][2][1][1] > 0
				oFrm:Add(5,{aNumerario[ni][3],Transform(aNumerario[ni][2][1][1],cMasc)})
			Endif
		Next ni

	Case Empty(cOperacao) .And. nLeiaute == 2	//Fechamento sem adm. Financeira
		//Entrada de troco
		Eval({|| nValTMP := 0, aEval(aNumerario,{|x| nValTMP += x[2][1][1]})})
		oFrm:Add(3,{STR0031,Transform(nValTMP,cMasc)}) //#"ENTRADA DE TROCO"
		oFrm:PrintLineWD()
		//Vendas totalizador
		Eval({|| nValTMP := 0, aEval(aNumerario,{|x| nValTMP += x[2][3][1]})}) //Valores
		Eval({|| nValTMP02 := 0, aEval(aNumerario,{|x| nValTMP02 += x[2][3][2]})}) //Quantidade
		oFrm:Add(4,{"",nValTMP02,Transform(nValTMP,cMasc)})
		oFrm:PrintLineWD()
		//Vendas itens
		lInsLinha := .F.
		For ni := 1 to Len(aNumerario)
			If aNumerario[ni][2][3][1] > 0 .OR. aNumerario[ni][2][3][2] > 0
				oFrm:Add(4,{aNumerario[ni][3],aNumerario[ni][2][3][2],Transform(aNumerario[ni][2][3][1],cMasc)})
				lInsLinha := .T.
			Endif
		Next ni
		If lInsLinha
			oFrm:PrintLineWD()
		Endif
		//Sangrias totalizador
		Eval({|| nValTMP := 0, aEval(aNumerario,{|x| nValTMP += x[2][2][1]})}) //Valores
		oFrm:Add(5,{STR0043 ,Transform(nValTMP,cMasc)}) //#"RETIRADAS"
		oFrm:PrintLineWD()
		//Sangria itens
		lInsLinha := .F.
		For ni := 1 to Len(aNumerario)
			If aNumerario[ni][2][2][1] > 0
				oFrm:Add(5,{aNumerario[ni][3],Transform(aNumerario[ni][2][2][1],cMasc)})
				lInsLinha := .T.
			Endif
		Next ni		
		If lInsLinha
			oFrm:PrintLineWD()
		Endif
		//Conferencia
		lInsLinha := .F.
		For ni := 1 to Len(aNumerario)
			If aNumerario[ni][2][3][1] > 0 .OR. aNumerario[ni][2][4][1] > 0
				oFrm:Add(6,{aNumerario[ni][3],"",""})											//FORMA PAGTO
				oFrm:Add(6,{Transform(aNumerario[ni][2][4][1],cMasc),; 						//DIGITADO
					Transform(aNumerario[ni][2][3][1],cMasc),;								//APURADO
					Transform(aNumerario[ni][2][4][1] - aNumerario[ni][2][3][1],cMasc)})	//DIGITADO - APURADO
				lInsLinha := .T.
			Endif
		Next ni
		If lInsLinha
			oFrm:PrintLineWD()
		Endif		

	Otherwise	//Fechamento - detalhamento de administradora financeira
		//Entrada de troco
		Eval({|| nValTMP := 0, aEval(aNumerario,{|x| nValTMP += x[2][1][1]})})
		oFrm:Add(3,{STR0031,Transform(nValTMP,cMasc)}) //"ENTRADA DE TROCO"
		oFrm:PrintLineWD()
		//Vendas totalizador
		Eval({|| nValTMP := 0, aEval(aNumerario,{|x| nValTMP += x[2][3][1]})}) //Valores
		Eval({|| nValTMP02 := 0, aEval(aNumerario,{|x| nValTMP02 += x[2][3][2]})}) //Quantidade
		oFrm:Add(4,{"",nValTMP02,Transform(nValTMP,cMasc)})
		oFrm:PrintLineWD()
		//Vendas itens
		lInsLinha := .F.
		For ni := 1 to Len(aNumerario)
			If aNumerario[ni][2][3][1] > 0 .OR. aNumerario[ni][2][3][2] > 0
				oFrm:Add(4,{aNumerario[ni][3],aNumerario[ni][2][3][2],Transform(aNumerario[ni][2][3][1],cMasc)})
				If lImpAF
					//Vendas itens - administradora financeira
					If (nPos := aScan(aTotAF,{|x| AllTrim(x[1]) == AllTrim(aNumerario[ni][1])})) > 0
						For nx := 1 to Len(aTotAF)
							If AllTrim(aTotAF[nx][1]) == AllTrim(aNumerario[ni][1])
								oFrm:Add(4,{"-" + aTotAF[nx][2] + Space(1) + GetAdvFVal("SAE","AE_DESC",xFilial("SAE") + RTrim(aTotAF[nx][2]),1),;
									aTotAF[nx][5],Transform(aTotAF[nx][3],cMasc)})
							Endif
						Next nx
					Endif
				Endif
				lInsLinha := .T.
			Endif      
		Next ni
		If lInsLinha
			oFrm:PrintLineWD()
		Endif
		//Sangrias totalizador
		Eval({|| nValTMP := 0, aEval(aNumerario,{|x| nValTMP += x[2][2][1]})}) //Valores
		oFrm:Add(5,{STR0043,Transform(nValTMP,cMasc)})//#"RETIRADAS"
		oFrm:PrintLineWD()
		//Sangria itens
		lInsLinha := .F.
		For ni := 1 to Len(aNumerario)
			If aNumerario[ni][2][2][1] > 0
				oFrm:Add(5,{aNumerario[ni][3],Transform(aNumerario[ni][2][2][1],cMasc)})
				lInsLinha := .T.
			Endif
		Next ni	
		If lInsLinha
			oFrm:PrintLineWD()
		Endif
		//Conferencia
		lInsLinha := .F.
		For ni := 1 to Len(aNumerario)
			nValTMP		:= aNumerario[ni][2][4][1]
			nValTMP02	:= aNumerario[ni][2][3][1] 
			If nValTMP > 0 .OR. nValTMP02 > 0
				oFrm:Add(6,{aNumerario[ni][3],"",""})			//FORMA PAGTO
				oFrm:Add(6,{Transform(nValTMP,cMasc),; 		//DIGITADO
					Transform(nValTMP02,cMasc),;				//APURADO
					Transform(Abs(nValTMP - nValTMP02),cMasc)})	//DIGITADO - APURADO
				//Conferencia - administradora financeira
				If lImpAF
					If (nPos := aScan(aTotAF,{|x| AllTrim(x[1]) == AllTrim(aNumerario[ni][1])})) > 0
						For nx := 1 to Len(aTotAF)
							If AllTrim(aTotAF[nx][1]) == AllTrim(aNumerario[ni][1])				
								nValTMP		:= aTotAF[nx][4]
								nValTMP02	:= aTotAF[nx][3]				
								oFrm:Add(6,{"-" + aTotAF[nx][2] + Space(1) + GetAdvFVal("SAE","AE_DESC",xFilial("SAE") + RTrim(aTotAF[nx][2]),1),"",""})	//ADM FINANCEIRA
								oFrm:Add(6,{Transform(nValTMP,cMasc),; 		//DIGITADO
									Transform(nValTMP02,cMasc),;				//APURADO
									Transform(Abs(nValTMP - nValTMP02),cMasc)})	//DIGITADO - APURADO
							Endif
						Next nx
					Endif
				Endif
				lInsLinha := .T.
			Endif
		Next ni
		If lInsLinha
			oFrm:PrintLineWD()
		Endif
End Case

oFrm:PrintLineWD() //Linha com tracejado
If ExistBlock("Frt272bAss")
	aFrt272bAss := ExecBlock("Frt272bAss", .F., .F.)
	For nx :=1 To Len(aFrt272bAss)
		oFrm:PrintText(aFrt272bAss[nx])
	Next nx
Else
	oFrm:PrintText(STR0035+" ________________________________") //#->"Ass. Caixa   :"
	oFrm:PrintBlaWD() // linha em branco
	oFrm:PrintText(STR0036+" ________________________________") //#->"Ass. Superior:"
EndIf
oFrm:PrintLineWD() //Linha com tracejado

//Imprimir o relatorio gerencial
oFrm:Exec()
oFrm:Finish()
RestArea(aArea)

Return Nil

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³FR271VLDSA ºAutor  ³Vendas Clientes       º Data ³  20/09/16   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³Rotina para validar o valor da sangria informada, não podendo  º±±
±±º          ³ser menor que zero.                                            º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametros³nValor : Valor da sangria                                      º±±
±±º          ³                                                               º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

Function FR271VLDSA(nValor)

Local lRet := .T.

If nValor < 0
	MsgAlert(STR0049, STR0024) // "Valor informado para a Sangria não pode ser menor que zero."
	lRet := .F.
EndIf

Return lRet


//--------------------------------------------------------
/*{Protheus.doc} FR271A6Bco()
Leio o tamanho de A6_COD (Código de Banco)

@param   cMvCxLoja - Conteúdo de MV_CXLOJA
@author  Varejo
@version P12.1
@since   17/01/2020
@return  nTamSA6 - o tamanho do campo A6_COD
@obs     
@sample
*/
//--------------------------------------------------------
Static Function Fr271A6Bco(cMvCxLoja)

Local nTamSA6 := 0 //Tamanho de A6_COD

nTamSA6 :=  At("/", cMvCxLoja) -1 
If nTamSA6 <= 0
	nTamSA6 := SA6->(TamSx3("A6_COD"))[1]
EndIf

Return nTamSA6

/*/{Protheus.doc} LjCompFKs
	Grava na tabala FK5 a origem do registro
	@type  Static Function
	@author Fábio S. dos Santos
	@since 17/03/2020
	@version 12.1.25
	@param 
	@return 
/*/
Static Function LjCompFKs()

Local aArea			:= GetArea()
Local aAreaFKA		:= FKA->( GetArea() )
Local cProcFKA		:= FKA->FKA_IDPROC

LjGrvLog(," LjCompFKs - FRTA271D | Inicio " )

//Atualiza campos das FKs
FKA->( dbSetOrder(2) )
FKA->( dbSeek( xFilial("FKA") + cProcFKA ) )
While FKA->( !EOF() ) .AND. ( xFilial("FKA") + cProcFKA == FKA->FKA_FILIAL + FKA->FKA_IDPROC )

	If FKA->FKA_TABORI == "FK5"

		//Posiciona na tabela e altera os campos
		FK5->( dbSetOrder(1) )
		If FK5->( dbSeek( xFilial("FK5") + FKA->FKA_IDORIG ) )

			RecLock("FK5",.F.)

			FK5->FK5_ORIGEM := "FRTA271D"
						
			FK5->( MsUnLock() )

		EndIf

	EndIf

	FKA->( dbSkip() )

End

RestArea(aAreaFKA)
RestArea(aArea)

Return

/*/{Protheus.doc} LjSE5ToFKs
Faz a chamada das funções para geração das tabelas FKs com base no registro da SE5
Para o uso deve estar posicionado no registro correto da SE5	
@type  Function
@author joao.marcos
@since 01/06/2022
@version 12.1.33
/*/
Function LjSE5ToFKs()

If !Alltrim(Upper(FunName())) $ "FRTA010|FRTA271"
	
	//Gera FKs com base na SE5 gerada
	FINXSE5( SE5->( Recno() ) , 1 )	// 1 - Movimento Bancário

	//Compatibiliza as Fks com padrao do loja
	LjCompFKs()
EndIf
	
Return
