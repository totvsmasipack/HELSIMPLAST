#include 'Protheus.ch'

/*/{Protheus.doc} User Function HELETQ02
Função para impressão das etiquetas dos endereços do estoque
@type  Function
@author E.DINIZ [ DS2U ]
@since 17/03/2021
/*/
User Function HELETQ03()

Local aPerg := {}
Local aParam    := {}

    If cEmpAnt == '15'

        AADD(aPerg, {1, 'Quantidade', 1			, '@E 9999'	, '.T.', '', '', 80, .F.})
        AADD(aPerg, {1, 'Texto 1: '	, SPACE(40)	, '@!'		, '.T.', '', '', 80, .F.})
        AADD(aPerg, {1, 'Texto 2: '	, SPACE(40)	, '@!'		, '.T.', '', '', 80, .F.})
        AADD(aPerg, {1, 'Texto 3: '	, SPACE(40)	, '@!'		, '.T.', '', '', 80, .F.})
        AADD(aPerg, {1, 'Texto 4: '	, SPACE(40)	, '@!'		, '.T.', '', '', 80, .F.})
        AADD(aPerg, {1, 'Texto 5: '	, SPACE(40)	, '@!'		, '.T.', '', '', 80, .F.})
        AADD(aPerg, {1, 'Texto 6: '	, SPACE(40)	, '@!'		, '.T.', '', '', 80, .F.})
        
        IF ParamBox(aPerg,'Impressão de Etiquetas Manual', aParam)
            PrintEtiq(aParam)
        EndIf

    Else
        FwAlertWarning('Função disponível na empresa Helsimplast')
    Endif

Return


Static Function PrintEtiq(aParam)

Local nX	:= 0

	MSCBPRINTER("OS 214","LPT1",NIL) 	        		
	MSCBCHKSTATUS(.F.)

	For nX := 1 To aParam[1]

		MSCBBEGIN(1,4)

		MSCBBOX(03,03,98,46,5)
		MSCBSAY(05,	40,	SubStr(aParam[2],1,40),	"N",	"3",	"01",	"01")
		MSCBSAY(05,	33,	SubStr(aParam[3],1,40),	"N",	"3",	"01",	"01")
		MSCBSAY(05,	27,	SubStr(aParam[4],1,40),	"N",	"3",	"01",	"01")
		MSCBSAY(05,	20,	SubStr(aParam[5],1,40),	"N",	"3",	"01",	"01")
		MSCBSAY(05,	13,	SubStr(aParam[6],1,40),	"N",	"3",	"01",	"01")
		MSCBSAY(05,	06, SubStr(aParam[7],1,40),	"N",	"3",	"01",	"01")
		
		MSCBEND()

	Next nX

	MSCBCLOSEPRINTER()

Return
