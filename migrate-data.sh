#!/bin/bash
# Script para migrar dados do PostgreSQL entre locais
# Uso: ./migrate-data.sh /caminho/origem /caminho/destino

if [ $# -ne 2 ]; then
    echo "❌ Uso: $0 <caminho_origem> <caminho_destino>"
    echo "   Exemplo: $0 /home/user/guacamole/postgres-data /home/user/novo-local/postgres-data"
    exit 1
fi

SOURCE_PATH="$1"
TARGET_PATH="$2"

echo "🔄 Migrando dados do PostgreSQL..."

# Verificar se o diretório fonte existe
if [ ! -d "$SOURCE_PATH" ]; then
    echo "❌ Diretório fonte não encontrado: $SOURCE_PATH"
    exit 1
fi

# Criar diretório de destino
mkdir -p "$TARGET_PATH"
echo "✅ Diretório de destino criado: $TARGET_PATH"

# Parar containers se estiverem rodando
echo "🛑 Parando containers..."
docker-compose down 2>/dev/null

# Copiar dados
echo "📁 Copiando dados..."
cp -r "$SOURCE_PATH"/* "$TARGET_PATH"/

echo "✅ Migração concluída!"
echo "📍 Dados copiados de: $SOURCE_PATH"
echo "📍 Para: $TARGET_PATH"
echo ""
echo "💡 Próximos passos:"
echo "   1. Atualize o docker-compose.yml para usar o novo caminho"
echo "   2. Execute: docker-compose up -d"
