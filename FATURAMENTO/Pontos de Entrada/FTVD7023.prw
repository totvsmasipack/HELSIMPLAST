/*/{Protheus.doc} User Function FTVD7023
    (long_description)
    @type  Function
    @author user
    @since 08/05/2023
    @version version
    @param param_name, param_type, param_descr
    @return return_var, return_type, return_description
    @example
    (examples)
    @see (links_or_references)
    /*/
User Function FTVD7023()

Local lRet := .F.
Local cFormaPg := PARAMIXB[1]

If cFormaPg == 'CHEQUE' 
    lRet := .T.
Endif

Return lRet
