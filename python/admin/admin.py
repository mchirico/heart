#!/usr/env python
import firebase_admin
from firebase_admin import credentials
from firebase_admin import storage


from os.path import expanduser
home = expanduser("~")

print(home)
cred = credentials.Certificate(home+'/.firebase_heart/'
                                    'heart-HeartFirebase.json')
#  default_app = firebase_admin.initialize_app(cred)


firebase_admin.initialize_app(cred, {
    'storageBucket': 'heart-pigbot.appspot.com'
})

bucket = storage.bucket()
uploadBlob = bucket.blob('junk2.txt');
print(uploadBlob)

uploadBlob.upload_from_filename(
    filename='./junk.txt');


download = bucket.get_blob('HeartRate.csv')
# print(download.download_as_string())
download.download_to_filename('HeartRate.csv')



print("test here...")
print(bucket)



