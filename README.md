# ctr-mysql - MySQL com Docker Compose

Ambiente padrao de MySQL 8.x com Docker Compose, configurado por variaveis de ambiente e scripts de inicializacao para criar bancos/usuarios de sistemas (GLPI, Zabbix, Grafana).

## Recursos

- MySQL com `utf8mb4` por padrao
- IP fixo na rede Docker externa `network-share`
- Inicializacao automatica via `mysql-init/`
- Variaveis de ambiente centralizadas em `.env`

## Estrutura do repositorio

```plaintext
.
├── databases/           # Dados persistentes do MySQL (host)
├── mysql-init/          # Scripts executados na primeira subida
├── docker-compose.yml   # Servico MySQL
├── .env.example         # Exemplo de configuracao
└── README.md            # Este documento
```

## Requisitos

- [Docker e Docker Compose](https://docs.docker.com/engine/install/)
- Rede Docker externa `network-share` criada

## Configuracao

### 1. Arquivo .env

Crie o arquivo `.env` a partir do exemplo:

```bash
cp .env.example .env
```

Edite os valores conforme o seu ambiente. Principais variaveis:

- `CONTAINER_NAME`, `RELEASE`
- `IPV4_ADDRESS`, `SUBNET`
- `PORTS_MYSQL`
- `MYSQL_ROOT_PASSWORD`
- `MYSQL_*_USER` e `MYSQL_*_PASSWORD` (GLPI, Zabbix, Grafana)
- `BASE_DIR`, `VOL_DATABASES_PATH`, `VOL_MYSQL_INIT`

### 2. Rede Docker externa

Se a rede ainda nao existir:

```bash
docker network create --driver bridge network-share --subnet=172.18.0.0/16
```

## Subindo o servico

```bash
# Na pasta do container execute

docker compose up -d
```

Verifique:

```bash
docker ps | grep ctr-mysql
```

Logs:

```bash
docker logs -f ctr-mysql
```

## Inicializacao de bancos e usuarios

Os scripts em `mysql-init/` são executados na primeira inicializacao do container e criam os bancos/usuarios configurados no `.env`.

- `mysql-init/01-glpi.sh`
- `mysql-init/02-zabbix.sh`
- `mysql-init/03-grafana.sh`

## Operacoes comuns

Parar e subir novamente:

```bash
docker compose stop

docker compose up -d
```

Acessar o container:

```bash
docker exec -it ctr-mysql bash
```

## Backup e restore

### Backup

```bash
docker exec -i ctr-mysql mysqldump -uroot -p'SENHA_DO_ROOT' nome_da_base > /tmp/backup.sql
```

### Restore

1) Copie o arquivo `.sql` para o host (ex.: `/tmp`).
2) Envie o arquivo para o container:

```bash
docker cp /tmp/backup.sql ctr-mysql:/tmp/backup.sql
```

3) Restaure dentro do container:

```bash
docker exec -it ctr-mysql bash
mysql -uroot -p
```

```sql
CREATE DATABASE IF NOT EXISTS nome_da_base
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;
```

```bash
mysql -uroot -p'SENHA_DO_ROOT' nome_da_base < /tmp/backup.sql
```

## Troubleshooting

- Erro de rede: confirme que `network-share` existe e que `SUBNET` e `IPV4_ADDRESS` nao conflitam.
- Scripts nao executaram: scripts em `mysql-init/` rodam apenas na primeira inicializacao (volume vazio).
- Permissao de volume: valide `BASE_DIR` e caminhos em `VOL_DATABASES_PATH`.
