$ErrorActionPreference = "Stop"

$root = $PSScriptRoot
$configPath = Join-Path $root "site-config.js"

if (-not (Test-Path $configPath)) {
  throw "Could not find site-config.js"
}

$rawConfig = [System.IO.File]::ReadAllText($configPath, [System.Text.Encoding]::UTF8)
$json = $rawConfig -replace '^\s*window\.SITE_CONFIG\s*=\s*', '' -replace ';\s*$', ''
$config = $json | ConvertFrom-Json

function Resolve-AbsoluteUrl([string]$path) {
  if ([string]::IsNullOrWhiteSpace($path)) {
    return ""
  }

  if ($path -match '^(https?:)?//') {
    return $path
  }

  $baseUrl = $config.site.baseUrl.TrimEnd('/')
  $relativePath = $path.TrimStart('/')
  return "$baseUrl/$relativePath"
}

function Encode-Html([string]$value) {
  return [System.Net.WebUtility]::HtmlEncode($value)
}

function First-Value {
  param(
    [Parameter(ValueFromRemainingArguments = $true)]
    [object[]]$Values
  )

  foreach ($value in $Values) {
    if ($null -ne $value -and -not [string]::IsNullOrWhiteSpace([string]$value)) {
      return [string]$value
    }
  }

  return ""
}

function Write-Utf8File([string]$path, [string]$content) {
  $encoding = New-Object System.Text.UTF8Encoding($false)
  [System.IO.File]::WriteAllText($path, $content, $encoding)
}

$landingImage = Resolve-AbsoluteUrl $config.site.landing.image
$landingTitle = Encode-Html $config.site.landing.title
$landingDescription = Encode-Html $config.site.landing.description
$landingTwitterTitle = Encode-Html (First-Value $config.site.landing.twitterTitle $config.site.landing.title)
$landingTwitterDescription = Encode-Html (First-Value $config.site.landing.twitterDescription $config.site.landing.description)
$landingPageTitle = Encode-Html $config.site.pageTitle
$landingUrl = Encode-Html (Resolve-AbsoluteUrl "index.html")

$indexHtml = @"
<!DOCTYPE html>
<html lang="en">
<head>
<!-- Generated from site-config.js via sync-pages.ps1 -->
<link href="https://fonts.googleapis.com/css2?family=Cinzel:wght@500;600&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;600&display=swap" rel="stylesheet">
<meta charset="UTF-8">

<meta property="og:title" content="$landingTitle">
<meta property="og:description" content="$landingDescription">
<meta property="og:image" content="$(Encode-Html $landingImage)">
<meta property="og:type" content="website">
<meta property="og:url" content="$landingUrl">

<meta name="twitter:card" content="summary_large_image">
<meta name="twitter:title" content="$landingTwitterTitle">
<meta name="twitter:description" content="$landingTwitterDescription">
<meta name="twitter:image" content="$(Encode-Html $landingImage)">

<meta name="viewport" content="width=device-width, initial-scale=1">
<title>$landingPageTitle</title>

<link rel="stylesheet" href="glass.css">
</head>

<body>

<div id="landingWrapper" class="landing-wrapper"></div>

<script src="site-config.js"></script>
<script src="landing.js"></script>
<script src="ripple.js"></script>
<script src="parallax.js"></script>
</body>
</html>
"@

Write-Utf8File -path (Join-Path $root "index.html") -content $indexHtml

foreach ($event in $config.events) {
  $redirectTarget = "invite.html?event=$($event.key)"
  $pageTitle = Encode-Html (First-Value $event.pageTitle $event.share.title $event.title)
  $shareTitle = Encode-Html (First-Value $event.share.title $event.pageTitle $event.title)
  $shareDescription = Encode-Html (First-Value $event.share.description)
  $shareImage = Encode-Html (Resolve-AbsoluteUrl $event.share.image)

  foreach ($pageName in $event.redirectPages) {
    $shareUrl = Encode-Html (Resolve-AbsoluteUrl $pageName)
    $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
<!-- Generated from site-config.js via sync-pages.ps1 -->
<link href="https://fonts.googleapis.com/css2?family=Orbitron:wght@500;600&display=swap" rel="stylesheet">
<meta charset="UTF-8">

<meta property="og:title" content="$shareTitle">
<meta property="og:description" content="$shareDescription">
<meta property="og:image" content="$shareImage">
<meta property="og:type" content="website">
<meta property="og:url" content="$shareUrl">

<meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1">
<title>$pageTitle</title>

<link rel="stylesheet" href="glass.css">
</head>

<body>

<script>
window.location.replace("$redirectTarget");
</script>

</body>
</html>
"@

    Write-Utf8File -path (Join-Path $root $pageName) -content $html
  }
}
