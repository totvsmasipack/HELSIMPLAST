#include 'Protheus.ch'

/*/{Protheus.doc} User Function HELETQ02
Função para impressão das etiquetas dos endereços do estoque
@type  Function
@author E.DINIZ [ DS2U ]
@since 17/03/2021
/*/
User Function HELETQ02()

Local aPerg := {}
Local aParam    := {}

    If cEmpAnt == '15'

        AADD(aPerg, {1, 'Cód. Produto', SPACE(TamSX3('B1_COD')[1]), PesqPict('SB1','B1_COD'), ".T.", "SB1", "", 80, .T.})
        AADD(aPerg, {1, 'Quantidade', 0, '@E 9999', ".T.", "", "", 80, .T.})
        
        IF ParamBox(aPerg,'Impressão de Etiquetas por Produto Acabado', aParam)
            PrintProd(aParam)
        EndIf

    Else
        FwAlertWarning('Função disponível na empresa Helsimplast')
    Endif

Return


Static Function PrintProd(aParam)

Local cAlias    := GetNextAlias()
Local nQtd      := aParam[2]
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
            MSCBSAY(05,40,"NUM. OP: ----","N","3","01","01")		
            MSCBSAY(05,33,"PRODUTO: " + ALLTRIM((cAlias)->B1_COD),"N","3","01","01")	
            MSCBSAY(05,27,"DESCRI.: " + SUBSTR(ALLTRIM((cAlias)->B1_DESC),1,35),"N","3","01","01")
            MSCBSAY(05,20,"DATA: " + DTOC(dDataBase) ,"N","3","01","01")
            MSCBSAY(05,13,"OPERADOR: ----" ,"N","3","01","01")
            MSCBSAY(05,06,"QUANTIDADE: " + IIF((cAlias)->B1_QE > 0, Alltrim(Transform((cAlias)->B1_QE,"@E 9,999,999,999")), ''),"N","3","01","01")
            
            MSCBEND()

        Next nX

        MSCBCLOSEPRINTER()

    Endif

    (cAlias)->(dbCloseArea())

Return
