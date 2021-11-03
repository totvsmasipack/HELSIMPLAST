#Include "Rwmake.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} RLOJR005
//TODO Impressão de etiquetas de código de barras.
@author felipe.freitas
@since 05/06/2019
@version 2.0
@return Nil
@type function
/*/

User Function RLOJR005()

Local cTitle	:= "Etiqueta de Código de Barras"
Local cPerg		:= "RLOJR005"
Local aSays		:= {}
Local aButtons 	:= {}

    Pergunte(cPerg,.F.)

	AADD(aSays,"Este programa irá realizar a impressão de etiquetas de código de barras,")
	AADD(aSays,"conforme os parâmetros selecionados no botão abaixo.")

	AADD(aButtons, {5,.T.,{|| Pergunte(cPerg,.T.)}})
	AADD(aButtons, {1,.T.,{|o| IF(!Empty(mv_par02) .And. MV_PAR03 > 0, FWMsgRun(, {|| ValidaInfo() }, "Aguarde", "Gerando etiquetas..."), Nil)  /*FechaBatch()*/}})
	AADD(aButtons, {2,.T.,{|o| FechaBatch() }})

	FormBatch(cTitle, aSays, aButtons)     

Return

Static Function ValidaInfo()

Local aCampos   := {}
Local cAlias	:= ""
Local _cQuery	:= ""
Local oTable	:= FwTemporaryTable():New()

    AADD(aCampos,{ "TB_PRODUTO","C",30,0 } )
    AADD(aCampos,{ "TB_CODGTIN","C",25,0 } )
	AADD(aCampos,{ "TB_COMPOSI","C",20,0 } )
    AADD(aCampos,{ "TB_VOLUME" ,"C",15,0 } )
    AADD(aCampos,{ "TB_QUANT","N",10,0})

    oTable:SetFields(aCampos)
	oTable:Create()
	cAlias := oTable:GetAlias()

    If mv_par01 == 1
        _cQuery := "SELECT SC5.C5_NUM,    SC5.C5_CLIENTE, SC5.C5_LOJAENT, SC5.C5_PESOL, SC5.C5_PBRUTO, SA1.A1_CGC,  "
        _cQuery += "       SA1.A1_NREDUZ, SC6.C6_ITEM,	  SC6.C6_PRODUTO, SC6.C6_QTDVEN, SB1.B1_LOCAL, SB1.B1_DESC,   SB5.B5_QE1,   "
        _cQuery += "       SB5.B5_QUAL, SB5.B5_MSVLETQ, SB1.B1_CODGTIN, SB1.B1_COD  "
        _cQuery += "FROM "+RetSqlName("SC5")+" SC5 "
        _cQuery += "INNER JOIN "+RetSqlName("SC6")+" SC6 ON SC6.C6_FILIAL = '"+xFilial("SC6")+"' AND SC6.C6_NUM = SC5.C5_NUM AND SC6.D_E_L_E_T_=' ' "		
        _cQuery += "INNER JOIN "+RetSqlName("SA1")+" SA1 ON SA1.A1_FILIAL = '"+xFilial("SA1")+"' AND SA1.A1_COD = SC5.C5_CLIENTE "
        _cQuery += "                                 AND SA1.A1_LOJA = SC5.C5_LOJAENT AND SA1.D_E_L_E_T_ = ' ' "
        _cQuery += "INNER JOIN "+RetSqlName("SB1")+" SB1 ON SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.B1_COD = SC6.C6_PRODUTO AND SB1.D_E_L_E_T_=' ' "
        _cQuery += "LEFT OUTER JOIN "+RetSqlName("SB5")+" SB5 ON SB5.B5_FILIAL = '"+xFilial("SB5")+"' AND SB5.B5_COD=SC6.C6_PRODUTO AND SB5.D_E_L_E_T_=' ' "
        _cQuery += "WHERE SC5.C5_FILIAL = '"+xFilial("SC5")+"' AND   SC5.D_E_L_E_T_ = ' ' "
        _cQuery += "AND   SC5.C5_NUM = '"+mv_par02+"' "
        _cQuery += "ORDER BY SC5.C5_NUM, SC6.C6_ITEM "
    Else
        _cQuery := "SELECT SB1.B1_COD, SB1.B1_CODGTIN, SB1.B1_SEGUM, SB5.B5_QUAL, SB5.B5_MSVLETQ "
        _cQuery += "FROM "+RetSqlName("SB1")+" SB1 "
        _cQuery += "INNER JOIN "+RetSqlName("SB5")+" SB5 ON SB5.B5_FILIAL = '"+xFilial("SB5")+"' AND SB5.B5_COD = SB1.B1_COD AND SB5.D_E_L_E_T_ = ' ' "
        _cQuery += "WHERE SB1.B1_FILIAL = '"+xFilial("SB1")+"' AND SB1.D_E_L_E_T_ = ' ' "
        _cQuery += "AND SB1.B1_COD = '"+mv_par02+"' "
        _cQuery += "ORDER BY SB1.B1_COD "
    EndIf

	TcQuery _cQuery New Alias "QR1"

	Do While !QR1->(Eof())

        (cAlias)->(DBAppend())
		(cAlias)->TB_PRODUTO := Alltrim(QR1->B1_COD)
		(cAlias)->TB_CODGTIN := Alltrim(QR1->B1_CODGTIN)
		(cAlias)->TB_COMPOSI := Alltrim(QR1->B5_QUAL)
		(cAlias)->TB_VOLUME  := Alltrim(QR1->B5_MSVLETQ)
        (cAlias)->TB_QUANT   := IIF(MV_PAR01 == 1, NoRound(QR1->C6_QTDVEN), 0)
		(cAlias)->(DBCommit())
        GeraEtiq(@cAlias)
		QR1->(dbSkip()) 	            

	EndDo
			                                                  
	QR1->(DbCloseArea())
   
