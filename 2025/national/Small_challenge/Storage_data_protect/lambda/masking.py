import json
import boto3
import re
import urllib.parse

s3 = boto3.client('s3')

def mask_names(text):
    """Mask names: Crystal White -> Crystal *****"""
    lines = text.split('\n')
    masked_lines = []
    for line in lines:
        parts = line.strip().split()
        masked_parts = parts[:-1] + ['*****']
        masked_lines.append(' '.join(masked_parts))
    return '\n'.join(masked_lines)

def mask_emails(text):
    """Mask emails: davisjesus@example.org -> d*********@example.org"""
    def mask_email(match):
        email = match.group(0)
        local, domain = email.split('@')
        masked_local = local[0] + '*' * (len(local) - 1)
        return f"{masked_local}@{domain}"

    pattern = r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}'
    return re.sub(pattern, mask_email, text)

def mask_phones(text):
    """Mask phones: 010-7658-5153 -> 010-7658-****"""
    pattern = r'(\d{3}-\d{4}-)(\d{4})'
    return re.sub(pattern, r'\1****', text)

def mask_ssns(text):
    """Mask SSNs: 887-07-7325 -> 887-07-****"""
    pattern = r'(\d{3}-\d{2}-)(\d{4})'
    return re.sub(pattern, r'\1****', text)

def mask_credit_cards(text):
    """Mask credit cards: 4468-6779-7028-4776 -> 4468-6779-7028-****"""
    pattern = r'(\d{4}-\d{4}-\d{4}-)(\d{4})'
    return re.sub(pattern, r'\1****', text)

def mask_uuids(text):
    """Mask UUIDs: 665ef2db-cd63-4086-81e9-661ccaf8dd20 -> 665ef2db-cd63-4086-81e9-************"""
    pattern = r'([0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-)([0-9a-f]{12})'
    return re.sub(pattern, r'\1************', text, flags=re.IGNORECASE)

def lambda_handler(event, context):
    print(f"Event: {json.dumps(event)}")

    for record in event.get('Records', []):
        bucket = record['s3']['bucket']['name']
        key = urllib.parse.unquote_plus(record['s3']['object']['key'])

        print(f"Processing file: s3://{bucket}/{key}")

        # Only process files in incoming/ prefix
        if not key.startswith('incoming/'):
            print(f"Skipping file not in incoming/: {key}")
            continue

        # Skip directory markers
        if key.endswith('/'):
            print(f"Skipping directory marker: {key}")
            continue

        try:
            # Get the file from S3
            response = s3.get_object(Bucket=bucket, Key=key)
            content = response['Body'].read().decode('utf-8')

            # Determine file type and apply masking
            filename = key.split('/')[-1]

            if 'names' in filename.lower():
                masked_content = mask_names(content)
            elif 'email' in filename.lower():
                masked_content = mask_emails(content)
            elif 'phone' in filename.lower():
                masked_content = mask_phones(content)
            elif 'ssn' in filename.lower():
                masked_content = mask_ssns(content)
            elif 'credit' in filename.lower() or 'card' in filename.lower():
                masked_content = mask_credit_cards(content)
            elif 'uuid' in filename.lower():
                masked_content = mask_uuids(content)
            else:
                # Apply all masking functions for unknown file types
                masked_content = content
                masked_content = mask_names(masked_content)
                masked_content = mask_emails(masked_content)
                masked_content = mask_phones(masked_content)
                masked_content = mask_ssns(masked_content)
                masked_content = mask_credit_cards(masked_content)
                masked_content = mask_uuids(masked_content)

            # Save to masked/ prefix
            masked_key = key.replace('incoming/', 'masked/', 1)
            s3.put_object(
                Bucket=bucket,
                Key=masked_key,
                Body=masked_content.encode('utf-8'),
                ContentType='text/plain'
            )

            print(f"Successfully masked and saved to: s3://{bucket}/{masked_key}")

        except Exception as e:
            print(f"Error processing {key}: {str(e)}")
            raise e

    return {
        'statusCode': 200,
        'body': json.dumps('Masking completed successfully')
    }
