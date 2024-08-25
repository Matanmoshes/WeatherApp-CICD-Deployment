FROM python:3.9-slim

# Set the working directory inside the container
WORKDIR /app

# Copy the app directory contents to the working directory in the container
COPY ./app /app

# Copy the requirements.txt file to the working directory in the container
COPY requirements.txt /app

# Upgrade pip to the latest version
RUN pip install --upgrade pip

# Install the Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Expose the port that the Flask app will run on
EXPOSE 5000

# Set the FLASK_APP environment variable to point to your Flask application
ENV FLASK_APP=app.py

# Define build-time argument for the API key
ARG OPENWEATHER_API_KEY

# Set the environment variable in the container using the build-time argument
ENV OPENWEATHER_API_KEY=${OPENWEATHER_API_KEY}

# Run the Flask application
CMD ["flask", "run", "--host=0.0.0.0", "--port=5000"]