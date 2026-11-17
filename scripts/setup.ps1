# Asistente de configuracion para Windows (PowerShell 5.1+ / 7+)
# Pide las API keys de cada usuario y las deja SOLO en el entorno del proceso.
# Nunca escribe claves en disco, variables persistentes ni el registro de Windows.
#
# Uso:
#   .\scripts\setup.ps1        # pedir claves y arrancar OpenCode
#   .\scripts\setup.ps1 -SkipLaunch # solo cargar claves en la sesion actual
#
# Si PowerShell bloquea el script:
#   powershell -ExecutionPolicy Bypass -File .\scripts\setup.ps1

param([switch]$SkipLaunch)

$keys = @('GROQ_API_KEY', 'OPENROUTER_API_KEY', 'GEMINI_API_KEY', 'NVIDIA_API_KEY')

Write-Host 'Configuracion de credenciales del pipeline multiagente' -ForegroundColor Cyan
Write-Host 'Las claves se piden de forma oculta y solo viven en memoria.' -ForegroundColor Cyan
Write-Host ''

foreach ($name in $keys) {
    $actual = [Environment]::GetEnvironmentVariable($name, 'Process')
    if (-not [string]::IsNullOrWhiteSpace($actual)) {
        $cambiar = Read-Host "$name ya esta configurado. Reemplazarlo? (s/N)"
        if ($cambiar -notmatch '^[sS]') {
            Write-Host "  Se mantiene el valor actual." -ForegroundColor Yellow
            continue
        }
    }

    $seguro = Read-Host "$name (oculto)" -AsSecureString
    $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($seguro)
    $valor = $null
    try {
        $valor = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr)
        if ([string]::IsNullOrWhiteSpace($valor)) {
            Write-Host "  Vacio: no se cambia nada." -ForegroundColor Yellow
            continue
        }
        [Environment]::SetEnvironmentVariable($name, $valor, 'Process')
        # NVIDIA publica su clave como NVIDIA_API_KEY; aceptamos ambos nombres.
        if ($name -eq 'NVIDIA_NIM_API_KEY') {
            [Environment]::SetEnvironmentVariable('NVIDIA_API_KEY', $valor, 'Process')
        }
        Write-Host '  OK' -ForegroundColor Green
    }
    finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr)
        if ($valor) { $valor = $null }
    }
}

Write-Host ''
Write-Host 'Claves cargadas en esta sesion. No se guardan en archivos.' -ForegroundColor Cyan

if (-not $SkipLaunch) {
    Write-Host 'Arrancando OpenCode...' -ForegroundColor Cyan
    opencode --standalone
}
