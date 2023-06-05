#INCLUDE 'PROTHEUS.CH'
#INCLUDE "LOJA701A.CH"
#Include "TOTVS.ch"

Static aMoeda
Static lFreteAlt	:= .F.												// Indica que ocorreu alteracao no valor do frete, despesa ou seguro.
Static lCenVenda 	:= SuperGetMv("MV_LJCNVDA",,.F.)
Static nDescAnt															// Bkp do valor de desconto Global
Static oMotivoDes	:= Nil
Static lMvljpdvpa	:= LjxBGetPaf()[2] 									// Indica se é pdv
Static lValidSenha  := .F.												// Variavel logica de validacao de senha
Static lLjMVRecIss	:= SuperGetMV("MV_LJRECIS",,.F.)					// Indica se ha desconto do iss no financeiro
Static lLjVfe		:= SuperGetMV("MV_LJVFE",,.F.)						// #VFE - Verifica se a rotina de Venda fora do estado esta ativa
Static lLj7IsNoFun	:= ExistFunc("Lj7IsNoFun")
Static lDtFontes	:= NIL
Static aTesInt		:= {}												// Array com as validações da TES Inteligente
Static lIsPafNfce	:= ExistFunc("STBPafNfce") .And. STBPafNfce()										//Usa NFC-e com PAF ?
Static lMFE			:= IIF( ExistFunc("LjUsaMfe"), LjUsaMfe(), .F. )		//Se utiliza MFE
Static lEmitAvsGE   := .F.	//Se emitiu aviso de Garantia Estendida/Serv. Fin. não permitido, SOMENTE VENDA DIRETA em SIGAFAT


/*/{Protheus.doc} User Function HELSP001
    Gatilho para preencher o campo LR_LOCAL
    @type  Function
    @author Fernando Corrêa (DS2U)
    @since 07/05/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/


User Function HELSP002()

Local _cSerie := ''

HelLj7Pr(.T.,,.T.)



Return _cSerie



/*ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±ºPrograma  ³Lj7Prod   ºAutor  ³ Vendas Clientes    º Data ³  01/07/05   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Valida o produto inserido no aCols.                        º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºParametro ³ ExpL1: Indica se a chamada foi a partir de um X3_VALID     º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºRetorno   ³ ExpL1: Valida se o produto informado e valido              º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºUso       ³ Loja701                                                    º±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß*/
Static Function HelLj7Pr( 	lValid		, lBonus	, lGarantia	,	lLjGrid		,;
					lSugestao	, nKit		, cProdKit	,	nItemKit	,;
					lItemKit	)

Local aArea	  		:= GetArea()																// Armazena area atual (alias, order e recno)
Local lRet			:= .T.																		// Retorno da funcao
Local nItem 		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_ITEM"})][2]		// Posicao da coluna Item
Local nPosProd		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRODUTO"})][2]	// Posicao da codigo do produto
Local nPosDescri	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_DESCRI"})][2]		// Posicao da Descricao do produto
Local nPosQuant		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_QUANT"})][2]		// Posicao da Quantidade
Local nPosVlUnit	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VRUNIT"})][2]		// Posicao do Valor unitario do item
Local nPosUM		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_UM"})][2]			// Posicao da Unidade de Medida
Local nPosDesc		:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_DESC"})][2]		// Posicao do percentual de desconto
Local nPosValDesc	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_VALDESC"})][2]	// Posicao do valor de desconto
Local nPosVlrItem	:= aPosCpo[Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "LR_VLRITEM"})][2]	// Posicao do valor do item
Local nPosLPre		:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_CODLPRE"})				// Posicao do código de lista de presentes
Local nPosPrdCob	:= Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PRDCOBE"})				// Posicao do codigo do Produto Cobertura
Local nPosNSerie   	:= Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_NSERIE" })				// Posicao do Numero de serie
Local nGarant	    := 0																		// Posicao do valor da garantia
Local nSerie	    := 0																		// Posicao do valor de série
Local nPosDtReserva	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_RESERVA"})				// Posicao do codigo da reserva
Local nPosDtLocal  	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_LOCAL"})				// Posicao do local (armazem)
Local nPosValePre	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_VALEPRE"})				// Posicao do codigo do Vale Presente
Local nPosPrcTab	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_PRCTAB"})				// Posicao do Preco de Tabela
Local nMoedaPrv     := 1																		// Armazena a moeda usada no Prc. Venda
Local lEstNeg 		:= (SuperGetMV("MV_ESTNEG",,"S") == "S") .OR. lMVLJPDVPA					// Indica se permite vender com estoque negativo
Local lTrcMoeda     := SuperGetMV("MV_TRCMOED",,.T.)											// Indica se permite escolha de moeda
Local cLocal 		:= ""																		// Armazena o local padrao
Local cProduto 		:= Space(TamSx3("LR_PRODUTO")[1])											// Armazena cod. do produto
Local lVAssConc	 	:= LjVassConc()																// Indica se o cliente utiliza a Vda Assistida Concomitante
Local lLJ7036		:= ExistBlock("LJ7036")														// Ponto de entrada antes da impressao concomitante
Local lTLJ7036		:= ExistTemplate( "LJ7036" )												// Ponto de entrada antes da impressao concomitante
Local lRetPE		:= .T.																		// Retorno do ponto de entrada
Local lValEst		:= .F.																		// Retorno da funcao Lj7VerEst (Verifica se o item tem etoque)
Local lLJ7041		:= ExistBlock("LJ7041")														// Verifica a existencia do P.E.
Local cValePre		:= Space(15)																// Variavel para auxiliar na captura de codigo de vale presente
Local xLocal		:= ""																		// Variavel auxiliar ao P.E. LJ7041 que permite personalizar o almoxarifado de saida do produto
Local nBkpVlruni   	:= 0      	 	  					 				 	   					// Backup do campo Valor Unitario do Produto no aCols
Local nBkpQuant     := 0	   	  					 			 		 						// Backup do campo Quantidade o Item no aCols
Local nBkpDesc      := 0	  		   			   						  						// Backup do campo Desconto do produto no aCols
Local nBkpValDesc   := 0	 												 					// Backup do campo Valor de Desconto  no aCols
Local cBkpDescri	:= Space( TamSx3("LR_DESCRI")[1] )											// Backup do campo Descricao do Produto no aCols
Local cBkpUm   		:= ""	 												 					// Backup do campo Unidade de Medida do Produto no aCols
Local cBkpProd		:= ""	 											 						// Backup do campo Produto no aCols
Local nBkpVlItem	:= 0	 											 						// Backup do campo Valor dO Item  no aCols
Local lPcMult       := .F.																		// Verifica se o produto digitado na consulta existe.
Local nPrecoTab		:= 0
Local nRet			:= 0
Local nAux			:= 0
Local cRetorno		:= ""
Local lDescCab      := .F.											   							// Indica se houve desconto no total pela regra de desconto cenario de venda
Local xRet
Local oLJCLocker 	:= If( ExistFunc("LOJA0051") .And. SuperGetMV( "MV_LJILVLO",,"2" ) == "1", LJCGlobalLocker():New(), )
Local lSuVend		:= SuperGetMV("MV_LJSUAUT",,.F.) 											// sugestao de vendas automatica
Local nPosProvEnt	:= Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_PROVENT"})				// Posicao da provincia de entrega //ANDERSON
Local cBkpProvEnt	:= ""	 											 						// Backup do campo provincia de entrega
Local nTotalCF		:= 0                                                            		    // Total do Cupom Fiscal (Diferente do total da Nota Fiscal)
Local cEntrega		:= ""																		// Tipo de entrega do item
Local nPosEntrega	:= aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_ENTREGA"})][2]	// Posicao da Unidade de Medida
Local lExLegSP10	:= ExistFunc("Lj950SP10OK")													// Verifica a existencia da funcao que valida a legislacao paulista que limita o cupom fiscal em 10.000,00
Local lExTotalCF	:= ExistFunc("LJXTotalCF")													// Verifica a existencia da funcao que calcula o total do cupom fiscal
Local lAutoExA		:= IsBlind()																// Verifica se a rotina sera executada via execauto ou nao
Local lRetaPaf		:= LjNfPafEcf(SM0->M0_CGC) .AND. !lMvljpdvpa 								// Sinaliza se utiliza Retaguarda com PAF-ECF, para realizar o tratamento da concomitancia
Local lIsRecCel 	:= .F.																		// Indica que eh produto "Recarga de Celular"
Local nVlrRecarg 	:= 0																		// Valor da "Recarga de Celular" ou "Recarga de Cartao Presente" (Gift Card)
Local lGE			:= ExistFunc("LjUP104OK") .AND. LjUP104OK()									// Validação do Conceito Garantia Estendida
Local cMV_CLIPAD	:= SuperGetMV("MV_CLIPAD")													// Cliente Padrão
Local cMV_LOJAPAD	:= SuperGetMV("MV_LOJAPAD") 												// Loja PAdrão
Local cMvLjTGar	    := SuperGetMV("MV_LJTPGAR",,"GE") 											// Define se é tipo GE
Local cMsnErro		:= ""																		// Ponto de entrada pra habilitar a Garantia Estendida Default .T.
Local lLJ7081		:= IIF(ExistBlock("LJ7081"), Execblock( "LJ7081", .F., .F. ), .T.)     		// Garantia Estendida	Ponto de entrada pra habilitar a Garantia Estendida Default .T.
Local cMvLjTSF	    := SuperGetMV("MV_LJTPSF",,"SF") 											// Define se é tipo SF
Local nItGarant		:= 0																		// Produto possui garantia
Local lIsRecCP 		:= .F.																		// Indica que eh produto "Recarga de Cartao Presente (Gift Card)"
Local nPosPRedIc	:= Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_PREDIC"}) // %Redução da Base do ICMS 																	// Indica que eh produto "Recarga de Cartao Presente (Gift Card)"
//³Relase 11.5 - Cartao Fidelidade³
Local lLjcFid 		:= SuperGetMv("MV_LJCFID",,.F.) .AND. CrdxInt()							// Indica se a recarga de cartao fidelidade esta ativa
Local nX			:= 0 																		// Contador
Local nTotProd		:= 0																		// Total de produtos nao deletados no aCols
Local nPosNumcFi 	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_NUMCFID"})				// Posicao do Numero do cartao fidelidade
Local nPosDtsdFi 	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_DTSDFID"})				// Posicao da data de validade do saldo inserido
Local nPosVlrcFi 	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_VLRCFID"})				// Posicao do valor do saldo inserido
Local nPosLocaliz  	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_LOCALIZ"})				// Posicao do Localizacao
Local nNSerieDet  	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_NSERIE" })				// Posicao do Numero de serie
Local nPosDtValid  	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_DTVALID" })			// Posicao da Data de validade
Local nPosSubLote	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_NLOTE"})				// Posicao do sublote do produto

