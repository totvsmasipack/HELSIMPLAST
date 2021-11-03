#include 'protheus.ch'
#include 'totvs.ch'

/*/{Protheus.doc} User Function HELETQ01
Fun��o para impress�o das etiquetas dos endere�os do estoque
@type  Function
@author E.DINIZ [ DS2U ]
@since 17/03/2021
/*/
User Function HELETQ01()

Local aPerg := {}
Local aParam    := {}

    AADD(aPerg, {1, 'Endere�o Inicial', SPACE(15), PesqPict('SBE','BE_LOCALIZ'), ".T.", "SBE", "", 80, .T.})
    AADD(aPerg, {1, 'Endere�o Final',   SPACE(15), PesqPict('SBE','BE_LOCALIZ'), ".T.", "SBE", "", 80, .T.})

    IF ParamBox(aPerg,'Impress�o de Etiquetas por Endere�o', aParam)
        PrintLocaliz(aParam)
    EndIf

Return

/*/{Protheus.doc} User Function PrintLocaliz
Dispara consulta ao banco para impress�o dos endere�os
@type  Static Function
@author E.DINIZ [ DS2U ]
@since 17/03/2021
/*/
Static Function PrintLocaliz(aParam)

Local cAlias    := GetNextAlias()

    BEGINSQL ALIAS cAlias
        SELECT BE_LOCALIZ
        FROM %Table:SBE% BE
        WHERE BE_FILIAL = %xFilial:SBE%
        AND BE_LOCALIZ BETWEEN %Exp:aParam[1]% AND %Exp:aParam[2]%
        AND BE.%NOTDEL%
    ENDSQL

    If (cAlias)->(EOF())
        
        FwAlertWarning('Endere�os n�o cadastrados!')
    
    Else
        
        MSCBPRINTER("OS 214","LPT1",NIL) 	        		
        MSCBCHKSTATUS(.F.)
        While (cAlias)->(!EOF())

            MSCBBEGIN(1,4)
            MSCBSAYBAR(10, 11, AllTrim((cAlias)->BE_LOCALIZ), "N", "MB07", 25,.F.,.F.,.F.,,5,5,.F.,.F.,"1",.T.)
            MSCBSAY(40, 06, AllTrim((cAlias)->BE_LOCALIZ), "N", "3", "01", "01")
            MSCBEND()

            (cAlias)->(dbSkip())

        Enddo  
        MSCBCLOSEPRINTER()  
    
    Endif

    (cAlias)->(dbCloseArea())

Return
