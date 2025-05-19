# exercise_2

INFO: Normally I would use terragrunt with modules to keep code shorter and simpler to read, but I wasn't sure if I could so I stuck to a plain terraform so you know what is under the hood.

I use AWS ECS as a orchestration service. 

I assume that each pod consists of two containers: nginx and application. Nginx configuration files are saved on network shared storage (EFS) and mounted to each nginx container. Application image is downloaded from ECR repository.

Application Load Balancer is connected to the Target Group that contains all running pods. Scaling in and out is based on CPU usage, from 2 to 10 replicas.

MySQL database (RDS) is running in MultiAZ mode to be High Available. Username and password have to be inserted manually to Secret Manager.

All variables are separated into variables.tf file so they are in one place, grouped by service, easy to read and change.