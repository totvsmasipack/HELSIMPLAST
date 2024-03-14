#include 'Protheus.ch'

/*/{Protheus.doc} User Function RLOJR007
Impressão de etiquetas de Ordem de Produção
@type  Function
@author [ DS2U ]
@since 14/03/2024
/*/
User Function HELETQ05()

Local aPerg := {}
Local aParam    := {}

    If cEmpAnt == '15'

        AADD(aPerg, {1, 'Ord de Producao.:'		    , Space(11)	, '@!'		, ".T.", "", "", 80, .T.})
		AADD(aPerg, {1, 'Qtde em Unidades.:'    	, 0			, '@E 9999'	, ".T.", "", "", 80, .T.})
		AADD(aPerg, {1, 'Motivo da Reprovacao.:'	, Space(20)	, '@!'		, ".T.", "", "", 80, .T.})
		AADD(aPerg, {1, 'Responsável.:'		    	, Space(20)	, '@!'		, ".T.", "", "", 80, .T.})
		AADD(aPerg, {1, 'Qtde de Etiquetas.:'		, 0			, '@E 9999', ".T.", "", "", 80, .T.})
        
        IF ParamBox(aPerg,'Impressão de Material Reprovado', aParam)
            GeraEtiq(aParam)
        EndIf

    Else
        FwAlertWarning('Função disponível na empresa Helsimplast')
    Endif

Return


/*/{Protheus.doc} GeraEtiq
Função para obter as OP's e imprimir as etiquetas
@type  Static Function
@author [ DS2U ]
@since 14/031/2024
/*/
Static Function GeraEtiq(aParam)

Local cAlias    := GetNextAlias()

Local cOPde		:= aParam[1]
Local nQtdUnid	:= aParam[2]
Local cMotRepro	:= aParam[3]
Local cResponsa	:= aParam[4]
Local nQtEtiq	:= aParam[5]

Local nCont     := 0

    BEGINSQL ALIAS cAlias
    
	SELECT	C2_NUM + C2_ITEM + C2_SEQUEN AS OP,
			C2_PRODUTO, B1_DESC, B1_QE, B1_CODBAR, H1_CODIGO, H1_DESCRI
		
	FROM %Table:SC2% C2
	INNER JOIN %Table:SB1% SB1 ON SB1.%NOTDEL% AND B1_FILIAL = %xFilial:SB1% AND B1_COD = C2_PRODUTO 
	INNER JOIN %Table:SG2% SG2 ON SG2.%NOTDEL% AND G2_FILIAL = %xFilial:SG2% AND G2_CODIGO = C2_ROTEIRO AND G2_PRODUTO = C2_PRODUTO
	INNER JOIN %Table:SH1% SH1 ON SH1.%NOTDEL% AND H1_FILIAL = %xFilial:SH1% AND H1_CODIGO = G2_RECURSO

	WHERE   C2_FILIAL = %xFilial:SC2%   
	  AND 	C2_NUM + C2_ITEM + C2_SEQUEN = %Exp:cOPde% 
	  AND	C2.%NOTDEL%

    ENDSQL

    IF (cAlias)->(EOF())
        FwAlertWarning('Ordens de produção não localizadas no parâmetro informado!')
    Else

        MSCBPRINTER("OS 214","LPT1",NIL)
        MSCBCHKSTATUS(.F.)

        WHILE (cAlias)->(!EOF())

            FOR nCont := 1 To nQtEtiq
                
                MSCBBEGIN(1,4)

                MSCBBOX(03,03,98,46,5)
                MSCBSAY(05,40,"--- M A T E R I A L   R E P R O V A D O ---"			                ,"N","3","01","01")
                MSCBSAY(05,40,"NUM. OP: " + (cAlias)->OP + " - " + DtoC(dDatabae)	                ,"N","3","01","01")	
				MSCBSAY(05,30,"NUM DA INJETORA.: " + AllTrim((cAlias)->H1_DESCRI)	                ,"N","3","01","01")
                MSCBSAY(05,25,"DESCRICAO DO PRODUTO.: "+SubString(AllTrim((cAlias)->B1_DESC),1,20)	,"N","3","01","01")
                MSCBSAY(05,20,"QTDE EM UNIDADES: " + AllTrim(Str(nQtdUnid))			                ,"N","3","01","01")
                MSCBSAY(05,15,"MOTIVO DA REPRO.: " + AllTrim(cMotRepro)				                ,"N","3","01","01")
                MSCBSAY(05,06,"RESPONSAVEL.: " + AllTrim(cResponsa)					                ,"N","3","01","01")
                
                MSCBEND()

            Next nCont

            (cAlias)->(dbSkip())
        
        ENDDO

        MSCBCLOSEPRINTER()

    Endif

    (cAlias)->(dbCloseArea())

Return
