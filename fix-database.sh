#!/bin/bash
# Script para corrigir problemas de inicialização do banco Guacamole
# Uso: ./fix-database.sh

echo "🔧 Corrigindo problemas de inicialização do banco Guacamole..."

# Parar containers
echo "🛑 Parando containers..."
docker-compose down

# Remover volume corrompido
echo "🗑️ Removendo volume corrompido..."
docker volume rm apache-guacamole_postgres_data 2>/dev/null

# Iniciar containers
echo "🚀 Iniciando containers..."
docker-compose up -d

# Aguardar inicialização
echo "⏳ Aguardando inicialização..."
sleep 15

# Verificar se o schema foi aplicado
echo "🔍 Verificando se o schema foi aplicado..."
result=$(docker exec guacamole-postgres psql -U guacamole_user -d guacamole_db -c "SELECT name FROM guacamole_entity WHERE type = 'USER';" 2>/dev/null)

if echo "$result" | grep -q "guacadmin"; then
    echo "✅ Schema aplicado com sucesso!"
    echo "🎉 Sistema funcionando corretamente!"
else
    echo "⚠️ Schema não foi aplicado automaticamente. Aplicando manualmente..."
    
    # Aplicar schema manualmente
    cat ./init-db/01-guacamole-schema.sql | docker exec -i guacamole-postgres psql -U guacamole_user -d guacamole_db
    
    echo "✅ Schema aplicado manualmente!"
fi

echo ""
echo "🎯 Próximos passos:"
echo "   1. Acesse: http://localhost:8080/guacamole/"
echo "   2. Login: guacadmin / guacadmin"
echo "   3. Sistema pronto para uso!"
