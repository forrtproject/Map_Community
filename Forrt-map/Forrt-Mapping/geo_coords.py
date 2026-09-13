"""Step 2 of the data pipeline: data/data.json -> data/coords_data.csv.

Run from Forrt-map/Forrt-Mapping/; the paths below are relative to that directory.
"""
import json
import pandas as pd
from geopy.geocoders import Nominatim
from geopy.extra.rate_limiter import RateLimiter
import os

INPUT_JSON = "data/data.json"
OUTPUT_CSV = "data/coords_data.csv"
# Nominatim's usage policy rejects requests with a generic or missing User-Agent header; see https://operations.osmfoundation.org/policies/nominatim/
OSM_USER_AGENT = "FORRT-Geocoding-Script/1.0"

def main():
    os.makedirs(os.path.dirname(OUTPUT_CSV), exist_ok=True)

    with open(INPUT_JSON) as f:
        data = json.load(f)

    df = pd.DataFrame(data)
    # Geocode each city once rather than once per member; the count drives marker size and colour
    city_counts = df.groupby('city').size().reset_index(name='count')

    geolocator = Nominatim(user_agent=OSM_USER_AGENT)
    # Nominatim allows at most 1 request/second; faster clients get blocked
    geocode = RateLimiter(geolocator.geocode, min_delay_seconds=1)

    # Bare city names take Nominatim's top match, so ambiguous names can land in the wrong place.
    # Errors are logged rather than raised so one bad name doesn't abort a long run.
    def get_coords(city):
        try:
            location = geocode(city)
            if location:
                return pd.Series([location.latitude, location.longitude])
            return pd.Series([None, None])
        except Exception as e:
            print(f"Error geocoding {city}: {str(e)}")
            return pd.Series([None, None])

    print(f"Geocoding {len(city_counts)} cities...")
    city_counts[['lat', 'lon']] = city_counts['city'].apply(get_coords)

    # Dropped cities disappear from the map entirely; check the errors printed above
    geocoded = city_counts.dropna(subset=['lat', 'lon'])

    geocoded.to_csv(OUTPUT_CSV, index=False)
    print(f"Saved coordinates for {len(geocoded)} cities to {OUTPUT_CSV}")

if __name__ == "__main__":
    main()
