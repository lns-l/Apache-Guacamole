# Apache Guacamole Docker Compose

Este projeto fornece uma configuração Docker Compose completa para o Apache Guacamole, seguindo as melhores práticas da documentação oficial.

## 📋 Pré-requisitos

- Docker Engine 20.10+
- Docker Compose 2.0+
- Pelo menos 2GB de RAM disponível
- Porta 8080 disponível (ou configure outra porta)

## 🚀 Início Rápido

### 1. Configuração Inicial

```bash
# Clone ou baixe este repositório
git clone <seu-repositorio>
cd Apache-Guacamole

# Edite o arquivo de configuração centralizado
nano config.env

# IMPORTANTE: Altere a senha do banco de dados e outras configurações sensíveis
```

### 2. Inicialização do Banco de Dados

O Guacamole requer que o banco de dados seja inicializado manualmente. Execute os seguintes comandos:

```bash
# Baixe os scripts SQL do Guacamole
wget https://downloads.apache.org/guacamole/1.6.0/binary/guacamole-auth-jdbc-1.6.0.tar.gz
tar -xzf guacamole-auth-jdbc-1.6.0.tar.gz

# Copie os scripts SQL para o diretório init-db
cp guacamole-auth-jdbc-1.6.0/postgresql/schema/*.sql init-db/
```

### 3. Executar o Ambiente

```bash
# Iniciar todos os serviços
docker-compose up -d

# Verificar o status dos containers
docker-compose ps

# Ver os logs
docker-compose logs -f
```

### 4. Acessar o Guacamole

Abra seu navegador e acesse:
- **URL**: http://localhost:8080/guacamole/
- **Usuário padrão**: guacadmin
- **Senha padrão**: guacadmin

⚠️ **IMPORTANTE**: Altere a senha padrão imediatamente após o primeiro login!

## 🏗️ Arquitetura

O ambiente é composto por três containers principais:

### 1. PostgreSQL (`postgres`)
- **Imagem**: postgres:15-alpine
- **Função**: Banco de dados para autenticação e configurações
- **Porta**: 5432 (interna)
- **Armazenamento**: `./postgres-data/` (diretório local do projeto)

### 2. Guacd (`guacd`)
- **Imagem**: guacamole/guacd:1.6.0
- **Função**: Daemon para protocolos de conexão remota (VNC, RDP, SSH, etc.)
- **Porta**: 4822 (interna)
- **Log Level**: info (configurável)

### 3. Guacamole Web (`guacamole`)
- **Imagem**: guacamole/guacamole:1.6.0
- **Função**: Interface web do Guacamole
- **Porta**: 8080 (exposta)
- **Dependências**: postgres e guacd

## ⚙️ Configurações

### Variáveis de Ambiente

Edite o arquivo `config.env` para personalizar todas as configurações:

```bash
# Configurações do banco de dados
POSTGRES_DB=guacamole_db
POSTGRES_USER=guacamole_user
POSTGRES_PASSWORD=sua_senha_segura

# Configurações do Guacamole
GUACAMOLE_PORT=8080
WEBAPP_CONTEXT=ROOT


# Configurações de proxy (opcional)
REMOTE_IP_VALVE_ENABLED=false
PROXY_ALLOWED_IPS_REGEX=^192\.168\.\d+\.\d+$

# Configurações de segurança
SESSION_TIMEOUT=30
CONNECTION_TIMEOUT=10
MAX_CONNECTIONS_PER_USER=5

# Configurações de autenticação LDAP (opcional)
# LDAP_HOSTNAME=ldap.example.com
# LDAP_PORT=389
# LDAP_USER_BASE_DN=ou=users,dc=example,dc=com
```

**Todas as configurações estão centralizadas no arquivo `config.env`** para facilitar a manutenção e personalização.

### Armazenamento Local

Os dados do banco de dados PostgreSQL são armazenados localmente no diretório `./postgres-data/` dentro do projeto:

- **Vantagens**: 
  - Dados ficam no projeto (fácil backup/restore)
  - Não depende de volumes Docker
  - Fácil migração entre ambientes
