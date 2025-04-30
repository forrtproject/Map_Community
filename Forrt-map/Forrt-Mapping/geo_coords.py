# geocode_cities.py
import json
import pandas as pd
from geopy.geocoders import Nominatim
from geopy.extra.rate_limiter import RateLimiter
import os
from time import sleep

# Configuration
INPUT_JSON = "data/data.json"
OUTPUT_CSV = "data/coords_data.csv"
OSM_USER_AGENT = "FORRT-Geocoding-Script/1.0"  # Required for Nominatim usage

def main():
    # Create data directory if needed
    os.makedirs(os.path.dirname(OUTPUT_CSV), exist_ok=True)

    # Load and process JSON data
    with open(INPUT_JSON) as f:
        data = json.load(f)
    
    df = pd.DataFrame(data)
    city_counts = df.groupby('city').size().reset_index(name='count')

    # Set up geocoder with rate limiting (1 request/sec)
    geolocator = Nominatim(user_agent=OSM_USER_AGENT)
    geocode = RateLimiter(geolocator.geocode, min_delay_seconds=1)

    # Geocoding function with error handling
    def get_coords(city):
        try:
            location = geocode(city)
            if location:
                return pd.Series([location.latitude, location.longitude])
            return pd.Series([None, None])
        except Exception as e:
            print(f"Error geocoding {city}: {str(e)}")
            return pd.Series([None, None])

    # Geocode cities and merge with counts
    print(f"Geocoding {len(city_counts)} cities...")
    city_counts[['lat', 'lon']] = city_counts['city'].apply(get_coords)
    
    # Remove failed geocodes
    geocoded = city_counts.dropna(subset=['lat', 'lon'])
    
    # Save results
    geocoded.to_csv(OUTPUT_CSV, index=False)
    print(f"Saved coordinates for {len(geocoded)} cities to {OUTPUT_CSV}")

if __name__ == "__main__":
    main()
