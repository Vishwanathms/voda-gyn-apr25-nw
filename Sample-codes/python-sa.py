from azure.storage.blob import ContainerClient
from PIL import Image
import requests
from io import BytesIO

# ✅ Replace with your actual SAS URL for the container
SAS_URL = "https://<your_storage_account>.blob.core.windows.net/<container_name>?<SAS_TOKEN>"

# Connect to the container using the SAS URL
container_client = ContainerClient.from_container_url(SAS_URL)

# List blobs in the container
print("Fetching image list...")
blob_list = container_client.list_blobs()

for blob in blob_list:
    print(f"Found blob: {blob.name}")

    # Form the full blob URL using the container SAS URL + blob name
    blob_url = f"{SAS_URL.split('?')[0]}/{blob.name}?{SAS_URL.split('?')[1]}"

    print(f"Downloading: {blob_url}")

    # Download the image
    response = requests.get(blob_url)
    if response.status_code == 200:
        img = Image.open(BytesIO(response.content))
        img.show()  # Opens the image using default image viewer
    else:
        print(f"Failed to download {blob.name}, Status Code: {response.status_code}")
