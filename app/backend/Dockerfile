# ========== STAGE 1: Build ==========
FROM python:3.11-slim as builder

WORKDIR /app

# Instalar dependencias de sistema
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements
COPY requirements/production.txt .
RUN pip install --no-cache-dir -r production.txt

# ========== STAGE 2: Runtime ==========
FROM python:3.11-slim

# Crear usuario no-root
RUN addgroup --system --gid 1001 appgroup && \
    adduser --system --uid 1001 --gid 1001 appuser

WORKDIR /app

# Instalar runtime dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar dependencias del builder
COPY --from=builder /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin

# Copiar código fuente
COPY src/ ./src/
COPY ../frontend/ ./frontend/

# Copiar frontend a static/templates
RUN mkdir -p src/static src/templates && \
    cp -r frontend/static/* src/static/ && \
    cp -r frontend/templates/* src/templates/

# Cambiar ownership
RUN chown -R appuser:appgroup /app

# Cambiar a usuario no-root
USER appuser

# Variables de entorno
ENV PYTHONPATH=/app/src
ENV PYTHONUNBUFFERED=1

# Puerto
EXPOSE 8000

# Comando de inicio
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]