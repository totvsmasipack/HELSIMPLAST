#include 'totvs.ch'
#include 'protheus.ch'
#include 'tbiconn.ch'


/*/{Protheus.doc} User Function HFATA001
 Funçao para cópia de pedidos de vendas entre filiais.
 - USO EXCLUSIVO HELSIMPLAST -
@type  Function
@author E.DINIZ - [ DS2U ]
@since 23/03/2022
/*/
User Function HFATA001()

Local aParam	:= {}
	
	If !(FWCodEmp() == '15')
		Help(Nil, Nil, "CLIEX", Nil, 'Rotina não permitida para esta empresa.', 1, 0, Nil, Nil, Nil, Nil, Nil, {"Rotina autorizada apenas para a empresa 15-Helsimplast"} )
		Return
	Endif
	
	AADD(aParam,{1,"Filial Destino"	,SPACE(2),"","","","",50,.T.})
	AADD(aParam,{1,"Pedido Inicial"	,SPACE(TamSX3('C5_NUM')[1]),"","","","",50,.T.})
	AADD(aParam,{1,"Pedido Final"	,SPACE(TamSX3('C5_NUM')[1]),"","","","",50,.T.})

	If ParamBox(aParam,"Parâmetros",,,,,,,,.T.,.T.)
		Processa({|| HMata410()}, 'Aguarde', 'Carregando informações', .T.)
	Endif

Return



/*/{Protheus.doc} HMata410
	Funçao para executar a inclusão do pedido de venda na Filial posicionada
 - USO EXCLUSIVO HELSIMPLAST -
@type  Static Function
@author E.DINIZ - [ DS2U ]
@since 23/03/2022
/*/
Static Function HMata410()

Local _aLinha	:= {}
Local _aCabec	:= {}
Local _aItens	:= {}
Local _cAlias	:= GetNextAlias()
Local _cCodFil	:= MV_PAR01
Local _cPedido	:= ''
Local _cDoc		:= ''
Local _nCount	:= 0

Private lMsErroAuto := .F.

	BeginSQL Alias _cAlias

		SELECT	*
		FROM	%Table:SC5% SC5, %Table:SC6% SC6
		WHERE	SC5.C5_FILIAL	=	%xFilial:SC5%	AND
				SC5.C5_NUM		BETWEEN %Exp:MV_PAR02%	AND %Exp:MV_PAR03%	AND
				SC5.%NOTDEL%	AND
				SC6.C6_FILIAL	=	SC5.C5_FILIAL	AND
				SC6.C6_NUM		=	SC5.C5_NUM		AND
				SC6.%NOTDEL%
		
		ORDER BY SC5.C5_FILIAL, SC5.C5_NUM, SC6.C6_ITEM

	EndSQL

	If (_cAlias)->(EOF())
		FwAlertError('Não identificamos pedidos de venda nos parâmetros informados','TOTVS')
		Return
	Endif

	(_cAlias)->(dbEval({|| _nCount++ },, { || !EOF() } ) )
	(_cAlias)->(dbGoTop())

	ProcRegua(_nCount)

	PREPARE ENVIRONMENT EMPRESA FWCodEmp() FILIAL Alltrim(_cCodFil) MODULO "FAT" TABLES "SC5","SC6","SA1","SA2","SB1","SB2","SF4"

	Pergunte("MTA410",.F.) 
	
	While (_cAlias)->(!EOF())
		
		IncProc('Copiando Pedido ' + (_cAlias)->C5_NUM + ' | Filial Destino: ' + Alltrim(_cCodFil) )
		
		_cPedido := (_cAlias)->C5_FILIAL + (_cAlias)->C5_NUM

		AADD(_aCabec,{ "C5_TIPO"	, (_cAlias)->C5_TIPO	, Nil })
		AADD(_aCabec,{ "C5_CLIENTE"	, (_cAlias)->C5_CLIENTE	, Nil })
		AADD(_aCabec,{ "C5_LOJAENT"	, (_cAlias)->C5_LOJAENT	, Nil })
		AADD(_aCabec,{ "C5_CONDPAG"	, (_cAlias)->C5_CONDPAG	, Nil })
		AADD(_aCabec,{ "C5_CLIENT"	, (_cAlias)->C5_CLIENT	, Nil })
		AADD(_aCabec,{ "C5_LOJACLI"	, (_cAlias)->C5_LOJACLI	, Nil })
		AADD(_aCabec,{ "C5_TRANSP"	, (_cAlias)->C5_TRANSP	, Nil })
		AADD(_aCabec,{ "C5_TIPOCLI"	, (_cAlias)->C5_TIPOCLI	, Nil })
		AADD(_aCabec,{ "C5_VEND1"	, (_cAlias)->C5_VEND1	, Nil })
		AADD(_aCabec,{ "C5_EMISSAO"	, dDataBase				, Nil })
		AADD(_aCabec,{ "C5_TPFRETE"	, (_cAlias)->C5_TPFRETE	, Nil })
		AADD(_aCabec,{ "C5_ESPECI1"	, (_cAlias)->C5_ESPECI1	, Nil })
		AADD(_aCabec,{ "C5_NATUREZ"	, (_cAlias)->C5_NATUREZ	, Nil })

		While (_cAlias)->(!EOF()) .And. (_cAlias)->(C5_FILIAL + C5_NUM) == _cPedido
			
			_aLinha := {}

			AADD(_aLinha, {"C6_ITEM"	,	(_cAlias)->C6_ITEM		, Nil})
			AADD(_aLinha, {"C6_PRODUTO"	,	(_cAlias)->C6_PRODUTO	, Nil})
			Aadd(_aLinha, {"C6_UM"		,	(_cAlias)->C6_UM		, Nil})
			Aadd(_aLinha, {"C6_LOCAL"	,	(_cAlias)->C6_LOCAL		, Nil})
			AADD(_aLinha, {"C6_QTDVEN"	,	(_cAlias)->C6_QTDVEN	, Nil})
			AADD(_aLinha, {"C6_PRUNIT"	,	(_cAlias)->C6_PRUNIT	, Nil})
			AADD(_aLinha, {"C6_PRCVEN"	,	(_cAlias)->C6_PRCVEN	, Nil})
			AADD(_aLinha, {"C6_VALOR"	,	(_cAlias)->C6_VALOR		, Nil})
			AADD(_aLinha, {"C6_QTDLIB"	,	0						, Nil})
			AADD(_aLinha, {"C6_TES"		,	'9XX'					, Nil})
			AADD(_aLinha, {"C6_DESCONT"	,	(_cAlias)->C6_DESCONT	, Nil})
			AADD(_aLinha, {"C6_VALDESC"	,	(_cAlias)->C6_VALDESC	, Nil})
			
			_aLinha := FWVetByDic( _aLinha, "SC6", .F. , )
			
			AADD(_aItens, _aLinha)

			(_cAlias)->(DbSkip())
		
		Enddo
		
		 MSExecAuto({|x,y,z| MATA410(x,y,z)}, _aCabec, _aItens, 3)
		
		If !lMsErroAuto
			_cDoc +=  CRLF + SC5->C5_NUM
		Else
			Mostraerro()
		EndIf

		_aCabec := {}
		_aItens := {}
		_nCount := 0

	Enddo

	If !Empty(_cDoc)
		FwAlertSuccess(_cDoc, 'Pedido(s) Gerado(s)')
	Endif

	(_cAlias)->(DbCloseArea())

Return