Return

Static Function GeraEtiq(cAlias)

Local nCont	:= 1

    If MV_PAR01 == 1
        mv_par03 := (cAlias)->TB_QUANT
    Endif

    MSCBPRINTER("OS 214","LPT1",NIL) 	        		
            
    MSCBCHKSTATUS(.F.)
    
    While nCont <= mv_par03

        MSCBBEGIN(1,4)
        
        MSCBSAYBAR(014,05,AllTrim((cAlias)->TB_CODGTIN),"B","MB04",10,.T.,.T.,.F.,,3,3)
        MSCBSAY(017,005,AllTrim((cAlias)->TB_PRODUTO),"B","0","002,002",,,,,.T.)
        MSCBSAY(019,005,"CNPJ: " + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),"B","0","002,002",,,,,.T.)
        MSCBSAY(021,005,"  IE: " + Transform(SM0->M0_INSC,"@R 999.999.999.999"),"B","0","002,002",,,,,.T.)
        MSCBSAY(023,005," SAC: (11) 4361-6077","B","0","002,002",,,,,.T.)
        MSCBSAY(025,005," VALIDADE INDETERMINADA","B","0","002,002",,,,,.T.)
        MSCBSAY(027,005,"COMPOSICAO: " + Alltrim((cAlias)->TB_COMPOSI),"B","0","002,002",,,,,.T.)
        MSCBSAY(029,005,"CONTEM 01 UNIDADE DE " + Alltrim((cAlias)->TB_VOLUME),"B","0","002,002",,,,,.T.)
        MSCBSAY(031,005,"  FABRICADO NO BRASIL","B","0","002,002",,,,,.T.)

        MSCBSAYBAR(044,05,AllTrim((cAlias)->TB_CODGTIN),"B","MB04",10,.T.,.T.,.F.,,3,3)
        MSCBSAY(047,005,AllTrim((cAlias)->TB_PRODUTO),"B","0","002,002",,,,,.T.)
        MSCBSAY(049,005,"CNPJ: " + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),"B","0","002,002",,,,,.T.)
        MSCBSAY(051,005,"  IE: " + Transform(SM0->M0_INSC,"@R 999.999.999.999"),"B","0","002,002",,,,,.T.)
        MSCBSAY(053,005," SAC: (11) 4361-6077","B","0","002,002",,,,,.T.)
        MSCBSAY(055,005," VALIDADE INDETERMINADA","B","0","002,002",,,,,.T.)
        MSCBSAY(057,005,"COMPOSICAO: " + Alltrim((cAlias)->TB_COMPOSI),"B","0","002,002",,,,,.T.)
        MSCBSAY(059,005,"CONTEM 01 UNIDADE DE " + Alltrim((cAlias)->TB_VOLUME),"B","0","002,002",,,,,.T.)
        MSCBSAY(061,005,"  FABRICADO NO BRASIL","B","0","002,002",,,,,.T.)

        MSCBSAYBAR(075,05,AllTrim((cAlias)->TB_CODGTIN),"B","MB04",10,.T.,.T.,.F.,,3,3)
        MSCBSAY(078,005,AllTrim((cAlias)->TB_PRODUTO),"B","0","002,002",,,,,.T.)
        MSCBSAY(080,005,"CNPJ: " + Transform(SM0->M0_CGC,"@R 99.999.999/9999-99"),"B","0","002,002",,,,,.T.)
        MSCBSAY(082,005,"  IE: " + Transform(SM0->M0_INSC,"@R 999.999.999.999"),"B","0","002,002",,,,,.T.)
        MSCBSAY(084,005," SAC: (11) 4361-6077","B","0","002,002",,,,,.T.)
        MSCBSAY(086,005," VALIDADE INDETERMINADA","B","0","002,002",,,,,.T.)
        MSCBSAY(088,005,"COMPOSICAO: " + Alltrim((cAlias)->TB_COMPOSI),"B","0","002,002",,,,,.T.)
        MSCBSAY(090,005,"CONTEM 01 UNIDADE DE " + Alltrim((cAlias)->TB_VOLUME),"B","0","002,002",,,,,.T.)
        MSCBSAY(092,005,"  FABRICADO NO BRASIL","B","0","002,002",,,,,.T.)

        nCont += 3
        
        MSCBEND()
                    
    End		

    nCont := 1

    MSCBCLOSEPRINTER()
	
Return
