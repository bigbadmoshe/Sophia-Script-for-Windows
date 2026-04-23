# https://www.deviantart.com/jepricreations/art/Windows-11-Cursors-Concept-886489356
# https://www.deviantart.com/studio/apps

# Get access token
# https://www.deviantart.com/developers/authentication

$Body = @{
	grant_type    = "client_credentials"
	client_id     = $env:DEVIANTART_CLIENT_ID
	client_secret = $env:DEVIANTART_CLIENT_SECRET
}
$Parameters = @{
	Uri             = "https://www.deviantart.com/oauth2/token"
	Body            = $Body
	Method          = "Post"
	Verbose         = $true
	UseBasicParsing = $true
}
$Response = Invoke-RestMethod @Parameters

# Get download URL
# https://www.deviantart.com/developers/http/v1/20240701/deviation_download/bed6982b88949bdb08b52cd6763fcafd
# UUID is 8A8DC033-242C-DD2E-EDB0-CC864772D5F4
$Headers = @{
	Authorization = "Bearer $($Response.access_token)"
}
$Parameters = @{
	Uri             = "https://www.deviantart.com/api/v1/oauth2/deviation/download/8A8DC033-242C-DD2E-EDB0-CC864772D5F4"
	Headers         = $Headers
	Verbose         = $true
	UseBasicParsing = $true
}
$Response = Invoke-RestMethod @Parameters

# Download archive
$Parameters = @{
	Uri             = $Response.src
	OutFile         = "Cursors\Windows11Cursors.zip"
	Verbose         = $true
	UseBasicParsing = $true
}
Invoke-WebRequest @Parameters