- **Localização**: `C:\GIT\Apache-Guacamole\postgres-data\`
- **Backup**: Copie o diretório `postgres-data` para fazer backup completo

### Configurações de Autenticação LDAP/Active Directory

Para usar autenticação LDAP ou Active Directory, descomente e configure as variáveis LDAP no arquivo `config.env`:

```bash
# Configurações LDAP
LDAP_HOSTNAME=seu-servidor-ldap.com
LDAP_PORT=389
LDAP_USER_BASE_DN=ou=users,dc=empresa,dc=com
LDAP_USERNAME_ATTRIBUTE=uid
LDAP_GROUP_BASE_DN=ou=groups,dc=empresa,dc=com
LDAP_SEARCH_BIND_DN=cn=admin,dc=empresa,dc=com
LDAP_SEARCH_BIND_PASSWORD=sua_senha_admin
```

### Configurações de Proxy Reverso

Se estiver usando um proxy reverso (Nginx, Apache, etc.), configure no arquivo `config.env`:

```bash
REMOTE_IP_VALVE_ENABLED=true
PROXY_ALLOWED_IPS_REGEX=^192\.168\.\d+\.\d+$
PROXY_BY_HEADER=X-Forwarded-By
PROXY_IP_HEADER=X-Forwarded-For
PROXY_PROTOCOL_HEADER=X-Forwarded-Proto
```

## 🔧 Comandos Úteis

```bash
# Parar todos os serviços
docker-compose down

# Parar e remover volumes (CUIDADO: apaga dados!)
docker-compose down -v

# Reiniciar um serviço específico
docker-compose restart guacamole

# Ver logs de um serviço
docker-compose logs -f guacamole

# Executar comandos no container
docker-compose exec postgres psql -U guacamole_user -d guacamole_db

# Backup do banco de dados
docker-compose exec postgres pg_dump -U guacamole_user guacamole_db > backup.sql

# Restaurar backup
docker-compose exec -T postgres psql -U guacamole_user -d guacamole_db < backup.sql

# Backup dos dados locais (cópia do diretório)
# Windows: xcopy postgres-data backup-postgres-data /E /I
# Linux/Mac: cp -r postgres-data backup-postgres-data
```

## 🔒 Segurança

### Configurações Recomendadas

1. **Altere as senhas padrão**:
   - Senha do banco de dados no arquivo `.env`
   - Senha do usuário admin do Guacamole

2. **Use HTTPS em produção**:
   - Configure um proxy reverso com SSL
   - Use certificados válidos

3. **Restrinja acesso à rede**:
   - Use firewalls para limitar acesso
   - Configure VPN se necessário

4. **Monitore logs**:
   - Configure rotação de logs
   - Monitore tentativas de acesso

## 🐛 Troubleshooting

### Problemas Comuns

**1. Container não inicia**
```bash
# Verificar logs
docker-compose logs guacamole

# Verificar se a porta está em uso
netstat -tulpn | grep :8080
```

**2. Erro de conexão com banco**
```bash
# Verificar se o PostgreSQL está rodando
docker-compose ps postgres

# Verificar logs do PostgreSQL
docker-compose logs postgres
```

**3. Guacamole não carrega**
```bash
# Verificar se todos os serviços estão saudáveis
docker-compose ps

# Aguardar inicialização completa
docker-compose logs -f guacamole
```

### Health Checks

Todos os serviços possuem health checks configurados:

```bash
# Verificar status de saúde
docker-compose ps
```

## 📚 Recursos Adicionais

- [Documentação Oficial do Guacamole](https://guacamole.apache.org/doc/gug/)
- [Guia de Instalação Docker](https://guacamole.apache.org/doc/gug/guacamole-docker.html)
- [Configuração de Autenticação](https://guacamole.apache.org/doc/gug/authentication.html)
- [Extensões Disponíveis](https://guacamole.apache.org/doc/gug/extensions.html)

## 🤝 Contribuição

1. Fork o projeto
2. Crie uma branch para sua feature (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'Add some AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

## 📄 Licença

Este projeto está sob a licença Apache 2.0. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## ⚠️ Disclaimer

Este é um projeto de exemplo baseado na documentação oficial do Apache Guacamole. Sempre revise e teste as configurações antes de usar em produção.
