#!/bin/bash

SRV4_PATH="/home/leandro/projetos/http-api-lab"
SRV2_USER="leandro"
SRV2_HOST="192.168.0.102"
SRV2_PATH="/home/leandro/www/app"
SRV2_PASS="14@213"

ARQUIVOS=(
  server.js
  index.html
  docker-compose.yml
  package.json
  README.md
  LEIA-ME.txt
  init.sql
  Dockerfile
  Instalar_Lab.bat
  .gitignore
)

echo '======================================'
echo '  SYNC http-api-lab → srv2/www/app'
echo '======================================'
echo ''

# recria o zip com os arquivos atuais
echo '[1/3] Atualizando zip...'
cd "$SRV4_PATH"
rm -f http-api-lab.zip
zip -r http-api-lab.zip . \
  --exclude '*.git*' \
  --exclude 'node_modules/*' \
  --exclude 'lab_postman.db' \
  --exclude 'http-api-lab.zip' \
  --quiet
echo '      ✓ http-api-lab.zip recriado'
echo ''

# sincroniza arquivos para o srv2
echo '[2/3] Sincronizando arquivos para srv2...'
for arquivo in "${ARQUIVOS[@]}" http-api-lab.zip; do
  sshpass -p "$SRV2_PASS" scp -o StrictHostKeyChecking=no \
    "$SRV4_PATH/$arquivo" \
    "$SRV2_USER@$SRV2_HOST:$SRV2_PATH/$arquivo" 2>/dev/null
  echo "      ✓ $arquivo"
done
echo ''

# commit e push no github
echo '[3/3] Commit e push no GitHub...'
cd "$SRV4_PATH"
git add -A
if git diff --cached --quiet; then
  echo '      Nenhuma mudanca para commitar.'
else
  git commit -m "Sync: $(date '+%Y-%m-%d %H:%M')"
  git push
  echo '      ✓ GitHub atualizado'
fi

echo ''
echo '======================================'
echo '  SYNC CONCLUIDO'
echo '======================================'
