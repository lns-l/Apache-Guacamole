# Apache Guacamole Docker Compose

Este projeto fornece uma configuração Docker Compose completa e **automatizada** para o Apache Guacamole, seguindo as melhores práticas da documentação oficial.

## ✨ Características

- **🚀 Inicialização Automática**: Schema do banco aplicado automaticamente na primeira execução
- **📦 Portabilidade Total**: Funciona em qualquer servidor sem configuração manual
- **🔧 Configuração Centralizada**: Todas as variáveis em `config.env`
- **💾 Volume Nomeado**: Dados do PostgreSQL gerenciados pelo Docker
- **🛡️ Health Checks**: Monitoramento automático de todos os serviços

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

# Copie o arquivo de exemplo e edite as configurações
cp config.env.example config.env
nano config.env

# IMPORTANTE: Altere a senha do banco de dados e outras configurações sensíveis
```

### 2. Executar o Ambiente

```bash
# Iniciar todos os serviços (funciona automaticamente!)
docker-compose up -d

# Verificar o status dos containers
docker-compose ps

# Ver os logs
docker-compose logs -f
```

### 3. Acessar o Guacamole

Abra seu navegador e acesse:
- **URL**: http://localhost/guacamole/
- **Usuário padrão**: guacadmin
- **Senha padrão**: guacadmin

⚠️ **IMPORTANTE**: 
- Altere a senha padrão imediatamente após o primeiro login!
- **TOTP está habilitado** - você precisará configurar um app autenticador na primeira vez

### 4. Configurar Autenticação Multifator (TOTP)

Na primeira vez que fizer login, você será solicitado a configurar TOTP:

1. **Faça login** com usuário/senha padrão
2. **Escaneie o QR Code** com seu app autenticador:
   - Google Authenticator
   - Microsoft Authenticator
   - Authy
   - FreeOTP
3. **Digite o código** de 6 dígitos gerado pelo app
4. **Confirme a configuração**

📱 **Apps Recomendados**:
- **Android/iOS**: Google Authenticator, Microsoft Authenticator
- **Desktop**: Authy, WinAuth (Windows)

## 🏗️ Arquitetura

O ambiente é composto por três containers principais:

### 1. PostgreSQL (`postgres`)
- **Imagem**: postgres:15-alpine
- **Função**: Banco de dados para autenticação e configurações
- **Porta**: 5432 (interna)
- **Armazenamento**: Volume nomeado `postgres_data` (gerenciado pelo Docker)

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
WEBAPP_CONTEXT=guacamole

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

# Configurações TOTP (Autenticação Multifator)
TOTP_ENABLED=true
TOTP_ISSUER=Apache Guacamole
TOTP_DIGITS=6
TOTP_PERIOD=30
TOTP_MODE=sha1
```

**Todas as configurações estão centralizadas no arquivo `config.env`** para facilitar a manutenção e personalização.

### Armazenamento

Os dados do banco de dados PostgreSQL são armazenados em um **volume nomeado** gerenciado pelo Docker:

- **Vantagens**: 
  - Dados persistem entre reinicializações
  - Fácil backup/restore com comandos Docker
  - Portabilidade entre diferentes locais de execução
- **Volume**: `apache-guacamole_postgres_data`
- **Backup**: Use `docker volume` commands para backup

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

### Configurações de Autenticação Multifator (TOTP)

O sistema inclui autenticação multifator TOTP habilitada por padrão. Configure no arquivo `config.env`:

```bash
# Habilitar/desabilitar TOTP
TOTP_ENABLED=true

# Nome da entidade (aparece no app autenticador)
TOTP_ISSUER=Apache Guacamole

# Número de dígitos (6, 7 ou 8)
TOTP_DIGITS=6

# Duração do código em segundos
TOTP_PERIOD=30

# Algoritmo de hash (sha1, sha256, sha512)
TOTP_MODE=sha1

# Bypass TOTP para IPs específicos (opcional)
# TOTP_BYPASS_HOSTS=192.168.1.0/24,10.0.0.0/8

# Forçar TOTP apenas para IPs específicos (opcional)
# TOTP_ENFORCE_HOSTS=0.0.0.0/0
```

**Como Funciona**:
1. **Primeiro fator**: Usuário/senha (autenticação normal)
2. **Segundo fator**: Código TOTP de 6 dígitos (30 segundos de validade)
3. **Apps compatíveis**: Google Authenticator, Microsoft Authenticator, Authy, FreeOTP

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

# Backup do volume Docker
docker run --rm -v apache-guacamole_postgres_data:/data -v $(pwd):/backup alpine tar czf /backup/postgres-backup.tar.gz -C /data .

# Restaurar volume Docker
docker run --rm -v apache-guacamole_postgres_data:/data -v $(pwd):/backup alpine tar xzf /backup/postgres-backup.tar.gz -C /data
```

## 🔒 Segurança

### Configurações Recomendadas

1. **Altere as senhas padrão**:
   - Senha do banco de dados no arquivo `config.env`
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

**4. Problemas com TOTP**
```bash
# Verificar se TOTP está habilitado nos logs
docker-compose logs guacamole | grep -i totp

# Resetar TOTP de um usuário (via interface web)
# 1. Acesse a interface de administração
# 2. Vá em Settings > Users
# 3. Edite o usuário
# 4. Marque "Clear TOTP secret" e salve
```

**5. Problemas de inicialização do banco**
```bash
# Se houver problemas com o schema, force uma reinicialização:
docker-compose down
docker volume rm apache-guacamole_postgres_data
docker-compose up -d
```

### Health Checks

Todos os serviços possuem health checks configurados:

```bash
# Verificar status de saúde
docker-compose ps
```

## 📁 Estrutura do Projeto

```
Apache-Guacamole/
├── docker-compose.yml          # Configuração principal do Docker Compose
├── config.env                  # Configurações centralizadas (criar a partir do exemplo)
├── config.env.example          # Exemplo de configurações
├── init-db/
│   └── 01-guacamole-schema.sql # Schema do banco (gerado automaticamente)
└── README.md                   # Este arquivo
```

## 🚀 Deploy em Novo Servidor

Para deploy em um novo servidor:

1. **Copie o projeto** para o servidor
2. **Configure** o arquivo `config.env`
3. **Execute** `docker-compose up -d`
4. **Acesse** `http://SEU_IP:8080/guacamole/`

**É isso! O sistema funciona automaticamente sem configuração manual adicional.**

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