#INCLUDE "protheus.ch"

/*/{Protheus.doc} User Function LJ7002 
    Ponto de entrada na finaliza��o do venda direta.
    @type  Function
    @author Fernando Corr�a
    @since 26/04/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

User Function LJ701Mbr()

    Local lAbre := .T.
    Local nTipo := PARAMIXB[1] //1=Salvar como or�amento <F4>; 2=Salvar como venda <F5>
    Local nOperacao := PARAMIXB[2] //3=Atendimento; 4=Finaliza venda

    lAbre := .T. //Nao abre a tela para uma nova venda

    If nTipo == 2 
        u_HELSR001(0) //Impress�o de Cupom n�o fiscal
    EndIf 

Return lAbre