Local lFTVD7041		:= ExistBlock("FTVD7041")													// Verifica a existencia do P.E.
Local lFTVD7036		:= ExistBlock("FTVD7036")													// Ponto de entrada antes da impressao concomitante
Local lTFTVD7036	:= ExistTemplate( "FTVD7036" )												// Ponto de entrada antes da impressao concomitante
Local nPosCodBar	:= Ascan(aPosCpoDet,{|x| AllTrim(Upper(x[1])) == "LR_CODBAR"})				// Guarda codigo de barras do produto para otimizar geracao da NFce
Local cCodBar 		:= ""																		// Armazena cod. de barras do produto
Local lIntSynt 	 	:= SuperGetMV("MV_LJSYNT",,"0") == "1"	 									// Informa se a integracao Synthesis esta ativa
Local lEmitNfce		:= ExistFunc("LjEmitNFCe") .AND.  LjEmitNFCe()								// Sinaliza se utiliza NFC-e

//usada na Integracao Protheus x SIAC
Local lScCsPreco	:= .F.																		// Indica se a consulta de preco via WS esta habilitada

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³Variaveis para uso Template Otica³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
Local cTipoIt		:= ""																		// Verifica o tipo do produto
Local lMargem       := SuperGetMV("MV_LJMARGE",,.F.) 											// Valida se considera a margem minIma no venda assistida.
Local nPosClasFis	:= Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_CLASFIS"}) 				// Classificacao Fiscal do Produto
Local lLJ8099		:= ExistBlock("LJ8099")   													// Garantia Estendida	Ponto de entrada pra habilitar a Garantia Estendida Default .T.
Local lVPNewRegra 	:= ExistFunc("Lj7VPNew") .And. Lj7VPNew() 									// Verifica se utiliza as novas modificacoes da implementacao de Vale Presente, para imprimir o comprovante nao fiscal na venda de vale presente.
Local lGiftCard 	:= ExistFunc("Lj7CP_OK") .And. Lj7CP_OK() 									// Verifica se permite utilizar a implementacao de Cartao Presente (Gift Card)
Local lSFinanc		:= AliasIndic("MG8") .AND. SuperGetMV("MV_LJCSF",,.F.)						// Valida implementação do servico financeiro
Local lVincServ		:= IIF(ExistFunc("Lj7GetServ"), Lj7GetServ(), .F.)
Local lNT2015002	:= ExistFunc("NT2015002")  													// Verifica se a funcao provisoria da NT2015/002 esta compilada (LOJNFCE)
Local lUseSat		:= LjUseSat()																// Usa Sat
Local nValorVP		:= 0																		// Valor do Vale Presente
Local aAreaSB1		:= {}																			// Variável Auxiliar
Local lIntegDef		:= lAutoExA .And. FWHasEAI("LOJA701",, .T., .T.) .AND. IIF( ExistFunc("Lj701GtInD") , Lj701GtInD(), IsInCallStack("LOJI701")) //Integracao via Mensagem Unica
Local lFtvdVer12	:= LjFTVD() 								   								//Verifica se é Release 11.7 e o FunName é FATA701 - Compatibilização Venda Direta x Venda Assisitida
Local nPosKit       := aPosCpo[Ascan(aPosCpo,{|x| AllTrim(Upper(x[1])) == "LR_KIT"})][2]   		//Posicao do parametro KIT


Default lValid		:= .T.																		// Indica se a chamada foi a partir de um X3_VALID
Default lBonus      := .F.                                                                  	// Indica se a Bonus
Default lLjGrid		:= .F.																		// Indica se foi digitado do grid
Default lGarantia	:= .T.    																	// Indica se é Garantia ou Sugestão de venda
Default lSugestao	:= .T.																		// Mostra a tela de sugestao de venda
Default nKit        :=  0         									                            // Controla a chamada a função Lj7Prod
Default cProdKit    := ""                                                                       // Atribuirá seu conteúdo a variavel cProduto, para que o sistema possa trabalhar o produto da acols do Kit
Default nItemKit    := 0                                                                        // Controla a posicao do produto no aCols
Default	lItemKit	:= .F.																		// Controla chamada da rotina LjInfoKit apenas para produto pai


// Limpa a variável estática
If Len(aCols) <= 1
	aTesInt := {}
EndIf 

If Type ("lAutomato")<> "L"
	lAutomato 	:= If(Type("lAutomatoX")<>"L",.F.,lAutomatoX)
EndIf

If !Empty(cProdKit)
	cProduto := AllTrim(cProdKit)
Endif

//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
//³ Verifica se o produto pertence ao kit ³
//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
If ExistFunc("Lj7IsKit") .And. Type("oGetVA") == "O" .AND. (oGetVA:LMODIFIED .Or. !Empty(aCols[n][nPosKit]))  .And. !IsInCallStack("LJNFCELOT") //Quando Finalização de NFCE em Lote, a validação de KIT não deve ser executada neste ponto, pois a mesma e executada via rotina automatica. 
	If Lj7IsKit(aCols[n][nItem], aCols[n][nPosProd])
		If aCols[n][nPosVlUnit] > 0
			Alert("Não é possível alterar este produto pois o mesmo pertence a um Kit de Produtos.") // "Não é possível alterar este produto pois o mesmo pertence a um Kit de Produtos."
			lRet := .F.
		EndIf
	EndIf
