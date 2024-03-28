#Include 'Protheus.ch'

/*/{Protheus.doc} FTVD7001
Esse ponto de entrada é chamado antes do início da gravação do orçamento. Utilizado para validações no final da venda.

LINK TDN: http://tdn.totvs.com/pages/releaseview.action?pageId=6784482

@type function
@author Fernando Corrêa
@since 25/04/2023
@version 1.0
@return ${return}, ${return_description}
@example
(examples)
@see (links_or_references)
/*/

User Function FTVD7001()

    Local nDescFolha    := aScan(APGTOS,{ |x| AllTrim(x[3]) == "DF" 	})
    Local nPosvlDesc    := aScan( aHeader, { |x| Trim(x[2]) == 'LR_VALDESC' })
    Local nPosDesc      := aScan( aHeader, { |x| Trim(x[2]) == 'LR_DESC' })
    Local lExistDesc    := .F.
    Local lRet			:= .T.
    Local nx            := 0
    Local aArea			:= GetArea()
    Local cMsgCartao      := ""
    Local cMsgDF        := ""
    Local cMsgJuros     := "Parcelamento acima de 3 x o Juros da Operadora é repassado ao cliente. "
    Local cFormDesF     := SUPERGETMV( "ES_HELFMDF", , "DF", ) //Formas de pagamentos desconfto em folha
    Local nHELP001      := SUPERGETMV( "ES_HELP01", , 0, )
    Local nHELP002      := SUPERGETMV( "ES_HELP02", , 3, )
    Local nHELP003A     := SUPERGETMV( "ES_HELP03A", , 1, )
    Local nHELP003B     := SUPERGETMV( "ES_HELP03B", , 100.00, )
    Local nHELP004A     := SUPERGETMV( "ES_HELP04A", , 3, )
    Local nHELP004B     := SUPERGETMV( "ES_HELP04B", , 400, )
    Local nHELP005A     := SUPERGETMV( "ES_HELP05A", , 100, )
    Local nHELP005B     := SUPERGETMV( "ES_HELP05B", , 1, )
    Local nHELP006A     := SUPERGETMV( "ES_HELP06A", , 400, )
    Local nHELP006B     := SUPERGETMV( "ES_HELP06B", , 2, )
    Local nAvisCli      := SUPERGETMV( "ES_HELSAVI", , 2, ) //Quantidade maxima de parcelas

    cMsgCartao       := " Parcelamento não permitido. " + CRLF 
    cMsgCartao       += " Cartão de Crédito  " + CRLF 
    cMsgCartao       += " Até R$ 99,00 - 1x sem juros " + CRLF 
    cMsgCartao       += " A partir de R$ 100,00 - 2x sem juros" + CRLF 
    cMsgCartao       += " A partir de R$ 400,00 - 3 x juros repassado para o cliente " + CRLF 

    cMsgDF := " Parcelamento não permitido " + CRLF 
    cMsgDF := " Desconto em folha " + CRLF 
    cMsgDF += " A partir de R$ 100,00 até R$ 399,00 - em 2x " + CRLF 
    cMsgDF += " A partir de R$ 400,00 - em 3x " + CRLF 
    cMsgDF += " Não permitido parcelamento maior que 3x " + CRLF 

    lExistDesc := (aScan( aCols, { |x| x[nPosvlDesc] > 0 }) > 0 ) .or.  (aScan( aCols, { |x| x[nPosDesc] > 0 }) > 0)

    //Função para garantir que o numero da nota fiscal não está se repetindo.
    valnumnf()

    If (lExistDesc .OR. aScan( ADESCONTO, { |x| x > 0 }) > 0) .and. Empty(LQ_XMOTDES)
         If Empty(M->LQ_XMAT)
            lRet := .F.
            Help(NIL, NIL, "FTVDHELDESC", NIL, "Quando houver desconto no pedido o motivo do desconto deve ser informado.", 1, 0)
        EndIf 
    EndIf 

    If nDescFolha > nHELP001 .and. lRet
        If Empty(M->LQ_XMAT)
            lRet := .F.
            Help(NIL, NIL, "FTVDHELP001", NIL, "Quando houver Desconto em Folha é obrigatório preencher a matricula do funcionario.", 1, 0)
        EndIf 
        //Desconto em folha precisa informar quantidade de parcelas
        If lRet .and. M->LQ_XQTDPAR <= nHELP001
            lRet := .F.
            Help(NIL, NIL, "FTVDHELP001", NIL, "Quando existe Debito em folha é obrigatório preencher a quantidade de parcelas..", 1, 0)
        EndIf 
    EndIf 

    If Len(APGTOSSINT) > 0 .and. lRet 
        For nx := 1 To Len(APGTOSSINT)
            //Desconto em folha, pagamento maior que 3 vezes
            If lRet .and. M->LQ_XQTDPAR > nHELP002 .and. APGTOSSINT[nx][1] $ cFormDesF
                lRet := .F.
                Help(NIL, NIL, "FTVDHELP002", NIL, cMsgDF, 1, 0)
            EndIf 
            //Desconto em folha, pagamento menor que R$ 100,00 não pode ser parcelado
            If lRet .and. APGTOSSINT[nx][1] $ cFormDesF .and. M->LQ_XQTDPAR > nHELP003A .and. Val(alltrim(STRTRAN(STRTRAN(APGTOSSINT[nx][3],'.',''),',','.'))) < nHELP003B
                lRet := .F.
                Help(NIL, NIL, "FTVDHELP003", NIL, cMsgDF , 1, 0)
            EndIf 
            //Desconto em folha, pagamento até R$ 399,00 não pode ser maior que duas vezes.
            If lRet .and. APGTOSSINT[nx][1] $ cFormDesF .and. M->LQ_XQTDPAR >= nHELP004A .and. Val(alltrim(STRTRAN(STRTRAN(APGTOSSINT[nx][3],'.',''),',','.'))) < nHELP004B
                lRet := .F.
                Help(NIL, NIL, "FTVDHELP004", NIL, cMsgDF , 1, 0)
            EndIf 
            //Cartão de crédito, não permite parcelar valores menores que R$ 100,00
            If  lRet .and.  Val(alltrim(STRTRAN(STRTRAN(APGTOSSINT[nx][3],'.',''),',','.'))) < nHELP005A .and. APGTOSSINT[nx][2] > nHELP005B
                lRet := .F.
                Help(NIL, NIL, "FTVDHELP005", NIL, cMsgCartao , 1, 0)
            EndIf 
            //Cartão de credito, não permite parcelamento de valor menor que 400 em mais que duas vezes.
            If  lRet .and.  (Val(alltrim(STRTRAN(STRTRAN(APGTOSSINT[nx][3],'.',''),',','.')))) < nHELP006A .and. APGTOSSINT[nx][2] > nHELP006B 
                lRet := .F.
                Help(NIL, NIL, "FTVDHELP006", NIL, cMsgCartao , 1, 0)
            EndIf 

            If  lRet .and. APGTOSSINT[nx][2] > nAvisCli 
                If !(MSGYESNO( cMsgJuros, "Avisar cliente!" ))
                    lRet := .F.
                EndIf 
            EndIf 

            If lRet .and. APGTOSSINT[nx][1] $ "BON" .and. ( Empty( M->LQ_XMOTDES ) .or. Len(M->LQ_XMOTDES) < 2 )
                lRet := .F.
                Help(NIL, NIL, "FTVDHELP008", NIL, "Para aplicar Bonificação é necessário preencher o Motivo...", 1, 0)
            EndIf 
            
        Next nx 

    EndIf 


    RestArea(aArea)

