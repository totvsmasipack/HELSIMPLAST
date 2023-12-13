 
#INCLUDE "TOTVS.CH"
#INCLUDE"TOPCONN.CH"
#INCLUDE "TBICONN.CH"

User Function uHELSP06()
    StartJob("u_HELSP006",GetEnvServer(),.T.,{"15","01"})
return
/*/{Protheus.doc} HELSP006
Função a ser executada por um schedule
@type  Function
@author DS2U(FC)
@since 20/11/2023
@version 1.0
/*/
User Function HELSP006(aParam)
    Local lRet := .T.
    Default aParam := NIL

    If aParam <> Nil
        Reset Environment
        RPCSETTYPE(3)
        RpcSetEnv(aParam[1] ,aParam[2])
        
        //CHECA PROPOSTAS IMPLANTADAS PARA GERAR PROVISÕES
        PROCMTRH()

        RpcClearEnv()
    elseif (!IsBlind())
        PROCMTRH()
	EndIf

Return lRet

 
 /*/{Protheus.doc} User Function PROCMTRH
    Função para gravar as matriculas dos funcionarios no cadastro da Loja.
    @type  Function
    @author user
    @since 20/11/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
 Static Function PROCMTRH()

    Local aCpos   := {}
    Local nx      := 0

    DbSelectArea("ZZ3")
    ZZ3->(DbSetOrder(1))
    ZZ3->(DbGoTop())

    If ZZ3->ZZ3_DTCARG != Date()
        
        querysra(@aCpos)

        If Len(aCpos) > 0
            DbSelectArea("ZZ3")
            ZZ3->(DbSetOrder(1))
            ZZ3->(DbGoTop())
            For nx := 1 To Len(aCpos)
                IF !(ZZ3->(MsSeek(xFilial("ZZ3")+aCpos[nx][1] + aCpos[nx][2])))
                    If RecLock("ZZ3",.T.)
                        ZZ3->ZZ3_FILIAL  := xFilial("ZZ3")
                        ZZ3->ZZ3_CODEMP  := aCpos[nx][1]
                        ZZ3->ZZ3_MAT     := aCpos[nx][2]
                        ZZ3->ZZ3_NOME    := aCpos[nx][3]
                        ZZ3->ZZ3_EMPRES  := aCpos[nx][4]
                        ZZ3->ZZ3_DTCARG  := Date()
                        ZZ3->ZZ3_CHAVE   := aCpos[nx][1] + aCpos[nx][2]
                        ZZ3->ZZ3_DEPTO   := aCpos[nx][5]
                        ZZ3->ZZ3_DPTODE  := aCpos[nx][6]
                        ZZ3->(MSUNLOCK())
                    EndIf 
                Else 
                    If RecLock("ZZ3",.F.)
                        ZZ3->ZZ3_DTCARG  := Date()
                        ZZ3->(MSUNLOCK())
                    EndIf 
                EndIf 
            Next nx  
        EndIf 
    EndIf 


 Return 

/*/{Protheus.doc} Static Function querysra 
    Função que Processa query no banco do ambiente de RH
    @type  Function
    @author Fernando Corrèa (DS2U)
    @since 26/04/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function querysra(aCpos)

    Local cQuery := ""
    Local cAlias := GetNextAlias()
    local cDB  := "MSSQL/RH" // alterar o alias/dsn para o banco/conexão que está utilizando
    local cSrv := "localhost" // alterar para o ip do DbAccess
    Local nPort := 6300
    
    nHwnd := TCLink(cDB, cSrv, nPort)
    
    if nHwnd >= 0
        
        cQuery := " SELECT '01' AS COD_EMP,'MASIPACK' AS EMPRESA, RA_FILIAL, RA_MAT, RA_NOME, RA_DEPTO, QB_DESCRIC " + CRLF
        cQuery += " FROM SRA010 SRA " + CRLF
        cQuery += " LEFT JOIN SQB010 SQB " + CRLF
	    cQuery += " ON QB_FILIAL = '' AND QB_DEPTO = RA_DEPTO AND SQB.D_E_L_E_T_ = '' " + CRLF
        cQuery += " WHERE SRA.D_E_L_E_T_ = '' " + CRLF

        cQuery += " union all " + CRLF

        cQuery += " SELECT  '10' AS COD_EMP, 'FABRIMA'   AS EMPRESA, RA_FILIAL, RA_MAT, RA_NOME, RA_CC AS 'RA_DEPTO', CTT_DESC01 QB_DESCRIC " + CRLF
        cQuery += " 	FROM SRA100 SRA " + CRLF
         cQuery += "LEFT JOIN CTT100 CTT " + CRLF
        cQuery += "ON CTT_FILIAL = RA_FILIAL AND CTT_CUSTO = RA_CC AND CTT.D_E_L_E_T_ = '' " + CRLF
        cQuery += " WHERE SRA.D_E_L_E_T_ = '' " + CRLF

        cQuery += " union all " + CRLF

        cQuery += " SELECT  '15' AS COD_EMP, 'MASITUBOS'  AS EMPRESA, RA_FILIAL, RA_MAT, RA_NOME, RA_CC AS 'RA_DEPTO', CTT_DESC01 QB_DESCRIC" + CRLF
        cQuery += " 	FROM SRA150 SRA " + CRLF
         cQuery += "LEFT JOIN CTT150 CTT " + CRLF
        cQuery += "ON CTT_FILIAL = RA_FILIAL AND CTT_CUSTO = RA_CC AND CTT.D_E_L_E_T_ = '' " + CRLF
        cQuery += " WHERE SRA.D_E_L_E_T_ = '' " + CRLF

        cQuery += " union all " + CRLF

        cQuery += " SELECT '25' AS COD_EMP, 'CASA HELSIM'  AS EMPRESA, RA_FILIAL, RA_MAT, RA_NOME, RA_CC AS 'RA_DEPTO', CTT_DESC01 QB_DESCRIC  " + CRLF
        cQuery += " 	FROM SRA250 SRA " + CRLF
         cQuery += "LEFT JOIN CTT250 CTT " + CRLF
        cQuery += "ON CTT_FILIAL = RA_FILIAL AND CTT_CUSTO = RA_CC AND CTT.D_E_L_E_T_ = '' " + CRLF
        cQuery += " WHERE SRA.D_E_L_E_T_ = '' " + CRLF

        cQuery += " union all " + CRLF

        cQuery += " SELECT  '55' AS COD_EMP, 'TERCEIROS'  AS EMPRESA, RA_FILIAL, RA_MAT, RA_NOME, RA_CC AS 'RA_DEPTO', CTT_DESC01 QB_DESCRIC " + CRLF
        cQuery += "FROM SRA550 SRA  " + CRLF
        cQuery += "LEFT JOIN CTT550 CTT " + CRLF
        cQuery += "ON CTT_FILIAL = RA_FILIAL AND CTT_CUSTO = RA_CC AND CTT.D_E_L_E_T_ = '' " + CRLF
        cQuery += " WHERE SRA.D_E_L_E_T_ = ''  " + CRLF

        //--Cria uma tabela temporária com as informações da query				
        dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cAlias,.F.,.T.)

        While (cAlias)->(!Eof())
            aAdd(aCpos,{(cAlias)->COD_EMP, (cAlias)->RA_MAT, (cAlias)->RA_NOME, (cAlias)->EMPRESA, (cAlias)->RA_DEPTO,  (cAlias)->QB_DESCRIC})
            (cAlias)->(dbSkip())
        End 
                                   
        (cAlias)->(DbCloseArea())

    endif
   
    TCUNLink(nHwnd)

Return  
