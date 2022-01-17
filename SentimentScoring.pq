// This script can be used to call the Azure Cognitive Services API from a Power Query standpoint. 
// Please know that you first need to create the Text Analysis Service in the Azure Portal before this scrip starts to work. 
// Be advised to look at the following blog post for an step-by-step guide for implementation: https://data-marc.com/2020/05/04/leverage-azure-cognitive-services-in-power-bi-without-premium-subscription/

// Please know that below script refers to two different parameters in Power Query, eg. "ApiKey" and "TextAnalyticsApiEndpoint" where both parameters should be configered as plain text. 
// Sentiment Scoring Script 
	(text) => let

		apikey      = (ApiKey),
		endpoint    = (TextAnalyticsApiEndpoint) & "/text/analytics/v2.1/sentiment",
		jsontext    = Text.FromBinary(Json.FromValue(Text.Start(Text.Trim(text), 5000))),
		jsonbody    = "{ documents: [ { language: ""en"", id: ""0"", text: " & jsontext & " } ] }",
		bytesbody   = Text.ToBinary(jsonbody),
		headers     = [#"Ocp-Apim-Subscription-Key" = apikey],
		bytesresp   = Web.Contents(endpoint, [Headers=headers, Content=bytesbody]),
		jsonresp    = Json.Document(bytesresp),
		sentiment   = jsonresp[documents]{0}[score]

	in  sentiment