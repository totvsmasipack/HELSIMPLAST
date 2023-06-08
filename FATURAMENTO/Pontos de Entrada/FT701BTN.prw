#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "LOJA701A.CH"
#INCLUDE "MSMGADD.CH"
#INCLUDE "TCBROWSE.CH"



/*/{Protheus.doc} User Function FT701BTN 
    Ponto de entrada para adicionar botão dentro do atendimento do venda assistida.
    https://tdn.totvs.com/pages/releaseview.action?pageId=6784519
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

User Function FT701BTN()

    Local aReturn := {}
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

    
    aReturn := { "Emissao de Nota?", {|| procprod()} }

    //Adiciono opção de reimprimir somente para pedidos finalizados.
    If (!Empty(SL1->L1_DOC) .OR. !Empty(SL1->L1_DOCPED) .OR. !Empty(SL1->L1_PEDRES) ) .AND.  !ALLTRIM(SL1->L1_NSO) == "P3"
        aReturn := { "Reimprimir Cupom", {|| u_HELSR001(1)} }
    Else 
        aReturn := { "Emissao de Nota?", {|| procprod()} }        
    EndIf 

Return aReturn 




Static Function querysra(aCpos)

    Local cQuery := ""
    Local cAlias := GetNextAlias()
    local cDB  := "MSSQL/RH" // alterar o alias/dsn para o banco/conexão que está utilizando
    local cSrv := "localhost" // alterar para o ip do DbAccess
    Local nPort := 6400
    
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
   
    TCUNLink()

Return  




Static Function procprod()

Local nx := 0
Local nPosVlUnit	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VRUNIT"})][2]		// Posicao do Valor unitario do item
Local nLinBkp := n


If MSGNOYES( "Esse processo irá aterar os preços dos produtos para o preço 2.", "Alterar preços?" )
    If Len(aCols) > 0
        For nx := 1 To Len(aCols)
            n := nx
            If aCols[n][nPosVlUnit] > 0
                altpreco()
            EndIf 
        Next nx
    EndIf 
EndIf 
n := nLinBkp

Return 

Static Function altpreco()


Local cSvAlias 		:= Alias()					// Area original
Local nSvRecno 		:= Recno()                	// Recno da area
Local nX 			:= 0						// Usada em lacos For...Next
Local nPosProd		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]	// Posicao da codigo do produto
Local nPosDesc		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_DESC"})][2]		// Posicao do percentual de desconto
Local nPosValDesc	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VALDESC"})][2]	// Posicao do valor de desconto
Local nPosPrcTab	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_PRCTAB"})	// Posicao do preco de tabela
Local nTabela 		:= 1						// Tabela selecionada no browse
Local aTabelas 		:= {}						// Array com as informacoes do TCBROWSE
Local bTabDlbClick	:= {|| }					// Evento do double click
Local lContinua 	:= .F.						// Indica se continua a execucao da funcao
Local lTrcMoeda     := SuperGetMV("MV_TRCMOED",,.T.)											// Indica se permite escolha de moeda
Local lLJ7043			:= ExistBlock("LJ7043")		// Ponto de entrada para validar a tabela de preco selecionada
Local lLJ7044			:= ExistBlock("LJ7044")		// Ponto de entrada para filtrar as tabelas de preco
Local oDlgTabela								// Objeto dialog principal
Local oTabelas									// Objeto Browse com a listagem de tabelas
Local nPosVlUnit	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VRUNIT"})][2]		// Posicao do Valor unitario do item
Local nMoedaPrv     := 1						// Moeda do Preco de Venda
Local nPosCod		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]		// Posicao do codigo do item
Local nPosBico		:= 0
Local cTabAnt		:= cTabPad					// Guarda a Tabela de preco anterior
Local xRet                                      // Retorno dos pontos de entrada
Local lVAssConc     := LjVassConc()				// Indica se o cliente utiliza a Vda Assistida Concomitante
Local lAutoExA		:= IsBlind()				// Verifica se a rotina sera executada via execauto ou nao

Local lFTVD7043		:= ExistBlock("FTVD7043")	// Ponto de entrada para validar a tabela de preco selecionada
Local lFTVD7044		:= ExistBlock("FTVD7044")	// Ponto de entrada para filtrar as tabelas de preco
Local nPrecoTab		:= 0

Local lAlterProd	:= .F.
Local lFtvdVer12	:= LjFTVD()	//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Verica Permissões do Usuário³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
/*
If !(ChkPsw( 32 ))
	Return .F.
Endif

If HasTemplate("PCL")
	nPosBico	:=	aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_BICO"})][2]		// Posicao do bico
	DbSelectArea("LEI")
	LEI->(DbSetOrder(2))

	// Filial + Produto + Bico , usa só o produto pois localizando-o na tabela já é o suficiente para barrar
	If LEI->(MsSeek( xFilial("LEI") + aCols[n][nPosCod] + aCols[n][nPosBico]))
		MsgInfo( STR0084 )//"De acordo com o Requisito XXXV da Legislação PAF-ECF no Ato Cotepe 0608 : Abastecimentos Importados nao podem ter um valor alterado."
		Return .F.
	EndIf
EndIf
*/
//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Monta o array aTabelas                                                   ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ


