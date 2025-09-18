# Script para corrigir problemas de inicialização do banco Guacamole
# Uso: .\fix-database.ps1

Write-Host "🔧 Corrigindo problemas de inicialização do banco Guacamole..." -ForegroundColor Yellow

# Parar containers
Write-Host "🛑 Parando containers..." -ForegroundColor Yellow
docker-compose down

# Remover volume corrompido
Write-Host "🗑️ Removendo volume corrompido..." -ForegroundColor Yellow
docker volume rm apache-guacamole_postgres_data 2>$null

# Iniciar containers
Write-Host "🚀 Iniciando containers..." -ForegroundColor Yellow
docker-compose up -d

# Aguardar inicialização
Write-Host "⏳ Aguardando inicialização..." -ForegroundColor Yellow
Start-Sleep -Seconds 15

# Verificar se o schema foi aplicado
Write-Host "🔍 Verificando se o schema foi aplicado..." -ForegroundColor Yellow
$result = docker exec guacamole-postgres psql -U guacamole_user -d guacamole_db -c "SELECT name FROM guacamole_entity WHERE type = 'USER';" 2>$null

if ($result -match "guacadmin") {
    Write-Host "✅ Schema aplicado com sucesso!" -ForegroundColor Green
    Write-Host "🎉 Sistema funcionando corretamente!" -ForegroundColor Green
} else {
    Write-Host "⚠️ Schema não foi aplicado automaticamente. Aplicando manualmente..." -ForegroundColor Yellow
    
    # Aplicar schema manualmente
    Get-Content ./init-db/01-guacamole-schema.sql | docker exec -i guacamole-postgres psql -U guacamole_user -d guacamole_db
    
    Write-Host "✅ Schema aplicado manualmente!" -ForegroundColor Green
}

Write-Host ""
Write-Host "🎯 Próximos passos:" -ForegroundColor Cyan
Write-Host "   1. Acesse: http://localhost:8080/guacamole/" -ForegroundColor White
Write-Host "   2. Login: guacadmin / guacadmin" -ForegroundColor White
Write-Host "   3. Sistema pronto para uso!" -ForegroundColor White
