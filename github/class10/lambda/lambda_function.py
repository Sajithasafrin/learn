import boto3
import json
from datetime import date
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

# CONFIG
GROUP_NAME = "third_party"  # <<< Replace with your IAM group
EXPIRY_DAYS = 30
REMINDER_EMAIL_AGE = 0
TO_EMAIL = "nisajudeen@gmail.com"
FROM_EMAIL = "sajitha0430@gmail.com"

def get_users_in_group(group_name):
    iam_client = boto3.client('iam')
    paginator = iam_client.get_paginator('get_group')
    users = []

    for response in paginator.paginate(GroupName=group_name):
        for user in response['Users']:
            users.append(user['UserName'])
    
    return users


def get_access_keys_age(username):
    iam_client = boto3.client('iam')
    response = iam_client.list_access_keys(UserName=username).get('AccessKeyMetadata', [])
    
    access_keys_info = []
    for item in response:
        if item['Status'] == 'Active':
            access_key_id = item['AccessKeyId']
            create_date = item['CreateDate'].date()
            age = (date.today() - create_date).days
            access_keys_info.append((access_key_id, age))
    
    return access_keys_info

   
def if_key_expired(username, access_key_id, age, reminder_email_age):
    if age >= reminder_email_age:
        return f'''
        <p>Reminder: Access key <strong>{access_key_id}</strong> for user <strong>{username}</strong> is <strong>{age}</strong> days old. Please rotate it.</p>
        <p>Visit <a href="https://us-east-1.console.aws.amazon.com/iam/home?region=ap-south-1#/users/details/{username}?section=security_credentials">IAM Console</a> to rotate the key.</p>
        '''
    return None


def process_group_users(group_name):
    email_body_list = []
    users = get_users_in_group(group_name)
    for user in users:
         
        #print(f"🔍 Checking user: {user}")  # DEBUG LINE
        access_keys_info = get_access_keys_age(user)
        for access_key_id, age in access_keys_info:
            #print(f"   - Access Key: {access_key_id}, Age: {age} days")  # DEBUG LINE
            email_body = if_key_expired(user, access_key_id, age, REMINDER_EMAIL_AGE)
            if email_body:
                email_body_list.append((user, email_body))  # include username for the subject
    return email_body_list


def build_email_message(to_email, from_email, subject, body):
    msg = MIMEMultipart()
    msg['From'] = from_email
    msg['To'] = to_email
    msg['Subject'] = subject

    body_part = MIMEText(body, 'html')
    msg.attach(body_part)

    return msg


def send_email(msg, to_emails):
    ses_client = boto3.client('ses')
    response = ses_client.send_raw_email(
        Source=msg["From"],
        Destinations=to_emails,
        RawMessage={"Data": msg.as_string()},
    )
    return response.get('MessageId', None)


def lambda_handler(event=None, context=None):
    #user_data = process_group_users(GROUP_NAME)
    #print("📦 Processed User Data:", user_data)  # DEBUG
    for username, email_body in process_group_users(GROUP_NAME):
        subject = f"AWS Access Key Rotation Reminder - User: {username}"
        email_msg = build_email_message(TO_EMAIL, FROM_EMAIL, subject, email_body)
        email_sent = send_email(email_msg, [TO_EMAIL])
        print(f"✅ Email sent for {username} with Message ID: {email_sent}")




