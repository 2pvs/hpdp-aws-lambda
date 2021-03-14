from PIL import Image
from io import BytesIO

def convert_jpeg(tiff_file):
    bio_jpeg = BytesIO()
    im = Image.open(tiff_file)
    im.save(bio_jpeg, format='jpeg', quality=15)
    return bio_jpeg