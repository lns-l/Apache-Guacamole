# Script para migrar dados do PostgreSQL entre locais
# Uso: .\migrate-data.ps1 -SourcePath "C:\GIT\Apache-Guacamole\postgres-data" -TargetPath "D:\NovoLocal\postgres-data"

param(
    [Parameter(Mandatory=$true)]
    [string]$SourcePath,
    
    [Parameter(Mandatory=$true)]
    [string]$TargetPath
)

Write-Host "🔄 Migrando dados do PostgreSQL..." -ForegroundColor Yellow

# Verificar se o diretório fonte existe
if (-not (Test-Path $SourcePath)) {
    Write-Host "❌ Diretório fonte não encontrado: $SourcePath" -ForegroundColor Red
    exit 1
}

# Criar diretório de destino
if (-not (Test-Path $TargetPath)) {
    New-Item -ItemType Directory -Path $TargetPath -Force | Out-Null
    Write-Host "✅ Diretório de destino criado: $TargetPath" -ForegroundColor Green
}

# Parar containers se estiverem rodando
Write-Host "🛑 Parando containers..." -ForegroundColor Yellow
docker-compose down 2>$null

# Copiar dados
Write-Host "📁 Copiando dados..." -ForegroundColor Yellow
Copy-Item -Path "$SourcePath\*" -Destination $TargetPath -Recurse -Force

Write-Host "✅ Migração concluída!" -ForegroundColor Green
Write-Host "📍 Dados copiados de: $SourcePath" -ForegroundColor Cyan
Write-Host "📍 Para: $TargetPath" -ForegroundColor Cyan
Write-Host ""
Write-Host "💡 Próximos passos:" -ForegroundColor Yellow
Write-Host "   1. Atualize o docker-compose.yml para usar o novo caminho" -ForegroundColor White
Write-Host "   2. Execute: docker-compose up -d" -ForegroundColor White
