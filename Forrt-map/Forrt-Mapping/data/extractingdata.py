"""Step 1 of the data pipeline: ****.json -> data.json.

Run from the data/ directory; the paths below are relative to it. users.json is not available due to privacy concerns.
only the time zone information is available, so the city in their time zone name stands in for it.
"""
import json

with open('users.json', 'r') as f:
    json_data = json.load(f)

output_data = []

for item in json_data:
    id_value = item.get('id', '')
    tz_value = item.get('tz', '')

    # Skip members without a timezone; an empty city can't be geocoded anyway
    if not tz_value:
        continue

    # Take the last segment so three-part zones (America/Indiana/Indianapolis) resolve
    # to the city, and restore spaces (New_York -> New York) for geocoding and display
    city_name = tz_value.split('/')[-1].replace('_', ' ')

    output_data.append({"id": id_value, "city": city_name})

with open('data.json', 'w') as outfile:
    json.dump(output_data, outfile, indent=2)

print("Data extraction and saving complete.")
