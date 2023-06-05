/*/{Protheus.doc} User Function HELSP003
    Gatilho LQ_XCODEMP -> LQ_XEMPFUN
    @type  Function
    @author Fernando Corrêa (DS2U)
    @since 14/05/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
/*/
User Function HELSP003(cCodEmpr)

    Local cRet := ""

    If cCodEmpr == '01'
        cRet := "Masipack"
    ElseIf cCodEmpr == '10'
        cRet := "Fabrima"
    ElseIf cCodEmpr == '15'
        cRet := "Masitubos"
    ElseIf cCodEmpr == '25'
        cRet := "Casa Helsim"
    ElseIf cCodEmpr == '55'
        cRet := "Terceiros"
    EndIf 

Return cRet
