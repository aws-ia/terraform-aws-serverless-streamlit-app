# syntax=docker/dockerfile:1.4
FROM --platform=linux/amd64 python:3.11-slim
WORKDIR /app
COPY requirements.txt ./requirements.txt
RUN pip3 install -r requirements.txt
EXPOSE 8501
COPY . .
ENTRYPOINT ["streamlit", "run", "streamlit_sample.py", "--server.port=8501", "--server.address=0.0.0.0"]
