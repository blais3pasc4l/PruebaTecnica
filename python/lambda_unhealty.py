import boto3
import time
import os

def lambda_handler(event, context):
    ecs_client = boto3.client('ecs')
    cluster_name = os.getenv('CLUSTER_NAME')
    service_name = os.getenv('SERVICE_NAME')

    # Obtener el detalle del servicio
    response = ecs_client.describe_services(
        cluster=cluster_name,
        services=[service_name]
    )
    service = response['services'][0]
    desired_count = service['desiredCount']
    running_count = service['runningCount']

    # El ARN de la tarea "unhealthy" viene directamente del evento de CloudWatch
    unhealthy_task_arn = event['detail']['taskArn']  # Asegúrate de que la ruta del dato es correcta

    # Logica para manejar tareas unhealthy
    if running_count >= 3:
        # Detener la tarea "unhealthy" directamente
        ecs_client.stop_task(
            cluster=cluster_name,
            task=unhealthy_task_arn,
            reason='Stopping unhealthy task due to high resource usage'
        )
        print(f"Stopped unhealthy task: {unhealthy_task_arn}")
    else:
        # Reintentos si hay menos de 3 tareas
        retries = 3
        for _ in range(retries):
            if check_running_tasks(ecs_client, cluster_name, service_name) >= 3:
                print("Sufficient running tasks now available.")
                return
            time.sleep(10)  # Esperar 10 segundos entre reintentos

        # Forzar nuevo despliegue si todavía no hay suficientes tareas
        print("Forcing a new deployment.")
        ecs_client.update_service(
            cluster=cluster_name,
            service=service_name,
            forceNewDeployment=True
        )


def check_running_tasks(ecs_client, cluster_name, service_name):
    # Verificar cuántas tareas están actualmente corriendo
    response = ecs_client.describe_services(
        cluster=cluster_name,
        services=[service_name]
    )
    return response['services'][0]['runningCount']