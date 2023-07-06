# API IVA Checker in Visual FoxPro

Questo repository contiene una classe di Visual FoxPro che consente la validazione di un numero di IVA europeo utilizzando l'API fornita da [VatCheckAPI](https://vatcheckapi.com/).

## Funzionalità

- Controlla la validità del formato del numero di IVA
- Controlla la validità del checksum del numero di IVA
- Recupera le informazioni aziendali associate al numero di IVA (se disponibili)

## Ottenimento di una chiave API

Per utilizzare VatCheckAPI, avrai bisogno di una chiave API. Segui questi passaggi per ottenerne una:

1. Vai su [VatCheckAPI](https://vatcheckapi.com/).
2. Clicca sul pulsante "Get API Key".
3. Segui le istruzioni per registrarti e ottenere la tua chiave API.

## Utilizzo

Una volta ottenuta la tua chiave API, la classe può essere utilizzata nel seguente modo:

```foxpro
DO VatCheckApiClass
oApi = CREATEOBJECT("VatCheckApiClass")
oApi.ApiKey = "InserisciQuiLaTuaApiKey"
IF oApi.HttpOpenGet("IT", "12345678901")
    ? "Il numero di IVA è valido."
    ? "Nome dell'azienda: ", oApi.Azienda.Nome
    ? "Indirizzo dell'azienda: ", oApi.Azienda.Indirizzo
ELSE
    ? "Il numero di IVA non è valido. Errore: ", oApi.ErrorMsg
ENDIF

```

## Licenza
Questo progetto è sotto licenza [gpl-3.0](LICENSE).

## Contribuire
I contributi sono i benvenuti! Sentiti libero di aprire un problema o una pull request se incontri problemi o se vuoi proporre miglioramenti al codice.

## Contatti
Se hai domande o suggerimenti, non esitare a contattarmi. Sarò lieto di ascoltare il tuo feedback e migliorare questo progetto.
