from flask import Flask, render_template, request
import requests
from datetime import datetime, timedelta
import os

app = Flask(__name__)

# Load API key from environment variables for better security
API_KEY = os.getenv("OPENWEATHER_API_KEY")
BASE_URL = "http://api.openweathermap.org/data/2.5/weather"


@app.route('/', methods=['GET', 'POST'])
def index():
    weather_data = None
    local_time = None
    if request.method == 'POST':
        city = request.form['city']
        params = {
            'q': city,
            'appid': API_KEY,
            'units': 'metric'
        }
        response = requests.get(BASE_URL, params=params)
        weather_data = response.json()

        if weather_data and weather_data.get('timezone'):
            utc_time = datetime.utcnow()
            timezone_offset = weather_data['timezone']
            local_time = utc_time + timedelta(seconds=timezone_offset)
            local_time = local_time.strftime('%Y-%m-%d %H:%M:%S')

    return render_template('index.html', weather_data=weather_data, local_time=local_time)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
