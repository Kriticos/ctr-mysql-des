#!/bin/bash

echo "📁 Iniciando preparação das pastas do ambiente..."

# Diretório onde o script está
BASE_DIR="$(dirname "$(realpath "$0")")"

# Pastas de dados (volumes persistentes)
DATA_DIRS=(
  "$BASE_DIR/databases"
)

# Criando diretórios
for DIR in "${DATA_DIRS[@]}"; do
  if [ ! -d "$DIR" ]; then
    echo "📂 Criando $DIR"
    mkdir -p "$DIR"
  else
    echo "✔️ Já existe: $DIR"
  fi
done

echo "🔧 Ajustando permissões..."
chmod -R 775 $BASE_DIR/databases
chmod +x $BASE_DIR/mysql-init/*.sh

# ou, para algo ainda mais seguro
find "$BASE_DIR/mysql-init" -name '*.sh' -exec chmod +x {} +


# Configurando rede Docker personalizada
if ! docker network ls | grep -q "network-share"; then
  echo "🌐 Criando rede network-share..."
  docker network create \
    --driver=bridge \
    --subnet=172.18.0.0/16 \
    network-share
fi

echo "✅ Preparação concluída!"
