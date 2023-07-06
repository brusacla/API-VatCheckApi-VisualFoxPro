CLEAR 

SET PROCEDURE TO VatCheckApiClass.prg
oCheckPiva = CREATEOBJECT('VatCheckApiClass')
oCheckPiva.ApiKEY = '[YOUR API KEY]'
oCheckPiva.ValidateVatNumber('IT'+INPUTBOX('Inserisci la piva'))

IF oCheckPiva.Success 
	? 'Numero valido: ' + TRANSFORM(oCheckPiva.Azienda.NumeroValido)
	? 'Nazione: ' + oCheckPiva.Azienda.Nazione             
	? 'Formato valido: ' + TRANSFORM(oCheckPiva.Azienda.FormatoValido)
	? 'Nome azienda: ' + oCheckPiva.Azienda.Nome
	? 'Indirizzo: ' + oCheckPiva.Azienda.Indirizzo         
	? 'Cap: ' + oCheckPiva.Azienda.Cap                 
	? 'Città: ' + oCheckPiva.Azienda.Citta               
	? 'Provincia: ' + oCheckPiva.Azienda.Provincia           
	? 'Presente in sistema: ' + TRANSFORM(oCheckPiva.Azienda.PresenteInSistema)
	? 'Verificata in data: ' + oCheckPiva.Azienda.VerificataInData    
	? 'Partita IVA: ' + oCheckPiva.Azienda.NumeroPartitaIva    
ELSE
	? oCheckPiva.ErrorMsg	
endif	


