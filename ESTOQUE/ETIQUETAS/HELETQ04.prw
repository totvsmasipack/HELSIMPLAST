#include 'Protheus.ch'

/*/{Protheus.doc} User Function HELETQ04
Função para impressão das etiquetas para MASTER
@type  Function
@author HOZAKI [ DS2U ]
@since 08/02/2024
/*/
User Function HELETQ04()

Local aPerg := {}
Local aParam    := {}

    If cEmpAnt == '15'

        AADD(aPerg, {1, 'Cód. Produto'	, SPACE(TamSX3('B1_COD')[1]), PesqPict('SB1','B1_COD'), ".T.", "SB1", "", 80, .T.})
        AADD(aPerg, {1, 'Quantidade'	, 0							, '@E 9999', ".T.", "", "", 80, .T.})
		AADD(aPerg, {1, 'Fornecedor'	, SPACE(TamSX3('A2_NOME')[1]), '@!', ".T.", "", "", 80, .T.})
        
        IF ParamBox(aPerg,'Impressão de Etiquetas para Master', aParam)
            PrintProd(aParam)
        EndIf

    Else
        FwAlertWarning('Função disponível na empresa Helsimplast')
    Endif

Return


Static Function PrintProd(aParam)

Local cAlias    := GetNextAlias()
Local nQtd      := aParam[2]
Local cFornec	:= aParam[3]
Local nX        := 0

    BEGINSQL ALIAS cAlias
        SELECT *
        FROM %Table:SB1% B1
        WHERE B1_FILIAL = %xFilial:SB1%
        AND B1_COD = %Exp:aParam[1]%
        AND B1.%NOTDEL%
    ENDSQL

    If (cAlias)->(EOF())
        
        FwAlertWarning('Produto não cadastrado')
    
    Else

        MSCBPRINTER("OS 214","LPT1",NIL) 	        		
        MSCBCHKSTATUS(.F.)

        For nX := 1 To nQtd

            MSCBBEGIN(1,4)

            MSCBBOX(03,03,98,46,5)
			//MSCBSAYBAR(70,27,AllTrim((cAlias)->B1_CODBAR),"N","MB07",8.36,.F.,.T.,.F.,,2,1)
            MSCBSAYBAR(60,33,AllTrim((cAlias)->B1_CODBAR),"N","MB07",8.36,.F.,.T.,.F.,,2,1)
            //MSCBSAY(05,40,"NUM. OP: ----","N","3","01","01")		
            MSCBSAY(05,33,"PRODUTO: " + ALLTRIM((cAlias)->B1_COD),"N","3","01","01")	
            MSCBSAY(05,27,"DESCRI.: " + SUBSTR(ALLTRIM((cAlias)->B1_DESC),1,35),"N","3","01","01")
            MSCBSAY(05,20,"DATA: " + DTOC(dDataBase) ,"N","3","01","01")
            MSCBSAY(05,13,"FORNECEDOR: " + AllTrim(cFornec),"N","3","01","01")
            //MSCBSAY(05,13,"QUANTIDADE: " + IIF((cAlias)->B1_QE > 0, Alltrim(Transform((cAlias)->B1_QE,"@E 9,999,999,999")), ''),"N","3","01","01")
            
            MSCBEND()

        Next nX

        MSCBCLOSEPRINTER()

    Endif

    (cAlias)->(dbCloseArea())

Return
