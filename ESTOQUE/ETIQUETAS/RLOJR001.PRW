#Include "Rwmake.ch"
#Include "Topconn.ch"

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³ RLOJR001  º Eduardo Bego Mantoan   º Data ³ 14/11/2014     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Impressão código de barras  (etiqueta)   			      º±±
±±ÈÍÍÍÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¼±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß

*/

User Function RLOJR001()

Private _cUsuario  := RetCodUsr()
Private _aUsuario  := {}
Private _cUsuSenha := ""
Private _cDeptoUsu := ""
Private nLastKey   := 0
Private cNum       := ""
Private cItem      := 0 
Private cCodBar      := ""
Private cRev       := ""
Private cProdAux   := ""
Private nQtdEtiq   := 0
Private nEtiq      := 0
Private cTipo      := ""
Private cNFiscal   := ""
Private cLocal     := ""
Private dDtEnt     := CTOD("")
Private cArqPRN    := "c:\relato_microsiga\EtiqBarra.PRN"
Private cRegPRN    := ""
Private cForn      := "" 
Private cDesc      := ""
Private _nLin      := 0
Private _nCol      := 0
Private _fInicio   := .T.
Private _fImpEtiq  := .F.
Private _lProc     := .T.
Private oEspes     := 0
Private _oDlg2
Private nEspes     := 0
Private nLargu     := "          "
Private nCompr     := "          "

_cUsuario  := RetCodUsr()
_cUsuSenha := UsrRetname(_cUsuario)

PswOrder(1)
If PswSeek(_cUsuario,.T.)
   _aUsuario  := PswRet()
   _cUsuSenha := UsrRetName(_cUsuario)
   _cDeptoUsu := Upper(Alltrim(_aUsuario[1][12]))
EndIf

SC2->(DbSetOrder(1))
SC7->(DbSetOrder(1))
SB1->(DbSetOrder(1))
SB5->(DbSetOrder(1)) 

aModelo  := {"1-Branca (5 Etiquetas)","2-Verde (3 Etiquetas)Almox","3-Verde (3 Etiquetas)Funilaria"}
//aModelo  := {"1-Verde (3 Etiquetas)- Almoxarifado","2-Verde (3 Etiquetas)- Funilaria"}
cNum     := Space(11)
dDtEnt   := CTOD("")
cNFiscal := Space(9)
cModelo  := Space(20)

If "ALMOXARIFADO" $ _cDeptoUsu
   _cDeptoUsu := "ALMOXARIFADO"
EndIf  

/*If _cDeptoUsu == "RECEBIMENTO"
   cModelo := "2-Verde (3 Etiquetas)"
Else
   cModelo := "1-Branca (5 Etiquetas)"
EndIf */
private nA := 1
Do While _lProc 
   
 
   cCodBar    := Space(15)
   nQtdEtiq := 1
   cLocal   := ""
   fImpEtiq := .F.
   fRet     := .F.
     
   @ 089,185 To 500,600 Dialog _oDlg1 Title OemToAnsi("Etiquetas - Código de Barras")
   @ 009,011 To 035,195
   @ 030,011 To 180,195
   @ 015,064 Say OemToAnsi("Código de Barras")              Size 151,010
   @ 085,020 Say OemToAnsi("Codigo de Barras.:")        Size 070,008
   @ 100,020 Say OemToAnsi("Qtde......:")    Size 070,008 
   @ 085,075 Get cCodBar  F3 "CBAR"                             Size 050,008
   @ 100,075 Get nQtdEtiq Picture "@E 999"                     Size 035,008
//   @ 085,075 Get nA Picture "@E 999"                     Size 035,008
   @ 165,110 BmpButton Type 1 Action Processa( { || ImpEtiq() })
   @ 165,145 BmpButton Type 2 Action _fFinaliza()
   
   If Alltrim(cNum) <> ""
      If Len(Alltrim(cNum)) > 6
         cNum := Space(11)
         oNum:SetFocus()
      Else
         cItem:=Space(4)   
         oItem:SetFocus()
      EndIf   
   EndIf 
   
   Activate Dialog _oDlg1 Centered
