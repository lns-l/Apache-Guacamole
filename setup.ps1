# Script de configuração do Apache Guacamole Docker Compose para Windows
# Baseado na documentação oficial: https://guacamole.apache.org/doc/gug/guacamole-docker.html

Write-Host "🚀 Configurando Apache Guacamole Docker Compose..." -ForegroundColor Green

# Verificar se Docker está instalado
try {
    docker --version | Out-Null
    Write-Host "✅ Docker encontrado" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker não está instalado. Por favor, instale o Docker Desktop primeiro." -ForegroundColor Red
    exit 1
}

# Verificar se Docker Compose está instalado
try {
    docker-compose --version | Out-Null
    Write-Host "✅ Docker Compose encontrado" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker Compose não está instalado. Por favor, instale o Docker Compose primeiro." -ForegroundColor Red
    exit 1
}

# Verificar se config.env existe, se não, criar a partir do template
if (-not (Test-Path "config.env")) {
    if (Test-Path "config.env.example") {
        Write-Host "📝 Criando config.env a partir do template..." -ForegroundColor Yellow
        Copy-Item "config.env.example" "config.env"
        Write-Host "✅ Arquivo config.env criado. Por favor, edite-o e altere as configurações necessárias." -ForegroundColor Green
    } else {
        Write-Host "❌ Arquivo config.env.example não encontrado. Por favor, certifique-se de que o arquivo existe." -ForegroundColor Red
        exit 1
    }
} else {
    Write-Host "✅ Arquivo config.env encontrado." -ForegroundColor Green
}

# Baixar scripts SQL do Guacamole
Write-Host "📥 Baixando scripts SQL do Guacamole..." -ForegroundColor Yellow
if (-not (Test-Path "guacamole-auth-jdbc-1.6.0")) {
    try {
        Invoke-WebRequest -Uri "https://downloads.apache.org/guacamole/1.6.0/binary/guacamole-auth-jdbc-1.6.0.tar.gz" -OutFile "guacamole-auth-jdbc-1.6.0.tar.gz"
        
        # Extrair arquivo tar.gz (requer 7-Zip ou similar)
        if (Get-Command "7z" -ErrorAction SilentlyContinue) {
            7z x "guacamole-auth-jdbc-1.6.0.tar.gz" | Out-Null
            7z x "guacamole-auth-jdbc-1.6.0.tar" | Out-Null
        } else {
            Write-Host "⚠️  7-Zip não encontrado. Por favor, extraia manualmente o arquivo guacamole-auth-jdbc-1.6.0.tar.gz" -ForegroundColor Yellow
        }
        
        Remove-Item "guacamole-auth-jdbc-1.6.0.tar.gz" -ErrorAction SilentlyContinue
        Remove-Item "guacamole-auth-jdbc-1.6.0.tar" -ErrorAction SilentlyContinue
        Write-Host "✅ Scripts SQL baixados com sucesso." -ForegroundColor Green
    } catch {
        Write-Host "❌ Erro ao baixar scripts SQL. Por favor, baixe manualmente de: https://downloads.apache.org/guacamole/1.6.0/binary/" -ForegroundColor Red
    }
} else {
    Write-Host "✅ Scripts SQL já existem." -ForegroundColor Green
}

# Copiar scripts SQL para init-db
Write-Host "📋 Copiando scripts SQL para init-db..." -ForegroundColor Yellow
if (Test-Path "guacamole-auth-jdbc-1.6.0\postgresql\schema") {
    Copy-Item "guacamole-auth-jdbc-1.6.0\postgresql\schema\*.sql" "init-db\" -Force
    Write-Host "✅ Scripts SQL copiados para init-db/" -ForegroundColor Green
} else {
    Write-Host "⚠️  Diretório de scripts SQL não encontrado. Por favor, copie manualmente os arquivos .sql para init-db/" -ForegroundColor Yellow
}

# Verificar se a porta 8080 está em uso
$portCheck = Get-NetTCPConnection -LocalPort 8080 -ErrorAction SilentlyContinue
if ($portCheck) {
    Write-Host "⚠️  Aviso: A porta 8080 está em uso. Você pode precisar alterar GUACAMOLE_PORT no arquivo .env" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🎉 Configuração concluída!" -ForegroundColor Green
Write-Host ""
Write-Host "📋 Próximos passos:" -ForegroundColor Cyan
Write-Host "1. Edite o arquivo config.env e altere as configurações necessárias (especialmente senhas)" -ForegroundColor White
Write-Host "2. Execute: docker-compose up -d" -ForegroundColor White
Write-Host "3. Acesse: http://localhost:8080/guacamole/" -ForegroundColor White
Write-Host "4. Login padrão: guacadmin / guacadmin" -ForegroundColor White
Write-Host ""
Write-Host "⚠️  IMPORTANTE: Altere a senha padrão após o primeiro login!" -ForegroundColor Red
Write-Host "📝 Todas as configurações estão centralizadas no arquivo config.env" -ForegroundColor Yellow
