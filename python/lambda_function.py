import json
import boto3
import os

ecs_client = boto3.client('ecs')


def lambda_handler(event, context):
    cluster_name = os.getenv('CLUSTER_NAME')
    service_name = os.getenv('SERVICE_NAME')

    try:
        response = ecs_client.update_service(
            cluster=cluster_name,
            service=service_name,
            forceNewDeployment=True
        )
        return {
            'statusCode': 200,
            'body': json.dumps('Redeploy triggered successfully')
        }
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps(f'Error triggering redeploy: {str(e)}')
        }
