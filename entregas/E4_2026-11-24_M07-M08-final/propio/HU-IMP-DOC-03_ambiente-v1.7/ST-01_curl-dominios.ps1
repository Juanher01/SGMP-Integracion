# HU-IMP-DOC-03 · ST-01 · Verificación de dominios (CA-3)
# Genera evidencias\curl-dominios.txt al lado de este script.
# Uso (desde cualquier carpeta):
#   powershell -ExecutionPolicy Bypass -File .\ST-01_curl-dominios.ps1
# Usa curl.exe (no el alias de PowerShell) y nunca -v, como pide la HU.

$hu  = Split-Path -Parent $MyInvocation.MyCommand.Path
$dir = Join-Path $hu 'evidencias'
$out = Join-Path $dir 'curl-dominios.txt'
New-Item -ItemType Directory -Force -Path $dir | Out-Null

$urls = @(
  @('DEV',  'Frontend',          'https://inmero.co/sigab-dev/'),
  @('DEV',  'Frontend (www)',    'https://www.inmero.co/sigab-dev/'),
  @('DEV',  'Frontend v1.6',     'https://api.inmero.co/sigab-dev'),
  @('DEV',  'Backend',           'https://api.inmero.co/api-sgpmp-dev/health'),
  @('DEV',  'Backend (www)',     'https://www.api.inmero.co/api-sgpmp-dev/health'),
  @('DEV',  'Gateway',           'https://api.inmero.co/broker-sigab-dev/v1/healthz'),
  @('TEST', 'Frontend',          'https://inmero.co/sigab-test/'),
  @('TEST', 'Frontend (www)',    'https://www.inmero.co/sigab-test/'),
  @('TEST', 'Backend',           'https://api.inmero.co/api-sgpmp-test/health'),
  @('TEST', 'Backend (www)',     'https://www.api.inmero.co/api-sgpmp-test/health'),
  @('TEST', 'Gateway',           'https://api.inmero.co/broker-sigab-test/v1/healthz'),
  @('PROD', 'Frontend',          'https://inmero.co/sigab/'),
  @('PROD', 'Frontend (www)',    'https://www.inmero.co/sigab/'),
  @('PROD', 'Backend',           'https://api.inmero.co/sigab/health'),
  @('PROD', 'Backend (www)',     'https://www.api.inmero.co/sigab/health'),
  @('PROD', 'Gateway',           'https://api.inmero.co/broker-sigab/v1/healthz')
)

$lineas = @()
$lineas += 'HU-IMP-DOC-03 - Verificacion de dominios (CA-3)'
$lineas += ('Fecha: ' + (Get-Date -Format 'yyyy-MM-dd HH:mm:ss zzz') + ' (equipo de ' + $env:USERNAME + ')')
$lineas += 'Comando: curl.exe -s -o NUL -w "%{http_code}" --max-time 15 <url>   (000 = sin respuesta)'
$lineas += ''
$lineas += ('{0,-5} {1,-17} {2,-5} {3}' -f 'Amb.', 'Servicio', 'HTTP', 'URL')
foreach ($u in $urls) {
  $code = & curl.exe -s -o NUL -w "%{http_code}" --max-time 15 $u[2]
  $lineas += ('{0,-5} {1,-17} {2,-5} {3}' -f $u[0], $u[1], $code, $u[2])
}

$lineas += ''
$lineas += 'ETag (curl.exe -sI <url>): si coinciden, /sigab captura /sigab-test (riesgo de PathPrefix)'
foreach ($u in @('https://inmero.co/sigab-test/', 'https://inmero.co/sigab/')) {
  $h = & curl.exe -sI --max-time 15 $u
  $etag = ($h | Where-Object { $_ -match '^etag:' }) -join ' '
  if (-not $etag) { $etag = '(sin ETag)' }
  $lineas += ('{0,-32} {1}' -f $u, $etag.Trim())
}

$lineas | Out-File -FilePath $out -Encoding utf8
Get-Content $out
Write-Host "`nGuardado en: $out"
