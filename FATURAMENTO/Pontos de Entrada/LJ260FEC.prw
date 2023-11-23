#INCLUDE "PROTHEUS.CH"
/*/{Protheus.doc} LJ260FEC
    @type  Function- PE do FONTE LOJA260
        Esse ponto de entrada é chamado antes da execução do fechamento do caixa
    @author R. GARCIA (DS2U)
    @create 08/11/2023 @version version 01
    @update 17/11/2023 @version version 02  
/*/
User Function LJ260FEC()
    
RETURN U_HELSP005("AF")
