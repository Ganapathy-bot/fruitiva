import zipfile
import os

with zipfile.ZipFile('jdk17.zip', 'r') as zip_ref:
    for member in zip_ref.infolist():
        parts = member.filename.split('/')
        if len(parts) > 1:
            parts[0] = 'jdk17_home'
            member.filename = '/'.join(parts)
            zip_ref.extract(member, '.')
print('Extracted to jdk17_home')
