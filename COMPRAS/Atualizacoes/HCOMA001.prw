#include 'totvs.ch'
#include 'protheus.ch'

/*/{Protheus.doc} User Function HCOMA001
Processamento de contratos para geracao de AE's por período
@type  Function
@author E. DINIZ [ DS2U ]
@since 12/12/2020
@example
MATA173.prw
@see (links_or_references)
/*/
User Function HCOMA001()

Local aSay      := {}
Local aButton   := {}
Local cCadastro := "TOTVS | Geração Automática de Autorizações de Entregas"
Local lContinua := .F.

    IF Pergunte("HCOMA01",.T.)
        
        AADD(aSay,OemToAnsi("Frase 1"))
        AADD(aSay,OemToAnsi("Frase 2"))
        AADD(aSay,OemToAnsi("Frase 3"))
        AADD(aSay,OemToAnsi("Frase 4"))
        AADD(aSay,OemToAnsi("Frase 5"))

        AADD(aButton, {5,.T.,{|| Pergunte("HCOMA01",.T.) }})
        AADD(aButton, {1,.T.,{|o| lContinua := .T., o:oWnd:End() }})
        AADD(aButton, {2,.T.,{|o| o:oWnd:End() }})

        FormBatch( cCadastro, aSay, aButton,,200,405 )
    
    ENDIF

    IF lContinua
        PROCESSA({|| PROCAEBYCTR() },"Aguarde","Processando..")
    ENDIF

Return


/*/{Protheus.doc} PROCAEBYCTR()
Inicia o processamento dos contratos para geração das AE's
@type  Static Function
@author E. DINIZ [ DS2U ]
@since 12/12/2020
/*/
Static Function PROCAEBYCTR()

Local aCabSC7   := {}
Local aIteSC7   := {}
Local aItem     := {}
Local cAlias    := GetNextAlias()
Local dDataEnt  := CTOD("  /  /  ")
Local nCount    := 0
Local nDay      := 0
Local nQuant    := 0

