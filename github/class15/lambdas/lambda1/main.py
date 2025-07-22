import json
import pandas as pd

def lambda_handler(event, context):
    # Sample data - could come from S3, RDS, etc.
    data = {
        'name': ['Alice', 'Bob', 'Charlie', 'Diana'],
        'age': [25, 30, 35, 28],
        'salary': [50000, 60000, 70000, 55000]
    }
    
    # Create DataFrame
    df = pd.DataFrame(data)
    
    # Perform some operations
    df['bonus'] = df['salary'] * 0.1
    avg_salary = df['salary'].mean()
    total_employees = len(df)
    
    # Filter high earners
    high_earners = df[df['salary'] > 55000]
    
    return {
        'statusCode': 200,
        'body': json.dumps({
            'total_employees': total_employees,
            'average_salary': float(avg_salary),
            'high_earners_count': len(high_earners),
            'high_earners': high_earners.to_dict('records')
        })
    }