#!/bin/bash

# Script de configuração do Apache Guacamole Docker Compose
# Baseado na documentação oficial: https://guacamole.apache.org/doc/gug/guacamole-docker.html

set -e

echo "🚀 Configurando Apache Guacamole Docker Compose..."

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não está instalado. Por favor, instale o Docker primeiro."
    exit 1
fi

# Verificar se Docker Compose está instalado
if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose não está instalado. Por favor, instale o Docker Compose primeiro."
    exit 1
fi

# Verificar se config.env existe, se não, criar a partir do template
if [ ! -f config.env ]; then
    if [ -f config.env.example ]; then
        echo "📝 Criando config.env a partir do template..."
        cp config.env.example config.env
        echo "✅ Arquivo config.env criado. Por favor, edite-o e altere as configurações necessárias."
    else
        echo "❌ Arquivo config.env.example não encontrado. Por favor, certifique-se de que o arquivo existe."
        exit 1
    fi
else
    echo "✅ Arquivo config.env encontrado."
fi

# Baixar scripts SQL do Guacamole
echo "📥 Baixando scripts SQL do Guacamole..."
if [ ! -d "guacamole-auth-jdbc-1.6.0" ]; then
    wget -q https://downloads.apache.org/guacamole/1.6.0/binary/guacamole-auth-jdbc-1.6.0.tar.gz
    tar -xzf guacamole-auth-jdbc-1.6.0.tar.gz
    rm guacamole-auth-jdbc-1.6.0.tar.gz
    echo "✅ Scripts SQL baixados com sucesso."
else
    echo "✅ Scripts SQL já existem."
fi

# Copiar scripts SQL para init-db
echo "📋 Copiando scripts SQL para init-db..."
cp guacamole-auth-jdbc-1.6.0/postgresql/schema/*.sql init-db/
echo "✅ Scripts SQL copiados para init-db/"

# Verificar se a porta 8080 está em uso
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  Aviso: A porta 8080 está em uso. Você pode precisar alterar GUACAMOLE_PORT no arquivo .env"
fi

echo ""
echo "🎉 Configuração concluída!"
echo ""
echo "📋 Próximos passos:"
echo "1. Edite o arquivo config.env e altere as configurações necessárias (especialmente senhas)"
echo "2. Execute: docker-compose up -d"
echo "3. Acesse: http://localhost:8080/guacamole/"
echo "4. Login padrão: guacadmin / guacadmin"
echo ""
echo "⚠️  IMPORTANTE: Altere a senha padrão após o primeiro login!"
echo "📝 Todas as configurações estão centralizadas no arquivo config.env"
