FROM python:3.9-slim

RUN pip install --upgrade pip
RUN useradd -m appuser
USER appuser

WORKDIR /app

COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

COPY configure-key.py /app/
CMD ["python", "/app/configure-key.py"]