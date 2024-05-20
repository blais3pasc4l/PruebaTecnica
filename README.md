# Wordpress en ECS

## Instrucciones
Como estamos utilizando AWS ECR para almacenar nuestros contenedores Docker y nuestro clúster ECS está extrayendo de él,
primero necesitaremos implementar nuestra infraestructura y luego construir y enviar nuestro contenedor de Wordpress

Exporta tus credenciales de AWS
```
export AWS_ACCESS_KEY_ID=your_access_key
export AWS_SECRET_ACCESS_KEY=your_secret_access_key
```

``` 
zip lambda_unhealty.zip python/lambda_unhealty.py
zip lambda_function.zip python/lambda_function.py
terraform apply
```
NOTA: El codigo de la prueba Python (Paso 1 - NoOps) se dentro de la carpeta llamada python
```
python/lambda_unhealty.py
```





#### Arquitectura implementada
![Descripción de la imagen](https://github.com/blais3pasc4l/PruebaTecnica/blob/main/Untitled%20Diagram.drawio%20(2).png)

(El NAT y la puerta de enlace a Internet no se muestran por motivos de claridad)

```
us-west-2
+--------------------------------------------------------------+
|                                                              |
|           +----------------+    +----------------+           |
|           |         +-----------------+          |           |
|           |         |      |ELB |     |          |           |
|public     |         +-----------------+          | public    |
|us-west-2a +----------------+ || +----------------+ us-west-2b|
|                              ||                              |
|           +----------------+ || +----------------+           |
|           |                | || |                |           |
|           | +------------+ | || | +------------+ |           |
|           | |ECS instance| | || | |ECS instance| |           |
|           | |            +^------^+            | |           |
|           | +-----^----^-+ |    | +-----^-----^+ |           |
|private    |       |    |   |    |       |     |  | private   |
|us-west-2a +----------------+    +----------------+ us—west—2b|
|                   |    |                |     |              |
|                +--+--+ +-------------+--+--+  |              |
|                | RDS |               | EFS |  |              |
|                +-----+               +-----+  |              |
|                      +------------------------+              |
+--------------------------------------------------------------+
```
