dig +short <record_name> CNAME
_cf618dba0c052030bb07a3c1fd2d17a6.sajitha.tech
_cf618dba0c052030bb07a3c1fd2d17a6.sajitha.tech.

import boto3    
import json
# Create IAM client
iam_client = boto3.client('iam')

# Replace with your group name
group_name = 'third_party'

# List users in the group
response = iam_client.get_group(GroupName=group_name)
#print (response)
print(json.dumps(response, indent=2, default=str))
# Extract user names
#users = response['Users']
#print(f"Users in group '{group_name}':")
#for user in users:
    #print(f"- {user['UserName']}")