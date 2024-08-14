FROM python:3.9-slim

WORKDIR /app

COPY . /app

RUN pip install --no-cache-dir -r requirements.txt

EXPOSE 5000

ENV FLASK_APP=app.py

# Define build-time argument
ARG OPENWEATHER_API_KEY

# Set the environment variable at build-time from the ARG
ENV OPENWEATHER_API_KEY=${OPENWEATHER_API_KEY}

# Run app.py when the container launches
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]
