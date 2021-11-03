#Include "Rwmake.ch"
#Include "Topconn.ch"

/*/{Protheus.doc} RLOJR004
//TODO Etiqueta de identificação de caixas, preenchimento manual.
@author felipe.freitas
@since 30/10/2019
@version 1.0
@return Nil
@type function
/*/

User Function RLOJR004()

Local cTitle	:= "Etiqueta de Identificação de Caixas - Manual"
Local cPerg		:= "RLOJR004"
Local aSays		:= {}
Local aButtons 	:= {}
Local nOpca		:= 0

	Pergunte(cPerg,.T.)

	AADD(aSays,"Este programa irá realizar a impressão de etiquetas de identificação de")
	AADD(aSays,"caixas, com preenchimento manual.")

	AADD(aButtons, {5,.T.,{|| Pergunte(cPerg,.T. )}})
	AADD(aButtons, {1,.T.,{|o| nOpca := 1,FechaBatch()}})
	AADD(aButtons, {2,.T.,{|o| FechaBatch() }})

	FormBatch(cTitle, aSays, aButtons)     

	If nOpca == 1 .AND. mv_par01 > 0
		FWMsgRun(, {|| GeraEtiq() }, "Aguarde", "Gerando etiquetas...")
	Else
        Alert("Parâmetros incorretos!")
	EndIf

Return

Static Function GeraEtiq()

Local nCont	 := 1

	MSCBPRINTER("OS 214","LPT1",NIL,)

	MSCBCHKSTATUS(.F.)
   
	While nCont <= mv_par01

		MSCBBEGIN(1,4)                            

		MSCBSAY(05,40,"Helsimplast Ind. e Com. Ltda / (11) 4361-6077","N","3","01","01")		
		MSCBSAY(05,35,"Produto: ","N","3","01","01")	
        MSCBSAY(05,25,"Cod.: ","N","3","01","01")
        MSCBSAY(50,25,"Data: __/__/____","N","3","01","01")
        MSCBSAY(05,15,"Operador: " ,"N","3","01","01")
        MSCBSAY(50,15,"Nº Operador: " ,"N","3","01","01")
        MSCBSAY(05,05,"Quantidade de Pecas: ","N","3","01","01")
		nCont++

		MSCBEND()
	
	End

	MSCBCLOSEPRINTER()

	If apmsgyesno("Deseja imprimir mais etiquetas?")
		U_RLOJR004()
	EndIf

Return
