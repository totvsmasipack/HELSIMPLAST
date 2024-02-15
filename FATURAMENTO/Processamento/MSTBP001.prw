#INCLUDE "protheus.ch"
#INCLUDE 'TOPCONN.CH'

/*/{Protheus.doc} MSTBMEN1
    Function usada para chamada via menu
    @type  Function
    @author Raphael
    @since 14/12/2023
    @version 01   
/*/
User Function MSTBMEN1()

    //Pergunte("")
    Processa( {|| U_MSTBP001() }, "Aguarde...", "Criando Pedido de Venda...",.T.) 

Return NIL

/*/{Protheus.doc} MSTBP001
    (long_description)
    @type  Function - 
    @author R. GARCIA (DS2U)
    @since 11/01/2024
    @version version 01    
/*/
User Function MSTBP001()
    Local cQueryPA  := ""
    Local cQuery    := ""
    Local aLiItem   := {}
    Local aItemPV   := {}
    Local cAlias    := GetNextAlias()
    Local cAliasPA  := GetNextAlias()
    Local cTes      := SUPERGETMV( 'ES_TSM410P', , '885',  )  
    Local cCodCli   := "000001"
    Local cLojCli   := "00"
    Local nItem     := 1
    Local nQtdP     := 0
    Local nQtdPA    := 0
    Local nVlrExe   := 0
    Local lConti    := .T.
    Local dDtEntre 

    Local aLogAuto := {}
    Local cLogTxt  := ""
    Local cArquivo := ""
    Local nAux     := 0
    Local lSucesso := .T.
    Local cNumOk   := ""

    Private lMSHelpAuto     := .T.
    Private lAutoErrNoFile  := .T.
    Private lMsErroAuto     := .F.
    //Adiciona os Itens no Cabeçalho do Pedido
    aCabPV := {}
    dDataEntrega = Daysum(Date(), 1) 

    cQuery := " SELECT SB1.B1_COD "
    cQuery += ", SB1.B1_DESC "
    cQuery += ", SB2.B2_QATU "
    cQuery += ", SB1.B1_ESTOMAX "
    cQuery += ", SB1.B1_UM "
    cQuery += ", SB1.B1_TIPO "
    cQuery += ", SB0.B0_PRV1 "
    cQuery += ", SB1.B1_GRUPO "
    cQuery += ", SBM.BM_XDEP "
    cQuery += ", SB2.B2_VATU1 "
    cQuery += ", SB2.B2_LOCAL "
    cQuery += " FROM " + RetSqlName("SB1") + " SB1 "
    cQuery += " INNER JOIN " + RetSqlName("SBm") + " SBM ON SBM.D_E_L_E_T_ = '' AND BM_FILIAL = '"+xFilial("SBM")+"' AND BM_GRUPO = B1_GRUPO AND BM_XDEP <> '' "
    cQuery += " INNER JOIN " + RetSqlName("SB2") + " SB2 "+ " ON SB1.B1_COD  = SB2.B2_COD "
    cQuery += " AND B2_FILIAL = '"+xFilial("SB2")+"'"
    cQuery += " AND (SB1.B1_ESTOMIN > 0 AND SB1.B1_ESTOMAX > 0) "
    cQuery += " AND SB1.D_E_L_E_T_=' ' and SB2.D_E_L_E_T_=' '"
    cQuery += " AND SB2.B2_QATU <= SB1.B1_ESTOMIN "
    cQuery += " AND ( SB2.B2_LOCAL = '50' ) "
    cQuery += " INNER JOIN SB0150 SB0  ON SB0.D_E_L_E_T_ = '' AND B0_FILIAL = B2_FILIAL AND SB0.B0_COD = SB1.B1_COD "
    cQuery += " ORDER BY BM_XDEP "

    cQuery := ChangeQuery(cQuery)
    TcQuery cQuery New Alias (cAlias) 
    DbSelectArea(cAlias)
    DbSelectArea('SB1')

    AAdd(aCabPV,{"C5_TIPO"   , "N"     , Nil})
    AAdd(aCabPV,{"C5_CLIENTE", cCodCli , Nil})
    AAdd(aCabPV,{"C5_LOJACLI", cLojCli , Nil})
    AAdd(aCabPV,{"C5_CLIENT" , cCodCli , Nil})
    AAdd(aCabPV,{"C5_LOJAENT", cLojCli , Nil})

    AAdd(aCabPV,{"C5_TIPOCLI", Posicione("SA1", 1, xFilial("SA1") + cCodCli + cLojCli, "A1_TIPO"), Nil})
    AAdd(aCabPV,{"C5_CONDPAG", "001"        , Nil}) 
    AAdd(aCabPV,{"C5_NATUREZ", "V04.3     " , Nil}) 
    AAdd(aCabPV,{"C5_EMISSAO", dDataBase    , Nil})
    AAdd(aCabPV,{"C5_MOEDA"  , 1            , Nil})
    AAdd(aCabPV,{"C5_VEND1"  , "000001"     , Nil})  
    AAdd(aCabPV,{"C5_TRANSP" ,"000001"      , Nil})
    AAdd(aCabPV,{"C5_TPFRETE" ,"F"          , Nil})
    AAdd(aCabPV,{"C5_ESPECI1" ,"CAIXA"      , Nil})     
    
    //Montagem de item...]
    nCont := 0
    cGrupo := ""
    dDtEntre := Daysum(Date(), 1)
    While (cAlias)->(!EOF()) 

        nQtdP   := (cAlias)->B1_ESTOMAX  - IIF( (cAlias)->B2_QATU < 0,  (cAlias)->B2_QATU * -1, (cAlias)->B2_QATU )

        cQueryPA := " SELECT C6_QTDENT "
        cQueryPA += ", C6_QTDVEN"
        cQueryPA += ", C6_CLI"        
        cQueryPA += " FROM " + RetSqlName("SC6") + " SC6 "
        cQueryPA += " WHERE C6_QTDVEN > C6_QTDENT "
        cQueryPA += " AND C6_PRODUTO = '" + Alltrim((cAlias)->B1_COD) + "'"
        cQueryPA += " AND C6_TES = '" + cTes + "'" 
        cQueryPA += " AND C6_CLI = '" + cCodCli + "'"         
        cQueryPA := ChangeQuery(cQueryPA)

        If Select(cAliasPA) > 0
            dbSelectArea(cAliasPA)
            dbCloseArea()
        EndIf

        TcQuery cQueryPA New Alias (cAliasPA) 
        DbSelectArea(cAliasPA)
        
        IF (cAliasPA)->(!EOF()) 
            nQtdPA := ( (cAliasPA)->C6_QTDVEN - (cAliasPA)->C6_QTDENT )
            IF( nQtdPA < nQtdP)
                nQtdP  := nQtdP - nQtdPA 
                lConti := .T.
            ELSE
                lConti := .F.
            ENDIF
        ENDIF
        
        If lConti

            IF (cAlias)->B2_VATU1 == 0 
                nVlrExe := ( Posicione('SB0',1,xfilial('SB0')+(cAlias)->B1_COD, 'B0_PRV1') * nQtdP )
            ELSE 
                nVlrExe := ( Posicione('SB0',1,xfilial('SB0')+(cAlias)->B1_COD, 'B0_PRV1') * nQtdP ) //(cAlias)->B2_VATU1
            ENDIF

            AAdd(aLiItem,{"C6_ITEM"   ,StrZero(nItem,2)                                                     ,Nil})
            AAdd(aLiItem,{"C6_PRODUTO",Alltrim((cAlias)->B1_COD)                                            ,Nil})
            AAdd(aLiItem,{"C6_DESCRI" ,Alltrim((cAlias)->B1_DESC)                                           ,Nil})
            AAdd(aLiItem,{"C6_UM"     ,(cAlias)->B1_UM                                                      ,Nil})
            AAdd(aLiItem,{"C6_QTDVEN" ,nQtdP                                                                ,Nil})
            AAdd(aLiItem,{"C6_PRCVEN" ,Posicione('SB0',1,xfilial('SB0')+(cAlias)->B1_COD, 'B0_PRV1')        ,Nil})  //(cAlias)->B1_PRV1 //
            AAdd(aLiItem,{"C6_PRUNIT" ,0                                                                    ,Nil})
            AAdd(aLiItem,{"C6_LOCAL"  ,(cAlias)->B2_LOCAL                                                   ,Nil})
            AAdd(aLiItem,{"C6_CLI"    ,cCodCli                                                              ,nil})
            AAdd(aLiItem,{"C6_LOJA"   ,cLojCli                                                              ,Nil})
            AAdd(aLiItem,{"C6_ENTREG" ,dDtEntre                                                             ,Nil})
            AAdd(aLiItem,{"C6_SUGENTR",dDtEntre                                                             ,Nil})
            AAdd(aLiItem,{"C6_PEDCLI" ,""                                                                   ,Nil})
            AAdd(aLiItem,{"C6_TES"    ,cTes                                                                 ,Nil})
            AAdd(aLiItem,{"C6_QTDLIB" ,nQtdP                                                                ,Nil})
            AAdd(aLiItem,{"C6_VALOR"  ,nVlrExe                                                              ,Nil})

            nQtdP := 0
            nItem := nItem + 1
        ENDIF

        cGrupo  := (cAlias)->BM_XDEP//(cAlias)->B1_GRUPO 
        

        (cAlias)->(DbSkip())
        
        If lConti
            AAdd(aItemPV,AClone(aLiItem))
            aLiItem := {}
            //IF cGrupo <> (cAlias)->B1_GRUPO // verifica se o grupo é diferente do proximo registro, para rodar o execAuto por Grupo 
            IF cGrupo <> (cAlias)->BM_XDEP // verifica se o grupo é diferente do proximo registro, para rodar o execAuto por Grupo 
                
                If Len(aCabPv) > 0 .And. Len(aItemPV) > 0        
                    lMSErroAuto := .F.
                    lSucesso := .T.
                    MSExecAuto({|x,y,z|Mata410(x,y,z)}, aCabPV, aItemPV, 3) //adiciona pedido de vendas    

                    If lMsErroAuto 
                        lSucesso := .F.
                        aLogAuto := GetAutoGRLog() 
                        For nAux := 1 To Len(aLogAuto)
                            cLogTxt += aLogAuto[nAux] + CRLF
                        Next

                        cArquivo := "C:\temp\log_erro_MATA410_" + dToS(Date()) + "_" + cValToChar(SECONDS()) + ".txt"
                        MemoWrite(cArquivo, cLogTxt)
                   // Else  
                     // // MSGINFO( 'Tranferência de produtos para a loja realizada com sucesso', 'Transferência para loja' )
                    EndIf

                    IF lSucesso
                        IF cNumOk == ""
                            cNumOk :=  SC5->C5_NUM 
                        ELSE
                            cNumOk := ", " + SC5->C5_NUM 
                        ENDIF
                    ENDIF

                    
                   aItemPV := {}
                Endif
            ENDIF
        ELSE 
            lConti := .T.
        ENDIF
    EndDo

    IF cNumOk <> ""
        MSGALERT("PEDIDO GERADO",cNumOk)
        cArquivo := "C:\temp\log_ok_MATA410_" + dToS(Date()) + "_" + cValToChar(SECONDS()) + ".txt"
        MemoWrite(cArquivo, "Pedido de venda gerado com sucesso - NUMERO(S): " +  cNumOk )
    ENDIF
RETURN 
