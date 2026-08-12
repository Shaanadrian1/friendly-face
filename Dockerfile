FROM python:3.11-slim

# --- System dependencies needed to build dlib (same as nixpacks.toml did for Railway) ---
RUN apt-get update && apt-get install -y --no-install-recommends \
    cmake \
    build-essential \
    libopenblas-dev \
    liblapack-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# --- Install Python deps (dlib first, same order as nixpacks.toml) ---
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir cmake \
    && pip install --no-cache-dir dlib \
    && pip install --no-cache-dir -r requirements.txt

# --- Copy app code ---
COPY . .

# Render injects the port to listen on via the $PORT env variable
EXPOSE 10000
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT:-10000}"]