EndIf

//indica se o Protheus pode consultar o preco de um produto no SIAC Store via WS
lScCsPreco := SuperGetMV("MV_SCINTEG",,.F.) .AND. SuperGetMV("MV_SCCSPRC",,.F.) .AND. ExistFunc("LJSCCSPRC")

//Para utilizar DAV eh necessario informar o CPF/CNPJ do cliente
// Se vier de lAutoexec, não é necessário checar DAV por causa da importação do uMov.me para o Sigaloja
If !lMvljpdvpa .AND. LjNfPafEcf(SM0->M0_CGC) .AND. !SuperGetMV("MV_LJPRVEN",,.F.) .AND.;
 	Empty(SA1->A1_CGC) .And. !(AllTrim(SA1->A1_EST) == "EX") .AND. !lFtvdVer12 .AND. (Type("lAutoExec") <> "L" .OR. !lAutoExec)
 	
	MsgStop( STR0081 + Chr(13) + STR0080)	//"Conforme previsto no Resquisito VI(ATO COTEPE/ICMS 0608):"  //"Para realizar um DAV é necessário informar cliente com CPF/CNPJ"
	lRet := .F.
EndIf

//³ Verifica se o tipo do produto inserido é OG e  ³
//³ chama a função do Template Otica para incluir  ³
//³ no aCols o conjunto Armação e Lentes direita e ³
//³ esquerda.									   ³
If HasTemplate("OTC")

	SB1->(dbSetorder(1))
	SB1->(dbSeek(xFilial("SB1")+M->LR_PRODUTO))

	cTipoIt := SB1->B1_TIPO

	If cTipoIt == "OG"
		T_ConjGlas(aCols)
	EndIf

EndIf

// NFC-e: Apresenta uma mensagem ao usuário, informando que se for ambiente de homologação,
// a Descrição do primeiro item da Nota Fiscal (tag:xProd) deve ser informada como
// "NOTA FISCAL EMITIDA EM AMBIENTE DE HOMOLOGACAO - SEM VALOR FISCAL"
If (lEmitNFCe .Or. lIsPafNfce) .AND. lNT2015002 .AND. n == 1 .And. !lUseSat
	NT2015002(Nil, M->LR_PRODUTO)
EndIf

//Verifica se foi informado o codigo do produto
If "LR_PRODUTO" $ ReadVar()
	If Empty(&(ReadVar()))
		lRet := .F.
	EndIf
EndIf

