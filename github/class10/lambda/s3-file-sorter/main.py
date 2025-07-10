import boto3

# Configure your bucket and prefix here
bucket = 'trial-demo-1234'  # Replace with your S3 bucket name
prefix = 'files/'

s3_client = boto3.client('s3')

def handler(event=None, context=None):
    response = s3_client.list_objects(
        Bucket=bucket,
        Prefix=prefix,
        Delimiter="/"
    ).get('Contents', [])

    for obj in response:
        file_key = obj.get('Key')
        if not file_key or not file_key.endswith('.txt'):
            continue

        filename = file_key.split('/')[-1]
        name_parts = filename.replace('.txt', '').split('-')

        # Expected format: filename-<ID>-<YEAR>-<MONTH>-<DAY>.txt (5 parts)
        if len(name_parts) != 5:
           #print(f"Skipping invalid filename (unexpected format): {filename}")
            continue

        day = name_parts[4]
        month = name_parts[3]
        year = name_parts[2]

        new_key = f"{prefix}{year}/{month}/{day}/{filename}"

        s3_client.copy_object(
            Bucket=bucket,
            CopySource={'Bucket': bucket, 'Key': file_key},
            Key=new_key
        )
        s3_client.delete_object(Bucket=bucket, Key=file_key)

       #print(f"Moved {file_key} → {new_key}")

def main():
    #print("Starting S3 file sorter...")
    handler()
    #print("Done.")

if __name__ == "__main__":
    main()