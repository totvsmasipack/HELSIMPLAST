#INCLUDE 'PROTHEUS.CH'

/*/{Protheus.doc} User Function HELSP001
    Gatilho para preencher o campo LR_LOCAL
    @type  Function
    @author Fernando Corrêa (DS2U)
    @since 07/05/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/

User Function HELSP001()

    Local _nPosLocal := aScan( aHeaderDet, { |x| Trim(x[2]) == 'LR_LOCAL' })
    Local _cLocal    := SUPERGETMV( 'ES_XLJLCPD',, '50') //Armazem padrao para loja

    If Len(aColsDet) >= n
        aColsDet[n][_nPosLocal] := _cLocal //Código do Armazém
    Endif
	                                                                                                               
Return _cLocal
