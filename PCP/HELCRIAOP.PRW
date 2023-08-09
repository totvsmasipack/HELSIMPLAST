#include "protheus.ch"
#include "PRTOPDEF.CH"
#include "TbiConn.ch"
#include "TbiCode.ch"

#DEFINE cEol CHR(13)+CHR(10)

/*/{Protheus.doc} DS2u
Função Cria Ordem de Produção
@author Rodrigo Lima (DS2U)
@since 
@version 1.0
@type function
/*/

User Function HELCRIAOP()
	Local cProd		:= M->D3_COD
	Local cLocal	:= space(2)
	Local nQuant	:= 0
	Local cRet		:= ""
	Local cArea 	:= getArea()

	If funname()=='MATA250'

		if Select("c2TMP") > 0
		c2TMP->(dbCloseArea())
		Endif

		cQuery :=""

		cQuery :=  " SELECT C2_QUANT FROM "+RETSQLNAME("SC2")+" SC2 (NOLOCK) " +cEol
		cQuery +=  " WHERE SC2.D_E_L_E_T_='' " +cEol
		cQuery +=  " AND C2_PRODUTO ='"+cProd+"' " +cEol
		cQuery +=  " AND C2_DATRF ='' "  +cEol
		cQuery +=  " AND C2_QUJE < C2_QUANT " +cEol

		dbUseArea( .T., "TOPCONN", TCGENQRY(,,cQuery),"c2TMP", .F., .T.)

		Count To nRec

		If nRec == 0
			DEFINE MSDIALOG oDlg FROM  62,1 TO 293,365 TITLE "Cria Ordem de Produção" PIXEL

			@ 0, 2 TO 28, 181 LABEL "" OF oDlg  PIXEL
			@ 31, 2 TO 91, 181 LABEL "" OF oDlg  PIXEL

			@ 08, 08 SAY "Selecione o Armazem :" SIZE 120, 7 OF oDlg PIXEL
			@ 18, 08 MSGET oLocal VAR  cLocal Picture "@!" F3 "NNR"  VALID (!Empty(cLocal) .and.  ExistCPO("NNR",cLocal) )  SIZE 43, 7 OF oDlg PIXEL

			@ 38, 08 SAY "Quantidade ==>" SIZE 120, 7 OF oDlg PIXEL
			@ 38, 60 MSGET oValor VAR nQuant PICTURE '@E 999,999.99'  SIZE 53, 7 OF oDlg PIXEL

			DEFINE SBUTTON FROM 98 , 149 TYPE 1 ACTION (Processa( {|| cRet:=HELProce(cProd, cLocal, nQuant ) }, "Aguarde...", "Gerando O.P...",.F.),oDlg:End()) ENABLE OF oDlg
			DEFINE SBUTTON FROM 98 , 119 TYPE 2 ACTION {|| oDlg:End() } ENABLE OF oDlg
			ACTIVATE MSDIALOG oDlg
		Endif

		if Select("c2TMP") > 0
		c2TMP->(dbCloseArea())
		Endif

	ENDIF

	RestArea(cArea)
Return cRet


Static Function HELProce(cProd, cLocal, nQuant )

	Local aAreaA	:= GetArea()
	Local aMATA650	:= {}
	Local nOpc		:= 3
	Local cNum		:= ""
	Local cUM		:= Posicione("SB1",1,xFilial("SB1")+cProd,"B1_UM")
	Local lCont		:= .F.
	Local cQuery	:= ""

	Private lMsErroAuto	:= .F.

	cNum := GetSXENum( "SC2", "C2_NUM")
	ConfirmSx8()

	dbSelectArea("SC2")
	dbSetorder(1)
	If dbSeek(xFIlial("SC2")+cNum+"01001")

		If Select("CONT") > 0
			CONT->(DbCloseArea())
		EndIf

		cQuery := "SELECT MAX(C2_NUM)+1 AS C2_NUM FROM "+RetSqlname("SC2")+" WHERE D_E_L_E_T_ ='' "

		dbUseArea(.T., "TOPCONN", TCGenQry(,,cQuery), 'CONT', .F., .T.)
		dbSelectArea("CONT")
		DBGoTop()

		WHILE CONT->(!EOF())
			cNum := CVALTOCHAR(CONT->C2_NUM)
			CONT->(DBSKIP())
		ENDDO
	enDIF


	aMata650  := {  {'C2_FILIAL'	,xFilial() ,NIL},;
		{'C2_PRODUTO'	,cProd				,NIL},;
		{'C2_NUM'		,cNum				,NIL},;
		{'C2_ITEM'		,"01"				,NIL},;
		{'C2_SEQUEN'	,"001"				,NIL},;
		{'C2_QUANT'		,nQuant				,NIL},;
		{'C2_LOCAL'		,cLocal        		,NIL},;
		{'C2_UM'		,cUM				,NIL},;
		{'C2_DATPRI'	,Date()				,NIL},;
		{'C2_DATPRF'	,Date()				,NIL},;
		{'C2_OPERAC'	,"01"				,NIL},;
		{'C2_EMISSAO'	,Date()				,NIL}}

	nModulo := 4
	msExecAuto({|x,Y| Mata650(x,Y)},aMata650,nOpc)

	If !lMsErroAuto
		lCont	:= .T.

		lMsErroAuto := .F.
		aVetor:={}
		aEmpen:={}

	Else
		MostraErro()
	EndIf


	RestArea(aAreaA)
Return cNum+"01"+"001"
