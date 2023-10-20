#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} User Function M410PVNF
    Função para alterar TES na transferencia para loja, para que não controle estoque.
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

User function M410PVNF()

    Local cC5Fil        := SC5->C5_FILIAL
    Local cNumPed       := SC5->C5_NUM
    Local cCliente      := SC5->C5_CLIENTE
    Local cLoja         := SC5->C5_LOJACLI
    Local cTesOri       := SUPERGETMV( 'ES_TSM410P', , '885',  )
    Local cTesTran      := SUPERGETMV( 'ES_TSTRANS', , '777',  )
    Local cCliTransf    := SUPERGETMV( 'ES_HCLITRA', , '00000101',  )
    Local lAlterado     := .F.
    Local lRet          := .T.
    Local aCabec        := {}
    Local aItens        := {}
    Local aLinha        := {}
    Local lMsErroAuto   := .F.
        

    //Regra se aplica somente para empresa 15 - Masitubos
    If Alltrim(SubStr(cNumEmp,1,2)) == "15"

        If  Alltrim(cCliente + cLoja) == Alltrim(cCliTransf)

            aadd(aCabec,{"C5_NUM"    , cNumPed             , Nil})
            aadd(aCabec,{"C5_TIPO"   , SC5->C5_TIPO        , Nil})
            aadd(aCabec,{"C5_CLIENTE", SC5->C5_CLIENTE     , Nil})
            aadd(aCabec,{"C5_LOJACLI", SC5->C5_LOJACLI     , Nil})
            aadd(aCabec,{"C5_LOJAENT", SC5->C5_LOJAENT     , Nil})
            aadd(aCabec,{"C5_CONDPAG", SC5->C5_CONDPAG     , Nil})    


            //Validações do Usuário 
            DbSelectArea('SC6')
            SC6->(DbSetOrder(1))
            SC6->(DbGoTop())

            If SC6->(MsSeek(cC5Fil+cNumPed))
        
                While SC6->(!Eof()) .and. SC6->C6_FILIAL == cC5Fil .and. SC6->C6_NUM == cNumPed
                    If Alltrim(SC6->C6_TES) == Alltrim(cTesOri)
                
                        aLinha := {}
                        aadd(aLinha,{"LINPOS"    , "C6_ITEM", SC6->C6_ITEM})
                        aadd(aLinha,{"AUTDELETA" , "N"              , Nil          })
                        aadd(aLinha,{"C6_PRODUTO", SC6->C6_PRODUTO  , Nil          })
                        aadd(aLinha,{"C6_QTDVEN" , SC6->C6_QTDVEN   , Nil          })
                        aadd(aLinha,{"C6_PRCVEN" , SC6->C6_PRCVEN   , Nil          })
                        aadd(aLinha,{"C6_PRUNIT" , SC6->C6_PRUNIT   , Nil          })
                        aadd(aLinha,{"C6_VALOR"  , SC6->C6_VALOR    , Nil          })
                        aadd(aLinha,{"C6_TES"    , cTesTran         , Nil          })
                        aadd(aItens, aLinha)
                    EndIf 
                    SC6->(DbSkip())
                EndDo         

            
                If Len(aItens) > 0
                    MSExecAuto({|a, b, c, d| MATA410(a, b, c, d)}, aCabec, aItens, 4, .F.)            
                    If !lMsErroAuto
                        lAlterado := .T.
                    Else
                        ConOut("Erro na alteracao!")
                        MOSTRAERRO()
                    EndIf

                    If  lAlterado
                        MSGINFO( 'As TES do pedido foram alteradas de ' + cTesOri + ' para '  +  cTesTran + ' .', 'Transferência para loja' )
                    EndIf 

                EndIf 

            EndIf 

        EndIf 

    EndIf 

Return lRet