DbSelectArea("SB0")
DbSetOrder(1)	// Filial + Cod
If MsSeek( xFilial("SB0") + aCols[n][nPosProd] )
    For nX := 1 to 9
        If lLJ7044 .AND. !lFtvdVer12
            xRet := ExecBlock( "LJ7044", .F., .F., {nx} )
            If ValType(xRet) == "L"
                If !xRet
                    Loop
                Endif
            Endif
        Endif

        If lFTVD7044 .AND. lFtvdVer12
            xRet := ExecBlock( "FTVD7044", .F., .F., {nx} )
            If ValType(xRet) == "L"
                If !xRet
                    Loop
                Endif
            Endif
        Endif

        DbSelectArea("SX3")
        DbSetOrder(2)
        // Checar se o campo da tabela de preços esta 'usado' e o nivel do usuario permite ver o campo
        If MsSeek( PadR("B0_PRV"+Str(nX,1,0),10," ") ) .AND. X3Uso(SX3->X3_USADO) .AND. cNivel >= SX3->X3_NIVEL
            If Empty(SB0->&("B0_DATA"+Str(nX,1,0))) .OR. SB0->&("B0_DATA"+Str(nX,1,0)) >= dDatabase
                aAdd( aTabelas, { StrZero(nX,2,0), SB0->&("B0_PRV"+Str(nX,1,0)) } )
                If cPaisLoc <> "BRA"
                    AAdd(aTabelas[Len(aTabelas)],Capital(SuperGetMV("MV_MOEDA"+LTrim(Str(Max(SB0->&("B0_MOEDA"+Str(nX,1,0)),1))))))
                EndIf
            Endif
        Endif
    Next nX
Endif

