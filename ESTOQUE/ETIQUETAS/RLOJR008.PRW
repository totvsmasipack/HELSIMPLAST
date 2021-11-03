#include 'Protheus.ch'

/*/{Protheus.doc} User Function RLOJR008
Impressão de etiquetas de Materia-Prima
@type  Function
@author E.DINIZ [ DS2U ]
@since 27/01/2021
/*/
User Function RLOJR008()

Local cTitle	:= "Etiquetas de Matéria-Prima"
Local cPerg		:= "RLOJR008"
Local aSays		:= {}
Local aButtons 	:= {}

    Pergunte(cPerg,.F.)

    AADD(aSays,"Este programa tem por objetivo imprimir as etiquetas de Matéria-Prima vinculado à NF de compra,")
	AADD(aSays,"conforme os parâmetros selecionados.")

	AADD(aButtons, {5,.T.,{|| Pergunte(cPerg,.T.)}})
	AADD(aButtons, {1,.T.,{|o| IIF(!EMPTY(MV_PAR01) .And. !EMPTY(MV_PAR02) .And. !EMPTY(MV_PAR03) .And. !EMPTY(MV_PAR04) .And. !EMPTY(MV_PAR06) .And. MV_PAR07 > 0, FWMsgRun(, {|| GeraEtiq() }, "Aguarde", "Gerando etiquetas..."), Nil ) }})
	AADD(aButtons, {2,.T.,{|o| FechaBatch() }})

	FormBatch(cTitle, aSays, aButtons)

Return


/*/{Protheus.doc} GeraEtiq
Função para obter as NF's e imprimir as etiquetas
@type  Static Function
@author E.DINIZ [ DS2U ]
@since 27/01/2021
/*/
Static Function GeraEtiq()

Local cAlias    := GetNextAlias()
Local nCont     := 0

    BEGINSQL ALIAS cAlias

        SELECT	D1_DOC, D1_SERIE, D1_FORNECE, D1_LOJA, A2_NOME,
                D1_COD, B1_DESC, D1_QUANT, D1_LOTEFOR
        FROM	%Table:SD1% D1, %Table:SB1% B1, %Table:SA2% A2
        WHERE	D1_FILIAL   = %xFilial:SD1%  AND
                D1_DOC      = %Exp:MV_PAR01% AND
                D1_SERIE    = %Exp:MV_PAR02% AND
                D1_FORNECE  = %Exp:MV_PAR03% AND
                D1_LOJA     = %Exp:MV_PAR04% AND
                D1_ITEM BETWEEN %Exp:MV_PAR05% AND %Exp:MV_PAR06% AND
                D1.%NOTDEL%                  AND
                B1_FILIAL = D1_FILIAL        AND
                B1_COD = D1_COD              AND
                B1.%NOTDEL%                  AND
                A2_FILIAL   = %xFilial:SA2%  AND
                A2_COD      = D1_FORNECE     AND
                A2_LOJA     = D1_LOJA        AND
                A2.%NOTDEL%
    ENDSQL

    IF (cAlias)->(EOF())
        FwAlertWarning('NFs não localizadas no parâmetro informado!')
    Else

        MSCBPRINTER("OS 214","LPT1",NIL) 	        		
        MSCBCHKSTATUS(.F.)

        WHILE (cAlias)->(!EOF())

            FOR nCont := 1 To MV_PAR07
                
                MSCBBEGIN(1,4)

                MSCBBOX(03,03,98,46,5)
                MSCBSAY(31,40,"IDENT. MATERIA PRIMA","N","3","01","01")		
                MSCBSAY(05,33,"NF/SERIE: " + ALLTRIM((cAlias)->(D1_DOC +'/'+ D1_SERIE)),"N","3","01","01")
                MSCBSAY(05,27,"FORN.: " + (cAlias)->(D1_FORNECE +'/'+ D1_LOJA) + ' ' + SUBSTR(ALLTRIM((cAlias)->A2_NOME),1,28),"N","3","01","01")
                MSCBSAY(05,20,"PRODUTO: " + (cAlias)->D1_COD ,"N","3","01","01")
                IF !EMPTY((cAlias)->D1_LOTEFOR)
                    MSCBSAY(53,20,"LOTE FORN: " + ALLTRIM((cAlias)->D1_LOTEFOR),"N","3","01","01")	
                ENDIF
                MSCBSAY(05,13,"DESCR.: " + (cAlias)->B1_DESC,"N","3","01","01")
                MSCBSAY(05,06,"QTDE.: " + cValToChar(NoRound((cAlias)->D1_QUANT)),"N","3","01","01")
                
                MSCBEND()

            Next nCont

            (cAlias)->(dbSkip())
        
        ENDDO

        MSCBCLOSEPRINTER()

    Endif

    (cAlias)->(dbCloseArea())

Return