Return(lRet)


/*/{Protheus.doc} valnumnf
    Função para garantir se o sistema não vai repetir o numero da nota
    foi necessaria a criação pois em 20/10/2023 o sistema passou a apresentar um erro intermitente
    onde o numero da nota na SX5 não era incrementado ao gerar uma nota, causando erro de nota existente na próxima emissão.
    @type  Static Function
    @author Fernando Corrêa (DS2U)
    @since 21/10/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function valnumnf()

    Local cSerie   := SUPERGETMV( 'MV_LOJANF ',, 'LJ',  )
    Local cQuery   := ''
    Local cAliasL1 := GetNextAlias()
    Local cDocL1   := ''
    Local cNewDoc  := ''

    cQuery := " SELECT TOP 1 SL1.L1_DOC AS DOC "
    cQuery += "	FROM " + RETSQLNAME('SL1') + " SL1 "
    cQuery += "	WHERE SL1.L1_FILIAL = '" + xFilial("SL1") + "' "
    cQuery += "	AND SL1.D_E_L_E_T_= '' "
    cQuery += "	ORDER BY L1_DOC DESC "

    //--Cria uma tabela temporária com as informações da query				
    dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAliasL1,.F.,.T.)

    If (cAliasL1)->(!Eof())
        cDocL1 := (cAliasL1)->DOC
    EndIf 

    DbSelectArea('SX5')
    SX5->(DbSetorder(1))
    If !Empty(cDocL1)
        If SX5->(MsSeek(xFilial("SX5")+'01'+cSerie))
            If SX5->X5_DESCRI <= cDocL1
                cNewDoc := Soma1(cDocL1)
                If RecLock('SX5',.F.)
                    SX5->X5_DESCRI  := cNewDoc
                    SX5->X5_DESCSPA := cNewDoc
                    SX5->X5_DESCENG := cNewDoc
                    SX5->(MSUNLOCK())
                EndIf 
            EndIf 
        EndIf  
    EndIf 

    (cAliasL1)->(DBCLOSEAREA())

Return 