If lRet
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Cria proteção para campos incluidos no fonte loja701³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lGE
		If Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_NSERIE"}) > 0
		    nSerie	    := aPosCpo[Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "LR_NSERIE"})][2]	// Posicao do valor de série
		EndIf

		If Ascan(aPosCpo,{|x| Alltrim(Upper(x[1])) == "LR_GARANT"}) > 0
			nGarant	    := aPosCpo[Ascan(aHeader,{|x| Alltrim(Upper(x[2])) == "LR_GARANT"})][2]	// Posicao do valor da garantia
		EndIf
	EndIf

	/*Executa Funcao Lj7VldUs que autoriza modificacoes
	nas celulas dos itens ja lancados por vendedores/usuarios.*/
	If !Lj7VldUs()
   		lRet := .F.
		Return lRet
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Caso a Consulta Multimida estaja ativada nao vai usar ³
	//³essa funcao.                                          ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If HasTemplate("DRO")
		If T_DroSendPCM()
			lPcMult :=  ExistCPO("SB1",M->LR_PRODUTO,1)
			Return (lPcMult)
		EndIf
	Endif

	If nPosProvEnt > 0
		nPosProvEnt	:= aPosCpo[nPosProvEnt][2]		// Posicao da provincia de entrega
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Sendo o primeiro item digitado, busca para saber se existem³
	//³tabelas de preco ativadas                                  ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If Len(aCols) == 1 .AND. lCenVenda
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Limpa o array estatico do LOJA701E³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		LjxClFindT()
		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Busca no LOJA701E se existem tabelas de preco ativa³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		LjxFindTab(M->LQ_CLIENTE, M->LQ_LOJA)
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ Verifica se existe reserva para o produto. Se existir nao  	 ³
	//³ deixar fazer altaracao                                       ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If ( "LR_" $ ReadVar() .And. &(ReadVar()) != GDFieldGet(Replace(ReadVar(),"M->","")) ) .And. ;
		((Len(aColsDet) >= n .AND. !Empty(aColsDet[n][nPosDtReserva])) .AND. !lFtvdVer12 .OR. ;
		(Len(aColsDet) >= n .AND. !Empty(aColsDet[n][nPosDtReserva])) .AND. !lAutoExA .AND. lFtvdVer12) .AND. !lIntSynt .AND.; 
		!lIntegDef
		
		If lAutoExA  .AND. !lFtvdVer12
			Conout(STR0001 + "  " +  STR0002)
		Else
			Aviso( STR0001, STR0002, {STR0003} ) //"Aviso"###"Já existe uma reserva para esse produto, não é possível ser alterado."###"Ok"
		EndIf
		lRet := .F.

	Else

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Confirma a existencia do codigo digitado ja efetuando busca	 ³
		//³ pelo codigo de barras										 ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ

		If "LR_PRODUTO" $ ReadVar() .AND. nKit == 0 .AND. AllTrim(aCols[n][nPosKit]) == ""
			cProduto := &(ReadVar())
			 M->LR_VDMOST :=  "N"

			//Zera descontos em qualquer alteracao no campo LR_PRODUTO somente se a venda não for concomitante
			//pois o desconto da venda concomitante é lançado antes do produto
			If !LjAnalisaLeg(14)[1] .And. !SuperGetMV("MV_LJVACC", ,.F.) 
				aCols[n][nPosDesc]		:= 0
				aCols[n][nPosValDesc]	:= 0
			EndIf
		Else
			cProduto := aCols[n][nPosProd]
		Endif

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Se contém código de lista de presentes,  ³
		//³ não trazer sugestão de vendas            ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If (nPosLPre > 0)
			nAux := aPosCpo[nPosLPre][2]
			If (nAux > 0)
				If( Len( AllTrim( aCols[n][nAux] ) ) ) > 0
					lSuVend := .F.
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Preenche com 1 caso a quantidade seja zero³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If aCols[n][nPosQuant] == 0
			aCols[n][nPosQuant] := 1
		Endif

		If cPaisLoc == "ARG" .AND. nPosProvEnt > 0
			aCols[n][nPosProvEnt] := M->LQ_PROVENT
			MaFisAlt("IT_PROVENT", aCols[n][nPosProvEnt], n)
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Relase 11.5 - Cartao Fidelidade³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lLjcFid
			//Verifica se o produto informado e de recarga de cartao fidelidade
			If LaFunhProd(cProduto)
				// Verifica se ja possui algum produto informado e nao deletado no aCols.
				If Len(aCols) > 1
					//Contar o total de produtos nao deletados (desconsiderando a ultima linha)
					For nX:=1 To Len(aCols)
						If !aCols[nX][Len(aCols[nX])] .AND. nX <> Len(aCols)
							nTotProd += 1
						EndIf
					Next nX

					//Se houver produto nao deletado, nao sera possivel incluir produto de recarga
					If nTotProd > 0
						If !lAutoExA
							Alert (STR0061)//"Este orçamento ja possui outros produtos. O produto para recarga de cartao fidelidade não poderá ser utilizado"
						Else
							Conout(STR0061)//"Este orçamento ja possui outros produtos. O produto para recarga de cartao fidelidade não poderá ser utilizado"
						EndIf
						lRet := .F.
						Return lRet
					Else
						//Se os dados informados na tela de recarga nao forem validos
						If !LaFunhInc ()
							lRet := .F.
							Return lRet
						Else
							//Atualizar vallor do produto com o valor da recarga
							aCols[n][nPosVlUnit]	:= LaFunhGet(3)
							aCols[n][nPosVlrItem]	:= LaFunhGet(3)
						EndIf
					EndIf
				Else
					//Se os dados informados na tela de recarga nao forem validos
					If !LaFunhInc ()
						lRet := .F.
						Return lRet
					Else
						//Atualizar vallor do produto com o valor da recarga
						aCols[n][nPosVlUnit]	:= LaFunhGet(3)
						aCols[n][nPosVlrItem]	:= LaFunhGet(3)
					EndIf
				EndIf
			Else
				//Contar o total de produtos nao deletados (desconsiderando a ultima linha)
				For nX:=1 To Len(aCols)
					If !aCols[nX][Len(aCols[nX])] .AND. nX <> Len(aCols)	.AND. LaFunhProd(aCols[nX][nPosProd])
						nTotProd += 1
					EndIf
				Next nX

				If nTotProd > 0
					Alert (STR0062)//"Este orçamento ja possui um produto para recarga de cartao fidelidade.Nenhum outro produto poderá ser utilizado."
					lRet := .F.
					Return lRet
				EndIf

			EndIf
		Else
			If LaFunhProd(cProduto)
				MsgStop (STR0063)//"Este produto é utilizado para recarga de cartao fidelidade e não poderá ser utilizado enquanto esta funcionalidade estiver desabilitada."
				lRet := .F.
				Return lRet
			EndIf
		EndIf

		If lRet .AND. nKit == 0 //só executa a chamada uma unica vez
			If	Posicione('SB1',1,xFilial('SB1')+cProduto,'B1_TIPO') == "KT"
				LjKitProd(@aCols,nItem,cProduto, aCols[n][nPosQuant])
				LjGrvLog("","Função Lj7Prod entrou no if de kitprod retorno da função LjKitProd= ",lRet)	
			    Return lRet
			Endif
        EndIf

		lRet := LjSB1SLK( @cProduto, @aCols[n][nPosQuant], .F., @cCodBar ) //Faz a pesquisa do codigo de produto digitado
		//Verifica se o produto tipo garantia estendida está sendo lançado no orcamento sem um produto com cobertura de garantia
		If lRet .AND. lGarantia .AND. lGE .AND. RTrim(SB1->B1_TIPO) ==  RTrim(cMvLjTGar) .AND. nGarant > 0
			//Verifica se o produto está associado
			nItGarant := Ascan(aCols, {|x| x[nGarant] == aCols[n][nPosProd]})

			If n == 1 .OR. nItGarant == 0
				If isBlind()
					ConOut( STR0001 + " "  + STR0085) //"A venda de um produto tipo garantia estendida é permitida somente amarrada a um produto com cobertura."
				Else
					Aviso( STR0001  ,STR0085, {STR0003}) //"anteção" + "A venda de um produto tipo garantia estendida é permitida somente amarrada a um produto com cobertura.""#" + "ok"
				EndIf
				lRet := .F.
			EndIf
		ElseIf lRet .AND. lSFinanc .AND. RTrim(SB1->B1_TIPO) == RTrim(cMvLjTSF)
			MG8->(dbSetOrder(2))

			//Valida se possui cadastro de servico financeiro vigente
			If MG8->(dbSeek(xFilial("MG8") + cProduto)) .AND. (dDataBase >= MG8->MG8_INIVIG .AND. dDataBase <= MG8->MG8_FIMVIG)
				If cMV_CLIPAD+cMV_LOJAPAD == M->LQ_CLIENTE+M->LQ_LOJA //Valida cliente padrao na Cxa01	venda
					Aviso(STR0001, STR0104, {STR0003}) //#"Aviso" ##"Venda de Serviço financeiro não permitida para Cliente padrão" ###"Ok"
					Return(.F.)
				ElseIf MG8->MG8_TPXPRD == "1" //Valida vinculo do produto
					If Empty(aCols[n][nPosPrdCob])
						Aviso( STR0001  ,STR0105, {STR0003}) //#"Aviso" ##"A venda de um produto tipo serviço vinculado deve ser feita na tela sugestão do produto cobertura." ###"Ok"
						Return(.F.)
					EndIf
				EndIf
			Else
				Aviso(STR0001, STR0106, {STR0003}) //#"Aviso" ##"Produto Serviço deve possuir cadastro vigente em Serviços Financeiros" ###"Ok"
				Return(.F.)
			EndIf
		ElseIf lRet .AND. lSFinanc .AND. cMV_CLIPAD+cMV_LOJAPAD == M->LQ_CLIENTE+M->LQ_LOJA .AND. lVincServ
			//Verifica se produto possui vinculo com servicos financeiros
			MBF->(dbSetOrder(4))

			//Valida se possui cadastro de servico financeiro vigente
			If MBF->(dbSeek(xFilial("MBF") + cProduto)) .AND. (dDataBase >= MBF->MBF_DTINI .AND. dDataBase <= MBF->MBF_DTFIM)
				MsgAlert(STR0107) //#"Este ítem possui vínculo com Serviços Financeiros, verifique se deseja mesmo utilizar o Cliente Padrão"

				If ExistFunc("Lj7SetServ")
					Lj7SetServ(.F.)
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Vale Presente³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. lVPNewRegra
			If !Empty(Lj7VPYesNo())
				If Lj7VPIsPrd(cProduto)
					If Lj7VPYesNo() == "N"
						MsgStop(STR0096) //"Esta venda já possui outros produtos. O Vale Presente somente pode ser vendido individualmente."
						lRet := .F.
						Return lRet
					EndIf
				Else
					If Lj7VPYesNo() == "S"
						MsgStop(STR0097) //"Esta venda possui Vale Presente. Outros produtos não podem ser adicionados nesta mesma venda."
						lRet := .F.
						Return lRet
					EndIf
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Cartao Presente (Gift Card)  ³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lRet .And. lGiftCard
			lIsRecCP := Lj7CP_Prod(cProduto) //Verifica se o produto informado eh "Recarga de Cartao Presente (Gift Card)"
			If !Empty(Lj7CPGetSt())
				If lIsRecCP
					If Lj7CPGetSt() == "N"
						MsgStop(STR0101) //"Esta venda já possui outros produtos. A Recarga de Cartão Presente somente pode ser vendida individualmente."
						lRet := .F.
						Return lRet
					EndIf
				Else
					If Lj7CPGetSt() == "S"
						MsgStop(STR0102) //"Esta venda possui Recarga de Cartão Presente. Outros produtos não podem ser adicionados nesta mesma venda."
						lRet := .F.
						Return lRet
					EndIf
				EndIf
			EndIf
		EndIf

		If lRet
			//Tratamento para produto "Recarga de Celular"
			If ExistFunc("Lj7RCPrdRC")
				lIsRecCel := Lj7RCPrdRC(cProduto) //Verifica se o produto informado eh "Recarga de Celular"
			EndIf

			//Tratamento para produto "Recarga de Cartao Presente (Gift Card)"
			If lGiftCard
				If !lIsRecCP
					If "LR_PRODUTO" $ ReadVar() .AND. !Empty(GDFieldGet("LR_PRODUTO")) .And. GDFieldGet("LR_PRODUTO") <> &(ReadVar())
						If Lj7CP_Prod(GDFieldGet("LR_PRODUTO")) //Verifica se o produto informado anteriormente no mesmo item eh "Recarga de Cartao Presente (Gift Card)"
							MsgAlert(STR0092) //"Não é permitido alterar este produto, pois é um item de Recarga de Cartão Presente."
							lRet := .F.
						EndIf
					EndIf
				EndIf
			EndIf

			If lRet
				//Tratamento para produto "Recarga de Celular"
				If lIsRecCel

					If Lj7RCAtiva() //Verifica se a configuracao de "Recarga de Celular" estah ativa

						If !Lj7RCStatus()
							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Tratamento para a recarga de celulares ³
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !Lj7RCRecCel( @nVlrRecarg, cProduto, .F., (Empty(aCols[n][nPosProd]) .And. Len(aCols)==1) )
								lRet := .F.
							Else
								nPrecoTab := nVlrRecarg
								Lj7RCStatus(.T.) //Atualiza o status para "Recarga Efetuada"

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Acerta informacoes do aCols³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								aCols[n][nPosQuant] := 1 	//Quantidade deve ser 1

								If nPosEntrega > 0
									If ValType(aCols[n][nPosEntrega]) == "C"
										aCols[n][nPosEntrega] := " " //Limpa o campo LR_ENTREGA
									EndIf
								EndIf
							EndIf
						ElseIf Lj7RCStatus()
				       		MsgAlert(STR0082) //"Não é possível efetuar mais de uma Recarga de Celular na mesma venda."
							lRet := .F.
						Endif
					Else
						MsgAlert(STR0083) //"Este produto somente poderá ser selecionado, quando a funcionalidade de Recarga de Celular estiver devidamente configurada no sistema."
						lRet := .F.
					EndIf

				ElseIf lIsRecCP

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Tratamento para produto "Recarga de Cartao Presente (Gift Card)"³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If Lj7CP_Ativ() //Verifica se a configuracao de "Recarga de Cartao Presente (Gift Card)" estah ativa

						//Se o produto for o mesmo e for "Recarga de Cartao Presente (Gift Card)", aborta para nao fazer a recarga novamente em duplicidade
						If "LR_PRODUTO" $ ReadVar() .AND. GDFieldGet("LR_PRODUTO") == &(ReadVar())
							lRet := .F.
						Else

							//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
							//³Tratamento para a "Recarga de Cartao Presente (Gift Card)" |
							//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
							If !Lj7CP_Rcg( M->LQ_NUM, @nVlrRecarg, cProduto, .F., (Empty(aCols[n][nPosProd]) .And. Len(aCols)==1) )
								lRet := .F.
							Else
								nPrecoTab := nVlrRecarg
								Lj7CPSetSt(1) //Atualiza o status para indicar que eh "Recarga de Cartao Presente (GIFT CARD)"

								//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
								//³Acerta informacoes do aCols³
								//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
								aCols[n][nPosQuant] := 1 	//Quantidade deve ser 1

								If nPosEntrega > 0
									If ValType(aCols[n][nPosEntrega]) == "C"
										aCols[n][nPosEntrega] := " " //Limpa o campo LR_ENTREGA
									EndIf
								EndIf
							EndIf

						EndIf

					Else
						MsgAlert(STR0103) //"Este produto somente poderá ser selecionado, quando a funcionalidade de Recarga de Cartao Presente estiver devidamente configurada no sistema."
						lRet := .F.
					EndIf
				Else
					lRet := LjxeValPre (@nPrecoTab	, cProduto, M->LQ_CLIENTE, M->LQ_LOJA	,;
										nMoedaCor 	, aCols[n][nPosQuant])

					//Caso tenha passado o preco do produto (campo LR_PRCTAB), entao desconsidera o preco do produto que foi encontrado e considera o preco enviado no array da rotina automatica
					If lRet .AND. ( lIntSynt .Or. ( Type("lAutoExec") == "L" .And. lAutoExec ) )
						If nPosPrcTab > 0 .And. Len(aColsDet) >= n .AND. !Empty(aColsDet[n][nPosPrcTab]) .AND. n > 0
							nPrecoTab := aColsDet[n][nPosPrcTab] //Para Rotina automatica, considera o preco enviado no campo LR_PRCTAB
						EndIf
					EndIf

				EndIf
			EndIf
		Else
			If Empty(cProduto)
				MsgAlert(STR0056) //"Digite o código do Produto!"
			Else
				MsgAlert(STR0057) //"Produto não encontrado!"
			EndIF
		EndIf

		//#VFE
		If lLjVfe
			//Verifica se a funcionalidade de Venda Fora do estado esta ativa.
			//Acessa a tabela SB0 e busca a informação de Retira, Retira Posterior ou Entraga no campo B0_ENTREGA
			//Alimenta o aCols caso o campo não esteja vazio.
			DbSelectArea('SB0')
			DbSetOrder(1)
			If DbSeek(xFilial('SB0')+SB1->B1_COD)
				If !Empty(AllTrim(SB0->B0_ENTREGA))
					aCols[n][nPosEntrega] := SB0->B0_ENTREGA
				EndIf
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³ Limitacao de 10.000,00 - Legislacao Paulista 	³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If lExTotalCF .AND. lExLegSP10 .AND. lRet
			If nPosEntrega > 0
				If ValType(aCols[n][nPosEntrega]) == "C"
					cEntrega := aCols[n][nPosEntrega]
				EndIf
			EndIf

			If !LjNFFimVd() .AND. LJXTpRetira(cEntrega)				  			// Se nao emitir Nota Fiscal e o produto for de Entrega = Retira ou Vazio
				nTotalCF := LJXTotalCF(n) + (nPrecoTab * aCols[n][nPosQuant])	// Obtem o total do Cupom Fiscal, considerando o item selecionado e a quantidade que ja estava no item
				lRet := Lj950SP10OK(nTotalCF, 2)								// Retona False / Sai da funcao
			EndIf
		EndIf

	    // Nesses estados nao e permitido preco zerado.
		If lRet .AND. LjAnalisaLeg(2)[1]
			//Verifica se tem Tab. de preco
			  if nPrecoTab == 0
				If !lAutoExA
					LjMsgLeg(LjAnalisaLeg(2))
					Help( " ", 1, "NOPRECO" )
				Else
					Conout(STR0073 +cProduto)		//"ATENCAO -->> PRODUTO SEM PRECO:  "
					Help( " ", 1, "Help",, STR0073 +cProduto, 1, 0 )
				EndIf
				lRet := .F.
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Deleta o item porque o produto nao tem preco. Na concomitancia ³
				//³ nao eh permitido produto sem preco                             ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lVAssConc
					aCols[n][nPosProd]   := Space(TamSX3("LR_PRODUTO")[1])
					aCols[n][nPosDescri] := Space(TamSX3("LR_DESCRI")[1])
					aCols[n][nPosQuant]  := 1
				Endif
		   	EndIf
		EndIf

		If lRet
			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Se o produto for diferente do informado, 'reseta' a linha    ³
			//³ do aCols. Apenas quando nao for concomitancia                ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If !lVAssConc
				If "LR_PRODUTO" $ ReadVar() .AND. gdFieldGet("LR_PRODUTO") <> &(ReadVar())
					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Se for alterar um produto que ja existe no aCols faz o Backup , ³
					//³ pois se no caso desse produto nao for valido reestaurar o aCols ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				    If !Empty(gdFieldGet("LR_PRODUTO"))
						If lGE
							cMsnErro := STR0087 //Produto nao Pode ser alterado devido a Garantia Estendida. Exclua o Produto Vendido e Inclua novamente
							If !Empty(aCols[n][nGarant])
								lRet := .F.
							Else
								SB1->(DbSeek(xFilial("SB1")+aCols[n][nPosProd]))
								If SB1->B1_TIPO == cMvLjTGar
									lRet := .F.
								Else
									SB1->(DbSeek(xFilial("SB1")+cProduto))
									If SB1->B1_TIPO==cMvLjTGar
										lRet := .F.
									ElseIf SB1->B1_GARANT == "1" .And. Len(aCols)> n
										lRet := .F.
										cMsnErro := STR0089 //Produto nao Incluido devido a Garantia Estendida. Inclua na Ultima Linha
									EndIf
								EndIf
							EndIf
						EndIf

						If !lRet
							MsgAlert(cMsnErro) ////Produto nao Incluido devido a Garantia Estendida. Inclua na Ultima Linha;
							cProduto := aCols[n][nPosProd]
							nPrecoTab := aCols[n][nPosVlUnit]
							M->LR_PRODUTO := cProduto
						Else
				 	   		nBkpQuant		:=	aCols[n][nPosQuant]
					   		nBkpVlruni		:=	aCols[n][nPosVlUnit]
					  		cBkpDescri 		:=	aCols[n][nPosDescri]
					  		nBkpDesc 		:=	aCols[n][nPosDesc]
					  		nBkpValDesc		:=	aCols[n][nPosValDesc]
							cBkpUm	  		:=	aCols[n][nPosUM]
							cBkpProd   		:=	aCols[n][nPosProd]
							nBkpVlItem		:=	aCols[n][nPosVlrItem]

							If cPaisLoc == "ARG" .AND. nPosProvEnt > 0
								cBkpProvEnt		:=	aCols[n][nPosProvEnt]
							EndIf
						EndIf

			   		EndIf

					If lRet .AND. nKit == 0
						aCols[n][nPosQuant] 	:= IIf(aCols[n][nPosQuant] == 0,1,aCols[n][nPosQuant])
						aCols[n][nPosVlUnit]	:= nPrecoTab
						aCols[n][nPosDesc]		:= 0
						aCols[n][nPosValDesc]	:= 0

				    	If lTrcMoeda .AND. !lCenVenda .AND. !lIntegDef //Integracao Mensagem Unica nao altera valor unitario do produto
						   nMoedaPrv := Max(&("SB0->B0_MOEDA" + Lj7DefTab()),1)
						   aCols[n][nPosVlUnit]	:= Round(xMoeda(&("SB0->B0_PRV" + Lj7DefTab()),nMoedaPrv,nMoedaCor,dDataBase,nDecimais+1,,nTxMoeda),nDecimais)
						EndIf
					EndIf
				EndIf
			EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Grava o codigo do produto no aCols                           ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				aCols[n][nPosProd] := cProduto
	        EndIf

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Verifica se permite vender com estoque negativo. Se a venda  ³
			//³ assistida estiver concomitante, nao deixara registrar o item ³
			//³ sem estoque.										         ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet .AND. !lEstNeg
				If Len(aColsDet) >= n
					If ValType(aColsDet[n][nPosDtLocal]) == "U"
						cLocal := RetFldProd(SB1->B1_COD, "B1_LOCPAD")
						aColsDet[n][nPosDtLocal] := cLocal
					Else
						cLocal := aColsDet[n][nPosDtLocal]
					EndIf
				Else
					cLocal := RetFldProd(SB1->B1_COD, "B1_LOCPAD")
				Endif

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Chamada do Ponto de Entrada para personalizacao do almoxarifado da venda ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				
				If lFtvdVer12
					If lFTVD7041
						LjGrvLog(M->LQ_NUM,"Antes da execução do P.E. FTVD7041",{cLocal,aColsDet})
						xLocal := Execblock( "FTVD7041", .F., .F., { cLocal, aColsDet } )
						LjGrvLog(M->LQ_NUM,"Depois da execução do P.E. FTVD7041",xLocal)
					EndIf
				Else				
					If lLJ7041
						LjGrvLog(M->LQ_NUM,"Antes da execução do P.E. LJ7041",{cLocal,aColsDet})
						xLocal := Execblock( "LJ7041", .F., .F., { cLocal, aColsDet } )
						LjGrvLog(M->LQ_NUM,"Depois da execução do P.E. LJ7041",xLocal)
					Endif
				EndIf
				
				If lLJ7041 .Or. lFTVD7041
					If ValType(xLocal) == "C" .AND. !Empty(xlocal)
						cLocal := xLocal
						If ((lLJ7041 .And. lAutoExA) .Or. (lFTVD7041 .And. IsBlind())) .AND. !Empty(xLocal)
							Conout(STR0074 + "[" + Alltrim(aCols[n][nPosProd]) + Alltrim(xLocal) + "]")		//"<<<<LJ7PROD CRIASB2"
							criaSB2(aCols[n][nPosProd], xLocal)
						Endif
					Endif
				EndIf
			/*
				lValEst := Lj7VerEst( aCols[n][nPosProd], cLocal, aCols[n][nPosQuant], .T. )
			    If !lValEst .AND. (SuperGetMV("MV_LJVACC", ,.F.) .OR. lIntegDef)			    
			    	lRet := .F.
			    EndIf
			*/
			Endif

			//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
			//³ Acerta as colunas da aCols                                   ³
			//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
			If lRet
				If Empty( cProduto )
					cProduto := IIf(lValid, &(ReadVar()), M->LR_PRODUTO)
				EndIf
				aCols[n][nPosProd]   := cProduto

				If cPaisLoc == "ARG" .AND. nPosProvEnt > 0
					aCols[n][nPosProvEnt]   := M->LQ_PROVENT
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³SIGAPHOTO - Apenas atualiza a descricao do produto se nao vier, para nao subistituir quando for envelope.³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nModulo == 72
					If Empty(aCols[n][nPosDescri])
						aCols[n][nPosDescri] := SB1->B1_DESC
					EndIf
				Else
					If nPosPrdCob > 0
						If Empty(aCols[n][nPosPrdCob])
							aCols[n][nPosDescri] := SB1->B1_DESC
						Else //Posiciono corretamente a descrição se for Serviço Financeiro Vinculado
							aAreaSB1 := SB1->(GetArea())
							If SB1->(DbSeek(xFilial("SB1")+aCols[n][nPosProd]))
								aCols[n][nPosDescri] :=	SB1->B1_DESC
							EndIf
							RestArea(aAreaSB1)
						EndIf
					Else
						aCols[n][nPosDescri] := SB1->B1_DESC
					EndIf
				EndIf

				aCols[n][nPosUM]     := SB1->B1_UM
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Ajusta a quantidade sempre para valor default "1". 			 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If aCols[n][nPosQuant] == 0
				   aCols[n][nPosQuant] :=  1
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³E necessario preencher a variavel de memoria para armazenar  ³
				//³o codigo do produto e nao o codigo de barras quando utilizado|
				//|leitor de codigo de barras.                                  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				M->LR_PRODUTO := cProduto

				If ExistBlock("LJ7061")
					LjGrvLog(M->LQ_NUM,"Antes da execução do P.E. LJ7061")
					xRet := ExecBlock("LJ7061",.F.,.F.)
					LjGrvLog(M->LQ_NUM,"Depois da execução do P.E. LJ7061",xRet)
					If ValType( xRet ) == "L"
						lRet := xRet
					EndIf
				EndIf

				If lRet
					//Chama a tela do vale presente para a escolha do vale presente a ser vendido
					If lRet .AND. !lAutomato .AND. nPosValePre > 0 .AND. SB1->B1_VALEPRE == "1"
						cValePre := Space(TamSx3('LR_VALEPRE')[1]) 
						nValorVP := aCols[n][nPosVlUnit]
						lRet     := LjGetVlPre( M->LR_PRODUTO, @cValePre, nPosValePre, @nValorVP )
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³Calcula o valor do item e verifica se ha desconto proveniente³
					//³das regras de desconto.                                      ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lRet .AND. (lCenVenda .OR. lScCsPreco)
						lRet := Lj7RegDesc(	cProduto			, lVAssConc	, @aCols		, @aHeader	,;
											aCols[n][nPosQuant]	, lBonus	, @lDescCab 	, lScCsPreco,;
											nKit)
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Calcula o valor do item 									 ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lRet .AND. !lCenVenda .AND. !lScCsPreco
						lRet := Lj7VlItem( 	Nil, Nil		, Nil		, lDescCab	,;
											Nil, Nil		, lIsRecCel	, nVlrRecarg,;
											Nil, lScCSPreco , nKit		, lIsRecCP	)
					Endif

					//Salva código de barras para utilizar na NFC-e
					If nPosCodBar > 0 .AND. !Empty(cCodBar) .AND. Len(aColsDet) >= n
						aColsDet[n][nPosCodBar] := cCodBar
					EndIf

					//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
					//³ Ponto de entrada antes da impressao concomitante do item     ³
					//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
					If lLJ7036 .AND. lRet .AND. !lFtvdVer12
						LjGrvLog(M->LQ_NUM,"Antes da execução do P.E. LJ7036")
						lRetPE := ExecBlock( "LJ7036", .F., .F. )
						LjGrvLog(M->LQ_NUM,"Depois da execução do P.E. LJ7036",lRetPE)
						
						If ValType( lRetPE ) == "L"
							lRet := lRetPE
						EndIf

						/* Se nao aceitar a digitacao do produto, desconsidera o valor
						 que foi informano na aCols                                */
						If !lRet
							aCols[n][nPosQuant]  := 0
							aCols[n][nPosVlUnit] := 0
							aCols[n][nPosDescri] := Space( TamSx3("LR_DESCRI")[1] )
						EndIf
					EndIf
				EndIf
				
				If lRet
					If lFtvdVer12 
						If lFTVD7036
							LjGrvLog(M->LQ_NUM,"Antes da execução do P.E. FTVD7061")
							lRetPE := ExecBlock( "FTVD7036", .F., .F. )
							LjGrvLog(M->LQ_NUM,"Depois da execução do P.E. FTVD7061",lRetPE)
							
							If ValType( lRetPE ) == "L"
								lRet := lRetPE
							EndIf
							
							/* Se nao aceitar a digitacao do produto, desconsidera o valor
								que foi informano na aCols */    
							If !lRet
								aCols[n][nPosQuant] 	:= 0
								aCols[n][nPosVlUnit]	:= 0
								aCols[n][nPosDescri]	:= Space( TamSx3("LR_DESCRI")[1] )
							EndIf
							
							lFTVD7036 := .F. //Coloco .F. para não executar novamente a validação do retorno do P.E.
						EndIf
						
						If lTFTVD7036
							LjGrvLog(M->LQ_NUM,"Antes da execução do Template Function FTVD7036")
							lRetPE := ExecTemplate( "FTVD7036", .F., .F.,{ M->LQ_NUM, M->LQ_DOC, M->LQ_SERIE, aCols[n][nItem],;
																		  cProduto	, aCols[n][nPosQuant] } )
							LjGrvLog(M->LQ_NUM,"Depois da execução do Template Function FTVD7036",lRetPE)
						EndIf
					Else
						If lTLJ7036
							LjGrvLog(M->LQ_NUM,"Antes da execução do Template Function LJ7061")
							lRetPE := ExecTemplate( "LJ7036", .F., .F.,{ M->LQ_NUM, M->LQ_DOC, M->LQ_SERIE, aCols[n][nItem],;
																		  cProduto	, aCols[n][nPosQuant] } )
							LjGrvLog(M->LQ_NUM,"Depois da execução do Template Function LJ7061",lRetPE)
						EndIf					
					EndIf
					
					If lTLJ7036 .Or. lFTVD7036 .Or. lTFTVD7036
						If ValType( lRetPE ) == "L"
							lRet := lRetPE
						EndIf
						
						/* Se nao aceitar a digitacao do produto, desconsidera o valor
							que foi informano na aCols */    
						If !lRet
							aCols[n][nPosQuant] 	:= 0
							aCols[n][nPosVlUnit]	:= 0
							aCols[n][nPosDescri]	:= Space( TamSx3("LR_DESCRI")[1] )
						EndIf
					EndIf
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Captura o codigo do vale presente, quando aplicavel			 ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If nPosValePre > 0 .AND. lRet .AND. (len(aColsDet)>=n)
					If SB1->B1_VALEPRE == "1"
						If lRet
							aColsDet[n][nPosValePre] := cValePre
							If lVPNewRegra
						        If !Empty( cValePre )
									Lj7VPVdaVP(1) //Indica que eh venda de "Vale Presente"
									If aCols[n][nPosVlUnit] <> nValorVP
										aCols[n][nPosVlUnit]	:= nValorVP		//Atribuo o valor do vale-presente
										aCols[n][nPosVlrItem]	:= A410Arred(aCols[n][nPosVlUnit] * aCols[n][nPosQuant],"LR_VLRITEM",nMoedaCor)
										Lj7VlItem(	2	,	nil,	nil,	nil,;
													nil	,	nil,	nil,	nil,;
													nil	,	nil,	nil,	nil,;
													nil	,	nil,	.T.)		//Recálculo do Preço Unitário, com o parâmetro 15 indicando Vale-Presente
									EndIf
						        EndIf
							EndIf
						EndIf
					Else
						aColsDet[n][nPosValePre] := ""
						If lVPNewRegra
				        	Lj7VPVdaVP(2) //Indica que eh venda de produto que NAO eh "Vale Presente"
						EndIf
					EndIf
				EndIf

				//Gift Card
				If lRet .And. lGiftCard .And. !lIsRecCP
					Lj7CPSetSt(2) //Atualiza o status para indicar que NAO eh "Recarga de Cartao Presente (GIFT CARD) na venda"
				EndIf

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³Relase 11.5 - Cartao Fidelidade                                    ³
				//³Caso a funcionalidade de recarga de cartao fidelidade estiver ativa³
				//³serao informadas nas respectivas colunas do aColsDet os dados	  ³
				//³da recarga informados na tela de inclusao de saldo (LOJXFUNH)      ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If lLjcFid .AND. LaFunhProd(aCols[n][nPosProd])
					//Obter numero do cartao
					If nPosNumcFi  > 0
						aColsDet[n][nPosNumcFi]:= LaFunhGet(1)
					EndIf
					//Obter data de validade do saldo
					If nPosDtsdFi  > 0
						aColsDet[n][nPosDtsdFi]:= LaFunhGet(2)
					EndIf
					//Obter valor do saldo
					If nPosVlrcFi  > 0
						aColsDet[n][nPosVlrcFi]:= LaFunhGet(3)
					EndIf
				EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se a alteração for no LR_PRODUTO e o produto nao for valido , desconsidera o valor  ³
				//³ que foi informado no aCols e volta os campos com os dados do produto que era antes  ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				If ( "LR_PRODUTO" $ ReadVar() )
					If !lRet
						aCols[n][nPosVlUnit]	:=	nBkpVlruni
						aCols[n][nPosQuant]		:=	nBkpQuant
			 		   	aCols[n][nPosDescri]	:=	cBkpDescri
			 		   	aCols[n][nPosDesc]		:=  nBkpDesc
						aCols[n][nPosValDesc]	:=  nBkpValDesc
						aCols[n][nPosUM]		:=  cBkpUm
						aCols[n][nPosProd]    	:=  cBkpProd
						ACols[n][nPosVlrItem]	:=	nBkpVlItem

						If cPaisLoc == "ARG" .AND. nPosProvEnt > 0
							aCols[n][nPosProvEnt]  	:=  cBkpProvEnt
						EndIf
					Else
						//Se o produto alterado era produto de "Recarga de Celular", cancela transacao TEF referente a Recarga de Celular
						If ExistFunc("Lj7RCAtiva") .And. Lj7RCAtiva() .And. !Empty(cBkpProd) .And. Lj7RCPrdRC(cBkpProd)
							If Lj7RCStatus()
								Lj7RCStatus(.F.) //Atualiza o status para "Recarga NAO efetuada"
								oTef:FinalTrn(0) //Envia o desfazimento da transacao TEF
							Endif
						ElseIf lGiftCard .And. Lj7CP_Ativ() .And. !Empty(cBkpProd) .And. Lj7CP_Prod(cBkpProd)
							//Se o produto alterado era produto de "Recarga de Cartao Presente (Gift Card)", cancela transacao TEF referente a Recarga
							If Lj7CPGetSt()=="S"
								Lj7CPSetSt(0) //Atualiza o status para "Recarga NAO efetuada"
								oTef:FinalTrn(0) //Envia o desfazimento da transacao TEF
							Endif
						EndIf
					EndIf
	            EndIf
				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Venda assistida Concomitante. Faz a impressao do item no ECF ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				//PAF: lVAssConc é ativada quando Retaguarda PAF-ECF para realizar diversas validacoes, porem, nao deve passar nesse ponto quando Retaguarda PAF-ECF.
				If !lEmitNFCe .And. !lIsPafNfce
					If lVAssConc .AND. lRet .AND. !lRetaPaf
		    			If !HasTemplate("DRO") .And. (!lVPNewRegra .Or. Empty(cValePre)) .And. (!lGiftCard .Or. Lj7CPGetSt()!="S")
		    				LJ7ImpItCC( n , , , , , ,n )
		    			EndIf
		    		ElseIf ExistFunc("LJHOMTEF") .AND. LJMSSM0(SM0->M0_CGC)
						//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
						//³ Nao concomitante abre o cupom fiscal                         ³
						//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
						nRet := IFStatus( nHdlECF, '5', @cRetorno )
						If LjAnalisaLeg(42)[1]
							If !LjCxAberto(.T.,xNumCaixa())
								nRet := 1
							Else
								nRet := IFAbreCup(nHdlECF ,Nil ,Nil ,Nil ,.F. )
							EndIf
						Else
							nRet := IFAbreCup(nHdlECF,Nil ,Nil, Nil ,.F.)
						EndIf
					EndIf
				EndIf

			Endif
		EndIf
	Endif

	If lRet .AND. (((SB1->( ColumnPos("B1_DESCONT")) > 0)  .AND. (SB1->B1_DESCONT > 0))  .OR. lLJ8099)

		If lLJ8099
			LjGrvLog(M->LQ_NUM,"Antes da execução do P.E. LJ8099")
			M->LR_DESC	:= Execblock( "LJ8099", .F., .F. )
			LjGrvLog(M->LQ_NUM,"Antes da execução do P.E. LJ8099",M->LR_DESC)
	 	Else
	 		M->LR_DESC	:= SB1->B1_DESCONT
	 	EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se o desconto está correto³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	 	If  !lj7VlItem(3, Nil, Nil, Nil, Nil, M->LR_DESC, Nil, Nil, Nil, lScCsPreco)
			If !lAutoExA
				Alert(STR0071)    //"Nao foi possivel realizar desconto cadastrado no produto e sera zerado."
			Else
				Conout(STR0071)   //"Nao foi possivel realizar desconto cadastrado no produto e sera zerado."
			EndIf
		EndIf
	EndIf

	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³Cria loker para carga nova³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	If lRet
		If( ExistFunc("LOJA0051") .And. SuperGetMV( "MV_LJILVLO",,"2" ) == "1", oLJCLocker:GetLock( "LOJA701AILLock" ), .T. )
			If lSuVend .AND. ( nModulo == 12 .OR. nModulo == 23 .OR. nModulo == 72 .OR. lFtvdVer12 ) .AND.  ExistFunc("Lj7SugVend")
				#IFDEF TOP
	 				Lj7SugVend(Nil,lSugestao,cProduto)
				#ENDIF
			EndIf
		EndIf

		//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
		//³Valida se o produto tem Garantia Estendida e Chama a Função principal de Garantia LOJXFUNG³
		//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
		If !lAutoExec .AND. lRet	//Não chamar se for SigaFat
			If lGE .AND. lGarantia .AND. (SB1->B1_GARANT == "1") .AND. ExistFunc("Lj7GarEst") .And. lLJ7081    // Parametro lLJ7081 para Habilitar a Garantia Estendida
				If (nModulo == 5)	//Chamo o aviso de não permitido uma única vez
					Lj7GeMod5()
				ElseIf (cMV_CLIPAD+cMV_LOJAPAD) <> (M->LQ_CLIENTE+M->LQ_LOJA) .And. Empty(aCols[n][nGarant])
	
					If Len(aCols) == n
						Lj7GarEst(Nil,Nil,cProduto,aCols[n][nPosVlUnit])
					Else
				    	MsgAlert(STR0088)//Não pode ser incluida a Garantia Estendida. Caso queira Incluir a Garantia Estendida, Exclua e Inclua novamente o Produto
					EndIf
				EndIf
			ElseIf lSFinanc .AND. SB0->(ColumnPos("B0_SERVFIN")) > 0 .AND. SB0->B0_SERVFIN = "1"
				If (nModulo == 5)	//Chamo o aviso de não permitido uma única vez
					Lj7GeMod5()
				ElseIf (cMV_CLIPAD+cMV_LOJAPAD) <> (M->LQ_CLIENTE+M->LQ_LOJA)
					//Chama a Funcao principal para Servicos Financeiros
					Lj7GarEst(Nil,Nil,cProduto,aCols[n][nPosVlUnit])
				EndIf
			EndIf
		EndIf
	EndIf


