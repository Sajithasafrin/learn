import boto3
import os
import io
from PIL import Image
from reportlab.pdfgen import canvas
from reportlab.lib.pagesizes import letter
import pandas as pd
#from docx2pdf import convert
import tempfile
import subprocess

# Initialize S3 client
s3 = boto3.client('s3')

# Define buckets
SOURCE_BUCKET = os.environ["source_bucket"]
TARGET_BUCKET = os.environ["destination_bucket"]


# List objects in source bucket
def list_files(bucket):
    response = s3.list_objects_v2(Bucket=bucket)
    return [item['Key'] for item in response.get('Contents', [])]

def txt_to_pdf(file_bytes):
    buffer = io.BytesIO()
    c = canvas.Canvas(buffer, pagesize=letter)
    text = file_bytes.decode('utf-8')
    y = 750
    for line in text.split('\n'):
        c.drawString(50, y, line)
        y -= 15
        if y < 50:
            c.showPage()
            y = 750
    c.save()
    buffer.seek(0)
    return buffer

def jpeg_to_pdf(file_bytes):
    image = Image.open(io.BytesIO(file_bytes)).convert('RGB')
    pdf_buffer = io.BytesIO()
    image.save(pdf_buffer, format='PDF')
    pdf_buffer.seek(0)
    return pdf_buffer

def excel_to_pdf(file_bytes):
    df = pd.read_excel(io.BytesIO(file_bytes))
    buffer = io.BytesIO()
    c = canvas.Canvas(buffer, pagesize=letter)
    y = 750
    for i, row in df.iterrows():
        line = ', '.join([str(cell) for cell in row])
        c.drawString(30, y, line)
        y -= 15
        if y < 50:
            c.showPage()
            y = 750
    c.save()
    buffer.seek(0)
    return buffer

def word_to_pdf(file_bytes, filename):
    import tempfile

    with tempfile.TemporaryDirectory() as tmpdir:
        input_path = os.path.join(tmpdir, filename)
        output_dir = tmpdir

        # Save the Word file
        with open(input_path, 'wb') as f:
            f.write(file_bytes)

        # Convert using LibreOffice in headless mode
        try:
            subprocess.run([
                "libreoffice",
                "--headless",
                "--convert-to", "pdf",
                "--outdir", output_dir,
                input_path
            ], check=True)
        except subprocess.CalledProcessError as e:
            raise RuntimeError(f"LibreOffice conversion failed: {e}")

        # Read the converted PDF
        pdf_path = os.path.splitext(input_path)[0] + ".pdf"
        with open(pdf_path, 'rb') as pdf_file:
            return io.BytesIO(pdf_file.read())

def process_files():
    files = list_files(SOURCE_BUCKET)
    for key in files:
        _, ext = os.path.splitext(key.lower())
        ext = ext.lstrip('.')
        file_obj = s3.get_object(Bucket=SOURCE_BUCKET, Key=key)
        file_bytes = file_obj['Body'].read()

        if ext == 'txt':
            pdf_buffer = txt_to_pdf(file_bytes)
            target_key = f"txt/{os.path.splitext(os.path.basename(key))[0]}.pdf"
        elif ext in ['jpeg', 'jpg']:
            pdf_buffer = jpeg_to_pdf(file_bytes)
            target_key = f"jpeg/{os.path.splitext(os.path.basename(key))[0]}.pdf"
        elif ext in ['xls', 'xlsx']:
            pdf_buffer = excel_to_pdf(file_bytes)
            target_key = f"excel/{os.path.splitext(os.path.basename(key))[0]}.pdf"
        elif ext in ['doc', 'docx']:
            pdf_buffer = word_to_pdf(file_bytes, os.path.basename(key))
            target_key = f"word/{os.path.splitext(os.path.basename(key))[0]}.pdf"
        else:
            print(f"Skipping unsupported file: {key}")
            continue

        s3.upload_fileobj(pdf_buffer, TARGET_BUCKET, target_key)
        print(f"Converted and uploaded: {target_key}")

#if __name__ == "__main__":
 # process_files()

def lambda_handler(event, context):
    process_files()
    return {
        'statusCode': 200,
        'body': 'File conversion complete.'
    }
