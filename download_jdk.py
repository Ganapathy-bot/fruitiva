import urllib.request
import zipfile
import os

url = 'https://api.adoptium.net/v3/binary/latest/17/ga/windows/x64/jdk/hotspot/normal/eclipse'
print('Downloading JDK 17...')
req = urllib.request.Request(
    url,
    headers={'User-Agent': 'Mozilla/5.0'}
)
with urllib.request.urlopen(req) as response, open('jdk17.zip', 'wb') as out_file:
    out_file.write(response.read())

print('Extracting JDK 17...')
with zipfile.ZipFile('jdk17.zip', 'r') as zip_ref:
    zip_ref.extractall('jdk17')
print('Done!')
