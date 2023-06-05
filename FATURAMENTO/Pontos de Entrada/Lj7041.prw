#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} User Function nomeFunction
    Ponto de entrada para travar o armazem do item.
    @type  Function
    @author user
    @since 07/05/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

User Function Lj7041()
    Local _cLocal   := ParamIxb[1] // Recebe parâmetro contendo almoxarifado
    Local _aColsDet := ParamIxb[2] // Recebe parâmetro contendo o array aColsDet
    Local cLocalPad := SUPERGETMV( 'ES_XLJLCPD',, '50') //Armazem padrao para loja
   
    If Len(_aColsDet) < n // Verifica se é um novo item, para só alterar o almoxarifado na inclusão do item 
        _cLocal := cLocalPad //Código do Armazém
    Endif

Return _cLocal
