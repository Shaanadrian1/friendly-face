FROM python:3.11-slim

WORKDIR /app

# --- Install Python deps ---
# dlib-bin = precompiled dlib wheel (no cmake/gcc build needed = no OOM during build)
# face_recognition's own setup.py hard-requires the real "dlib" package name, which pip
# doesn't know dlib-bin satisfies, so it tries to build dlib from source and fails
# (no cmake in this image). Fix: install face_recognition with --no-deps, then install
# its actual small deps (Click, face_recognition_models) manually.
COPY requirements.txt .
RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir dlib-bin \
    && pip install --no-cache-dir Click face_recognition_models \
    && pip install --no-cache-dir --no-deps face_recognition==1.3.0 \
    && grep -v '^face_recognition==' requirements.txt > /tmp/reqs.txt \
    && pip install --no-cache-dir -r /tmp/reqs.txt

# --- Copy app code ---
COPY . .

# Render injects the port to listen on via the $PORT env variable
EXPOSE 10000
CMD ["sh", "-c", "uvicorn main:app --host 0.0.0.0 --port ${PORT:-10000}"]
