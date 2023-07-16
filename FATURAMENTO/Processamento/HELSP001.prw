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

User Function HELSP001(nOpc)

    Local _nPosLocal   := 0
    Local _cLocalLJ    := SUPERGETMV( 'ES_XLJLCPD',, '50') //Armazem padrao para loja
    Local _cLocalCol   := SUPERGETMV( 'ES_XLJLCOL',, '51') //Armazem padrao para encomendas colaborares
    Local _cUserCol    := SUPERGETMV( 'ES_XCOLUSR',, '001888') //Usuários que atendem no balcão 
    Local _cLocal      := ''

    Default nOpc := 0

    If nOpc == 0    
        _nPosLocal := aScan( aHeaderDet, { |x| Trim(x[2]) == 'LR_LOCAL' })
        If Len(aColsDet) >= n
            If RETCODUSR() $ _cUserCol
                
                aColsDet[n][_nPosLocal] := _cLocalCol //Código do Armazém
                _cLocal := _cLocalCol
            Else 
                aColsDet[n][_nPosLocal] := _cLocalLJ //Código do Armazém
                _cLocal := _cLocalLJ
            EndIf 
        Endif
    Else 
        If RETCODUSR() $ _cUserCol
            _cLocal := _cLocalCol
        Else 
            _cLocal := _cLocalLJ
        EndIf 
    EndIf 

Return _cLocal