Private lMsErroAuto := .F.

    BEGINSQL ALIAS cAlias
        SELECT C3_FILIAL, C3_NUM, C3_ITEM
        FROM %Table:SC3%
        WHERE C3_FILIAL = %Exp:FWxFilial("SC3")%                AND
        C3_NUM      BETWEEN %Exp:MV_PAR03% AND %Exp:MV_PAR04%   AND
        C3_PRODUTO  BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02%   AND
        C3_FORNECE  BETWEEN %Exp:MV_PAR07% AND %Exp:MV_PAR09%   AND
        C3_LOJA     BETWEEN %Exp:MV_PAR08% AND %Exp:MV_PAR10%   AND
        C3_DATPRI <= %Exp:DTOS(dDataBase)% AND
        C3_DATPRF >= %Exp:DTOS(dDataBase)% AND
        C3_EMISSAO  BETWEEN %Exp:DTOS(MV_PAR05)% AND %Exp:DTOS(MV_PAR06)%   AND
        (C3_QUANT - C3_QUJE) > 0    AND
        C3_RESIDUO = ' '    AND
        C3_CONAPRO = 'L'    AND
        %NOTDEL%
        ORDER BY C3_NUM, C3_ITEM
    ENDSQL

    IF (cAlias)->(!EOF())
        
        dbEval( {|| nCount++ } )
        ProcRegua(nCount)
        (cAlias)->(dbGoTop())

        BEGIN TRANSACTION 

        dbSelectArea("SC3")
        SC3->(dbSetOrder(1)) //C3_FILIAL+C3_NUM+C3_ITEM

        nDay := MV_PAR12

        WHILE (cAlias)->(!EOF())

            SC3->(dbSetOrder(1))
            IF SC3->(dbSeek((cAlias)->C3_FILIAL + (cAlias)->C3_NUM + (cAlias)->C3_ITEM))

                dDataEnt := CTOD(StrZero(nDay,2) + "/" + StrZero(Month(MonthSum(dDatabase,1)),2) + "/" + Str(Year(MonthSum(dDatabase,1))))
                nQuant := Round(SC3->C3_QUANT / DateDiffMonth(SC3->C3_DATPRF, dDatabase), TamSX3('C7_QUANT')[2])

                IncProc("Gerando AE do Contrato/Item: " + (cAlias)->C3_NUM + "/" + (cAlias)->C3_ITEM)

                While SC3->C3_DATPRF >= dDataEnt

                    // CABEÇALHO DO AUTORIZAÇÃO DE ENTREGA
                    AADD(aCabSC7,{'C7_FORNECE',SC3->C3_FORNECE,Nil})
                    AADD(aCabSC7,{'C7_LOJA',SC3->C3_LOJA,Nil})
                    AADD(aCabSC7,{'C7_COND',SC3->C3_COND,Nil})
                    AADD(aCabSC7,{'C7_CONTATO',SC3->C3_CONTATO,Nil})
                    AADD(aCabSC7,{'C7_FILENT',SC3->C3_FILIAL,Nil})
                    AADD(aCabSC7,{'C7_EMISSAO',dDataBase,Nil})
                    AADD(aCabSC7,{'C7_NUM',GetSX8Num("SC7","C7_NUM"),Nil})

                    //ITEM DA AUTORIZAÇÃO DE ENTREGA
                    AADD(aItem,{'C7_FILIAL',FWxFilial("SC7"),Nil})
                    AADD(aItem,{'C7_ITEM',"0001",Nil})
                    AADD(aItem,{'C7_NUMSC',SC3->C3_NUM,Nil})
                    AADD(aItem,{'C7_ITEMSC',SC3->C3_ITEM,Nil})
                    AADD(aItem,{'C7_PRECO',SC3->C3_PRECO,Nil})
                    AADD(aItem,{'C7_QUANT',nQuant,Nil})
                    AADD(aItem,{'C7_TOTAL',nQuant * SC3->C3_PRECO,Nil})
                    AADD(aItem,{'C7_LOCAL',SC3->C3_LOCAL,Nil})
                    AADD(aItem,{'C7_IPI',SC3->C3_IPI,Nil})
                    AADD(aItem,{'C7_REAJUST',SC3->C3_REAJUST,Nil})
                    AADD(aItem,{'C7_FRETE',SC3->C3_FRETE,Nil})
                    AADD(aItem,{'C7_DATPRF',dDataEnt,Nil})
                    AADD(aItem,{'C7_PRODUTO',SC3->C3_PRODUTO,Nil})
                    AADD(aItem,{'C7_MSG',SC3->C3_MSG,Nil})
                    AADD(aItem,{'C7_TPFRETE',SC3->C3_TPFRETE,Nil})
                    AADD(aItem,{'C7_OBS',SC3->C3_OBS,Nil})
                    AADD(aItem,{'C7_RESIDUO',Space(TamSx3("C7_RESIDUO")[1]),Nil})
                    AADD(aItem,{'C7_QTDSOL',nQuant,Nil})
                    AADD(aItem,{'C7_UM',SC3->C3_UM,Nil})
                    
                    IF !EMPTY(SC3->C3_SEGUM)
                        AADD(aItem,{'C7_QTSEGUM',SC3->C3_QTSEGUM,Nil})
                        AADD(aItem,{'C7_SEGUM',SC3->C3_SEGUM,Nil})
                    ENDIF

                    AADD(aItem,{'C7_TPOP',IIF(MV_PAR11 == 1,'F','P'),Nil})
                    AADD(aItem,{'C7_CONTA',Space(TamSx3("C7_CONTA")[1]),Nil})
                    AADD(aItem,{'C7_CC',SC3->C3_CC,Nil})
                    AADD(aItem,{'C7_QUJE',0,Nil})
                    AADD(aItem,{'C7_DESC1',0,Nil})
                    AADD(aItem,{'C7_DESC2',0,Nil})
                    AADD(aItem,{'C7_DESC3',0,Nil})
                    AADD(aItem,{'C7_EMISSAO',dDataBase,Nil})
                    AADD(aItem,{'C7_EMITIDO',"S",Nil})
                    AADD(aItem,{'C7_QTDREEM',0,Nil})
                    AADD(aItem,{'C7_CODLIB',Space(TamSx3("C7_CODLIB")[1]),Nil})
                    AADD(aItem,{'C7_NUMCOT',Space(TamSx3("C7_NUMCOT")[1]),Nil})
                    AADD(aItem,{'C7_TX',Space(TamSx3("C7_TX")[1]),Nil})
                    AADD(aItem,{'C7_CONTROL',Space(TamSx3("C7_CONTROL")[1]),Nil})
                    AADD(aItem,{'C7_ENCER',Space(TamSx3("C7_ENCER")[1]),Nil})
                    AADD(aItem,{'C7_IPIBRUT',"B",Nil})
                    AADD(aItem,{'C7_TES',Space(TamSx3("C7_TES")[1]),Nil})
                    AADD(aItem,{'C7_VALFRE',SC3->C3_VALFRE,Nil})
                    AADD(aItem,{'C7_MOEDA',SC3->C3_MOEDA,Nil})
					AADD(aItem,{'C7_TXMOEDA',SC3->C3_TXMOEDA,Nil})
					
                    AADD(aIteSC7,aClone(aItem))

                    MSExecAuto({|v,x,y,z| MATA120(v,x,y,z)},2,aCabSC7,aIteSC7,3)

                    If lMsErroAuto
                        RollBackSX8()
                        DisarmTransaction()
						MostraErro()
                        Exit
                    Else
                        ConfirmSx8()
                    Endif

                    dDataEnt := MonthSum(dDataEnt,1)
                    aCabSC7 := {}
                    aIteSC7 := {}
                    aItem   := {}
                
                ENDDO

            ENDIF

            (cAlias)->(dbSkip())

        ENDDO

        END TRANSACTION
    
    ELSE
        
        Help(Nil, Nil, "CTRNEX", Nil, "Nenhum contrato foi encontrado para gerar Autorizações de Entrega", 1, 0, Nil, Nil, Nil, Nil, Nil, {"Revise os parâmetros e os contratos e processe novamente"} )
    
    ENDIF

Return
