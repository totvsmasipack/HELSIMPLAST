#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} LJ260TRA
    @type  Function- PE do FONTE LOJA260
        Esse ponto de entrada é chamado antes da execução da abertura do caixa
    @author R. GARCIA (DS2U)
    @create 09/11/2023  @version version 01
    @update 17/11/2023  @version version 02 
       
/*/
User Function LJ260TRA()
    
RETURN U_HELSP005("AF")
