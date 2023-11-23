#INCLUDE "PROTHEUS.CH"
#INCLUDE "TOTVS.CH"
#INCLUDE "LOJA701A.CH"
#INCLUDE "MSMGADD.CH"
#INCLUDE "TCBROWSE.CH"

/*/{Protheus.doc} User Function FT701BTN 
    Ponto de entrada para adicionar bot�o dentro do atendimento do venda assistida.
    https://tdn.totvs.com/pages/releaseview.action?pageId=6784519
    @type  Function
    @author Fernando Corr�a (DS2U)
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
       
    //Adiciono op��o de reimprimir somente para pedidos finalizados.
    If (!Empty(SL1->L1_DOC) .OR. !Empty(SL1->L1_DOCPED) .OR. !Empty(SL1->L1_PEDRES) ) .AND.  !ALLTRIM(SL1->L1_NSO) == "P3"
        aReturn := { "Reimprimir Cupom", {|| u_HELSR001(1)} }
    Else 
        aReturn := { "Emissao de Nota?", {|| procprod()} }        
    EndIf 

Return aReturn 

/*/{Protheus.doc} procprod
    Fun��o para exibir mensagem de desi��o sobre altera��o de pre�o
    @type  Static Function
    @author DS2U (Fernando Corr�a)
    @since 20/11/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

Static Function procprod()

Local nx := 0
Local nPosVlUnit	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VRUNIT"})][2]		// Posicao do Valor unitario do item
Local nLinBkp := n


If MSGNOYES( "Esse processo ir� aterar os pre�os dos produtos para o pre�o 2.", "Alterar pre�os?" )
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

/*/{Protheus.doc} procprod
    Fun��o que altera o pre�o de todos os itens do pedido para o pre�o 2 da tabela
    @type  Static Function
    @author DS2U (Fernando Corr�a)
    @since 20/11/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

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
Local lFtvdVer12	:= LjFTVD()	//Verifica se � Release 11.7 e o FunName � FATA701 - Compatibiliza��o Venda Direta x Venda Assisitida


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
        // Checar se o campo da tabela de pre�os esta 'usado' e o nivel do usuario permite ver o campo
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

//��������������������������������������������������������������Ŀ
//� Ponto de Entrada para validar a tabela de preco selecionada. �
//����������������������������������������������������������������
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
	//��������������������������������������������������������������������������Ŀ
	//� Ajusta a variavel que indica a tabela padrao                             �
	//����������������������������������������������������������������������������
	cTabPad := Str( 2, 1, 0 )

	//��������������������������������������������������
	//� Verifica se e permitido tabela de preco zerada �
	//��������������������������������������������������
	If (LjAnalisaLeg(2)[1] .AND. (&("SB0->B0_PRV"+cTabPad)) == 0)
		If !lAutoExA
			LjMsgLeg(LjAnalisaLeg(2))
		EndIf
		cTabPad := cTabAnt
    Else
		If lVAssConc
			//�����������������������������������������������������������������Ŀ
			//� No caso de venda concomitante nao altera o valor do item que ja �
			//� foi registrado e somente os proximos a serem registrados 		�
			//�������������������������������������������������������������������
			If !lAutoExA
				MsgAlert(STR0049+Chr(13)+STR0050)	//"Para a venda concomitante a mudanca de preco "##"somente influenciara no registro do pr�ximo item"
			Else
				ConOut(STR0049+Chr(13)+STR0050)	//"Para a venda concomitante a mudanca de preco "##"somente influenciara no registro do pr�ximo item"
			EndIf
		Else
			//��������������������������������������������������������������������������Ŀ
			//� Acerto das colunas da aCols                                              �
			//����������������������������������������������������������������������������
			aCols[n][nPosVlUnit] 	:= &("SB0->B0_PRV"+cTabPad)
			aCols[n][nPosDesc]		:= 0
			aCols[n][nPosValDesc]	:= 0

			//��������������������������������������������������������������������������Ŀ
			//� Acerto das colunas da aColsDet                                              �
			//����������������������������������������������������������������������������
			aColsDet[n][nPosPrcTab] := &("SB0->B0_PRV"+cTabPad)
       
            Lj7DefTab(.T.)

			//��������������������������������������������������������������������������Ŀ
			//� Chama a LJ7VlItem para acerto dos totais na tela                         �
			//����������������������������������������������������������������������������
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
