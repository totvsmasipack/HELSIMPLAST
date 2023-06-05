#INCLUDE "RPTDEF.CH"
#INCLUDE "FWPrintSetup.ch"
#INCLUDE "protheus.ch"

/*/{Protheus.doc} User Function HELSR001
    Fonte responsável pela impressão do Cupom NÃO FISCAL venda direta
    @type  Function
    @author Fernando Correa (DS2U)
    @since 06/05/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function HELSR001(nOpc)

    
    Local oFont1 := TFont():New( "Arial Black", , -18, .T.)
    Local oFont2 := TFont():New( "Arial Black", , -14, .T.)
    Local oFont3 := TFont():New( "Arial Black", , -12, .T.)
    Local nPosProd		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]	// Posicao da codigo do produto
    Local nPosDescri	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_DESCRI"})][2]		// Posicao da Descricao do produto
    Local nPosQuant		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_QUANT"})][2]		// Posicao da Quantidade
    Local nPosVlUnit	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VRUNIT"})][2]		// Posicao do Valor unitario do item
    Local nPosUM		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_UM"})][2]			// Posicao da Unidade de Medida
    Local nPosDesc		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_DESC"})][2]		// Posicao do percentual de desconto
    Local nPosValDesc	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VALDESC"})][2]	// Posicao do valor de desconto
    Local nPosVlrItem	:= aPosCpo[Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "LR_VLRITEM"})][2]	// Posicao do valor do item
    Local nPosLPre		:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_CODLPRE"})				// Posicao do código de lista de presentes
    Local nPosPrdCob	:= Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRDCOBE"})				// Posicao do codigo do Produto Cobertura
    Local nPosNSerie   	:= Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_NSERIE" })				// Posicao do Numero de serie
    Local nPosDtReserva	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_RESERVA"})				// Posicao do codigo da reserva
    Local nPosDtLocal  	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_LOCAL"})				// Posicao do local (armazem)
    Local nPosValePre	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_VALEPRE"})				// Posicao do codigo do Vale Presente
    Local nPosPrcTab	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_PRCTAB"})				// Posicao do Preco de Tabela
    Local lAdjustToLegacy := .T.
    Local lDisableSetup   := .T.
    Local cLocal          := "c:\temp"
    Local nLinha := 30
    Local nQuebra := 0
    Local nCountPar := 0
    Local nx := 0
    Local nxT := 0
    Local nDescFolha    := 0
    Local aPagImp       := {}
    Private oPrinter
    Default nOpc := 0 //0 = Chamada pela finalização da venda | 1 = Chamada pelo botão de reimprimir

If nOpc == 1 .and. .not. ((!Empty(SL1->L1_DOC) .OR. !Empty(SL1->L1_DOCPED) .OR. !Empty(SL1->L1_PEDRES) ) .AND.  !ALLTRIM(SL1->L1_NSO) == "P3")

    FWAlertError("Reimpressão só pode ser realizada para pedidos encerrados ", "Reimpressão")
    Return 

EndIf 


If MSGYESNO( "Deseja imprimir o cupom?", "Imprimir?" )

            If nOpc == 0
                If Len(APGTOS) > 0
                    nDescFolha    := aScan(APGTOS,{ |x| AllTrim(x[3]) == "DF" 	})
                EndIf 
            Else 
                If Len(AADMFINANC) > 0
                    nDescFolha    := aScan(APGTOSSINT,{ |x| AllTrim(x[1]) == "DF" 	})
                EndIf 
            EndIf 
        
            oPrinter := FwMsPrinter():New("exemplo.rel", IMP_SPOOL, lAdjustToLegacy, cLocal, lDisableSetup, , , 'EPSON TM-T20X Receipt',,,,, 2)

            oPrinter:StartPage()
            oPrinter:Say( nLinha, 40 , "                         HELSIM",oFont2)
            newline(@nLinha)
            oPrinter:Say( nLinha, 40 , "          HELSIMPLAST INDUSTRIA E COM",oFont2)
            newline(@nLinha)
            oPrinter:Say( nLinha, 40 , "               CNPJ: 51.317.402.0001/55",oFont2)
            newline(@nLinha)
            oPrinter:Say( nLinha, 40 , "                RUA ALVARO ALVIM, 756",oFont2)
            newline(@nLinha)
            oPrinter:Say( nLinha, 40 , "----------------------------------------------------------------------------",oFont2)
            newline(@nLinha)
            oPrinter:Say( nLinha, 40 , "Pedido: " + LQ_NUM + "  " + cValToChar(DATE()) + cValToChar(Time()),oFont3)
            newline(@nLinha)
            oPrinter:Say( nLinha, 40 , "----------------------------------------------------------------------------",oFont2)
            newline(@nLinha)
            oPrinter:Say( nLinha, 40 , "Num. Registro: " + Alltrim(SL1->L1_DOC) + '/' + Alltrim(SL1->L1_SERIE)  + "  " ,oFont3)
            newline(@nLinha)
            oPrinter:Say( nLinha, 40 , "----------------------------------------------------------------------------",oFont2)
            newline(@nLinha)
            oPrinter:Say( nLinha, 40 , "Cliente: " + Alltrim(LQ_NOMCLI) + "  " + cValToChar(DATE()) + cValToChar(Time()),oFont3)
            newline(@nLinha)
            oPrinter:Say( nLinha, 40 , "----------------------------------------------------------------------------",oFont2)
            newline(@nLinha)
            oPrinter:Say( nLinha, 40 , "Vendedor: " + LQ_NOMVEND ,oFont3)
            newline(@nLinha)
            oPrinter:Say( nLinha, 40 , "----------------------------------------------------------------------------",oFont2)
            If Len(aCols) > 0
                For nx := 1 to Len(aCols)
                    //Não imprimo linhas deletadas.
                    If !(aCols[nx][len(aCols[nx])])
                        newline(@nLinha)
                        oPrinter:Say( nLinha, 40 ,aCols[nx][nPosProd],oFont3)
                        newline(@nLinha)
                        If Len(aCols[nx][nPosDescri]) > 40
                            nQuebra := Ceiling(Len(aCols[nx][nPosDescri]) / 40)
                            For nxT := 1 to nQuebra
                                If nxT == 1
                                    oPrinter:Say( nLinha, 40 ,SUBSTR(aCols[nx][nPosDescri],1,40),oFont3)
                                    newline(@nLinha)
                                Else 
                                    oPrinter:Say( nLinha, 40 ,SUBSTR(aCols[nx][nPosDescri],(nxT - 1) * 40,40),oFont3)
                                    newline(@nLinha)
                                EndIf 
                            Next nxT
                        Else 
                            oPrinter:Say( nLinha, 40 ,aCols[nx][nPosDescri],1,40,oFont3)
                            newline(@nLinha)
                        EndIf 
                        oPrinter:Say( nLinha, 40 ,"     "  +  cValToChar(aCols[nx][nPosQuant]) + " x  " +;
                                            "                      " + Alltrim(Transform(aCols[nx][nPosVlUnit],"@E 9,999,999.99"))  + " = " +;
                                            Alltrim(Transform(aCols[nx][nPosVlrItem],"@E 9,999,999.99")) ,oFont3)
                    EndIf 
                Next nx  
            EndIf 
            newline(@nLinha)
            oPrinter:Say( nLinha, 40 , "----------------------------------------------------------------------------",oFont2)
            newline(@nLinha)
            oPrinter:Say( nLinha, 40 , ATOTAIS[1][1] + ": " + Alltrim(Transform(ATOTAIS[1][2],"@E 9,999,999.99"))  ,oFont3)
            newline(@nLinha)        
            oPrinter:Say( nLinha, 40 , ATOTAIS[2][1] + ": " + Alltrim(Transform(ATOTAIS[2][2],"@E 9,999,999.99"))  ,oFont3)
            newline(@nLinha)
            oPrinter:Say( nLinha, 40 , ATOTAIS[3][1] + ": " + Alltrim(Transform(ATOTAIS[3][2],"@E 9,999,999.99"))  ,oFont3)
            newline(@nLinha)
            oPrinter:Say( nLinha, 40 , ATOTAIS[4][1] + ": " + Alltrim(Transform(ATOTAIS[4][2],"@E 9,999,999.99"))  ,oFont3)
            newline(@nLinha)
            oPrinter:Say( nLinha, 40 , "Total Pago: " + Alltrim(Transform(ATOTAIS[5][2],"@E 9,999,999.99"))  ,oFont3)
            newline(@nLinha)
            oPrinter:Say( nLinha, 40 , ATOTAIS[6][1] + ": " + Alltrim(Transform(ATOTAIS[6][2],"@E 9,999,999.99"))  ,oFont3)
            newline(@nLinha)
            newline(@nLinha)

            If nOpc == 0
                If Len(APGTOS) > 0
                    
                    oPrinter:Say( nLinha, 40 , " Tipo de Pagto.",oFont2)
                    For nx := 1 to Len(APGTOSSINT)
                        newline(@nLinha)
                        If  Alltrim(APGTOSSINT[nx][1]) == 'CC'
                            oPrinter:Say( nLinha, 40 , Alltrim(APGTOSSINT[nx][6][5])  ,oFont3)
                            newline(@nLinha)
                            oPrinter:Say( nLinha, 40 , "R$ " + Alltrim(APGTOSSINT[nx][6][1]) + "      Pacelado em: "  ;
                                        + cValToChar(APGTOSSINT[nx][2]) + " vezes" ,oFont3)
                            If APGTOSSINT[nx][2] >= 3
                                newline(@nLinha)
                                newline(@nLinha)
                                oPrinter:Say( nLinha, 40 , " Parcelamento no Cartão de Crédito maior que ",oFont2)
                                newline(@nLinha)
                                oPrinter:Say( nLinha, 40 , "  2 vezes estará sujeito ao juros da operadora",oFont2)
                                newline(@nLinha)
                            EndIf 
                        ElseIf  Alltrim(APGTOSSINT[nx][1]) == 'DF'
                            oPrinter:Say( nLinha, 40 , Alltrim(APGTOSSINT[nx][6][5])  ,oFont3)
                            newline(@nLinha)
                            oPrinter:Say( nLinha, 40 , "R$ " + Alltrim(APGTOSSINT[nx][6][1]) + " Pacelado em: "  ;
                                        + cValtoChar(LQ_XQTDPAR)  + " vezes" ,oFont3)
                        Else 
                            oPrinter:Say( nLinha, 40 , Alltrim(APGTOSSINT[nx][6][5])  ,oFont3)
                            newline(@nLinha)
                            oPrinter:Say( nLinha, 40 , "R$ " + Alltrim(APGTOSSINT[nx][6][1]) ,oFont3)

                        EndIf 
                    Next nx
                  
                EndIf
            Else 
                If Len(APGTOSSINT) > 0
                    
                    oPrinter:Say( nLinha, 40 , " Tipo de Pagto.",oFont2)
                    For nx := 1 to Len(APGTOSSINT)
                        If  Alltrim(APGTOSSINT[nx][1]) == 'CC'
                            newline(@nLinha)
                            oPrinter:Say( nLinha, 40 , Alltrim(AADMFINANC[aScan(AADMFINANC,{ |x| AllTrim(x[1]) == APGTOSSINT[NX][1] })][2])  + " : " + Alltrim(APGTOSSINT[NX][3] ) ,oFont3)
                            newline(@nLinha)
                            oPrinter:Say( nLinha, 40 , "R$ " + Alltrim(APGTOSSINT[NX][3] ) + "     Pacelado em: "  ;
                                                    + cValToChar(APGTOSSINT[nx][2]) + " vezes" ,oFont3)
                            If APGTOSSINT[nx][2] >= 3
                                newline(@nLinha)
                                newline(@nLinha)
                                oPrinter:Say( nLinha, 40 , " Parcelamento no Cartão de Crédito maior que ",oFont2)
                                newline(@nLinha)
                                oPrinter:Say( nLinha, 40 , "  2 vezes estará sujeito ao juros da operadora",oFont2)
                                newline(@nLinha)
                            EndIf 
                        ElseIf  Alltrim(APGTOSSINT[nx][1]) == 'DF'
                            newline(@nLinha)
                            oPrinter:Say( nLinha, 40 , Alltrim(AADMFINANC[aScan(AADMFINANC,{ |x| AllTrim(x[1]) == APGTOSSINT[NX][1] })][2])  + " : " + Alltrim(APGTOSSINT[NX][3] ) ,oFont3)
                            newline(@nLinha)
                            oPrinter:Say( nLinha, 40 , "R$ " + Alltrim(APGTOSSINT[NX][3] ) + "     Pacelado em: "  ;
                                                    + cValtoChar(LQ_XQTDPAR)  + " vezes" ,oFont3)
                        Else 
                            newline(@nLinha)
                            oPrinter:Say( nLinha, 40 , Alltrim(AADMFINANC[aScan(AADMFINANC,{ |x| AllTrim(x[1]) == APGTOSSINT[NX][1] })][2])  + " : " + Alltrim(APGTOSSINT[NX][3] ) ,oFont3)
                            newline(@nLinha)
                            oPrinter:Say( nLinha, 40 , "R$ " + Alltrim(APGTOSSINT[NX][3] ) ,oFont3)   
                        EndIf   

                    Next nx
                EndIf

            EndIf 

            newline(@nLinha)
            newline(@nLinha)  
            oPrinter:Say( nLinha, 40 , "----------------------------------------------------------------------------",oFont2)
            newline(@nLinha)
            oPrinter:Say( nLinha, 40 , "                           CUPOM SEM VALOR FISCAL                          ",oFont3)
            newline(@nLinha)
            oPrinter:Say( nLinha, 40 , "----------------------------------------------------------------------------",oFont2)
            newline(@nLinha)
            newline(@nLinha)
            newline(@nLinha)
            oPrinter:Say( nLinha, 40 , "",oFont2)
        
            oPrinter:PaperSize()
            oPrinter:EndPage()
            oPrinter:lServer := .T.
            oPrinter:Print()

            oPrinter:Deactivate()
            FreeObj(oPrinter)
            oPrinter := NIL
            /////////////////////////////////////////////TERCEIRA VIA PARA DESCONTO EM FOLHA/////////////////////////////////////////////////////
            If nDescFolha > 0
                nLinha := 30

                oPrinter := FwMsPrinter():New("exemplo.rel", IMP_SPOOL, lAdjustToLegacy, cLocal, lDisableSetup, , , 'EPSON TM-T20X Receipt',,,,, 1)

                oPrinter:StartPage()
                oPrinter:Say( nLinha, 40 , "                         HELSIM",oFont2)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , "          HELSIMPLAST INDUSTRIA E COM",oFont2)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , "               CNPJ: 51.317.402.0001/55",oFont2)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , "                RUA ALVARO ALVIM, 756",oFont2)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , "----------------------------------------------------------------------------",oFont2)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , "Pedido: " + LQ_NUM + "  " + cValToChar(DATE()) + cValToChar(Time()),oFont3)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , "----------------------------------------------------------------------------",oFont2)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , "Num. Registro: " + Alltrim(SL1->L1_DOC) + '/' + Alltrim(SL1->L1_SERIE)  + "  " ,oFont3)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , "----------------------------------------------------------------------------",oFont2)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , "Cliente: " + Alltrim(LQ_NOMCLI) + "  " + cValToChar(DATE()) + cValToChar(Time()),oFont3)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , "----------------------------------------------------------------------------",oFont2)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , "Vendedor: " + LQ_NOMVEND ,oFont3)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , "----------------------------------------------------------------------------",oFont2)
                If Len(aCols) > 0
                    For nx := 1 to Len(aCols)
                        If !(aCols[nx][len(aCols[nx])])
                            newline(@nLinha)
                            oPrinter:Say( nLinha, 40 ,aCols[nx][nPosDescri],oFont3)
                            newline(@nLinha)
                            If Len(aCols[nx][nPosDescri]) > 40
                                nQuebra := Ceiling(Len(aCols[nx][nPosDescri]) / 40)
                                For nxT := 1 to nQuebra
                                    If nxT == 1
                                        oPrinter:Say( nLinha, 40 ,SUBSTR(aCols[nx][nPosDescri],1,40),oFont3)
                                        newline(@nLinha)
                                    Else 
                                        oPrinter:Say( nLinha, 40 ,SUBSTR(aCols[nx][nPosDescri],(nxT - 1) * 40,40),oFont3)
                                        newline(@nLinha)
                                    EndIf 
                                Next nxT
                            Else 
                                oPrinter:Say( nLinha, 40 ,aCols[nx][nPosDescri],1,40,oFont3)
                                newline(@nLinha)
                            EndIf 
                            oPrinter:Say( nLinha, 40 ,"     "  +  cValToChar(aCols[nx][nPosQuant]) + " x  " +  "                      " +;
                                        Alltrim(Transform(aCols[nx][nPosVlUnit],"@E 9,999,999.99"))  + " = " +;
                                        Alltrim(Transform(aCols[nx][nPosVlrItem],"@E 9,999,999.99")) ,oFont3)
                        EndIf 
                    Next nx  
                EndIf 
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , "----------------------------------------------------------------------------",oFont2)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , ATOTAIS[1][1] + ": " + Alltrim(Transform(ATOTAIS[1][2],"@E 9,999,999.99"))  ,oFont3)
                newline(@nLinha)        
                oPrinter:Say( nLinha, 40 , ATOTAIS[2][1] + ": " + Alltrim(Transform(ATOTAIS[2][2],"@E 9,999,999.99"))  ,oFont3)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , ATOTAIS[3][1] + ": " + Alltrim(Transform(ATOTAIS[3][2],"@E 9,999,999.99"))  ,oFont3)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , ATOTAIS[4][1] + ": " + Alltrim(Transform(ATOTAIS[4][2],"@E 9,999,999.99"))  ,oFont3)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , "Total Pago: " + Alltrim(Transform(ATOTAIS[5][2],"@E 9,999,999.99"))  ,oFont3)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , ATOTAIS[6][1] + ": " + Alltrim(Transform(ATOTAIS[6][2],"@E 9,999,999.99"))  ,oFont3)
                newline(@nLinha)
                newline(@nLinha)

                If nOpc == 0
                    If Len(APGTOS) > 0
                        
                        oPrinter:Say( nLinha, 40 , " Tipo de Pagto.",oFont2)
                        For nx := 1 to Len(APGTOSSINT)
                            newline(@nLinha)
                            If  Alltrim(APGTOSSINT[nx][1]) == 'CC'
                               
                                oPrinter:Say( nLinha, 40 , Alltrim(APGTOSSINT[nx][6][5])  ,oFont3)
                                newline(@nLinha)
                                oPrinter:Say( nLinha, 40 , "R$ " + Alltrim(APGTOSSINT[nx][6][1]) + "      Pacelado em: "  ;
                                            + cValToChar(APGTOSSINT[nx][2]) + " vezes" ,oFont3)
                               
                                If APGTOSSINT[nx][2] >= 3
                                    newline(@nLinha)
                                    newline(@nLinha)
                                    oPrinter:Say( nLinha, 40 , " Parcelamento no Cartão de Crédito maior que ",oFont2)
                                    newline(@nLinha)
                                    oPrinter:Say( nLinha, 40 , "  2 vezes estará sujeito ao juros da operadora",oFont2)
                                    newline(@nLinha)
                                EndIf 

                            ElseIf  Alltrim(APGTOSSINT[nx][1]) == 'DF'
                                oPrinter:Say( nLinha, 40 , Alltrim(APGTOSSINT[nx][6][5])  ,oFont3)
                                newline(@nLinha)
                                oPrinter:Say( nLinha, 40 , "R$ " + Alltrim(APGTOSSINT[nx][6][1]) + " Pacelado em: "  ;
                                            + cValtoChar(LQ_XQTDPAR)  + " vezes" ,oFont3)

                            Else 

                                oPrinter:Say( nLinha, 40 , Alltrim(APGTOSSINT[nx][6][5])  ,oFont3)
                                newline(@nLinha)
                                oPrinter:Say( nLinha, 40 , "R$ " + Alltrim(APGTOSSINT[nx][6][1]) ,oFont3)

                            EndIf 
                        Next nx
                    
                    EndIf
                Else 
                    If Len(APGTOSSINT) > 0
                        
                        oPrinter:Say( nLinha, 40 , " Tipo de Pagto.",oFont2)
                        For nx := 1 to Len(APGTOSSINT)
                            If  Alltrim(APGTOSSINT[nx][1]) == 'CC'
                                newline(@nLinha)
                                oPrinter:Say( nLinha, 40 , Alltrim(AADMFINANC[aScan(AADMFINANC,{ |x| AllTrim(x[1]) == APGTOSSINT[NX][1] })][2]) ,oFont3)
                                newline(@nLinha)
                                oPrinter:Say( nLinha, 40 , "R$ " + Alltrim(APGTOSSINT[NX][3] ) + "     Pacelado em: "  ;
                                                        + cValToChar(APGTOSSINT[nx][2]) + " vezes" ,oFont3)
                            ElseIf  Alltrim(APGTOSSINT[nx][1]) == 'DF'
                                newline(@nLinha)
                                oPrinter:Say( nLinha, 40 , Alltrim(AADMFINANC[aScan(AADMFINANC,{ |x| AllTrim(x[1]) == APGTOSSINT[NX][1] })][2]) ,oFont3)
                                newline(@nLinha)
                                oPrinter:Say( nLinha, 40 , "R$ " + Alltrim(APGTOSSINT[NX][3] ) + "     Pacelado em: "  ;
                                                        + cValtoChar(LQ_XQTDPAR)  + " vezes" ,oFont3)
                            Else 
                                newline(@nLinha)
                                oPrinter:Say( nLinha, 40 , Alltrim(AADMFINANC[aScan(AADMFINANC,{ |x| AllTrim(x[1]) == APGTOSSINT[NX][1] })][2])   ,oFont3)
                                newline(@nLinha)
                                oPrinter:Say( nLinha, 40 , "R$ " + Alltrim(APGTOSSINT[NX][3] ) ,oFont3)   
                            EndIf 

                        Next nx
                    EndIf

                EndIf 



                newline(@nLinha)
                newline(@nLinha)  
                oPrinter:Say( nLinha, 40 , "----------------------------------------------------------------------------",oFont2)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , "                           CUPOM SEM VALOR FISCAL                          ",oFont3)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , "----------------------------------------------------------------------------",oFont2)
                oPrinter:Say( nLinha, 40 , "",oFont2)
                newline(@nLinha)
                newline(@nLinha)  
                oPrinter:Say( nLinha, 40 , "----------------------------------------------------------------------------",oFont2)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , " Nome: " + LQ_XNOME   ,oFont3)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , " Matricula: " + LQ_XMAT      ,oFont3)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , " Departamento: "  + LQ_XNDEPTO     ,oFont3)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , " Numero de Parcelas: "  + cValtoChar(LQ_XQTDPAR)     ,oFont3)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , " Empresa: " + LQ_XEMPFUN      ,oFont3)
                newline(@nLinha)
                newline(@nLinha)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , " Assinatura: _______________________________________________________________  " + LQ_XEMPFUN      ,oFont3)
                newline(@nLinha)
                newline(@nLinha)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , "----------------------------------------------------------------------------",oFont2)
                newline(@nLinha)
                newline(@nLinha)
                newline(@nLinha)
                oPrinter:Say( nLinha, 40 , "",oFont2)
            
            
                oPrinter:EndPage()
                oPrinter:lServer := .T.
                oPrinter:Print()

            EndIf
        
        EndIf 
    
Return 


/*/{Protheus.doc} nomeStaticFunction
    (long_description)
    @type  Static Function
    @author user
    @since 14/05/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
Static Function newline(nLinha)

    Local nTamLinha := 40
    Local nTamPag   := 40 * 65


    nLinha += nTamLinha
    If nLinha >= nTamPag
        oPrinter:EndPage()
        oPrinter:StartPage()
        nLinha := 30
    EndIf     
Return 
