#include 'totvs.ch'
#include 'protheus.ch'

/*/{Protheus.doc} RLOJR003
//TODO Etiqueta de identificação de caixas, preenchimento automático.
@author felipe.freitas
@since 30/10/2019
@version 1.0
@return Nil
@type function
/*/

User Function RLOJR003()

Local cTitle	:= "Etiqueta de Identificação de Caixas - Automático"
Local cPerg		:= "RLOJR003"
Local cAlias	:= ""
Local aSays		:= {}
Local aButtons 	:= {}

	If Pergunte(cPerg,.T.)

		AADD(aSays,"Este programa irá realizar a impressão de etiquetas de identificação de")
		AADD(aSays,"caixas, conforme os parâmetros selecionados abaixo.")

		AADD(aButtons, {5,.T.,{|| Pergunte(cPerg,.T. )}})
		AADD(aButtons, {1,.T.,{|o| IIF(!Empty(mv_par01), (FwMsgRun(, {|| ValidaInfo(@cAlias) }, "Aguarde", "Gerando etiquetas...")), FwAlertError("Parâmetros incorretos!"))	}})
		AADD(aButtons, {2,.T.,{|o| FechaBatch() }})

		FormBatch(cTitle, aSays, aButtons)

	Endif

Return



Static Function ValidaInfo(cAlias)

Local cAlsTMP	:= GetNextAlias()
Local cWhere	:= ''
Local nCont		:= 0

	cWhere := "%"
	cWhere += "SC5.C5_FILIAL = '"+FWxFilial('SC5')+"' "
	cWhere += "AND SC5.C5_NUM = '" + MV_PAR01 + "' "
	If !Empty(MV_PAR03) 
		cWhere += "AND SC6.C6_ITEM BETWEEN '" + STRZERO(Val(MV_PAR02),TamSx3('C6_ITEM')[1]) + "' AND '" + STRZERO(Val(MV_PAR03),TamSx3('C6_ITEM')[1]) + "' "
	EndIf
	cWhere += "AND SC5.D_E_L_E_T_ = ' ' "
	cWhere += "%"
	
	BEGINSQL ALIAS cAlsTMP
		
		SELECT	SC5.C5_NUM, SC5.C5_CLIENTE, SC5.C5_LOJAENT, SC5.C5_PESOL, SC5.C5_PBRUTO, SA1.A1_CGC, SB1.B1_COD,  SB1.B1_CODBAR, 
				SA1.A1_NREDUZ, SC6.C6_ITEM, SC6.C6_PRODUTO, SB1.B1_LOCAL, SB1.B1_DESC, SB1.B1_QE, SC6.C6_QTDVEN
		
		FROM %Table:SC5% SC5
		
			INNER JOIN %Table:SC6% SC6 ON SC6.C6_FILIAL = %xFilial:SC6% AND SC6.C6_NUM = SC5.C5_NUM AND SC6.%NOTDEL%		
			INNER JOIN %Table:SA1% SA1 ON SA1.A1_FILIAL = %xFilial:SA1% AND SA1.A1_COD = SC5.C5_CLIENTE AND SA1.A1_LOJA = SC5.C5_LOJAENT AND SA1.%NOTDEL%
			INNER JOIN %Table:SB1% SB1 ON SB1.B1_FILIAL = %xFilial:SB1% AND SB1.B1_COD = SC6.C6_PRODUTO AND SB1.%NOTDEL%
		
		WHERE	%Exp:cWhere%
	
	ENDSQL

	If (cAlsTMP)->(EOF())
        
		FwAlertWarning('Registros não localizadas no parâmetro informado!')
    
	Else

		MSCBPRINTER("OS 214","LPT1",NIL) 	        		
        MSCBCHKSTATUS(.F.)

		Do While !(cAlsTMP)->(EOF())

//			IF (cAlsTMP)->B1_QE == 0
//				FwAlertWarning('o produto ' + ALLTRIM((cAlsTMP)->B1_COD) + ' não possui Qtde. de Embalagem informado.')
//				(cAlsTMP)->(dbSkip())
//				Loop
//			Endif

//			FOR nCont := 1 To (cAlsTMP)->C6_QTDVEN / (cAlsTMP)->B1_QE
			FOR nCont := 1 To MV_PAR05
				
				MSCBBEGIN(1,4)

				MSCBBOX(03,03,98,46,5)
				MSCBSAYBAR(70,27,AllTrim((cAlsTMP)->B1_CODBAR),"N","MB07",8.36,.F.,.T.,.F.,,2,1)
				MSCBSAY(05	,40	,ALLTRIM(SM0->M0_NOMECOM)								,'N'	,'3'	,'01'	,'01')
				MSCBSAY(05	,33	,'CLIENTE: ' + ALLTRIM((cAlsTMP)->(A1_NREDUZ))			,'N'	,'3'	,'01'	,'01')
				MSCBSAY(05	,27	,'PRODUTO: ' + ALLTRIM((cAlsTMP)->B1_COD)				,'N'	,'3'	,'01'	,'01')
				MSCBSAY(05	,20	,'DESCRI.: ' + ALLTRIM((cAlsTMP)->B1_DESC)				,'N'	,'3'	,'01'	,'01')
//				MSCBSAY(05	,13	,'QTDE.: '   + ALLTRIM(cValToChar((cAlsTMP)->B1_QE))	,'N'	,'3'	,'01'	,'01')
				MSCBSAY(05	,13	,'QTDE.: '   + ALLTRIM(cValToChar((cAlsTMP)->C6_QTDVEN)),'N'	,'3'	,'01'	,'01')
				MSCBSAY(32	,13	,'PESO.: '   + AllTrim(cValToChar(MV_PAR04)) + ' KG'	,'N'	,'3'	,'01'	,'01')
				MSCBSAY(65	,13	,'FABR.: '	 + DTOC(dDataBase)							,'N'	,'3'	,'01'	,'01')
				MSCBSAY(05	,05	,'MANTER PROTEGIDO DO SOL, UMIDADE E POEIRA'			,'N'	,'3'	,'01'	,'01')
				
				
				MSCBEND()
            
			Next nCont
			
			(cAlsTMP)->(dbSkip())
		
		EndDo	
		
		MSCBCLOSEPRINTER()
		
		(cAlsTMP)->(DbCloseArea())

	Endif
   
Return
