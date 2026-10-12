# Convierte un Markdown del repositorio a Word usando los estilos de plantillas/referencia.docx.
# Uso:
#   powershell -ExecutionPolicy Bypass -File herramientas/md2docx.ps1 entregables/ambiente.md
#   powershell -ExecutionPolicy Bypass -File herramientas/md2docx.ps1 entregables/ambiente.md -SinIndice
# Requiere Pandoc (https://pandoc.org/installing.html o: winget install --id JohnMacFarlane.Pandoc)

param(
    [Parameter(Mandatory = $true, Position = 0)][string]$Entrada,
    [string]$Salida = '',
    [switch]$SinIndice
)

$ErrorActionPreference = 'Stop'
$raiz = Split-Path -Parent $PSScriptRoot

if (-not (Get-Command pandoc -ErrorAction SilentlyContinue)) {
    Write-Error 'Pandoc no esta instalado o no esta en el PATH. Instalalo con: winget install --id JohnMacFarlane.Pandoc'
}
$entradaAbs = (Resolve-Path -LiteralPath $Entrada).Path
$referencia = Join-Path $raiz 'herramientas\plantillas\referencia.docx'
if (-not (Test-Path -LiteralPath $referencia)) { Write-Error "No existe la plantilla de estilos: $referencia" }
$filtro = Join-Path $raiz 'herramientas\filtros\salto-pagina.lua'

if ([string]::IsNullOrEmpty($Salida)) {
    $dirSalida = Join-Path $raiz 'salida'
    if (-not (Test-Path -LiteralPath $dirSalida)) { New-Item -ItemType Directory -Path $dirSalida | Out-Null }
    $Salida = Join-Path $dirSalida ([IO.Path]::GetFileNameWithoutExtension($entradaAbs) + '.docx')
}

$argumentos = @(
    $entradaAbs,
    '--from', 'markdown+pipe_tables+grid_tables+yaml_metadata_block+raw_attribute',
    '--to', 'docx',
    '--reference-doc', $referencia,
    '--lua-filter', $filtro,
    '--resource-path', (Split-Path -Parent $entradaAbs),
    '--metadata', 'toc-title=Tabla de Contenido',
    '--output', $Salida
)
if (-not $SinIndice) { $argumentos += @('--toc', '--toc-depth=3') }

& pandoc @argumentos
if ($LASTEXITCODE -ne 0) { Write-Error "Pandoc termino con codigo $LASTEXITCODE" }
Write-Output "Generado: $Salida"
