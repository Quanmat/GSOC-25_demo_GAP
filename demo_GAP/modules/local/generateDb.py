import json
import os

def generate_trackDb(metadata_dir, output_file):
    tracks = []
    for root, _, files in os.walk(metadata_dir):
        for file in files:
            if file.endswith(".json"):
                with open(os.path.join(root, file)) as f:
                    data = json.load(f)
                    track_entry = (
                        f"track type={data['type']} name=\"{data['name']}\" "
                        f"description=\"{data['description']}\" "
                        f"color={data['color']} "
                        f"bigDataUrl={data['path']}\n"
                    )
                    tracks.append(track_entry)
    with open(output_file, 'w') as f:
        f.writelines(tracks)

if __name__ == "__main__":
    generate_trackDb("results/track_hub/metadata", "results/track_hub/trackDb.txt")