End

Return

//***********************************
	Static Function _fFinaliza()
//***********************************
   _lProc := .F.
   FClose(cArqPRN)
   FErase("c:\relato_microsiga\EtiqBarra.prn")
   _oDlg1:End()
Return



//***********************************
	Static Function ImpEtiq()
//***********************************

Local n

If apMsgYesNo("*** ATENÇÃO, Deseja Imprimir as Etiquetas ***")
	_fImpEtiq := .T.
	
	
	If !(Alltrim(_cUsuSenha) $ "FPadial")
		_cEXE2  := "cmd /c net use lpt1: /delete"
		WaitRun(_cEXE2)// Deleta mapeamento LPT1    
	Endif 
	
	If cResp1:=msgbox("Impressora LPT1?","Atenção...","YESNO") 
		MSCBPRINTER("OS 214","LPT1",NIL,)         
	Else
		MSCBPRINTER("OS 214","COM1",NIL,)	
	EndIf   
   
	
	MSCBCHKSTATUS(.F.)
	nCont := 0
	For n = 1 To nQtdEtiq
		
		If _fImpEtiq = .F.
			Return
		EndIf 
		
		
		
   /*		If nQtdEtiq > nCont
			MSCBBEGIN(1,4)
			//MSCBSAYBAR(012,01,AllTrim(cCodBar)      ,"B","MB04",10  ,.T.,.T.,.F.,,1,2)
			MSCBSAY(010,010,STRZERO(n,4)   ,"B","4"   ,"01","01")
			nCont ++
			N++
			If nQtdEtiq > nCont
				MSCBSAY(27,10,STRZERO(n,4)   ,"B","4"   ,"01","01")
				nCont++
				N++
				If nQtdEtiq > nCont
					MSCBSAY(45,10,STRZERO(n,4)    ,"B","4"   ,"01","01")
					nCont++
					N++
					If nQtdEtiq > nCont
						MSCBSAY(62,10,STRZERO(n,4)    ,"B","4"   ,"01","01")
						nCont++
						N++
						If nQtdEtiq > nCont
							MSCBSAY(80,10,STRZERO(n,4)    ,"B","4"   ,"01","01")
							nCont++
						EndIf
					EndIf
				EndIf
			EndIf
			MSCBEND() //Fim da Imagem da Etiqueta
		EndIf    */
		If nQtdEtiq > nCont
			MSCBBEGIN(1,4)
			MSCBSAYBAR(012,01,AllTrim(cCodBar),"B","MB04",10,.T.,.T.,.F.,,1,2)
			nCont ++
			N++
			If nQtdEtiq > nCont
				MSCBSAYBAR(30,01,AllTrim(cCodBar),"B","MB04",10,.T.,.T.,.F.,,1,2)
				nCont++
				N++
				If nQtdEtiq > nCont
					MSCBSAYBAR(48,01,AllTrim(cCodBar),"B","MB04",10,.T.,.T.,.F.,,1,2)
					nCont++
					N++
					If nQtdEtiq > nCont
						MSCBSAYBAR(66,01,AllTrim(cCodBar),"B","MB04",10,.T.,.T.,.F.,,1,2)
						nCont++
						N++
						If nQtdEtiq > nCont
							MSCBSAYBAR(84,01,AllTrim(cCodBar),"B","MB04",10,.T.,.T.,.F.,,1,2)
							nCont++
						EndIf
					EndIf
				EndIf
			EndIf
			MSCBEND() //Fim da Imagem da Etiqueta
		EndIf
		
		
		
	NEXT N
	
	
	
	MSCBCLOSEPRINTER()
	
Else
	_fImpEtiq := .F.
	
EndIf

Return        


