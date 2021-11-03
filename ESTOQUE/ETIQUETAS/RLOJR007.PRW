#include 'Protheus.ch'

/*/{Protheus.doc} User Function RLOJR007
Impressão de etiquetas de Ordem de Produção
@type  Function
@author E.DINIZ [ DS2U ]
@since 27/01/2021
/*/
User Function RLOJR007()

Local cTitle	:= "Etiquetas de OP"
Local cPerg		:= "RLOJR007"
Local aSays		:= {}
Local aButtons 	:= {}

    Pergunte(cPerg,.F.)

    AADD(aSays,"Este programa tem por objetivo imprimir as etiquetas de Ordens de Produção,")
	AADD(aSays,"conforme os parâmetros selecionados.")

	AADD(aButtons, {5,.T.,{|| Pergunte(cPerg,.T.)}})
	AADD(aButtons, {1,.T.,{|o| IIF(!EMPTY(MV_PAR02) .And. MV_PAR03 > 0, FWMsgRun(, {|| GeraEtiq() }, "Aguarde", "Gerando etiquetas..."), Nil ) }})
	AADD(aButtons, {2,.T.,{|o| FechaBatch() }})

	FormBatch(cTitle, aSays, aButtons)

Return


/*/{Protheus.doc} GeraEtiq
Função para obter as OP's e imprimir as etiquetas
@type  Static Function
@author E.DINIZ [ DS2U ]
@since 27/01/2021
/*/
Static Function GeraEtiq()

Local cAlias    := GetNextAlias()
Local nCont     := 0

    BEGINSQL ALIAS cAlias
    
    SELECT	C2_NUM + C2_ITEM + C2_SEQUEN AS OP,
    		C2_PRODUTO, B1_DESC, B1_QE
    FROM %Table:SC2% C2, %Table:SB1% B1
    WHERE C2_FILIAL = %xFilial:SC2% AND
    C2_NUM + C2_ITEM + C2_SEQUEN BETWEEN %Exp:MV_PAR01% AND %Exp:MV_PAR02% AND
    C2.%NOTDEL% AND
    B1_FILIAL = C2_FILIAL AND
    B1_COD = C2_PRODUTO AND
    B1.%NOTDEL%

    ENDSQL

    IF (cAlias)->(EOF())
        FwAlertWarning('Ordens de produção não localizadas no parâmetro informado!')
    Else

        MSCBPRINTER("OS 214","LPT1",NIL) 	        		
        MSCBCHKSTATUS(.F.)

        WHILE (cAlias)->(!EOF())

            FOR nCont := 1 To MV_PAR03
                
                MSCBBEGIN(1,4)

                MSCBBOX(03,03,98,46,5)
                MSCBSAY(05,40,"NUM. OP: " + (cAlias)->OP,"N","3","01","01")		
                MSCBSAY(05,33,"PRODUTO: " + ALLTRIM((cAlias)->C2_PRODUTO),"N","3","01","01")	
                MSCBSAY(05,27,"DESCRI.: " + SUBSTR(ALLTRIM((cAlias)->B1_DESC),1,35),"N","3","01","01")
                MSCBSAY(05,20,"DATA: _____/" + StrZero(MONTH(dDataBase),2) + "/" + cValToChar(YEAR(dDataBase)) ,"N","3","01","01")
                MSCBSAY(05,13,"OPERADOR: " ,"N","3","01","01")
                MSCBSAY(05,06,"QUANTIDADE: " + IIF((cAlias)->B1_QE > 0, Transform((cAlias)->B1_QE,"@E 9,999,999,999"), ''),"N","3","01","01")
                
                MSCBEND()

            Next nCont

            (cAlias)->(dbSkip())
        
        ENDDO

        MSCBCLOSEPRINTER()

    Endif

    (cAlias)->(dbCloseArea())

Return
