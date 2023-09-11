/*/{Protheus.doc} User Function HELSP004
    Função para processar transferencia de estoque para loja ao gerar documento de saida (CHAMADA PELO PONTO DE ENTRADA M460FIM)
    @type  Function
    @author Fernando Corrêa
    @since 05/09/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

User Function HELSP004()
    
    Local cTesTran      := SUPERGETMV( 'ES_TSTRANS', , '777',  )
    Local cArmOri       := SUPERGETMV( 'ES_HARMORI', , '01',  )
    Local cArmDest      := SUPERGETMV( 'ES_HARMODE', , '50',  )
    Local cArmDest9     := SUPERGETMV( 'ES_HARMOD9', , '51',  )
    Local cCliTransf    := SUPERGETMV( 'ES_HCLITRA', , '00000101',  )
    Local cFilNota      := SF2->F2_FILIAL
    Local cNota         := SF2->F2_DOC
    Local cSerie        := SF2->F2_SERIE
    Local cCliLj        := SF2->F2_CLIENTE + SF2->F2_LOJA
    Local cChave        := cFilNota + cNota + cSerie + cCliLj
    Local aAuto         := {}
    Local aLinha        := {}
    Local nOpcAuto      := 3
    Local cItem         := '000'
    
    Private lMsErroAuto := .F.
    
    If alltrim(cSerie) $ '8|9'
        IF Alltrim(cCliLj) $ Alltrim(cCliTransf)
            DbSelectArea("SD2")
            SD2->(DbSetOrder(3)) //D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM
            SD2->(DbGoTop()) //D2_FILIAL, D2_DOC, D2_SERIE, D2_CLIENTE, D2_LOJA, D2_COD, D2_ITEM

            DbSelectArea('SB1')
            SB1->(DbSetOrder(1)) //B1_FILIAL, B1_COD

            //Valido se a TES existe e se não movimenta estoque
            DbSelectArea("SF4")
            SF4->(DbSetOrder(1))
            If SF4->(MsSeek(xFilial('SF4')+cTesTran))
                If Alltrim(SF4->F4_ESTOQUE) == 'S'
                    Help(NIL, NIL, "HELSP004", NIL, "A TES informada no parametro ES_TSTRANS atualiza estoque, a transferência automatica não será realizada para a loja. ", 1, 0,,,,,,;
                    {" Altere o cadastro do parametro para uma TES que não atualize estoque."})
                    Return 
                EndIf 
            Else   
                Help(NIL, NIL, "HELSP004", NIL, "A TES informada no parametro ES_TSTRANS não foi encontrada, a transferência automatica não será realizada para a loja. ", 1, 0,,,,,,;
                {" Altere o cadastro do parametro para uma TES valida."})
                Return 
            EndIf 
            //Busco os itens da nota fiscal
            If SD2->(MsSeek(cChave))
                While SD2->(!EOF()) .and. SD2->D2_FILIAL+ SD2->D2_DOC + SD2->D2_SERIE + SD2->D2_CLIENTE + SD2->D2_LOJA == cChave
                    If Alltrim(cTesTran) $ SD2->D2_TES .and. Alltrim(SD2->D2_LOCAL) $ cArmOri

                        If SB1->(MsSeek(xFilial("SB1")+SD2->D2_COD))

                            //Não realizo transferencia automatica de item que controla endereço
                            iF .not. (Alltrim(SB1->B1_LOCALIZ) == 'S')

                                If  Len(aAuto) == 0
                                    //Cabecalho a Incluir
                                    aadd(aAuto,{GetSxeNum("SD3","D3_DOC"),dDataBase}) //Cabecalho
                                EndIf 

                                aLinha := {}
                                cItem := Soma1(cItem)

                                aadd(aLinha,{"ITEM"      ,cItem,Nil})
                                aadd(aLinha,{"D3_COD"    , SD2->D2_COD, Nil}) //Cod Produto origem 
                                aadd(aLinha,{"D3_DESCRI" , SB1->B1_DESC, Nil}) //descr produto origem 
                                aadd(aLinha,{"D3_UM"     , SB1->B1_UM, Nil}) //unidade medida origem 
                                aadd(aLinha,{"D3_LOCAL"  , SD2->D2_LOCAL, Nil}) //armazem origem 
                                aadd(aLinha,{"D3_LOCALIZ", PadR("", tamsx3('D3_LOCALIZ') [1]),Nil}) //Informar endereço origem

                                //Destino 
                                aadd(aLinha,{"D3_COD"    , SD2->D2_COD, Nil}) //cod produto destino 
                                aadd(aLinha,{"D3_DESCRI" , SB1->B1_DESC, Nil}) //descr produto destino 
                                aadd(aLinha,{"D3_UM"     , SB1->B1_UM, Nil}) //unidade medida destino 
                                aadd(aLinha,{"D3_LOCAL"  , Iif(Alltrim(cSerie) == '8', cArmDest,cArmDest9), Nil}) //armazem destino 
                                aadd(aLinha,{"D3_LOCALIZ", PadR("", tamsx3('D3_LOCALIZ') [1]),Nil}) //Informar endereço destino

                                //aadd(aLinha,{"D3_XDOC"   , SD2->D2_DOC, Nil}) //Grava campo customizado de nota 
                                //aadd(aLinha,{"D3_XSERIE" , SD2->D2_SERIE, Nil}) //Grava campo customizado de serie da nota

                                aadd(aLinha,{"D3_NUMSERI", SD2->D2_NUMSERI, Nil}) //Numero serie
                                aadd(aLinha,{"D3_LOTECTL", SD2->D2_LOTECTL, Nil}) //Lote Origem
                                aadd(aLinha,{"D3_NUMLOTE", SD2->D2_NUMLOTE, Nil}) //sublote origem
                                aadd(aLinha,{"D3_DTVALID", SD2->D2_DTVALID, Nil}) //data validade 
                                aadd(aLinha,{"D3_POTENCI", SD2->D2_POTENCI, Nil}) // Potencia
                                aadd(aLinha,{"D3_QUANT"  , SD2->D2_QUANT, Nil}) //Quantidade
                                aadd(aLinha,{"D3_QTSEGUM", SD2->D2_QTSEGUM, Nil}) //Seg unidade medida
                                aadd(aLinha,{"D3_ESTORNO", "", Nil}) //Estorno 
                                aadd(aLinha,{"D3_NUMSEQ", "", Nil}) // Numero sequencia D3_NUMSEQ

                                aadd(aLinha,{"D3_LOTECTL", SD2->D2_LOTECTL, Nil}) //Lote destino
                                aadd(aLinha,{"D3_NUMLOTE", SD2->D2_NUMLOTE, Nil}) //sublote destino 
                                aadd(aLinha,{"D3_DTVALID", SD2->D2_DTVALID, Nil}) //validade lote destino
                                aadd(aLinha,{"D3_ITEMGRD", "", Nil}) //Item Grade

                                aadd(aLinha,{"D3_CODLAN", SD2->D2_CODLAN, Nil}) //cat83 prod origem
                                aadd(aLinha,{"D3_CODLAN", SD2->D2_CODLAN, Nil}) //cat83 prod destino 

                                aAdd(aAuto,aLinha)
                            EndIf 

                        EndIf 
                        
                    EndIf 
                                

                    SD2->(DbSkip())

                EndDo 

                //Se houver item para transferencia chamo o execauto
                iF Len(aAuto ) > 0

                    MSExecAuto({|x,y| mata261(x,y)},aAuto,nOpcAuto)

                    If lMsErroAuto 
                        MostraErro()
                    Else 
                         MSGINFO( 'Tranferência de produtos para a loja realizada com sucesso', 'Transferência para loja' )
                    EndIf
                 
                EndIf 
       
            EndIf 

        EndIf 
        
    EndIf 


Return 
