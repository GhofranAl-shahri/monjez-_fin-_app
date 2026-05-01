import os

folder = 'screenshots'
for filename in os.listdir(folder):
    if ' ' in filename:
        new_name = filename.replace(' ', '_').replace('__', '_')
        os.rename(os.path.join(folder, filename), os.path.join(folder, new_name))
        print(f'Renamed: {filename} -> {new_name}')
