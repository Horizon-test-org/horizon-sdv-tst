FROM python:3.9-slim
WORKDIR /app
COPY configure-key.py /app/
COPY requirements.txt /app/
RUN pip install -r requirements.txt
CMD ["python", "/app/my_script.py"]