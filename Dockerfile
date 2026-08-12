FROM python:3.11-slim

WORKDIR /app

# --- Install Python deps ---
# dlib-bin = precompiled dlib wheel (no cmake/gcc build needed = no OOM during build)
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir dlib-bin \
    && pip install --no-cache-dir -r requirements.txt

# --- Copy app code ---
COPY . .

# Render injects the port to listen on via the $PORT env variable
EXPOSE 10000
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT:-10000}"]
