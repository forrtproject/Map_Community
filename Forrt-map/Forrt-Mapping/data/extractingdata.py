import json

# Load the JSON data from your source file (assuming the data is stored in `users.json`)
with open('users.json', 'r') as f:
    json_data = json.load(f)

# Initialize a list to store the extracted data
output_data = []

# Iterate through each object in the JSON data
for item in json_data:
    # Extract id and tz fields
    id_value = item.get('id', '')
    tz_value = item.get('tz', '')

    # Format tz_value as city (if desired)
    city_name = tz_value.split('/')[1] if '/' in tz_value else tz_value

    # Append id and city to output_data
    output_data.append({"id": id_value, "city": city_name})

# Save the extracted data to a new JSON file
with open('data.json', 'w') as outfile:
    json.dump(output_data, outfile, indent=2)

print("Data extraction and saving complete.")