//Valida se a margem esta aceitavel.
If lMargem .AND. lRet
	If Lj701MgV(n)
		If MsgYesNo(STR0094)//"O produto esta fora da margem de preço cadastrada. Deseja continuar ?"
			If !LjProfile(35)
				Lj7ValDel(, ,  , ,.T.)
				If Len(aColsDet) >= n
				   aColsDet[n][Len(aColsDet[n])] 	:= .T.
				EndIf
				aColsDet[n][Len( aHeaderDet )+1]	:= .T.
				aCols[n][Len( aHeader )+1]	:= .T.
			EndIf
		Else
			Lj7ValDel(, ,  , ,.T.)
			If Len(aColsDet) >= n
			   aColsDet[n][Len(aColsDet[n])] 	:= .T.
			EndIf
			aColsDet[n][Len( aHeaderDet )+1]	:= .T.
			aCols[n][Len( aHeader )+1]	:= .T.
		EndIf
	EndIf
EndIf

If lRet .And. nPosClasFis > 0 .And. (nPosClasFis := aPosCpo[nPosClasFis][2] ) > 0
	aCols[n][nPosClasFis] := iIf(ExistFunc("Lj7RetClasFis"), Lj7RetClasFis(/*cProd*/, /*cTes*/, /*cNumLote*/, /*cLoteCtl*/,/*nItens*/n), Space(TamSx3("LR_CLASFIS")[1]))
