#!/usr/bin/env bash
# Prepara el proyecto en macOS / Linux: crea .venv, instala librerías y copia .env
set -e
cd "$(dirname "$0")"

echo "→ Creando entorno virtual .venv"
python3 -m venv .venv

echo "→ Instalando librerías"
.venv/bin/python -m pip install --upgrade pip -q
.venv/bin/python -m pip install -r requirements-dev.txt -q

if [ ! -f .env ]; then
  cp .env.example .env
  echo "→ Se creó el archivo .env: edítalo con tu usuario y contraseña de PostgreSQL"
fi

echo ""
echo "Listo. Para iniciar la aplicación:"
echo "  source .venv/bin/activate"
echo "  python app.py"
echo "y abre http://127.0.0.1:5001"