/*

If Len(aTabelas) > 0

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Desabilita as teclas de atalho                                           ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Lj7SetKeys(.F.)

	DEFINE MSDIALOG oDlgTabela TITLE STR0024	FROM 0,0 TO 14.5,35 OF oDlgVA //"Tabela de Preços"

	oTabelas := TCBROWSE():New(5,5,100,100, Nil, Nil, {30,30}, oDlgTabela, Nil, Nil, Nil, Nil,bTabDlbClick,,,,,,,,, .T. )

	oTabelas:SetArray( aTabelas )
	ADD COLUMN TO oTabelas HEADER STR0025 	OEM DATA {|| aTabelas[oTabelas:nAt,1] } ALIGN LEFT SIZE 30 PIXELS //"Tabela"
	ADD COLUMN TO oTabelas HEADER STR0026 	OEM DATA {|| Transform(aTabelas[oTabelas:nAt,2],PesqPict("SB0","B0_PRV1")) } ALIGN LEFT SIZE 30 PIXELS //"Preço"
	If cPaisLoc <> "BRA"
	   ADD COLUMN TO oTabelas HEADER STR0032 OEM DATA {|| aTabelas[oTabelas:nAt,3] } ALIGN LEFT SIZE 30 PIXELS //"Moeda"
	EndIf
	oTabelas:nFreeze := 1

	DEFINE SBUTTON FROM 006,108 TYPE 1 ACTION (lContinua := .T. , nTabela := Val(aTabelas[oTabelas:nAt,1]) , ;
	                                           oDlgTabela:End()) ENABLE OF oDlgTabela
	DEFINE SBUTTON FROM 020,108 TYPE 2 ACTION (oDlgTabela:End()) ENABLE OF oDlgTabela

	ACTIVATE MSDIALOG oDlgTabela CENTERED

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Habilita as teclas de atalho                                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Lj7SetKeys(.T.)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Ponto de Entrada para validar a tabela de preco selecionada. ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
*/
nTabela := 2
If lContinua .AND. lLJ7043 .AND. !lFtvdVer12
	xRet := ExecBlock( "LJ7043", .F., .F., {nTabela} )
	If ValType(xRet) == "L"
		lContinua := xRet
	Endif
Endif

If lContinua .AND. lFTVD7043 .AND. lFtvdVer12
	xRet := ExecBlock( "FTVD7043", .F., .F., {nTabela} )
	If ValType(xRet) == "L"
		lContinua := xRet
	Endif
Endif


lContinua := .T.
If lContinua
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Ajusta a variavel que indica a tabela padrao                             ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	cTabPad := Str( 2, 1, 0 )

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se e permitido tabela de preco zerada ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If (LjAnalisaLeg(2)[1] .AND. (&("SB0->B0_PRV"+cTabPad)) == 0)
		If !lAutoExA
			LjMsgLeg(LjAnalisaLeg(2))
		EndIf
		cTabPad := cTabAnt
    Else
		If lVAssConc
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ No caso de venda concomitante nao altera o valor do item que ja ³
			//³ foi registrado e somente os proximos a serem registrados 		³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lAutoExA
				MsgAlert(STR0049+Chr(13)+STR0050)	//"Para a venda concomitante a mudanca de preco "##"somente influenciara no registro do próximo item"
			Else
				ConOut(STR0049+Chr(13)+STR0050)	//"Para a venda concomitante a mudanca de preco "##"somente influenciara no registro do próximo item"
			EndIf
		Else
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acerto das colunas da aCols                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aCols[n][nPosVlUnit] 	:= &("SB0->B0_PRV"+cTabPad)
			aCols[n][nPosDesc]		:= 0
			aCols[n][nPosValDesc]	:= 0

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acerto das colunas da aColsDet                                              ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			aColsDet[n][nPosPrcTab] := &("SB0->B0_PRV"+cTabPad)
            /*
			//If lTrcMoeda .AND. !lCenVenda
			nMoedaPrv := Max(&("SB0->B0_MOEDA" + cTabPad),1)
			aCols[n][nPosVlUnit]	:= Round(xMoeda(&("SB0->B0_PRV" + cTabPad), nMoedaPrv, nMoedaCor, dDataBase ,;
			                                         nDecimais+1, NIL, nTxMoeda), nDecimais)
			//EndIf
			*/
            Lj7DefTab(.T.)

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Chama a LJ7VlItem para acerto dos totais na tela                         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			lAlterProd := .T.
			lj7VlItem( Nil, Nil, Nil, Nil, Nil, Nil, Nil, Nil, lAlterProd )
		EndIf
	EndIf
Endif

If !Empty(cSvAlias)
	DbSelectArea(cSvAlias)
	DbGoto(nSvRecno)
EndIf

Return Nil
