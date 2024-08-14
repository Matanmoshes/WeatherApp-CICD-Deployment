import pytest
from flask import url_for
from unittest.mock import patch
import os

# Import the app from your main application
from app import app

@pytest.fixture
def client():
    app.config['TESTING'] = True
    with app.test_client() as client:
        yield client

# Mock response data for the OpenWeather API
mock_weather_data = {
    "timezone": 3600,  # Example timezone offset in seconds
    "main": {
        "temp": 15,
        "feels_like": 14,
        "temp_min": 10,
        "temp_max": 20,
    },
    "weather": [{
        "description": "clear sky",
    }],
    "name": "London"
}

@patch('app.requests.get')
def test_index_get(mock_get, client):
    # Test the GET request
    response = client.get('/')
    assert response.status_code == 200
    assert b'Weather Information' in response.data

@patch('app.requests.get')
def test_index_post(mock_get, client):
    # Mock the API response
    mock_get.return_value.json.return_value = mock_weather_data

    # Test the POST request with a sample city
    response = client.post('/', data={'city': 'London'})
    
    assert response.status_code == 200
    assert b'London' in response.data
    assert b'clear sky' in response.data
    assert b'15' in response.data  # Temp in Celsius
    
    # Check that the local time is correctly calculated
    assert b'Local time' in response.data

def test_api_key():
    # Ensure the API key is loaded from the environment
    assert os.getenv('OPENWEATHER_API_KEY') is not None