EndIf

//Integracao Mensagem Unica nao carrega Reducao de Base pois ja informado no xml
If !lIntegDef
	If nPosPRedIc > 0 .And. n > 0 .And. MaFisFound("NF") .And. MaFisFound("IT",n)
		aCols[n][nPosPRedIc]  :=  MaFisRet(n,"IT_PREDIC")// %Redução da Base do ICMS
	EndIf
EndIf

//Como o UPDLOJ09 se tornou obsoleto, executamos a funcao que estava no X3_VALID do campo LR_PRODUTO,
// para verificar se o produto possui acessorios cadastrados (Kit de Produtos)
//Adicionada validacao lItemKit para chamar apenas para produto pai
LjGrvLog("","Função Lj7Prod MV_LOJKIT ",SuperGetMV("MV_LOJKIT",,.F.))
If SuperGetMV("MV_LOJKIT",,.F.) .AND. !lItemKit
	LjInfoKit()
EndIf

if ((Type("lAutoExec") == "L" .And. !lAutoExec) .Or.;
	(Type("lAutoExec") <> "L"))	.And.;
 	lRet .AND.  aCols[N][nPosProd] <> cBkpProd
 	
	If nPosNSerie > 0
		aCols[N][nPosNSerie] := Nil
	EndIf
	aColsDet[N][nPosLocaliz] := Space(TamSX3("LR_LOCALIZ")[1])
	aColsDet[N][nNSerieDet]  := Nil
	aColsDet[N][nPosDtValid] := cToD("")
	aColsDet[N][nPosSubLote] := Space(TamSX3("LR_NLOTE")[1])
EndIf 

RestArea(aArea)		// Restaura area anterior

Return lRet

