#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} User Function LJ140VLC
    Fun��o do PONTO DE ENTRADA LJ140VLC - Validar se a venda poder� ser cancelada/exclu�da
    - Customiza��o para chamar tela de autentica��o de um Superior, para autorizar a exclus�o
    @type  User Function
    @author R.Garcia (DS2U)
    @since 13/03/2024
    @version version    
/*/

User Function LJ140VLC()
Local lRetorno   := .T.
Local lParamet   := SuperGetMV("MV_XVEREXC",,.T.)	// Parametro que determnina se usa a rotina ou nao
Private cNomeSup := ""

IF lParamet
    lRetorno := LjValSup()

    IF(lRetorno)
        DbSelectArea('SL1')
        SL1->( DbSetOrder(1) )
        IF SL1->(DbSeek(xFilial("SL1")+SL1->L1_NUM))
        IF Reclock("SL1",.F.)
                SL1->L1_XRESEXC := cNomeSup
                SL1->L1_XDTEXCL := dDataBase
                SL1->(MSUNLOCK())
                lRetorno := .T.
            ELSE
                lRetorno := .F.
            ENDIF
        ENDIF
    ENDIF
ELSE
    lRetorno := .F.
ENDIF

Return lRetorno
/*
    Statica function LjValSup
    Rotina de criar tela de autentica��o do superior 
    @author R.Garcia (DS2U)
    @since 13/03/2024
    @version version  
*/
static function LjValSup()
Local aUsers	    := {}
Local aCodSup	    := LjRetSup(1,"",@aUsers)
Local cCodSup	    := ""
Local cSuperSel	    := ""
Local lRet  	    := .T.
Local cBkReadVar    := ""
Local cIDSel	    := ""	

cCodSup	:= LjSelSup( aCodSup , @cSuperSel, aUsers )
cBkReadVar := ReadVar()	// Backup da variavel __ReadVar, pois a qdo. chamada a funcao "FWAuthSuper" o conteudo da variavel __ReadVar eh modificado para "CUSERLOGIN"

If FWAuthSuper(@cIDSel, @cSuperSel)
    cNomeSup := AllTrim(cSuperSel)
    lRet := .T.
Else
    lRet := .F.
EndIf

If !Empty(cBkReadVar)
    __ReadVar := cBkReadVar //Restaura o conteudo da variavel "__Readvar"
EndIf
    
Return lRet
