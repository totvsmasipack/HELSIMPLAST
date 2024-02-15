#include 'Protheus.ch'

/*/{Protheus.doc} User Function HELETQ05
Função para impressão das etiquetas de Material Reprovado
@type  Function
@author HOZAKI [ DS2U ]
@since 08/02/2024
/*/
User Function HELETQ05()

Local aPerg := {}
Local aParam    := {}

    If cEmpAnt == '15'

        AADD(aPerg, {1, 'Quantidade'	, 0	, '@E 9999', ".T.", "", "", 80, .T.})

        
        IF ParamBox(aPerg,'Impressão de Material Reprovado', aParam)
            PrintProd(aParam)
        EndIf

    Else
        FwAlertWarning('Função disponível na empresa Helsimplast')
    Endif

Return


Static Function PrintProd(aParam)

Local nQtd      := aParam[1]
Local nX        := 0


        MSCBPRINTER("OS 214","LPT1",NIL) 	        		
        MSCBCHKSTATUS(.F.)

        For nX := 1 To nQtd

            MSCBBEGIN(1,4)

            MSCBBOX(03,03,98,46,5)
            MSCBSAY(05,40,"--- M A T E R I A L   R E P R O V A D O ---","N","3","01","01")		
            MSCBSAY(05,35,"NUM. OP: ","N","3","01","01")	
            MSCBSAY(05,30,"NUM DA INJETORA.: ","N","3","01","01")
            MSCBSAY(05,25,"DESCRICAO DO MATERIAL.: ","N","3","01","01")
            MSCBSAY(05,20,"QTDE EM UNIDADES: ","N","3","01","01")
            MSCBSAY(05,15,"MOTIVO DA REPRO.: ","N","3","01","01")
			MSCBSAY(05,06,"RESPONSAVEL.: ","N","3","01","01")
            
            MSCBEND()

        Next nX

        MSCBCLOSEPRINTER()

Return
