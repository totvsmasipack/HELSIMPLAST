#include 'Protheus.ch'

/*/{Protheus.doc} User Function MC030PRD
Ponto de Entrada para adicionar Linhas no a Header do MATC030 (KARDEX DIARIO)
https://tdn.totvs.com/pages/releaseview.action?pageId=6087671
@type  Function
@author [ DS2U ]
@since 11/04/2024
/*/

User Function MC030PRD()

Local aRetCabec := {}
Local cMens     := ""
Local _aArea    := GetArea()

If SubStr(cNumEmp,1,2) $ "15"  //MASITUBOS 

    If Empty(cMens := Posicione( "SB1",1,xFilial("SB1")+SD3->D3_COD,"B1_LOCAL" ))
        cMens := "Atualizar o Cadastro"
    EndIf

    AADD(aRetCabec,'Local de Guarda : ' + cMens )
EndIf

RestArea(_aArea)

Return aRetCabec  
