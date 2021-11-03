#Include "Rwmake.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} RLOJR006
//TODO Impressão de etiquetas de código de barras.
@author felipe.freitas
@since 05/06/2019
@version 2.0
@return Nil
@type function
/*/

User Function RLOJR006()
    
Local cTitle	:= "Etiqueta de Código de Barras"
Local cPerg		:= "RLOJR006"
Local aSays		:= {}
Local aButtons 	:= {}
Local nOpca		:= 0

	Pergunte(cPerg,.T.)

	AADD(aSays,"Este programa irá realizar a impressão de etiquetas de código de barras,")
	AADD(aSays,"conforme os parâmetros selecionados no botão abaixo.")

	AADD(aButtons, {5,.T.,{|| Pergunte(cPerg,.T. )}})
	AADD(aButtons, {1,.T.,{|o| nOpca := 1,FechaBatch()}})
	AADD(aButtons, {2,.T.,{|o| FechaBatch() }})

	FormBatch(cTitle, aSays, aButtons)     

	If nOpca == 1 .AND. !Empty(mv_par01) .AND. mv_par02 > 0
		FWMsgRun(, {|| GeraEtiq() }, "Aguarde", "Gerando etiquetas...")
	Else
        Alert("Parâmetros incorretos!")
    EndIf
    
Return

Static Function GeraEtiq()

Local nCont := 1

Local cLinTxt1 := "CNPJ: 51.317.402/0001-55"
Local cLinTxt2 := "  IE: 635.125.560.111"
Local cLinTxt3 := " SAC: (11)4361-6077"
Local cLinTxt4 := " VALIDADE INDETERMINADA"
Local cLinTxt5 := "COMPOSICAO: "+Alltrim(mv_par03)
Local cLinTxt6 := "CONTEM 01 UNIDADE DE "+Alltrim(cValToChar(mv_par04))+" ML"
Local cLinTxt7 := "  FABRICADO NO BRASIL"

    DBSelectArea("SB1")
    DBSetOrder(1)

    MSCBPRINTER("OS 214","LPT1",NIL)         	   
    
    MSCBCHKSTATUS(.F.)

    If SB1->(DBSeek(xFilial("SB1")+Alltrim(mv_par01)))

        While nCont <= mv_par02

            MSCBBEGIN(1,4)

            MSCBSAYBAR(014,05,AllTrim(SB1->B1_CODGTIN),"B","MB04",10,.T.,.T.,.F.,,3,3)
            MSCBSAY(017,005,cLinTxt1,"B","0","002,002",,,,,.T.)
            MSCBSAY(019,005,cLinTxt2,"B","0","002,002",,,,,.T.)
            MSCBSAY(021,005,cLinTxt3,"B","0","002,002",,,,,.T.)
            MSCBSAY(023,005,cLinTxt4,"B","0","002,002",,,,,.T.)
            MSCBSAY(025,005,cLinTxt5,"B","0","002,002",,,,,.T.)
            MSCBSAY(027,005,cLinTxt6,"B","0","002,002",,,,,.T.)
            MSCBSAY(029,005,cLinTxt7,"B","0","002,002",,,,,.T.)

            MSCBSAYBAR(044,05,AllTrim(SB1->B1_CODGTIN),"B","MB04",10,.T.,.T.,.F.,,3,3)
            MSCBSAY(047,005,cLinTxt1,"B","0","002,002",,,,,.T.)
            MSCBSAY(049,005,cLinTxt2,"B","0","002,002",,,,,.T.)
            MSCBSAY(051,005,cLinTxt3,"B","0","002,002",,,,,.T.)
            MSCBSAY(053,005,cLinTxt4,"B","0","002,002",,,,,.T.)
            MSCBSAY(055,005,cLinTxt5,"B","0","002,002",,,,,.T.)
            MSCBSAY(057,005,cLinTxt6,"B","0","002,002",,,,,.T.)
            MSCBSAY(059,005,cLinTxt7,"B","0","002,002",,,,,.T.)
                
            MSCBSAYBAR(075,05,AllTrim(SB1->B1_CODGTIN),"B","MB04",10,.T.,.T.,.F.,,3,3)
            MSCBSAY(078,005,cLinTxt1,"B","0","002,002",,,,,.T.)
            MSCBSAY(080,005,cLinTxt2,"B","0","002,002",,,,,.T.)
            MSCBSAY(082,005,cLinTxt3,"B","0","002,002",,,,,.T.)
            MSCBSAY(084,005,cLinTxt4,"B","0","002,002",,,,,.T.)
            MSCBSAY(086,005,cLinTxt5,"B","0","002,002",,,,,.T.)
            MSCBSAY(088,005,cLinTxt6,"B","0","002,002",,,,,.T.)
            MSCBSAY(090,005,cLinTxt7,"B","0","002,002",,,,,.T.)
                    
            nCont++

            MSCBEND()

        End

    EndIf
    
    MSCBCLOSEPRINTER()
    
    If apmsgyesno("Deseja imprimir mais etiquetas?")
        U_RLOJR006()
    EndIf

Return        
