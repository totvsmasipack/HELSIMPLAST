#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} HELSP005
    (long_description)
    @type  Function - Usada para verifica��o se usuario � o mesmo que o do BANCO 
    PE que chamam, s�o - LJ260ABR e LJ260FEC
    @author R. GARCIA (DS2U)
    @since 08/11/2023
    @version version 01    
/*/
User Function HELSP005(cTipo)

    Local lRet     := .T.  
    Local cPcNome  := SA6->A6_XPCNOM
    Local _cMsg    := ""
    
    Default cTipo := ""
    /*
     SE NOME DO DISPOSITIVO (COMPUTADOR) DO USUARIO FOR DIFERENTE DO BANCO SELECIONADO, 
        N�O PERMITIR ABERTURA E NEM FECHAMENTO
    */
    IF AllTrim(ComputerName()) <> AllTrim(cPcNome) 
        IF cTipo == "AF"
            _cMsg := " Abrir/Fechar esse Caixa"
        ELSE
            _cMsg := " Incluir/Fechar Vendas"
        ENDIF
        MsgAlert( "Dispositivo " + ComputerName() + " sem permiss�o <br> para " +_cMsg + " nesse Caixa" )
        lRet := .F.
    ENDIF
    IF cTipo == "AF"
        If !(Alltrim(cUserName) == Alltrim(SA6->A6_NOME))
            MsgAlert( "Usuario " + Alltrim(cUserName)  + " sem permiss�o <br> para Abrir/Fechar o caixa " + Alltrim(SA6->A6_NOME) + " ." )
            lRet := .F.
        EndIf
    EndIf 

Return lRet

