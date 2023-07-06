
********************************************************************************************************************
********************************************************************************************************************
** Definizione oggetto Azienda *************************************************************************************
********************************************************************************************************************
********************************************************************************************************************
Define class Azienda as Custom
    Nazione             = '' &&"country_code": "IT",
    NumeroPartitaIva    = '' && "vat_number": "03110130618",
    FormatoValido       = '' && "format_valid": true,
    NumeroValido        = '' && "checksum_valid": true,
    PresenteInSistema   = '' && "is_registered": true,
    Nome                = '' && "name": "'LEONARDO S.R.L.'",
    Indirizzo           = '' && "address": "VIA APPIA KM 187,30 \n81056 SPARANISE CE",
    Cap                 = ''
    Citta               = ''
    Provincia           = ''
    VerificataInData    = '' && "checked_at": "2023-07-03T13:25:42.000000Z"
Enddefine

********************************************************************************************************************
********************************************************************************************************************
** Definizione classe per usare API valida Piva ********************************************************************
********************************************************************************************************************
********************************************************************************************************************
Define class VatCheckApiClass as Custom

    ** Variabili di controllo della classe
    Success     = .F.
    Errors      = .F.
    ErrorMsg    = ""
    Result      = null

    ** Oggetto per il collegamento Http
	Http		= Null

    ** Oggetto per contenere i dati dell'Azienda
    Azienda		= Null

    ** Variabili del servizio API
    ApiUrl      = "https://api.vatcheckapi.com/v2/"
    ApiKey      = ""


    ** Nell'Init setto le variabili di controllo della classe
    Function init()
        * Resetto variabili di controllo della classe
        this.setParameters(.F., .F., "", null)
        
        * Creo l'oggetto per il collegamento Http
		This.Http = Createobject("MSXML2.XMLHTTP.6.0")
		
		* Creo l'oggetto per contenere i dati dell'Azienda
		This.Azienda = Createobject("Azienda")

        * Verifico che la classe nfjsonread.prg sia presente
        this.checkJsonReader()
    endfunc 

    ** Metodo che setta l'esito nell'oggetto
    Function setParameters(tSuccess, tErrors, tErrorMsg, tResult)
        this.Success    = tSuccess
        this.Errors     = tErrors
        this.ErrorMsg   = tErrorMsg
        this.Result     = tResult
    endfunc   
    
    ** Ogetto Http tipo GET	
    Function HttpOpenGet(cEndpoint)
    * Verifico che sia stato settato l'apikey
    if this.ApiKey = "" OR this.Success = .f.
        this.setParameters(.F., .T., "ApiKey non settata", null)
        return .F.
    else
        This.Http.Open("GET", This.ApiUrl + cEndpoint + '&' + 'apikey=' + this.ApiKey, .F.)
        This.Http.Send()

        * Verifico che lo status sia 200 e restituisco l'esito
        If This.Http.Status = 200
            this.setParameters(.T., .F., "", nfjsonread(This.Http.ResponseText))   
            return .T.
        Else
            this.HandleHttpError(This.Http.Status)
            this.setParameters(.F., .T., this.ErrorMsg, null)
            return .F.
        endif
    endif
    ENDFUNC

    ** Metodo che verifica se esiste il file nfjsonread.prg
    Function checkJsonReader()
        * Siccome questa classe ha bisogno del prg nfjsonread.prg per funzionare 
        * verifico che esista e lo includo qui -> https://github.com/VFPX/nfJson
        If File("nfjsonread.prg")
            Set Procedure To nfjsonread Additive
            this.setParameters(.T., .F., "", null)
            return .T.
        else
            * Se non esiste lo scarico da github
            This.HttpOpenGet('https://raw.githubusercontent.com/VFPX/nfJson/master/nfJson/nfjsonread.PRG')
            This.Result = This.Http.ResponseText

            * Verifico che lo status sia 200 e restituisco l'esito
            If This.Http.Status = 200
                STRTOFILE(ohttp.responseText, 'nfjsonread.prg')
                Set Procedure To nfjsonread Additive
                this.setParameters(.T., .F., "", null)
                return .T.
            Else
                this.setParameters(.F., .T., "Errore " + This.Http.Status + " - " + This.Http.StatusText, null)
                return .F.
            endif
        Endif
    endfunc

    ** Metodo che prende i dati dell'azienda dal Json e li mette nell'oggetto Azienda
    Function SetDataIntoAzienda()
        if this.Success AND this.result.registration_info.is_registered
            try
				This.Azienda.NumeroValido        = this.Result.checksum_valid
				This.Azienda.Nazione             = this.Result.country_code
				This.Azienda.FormatoValido       = this.Result.format_valid
				
				********************************************************************************************************************
                ** L'indirizzo è un'unica stringa per cui devo estrarre l'inidirizzo, il cap e la città
                ********************************************************************************************************************
                cString = This.result.registration_info.address

				* Trova la posizione del CAP (assumendo che sia sempre di 5 cifre)
				nCAPStartPos = 0
				FOR i = 1 TO LEN(cString) - 4
				    cPotentialCAP = SUBSTR(cString, i, 5)
				    IF this.ISNUMBER(cPotentialCAP) AND SUBSTR(cString, i - 1, 1) == " " AND (SUBSTR(cString, i + 5, 1) == " " OR i + 5 >= LEN(cString))
				        nCAPStartPos = i
				        EXIT
				    ENDIF
				ENDFOR

				* Estrai l'indirizzo
				cAddress = TRIM(LEFT(cString, nCAPStartPos - 2))

				* Estrai il CAP
				cCAP = TRIM(SUBSTR(cString, nCAPStartPos, 5))

				* Rimuovi l'indirizzo e il CAP dalla stringa
				cString = TRIM(SUBSTR(cString, nCAPStartPos + 5))

				* Trova la posizione della provincia (assumendo che sia sempre di 2 lettere maiuscole)
				nProvinceStartPos = LEN(cString) - 1

				* Estrai la città
				cCity = LEFT(cString, nProvinceStartPos - 1)

				* Estrai la provincia
				cProvince = RIGHT(cString, 2)
				
                This.Azienda.Indirizzo           = cAddress
                This.Azienda.Cap                 = cCAP
                This.Azienda.Citta               = cCity
                This.Azienda.Provincia           = cProvince
                ********************************************************************************************************************
                *******************************************************************************************************************

				This.Azienda.PresenteInSistema   = this.Result.registration_info.is_registered                                
				This.Azienda.VerificataInData    = this.Result.registration_info.checked_at
				This.Azienda.Nome                = this.Result.registration_info.name                                
                This.Azienda.NumeroPartitaIva    = this.Result.vat_number

                this.setParameters(.T., .F., "", null)
            catch
                this.setParameters(.F., .T., "Errore nella lettura dei dati", null)
            ENDTRY

            * Se andato in errore
            IF this.Errors
            	return .F.
            ELSE
				return .t.	
            endif 
        else    
            IF this.result.registration_info.is_registered = .f.
	            this.setParameters(.F., .T., "Partita IVA non presente in archivio", null)
	        ELSE
				this.setParameters(.F., .T., "Errore nella lettura dei dati", null)
			ENDIF 				
            return .F.
        endif
    ENDFUNC

    ** Metodo per gestire gli errori HTTP
    Function HandleHttpError(nHttpStatusCode)
        DO CASE
        CASE nHttpStatusCode = 401
            * Gestisci l'errore 401 qui
            this.ErrorMsg = "Credenziali di autenticazione non valide"
        CASE nHttpStatusCode = 403
            * Gestisci l'errore 403 qui
            this.ErrorMsg = "Non sei autorizzato a utilizzare questo endpoint, si prega di aggiornare il tuo piano"
        CASE nHttpStatusCode = 404
            * Gestisci l'errore 404 qui
            this.ErrorMsg = "L'endpoint richiesto non esiste"
        CASE nHttpStatusCode = 422
            * Gestisci l'errore 422 qui
            this.ErrorMsg = "Errore di validazione, si prega di controllare i parametri"
        CASE nHttpStatusCode = 429
            * Gestisci l'errore 429 qui
            this.ErrorMsg = "Hai raggiunto il tuo limite di richieste o il tuo limite mensile. Per ulteriori richieste si prega di aggiornare il tuo piano"
        CASE nHttpStatusCode = 500
            * Gestisci l'errore 500 qui
            this.ErrorMsg = "Errore interno del server - si prega di contattare support@vatcheckapi.com"
        OTHERWISE
            * Gestisci altri errori qui
            this.ErrorMsg = "Si è verificato un errore sconosciuto"
        ENDCASE
    Endfunc
    
    * Metodo che ripulisce il json da caratteri speciali
    FUNCTION clearSpecialChar(cString)
		cString = STRTRAN(cString, '\n', ' ')    
		cString = STRTRAN(cString, '/', '-')    
		cString = STRTRAN(cString, '\', ' ')    
		RETURN cString
    ENDFUNC
    
    * Metodo per verificare se un carattere è un numero
    FUNCTION ISDIGIT(cChar)
    	RETURN cChar >= "0" AND cChar <= "9"
	ENDFUNC
	
	* Metodo per verificare se una stringa contiene solo numeri
	FUNCTION ISNUMBER(cString)
	    LOCAL nLength, i
	    nLength = LEN(cString)
	    FOR i = 1 TO nLength
	        IF !BETWEEN(ASC(SUBSTR(cString, i, 1)), 48, 57)
	            RETURN .F.
	        ENDIF
	    ENDFOR
	    RETURN .T.
	ENDFUNC



    **********************************************************************************
    **********************************************************************************
    ****** Endpoints *****************************************************************
    **********************************************************************************
    **********************************************************************************

    ** Metodo che verifica lo status dell'API
    Function StatusEndpoint()
        Local cEndpoint
        cEndpoint = "status?"
        
        * Apro la connessione ed eseguo la chiamata
        if This.HttpOpenGet(cEndpoint)
            This.Result = This.Http.ResponseText

            * Verifico che lo status sia 200 e restituisco l'esito
            If This.Http.Status = 200
                this.setParameters(.T., .F., "", nfjsonread(This.Result))   
                return .T.
            Else
                this.setParameters(.F., .T., "Errore " + This.Http.Status + " - " + This.Http.StatusText, null)
                return .F.
            endif
        else
            return .F.
        endif

    endfunc

    ** Metodo che verifica la validità di una partita iva
    Function ValidateVatNumber(cPiva) && la partita iva deve essere con il codice nazione 
    
    	* Primo verifico la disponibilità di ricerche
		IF this.StatusEndpoint()
			IF NOT this.result.quotas.month.remaining > 0
				this.setParameters(.F., .T., "Limite mensile ricerche raggiunto, attivare un nuovo piano per effettuare nuove ricerche", null)
    			return .F.	
			endif
		ELSE
			this.setParameters(.F., .T., "Servizio non disponibile al momento", null)
    		return .F.
		ENDIF
		
        local cEndpoint
        cEndpoint = "check?vat_number=" + cPiva


        * Apro la connessione ed eseguo la chiamata
        if This.HttpOpenGet(cEndpoint)
            This.Result = This.Http.ResponseText

            * Verifico che lo status sia 200 e restituisco l'esito
            If This.Http.Status = 200
            	* Prima di elbaorare il json lo ripulisco dal carattere \n
				this.Result = this.clearSpecialChar(this.Result)

				* Traduco il json in un oggetto
                this.setParameters(.T., .F., "", nfjsonread(This.Result))  
                
                * Inserisco i dati nell'oggetto Azienda
                this.SetDataIntoAzienda() 
                return .T.
            Else
                this.setParameters(.F., .T., "Errore " + This.Http.Status + " - " + This.Http.StatusText, null)
                return .F.
            endif
        else
            return .F.
        endif

    endfunc

Enddefine
