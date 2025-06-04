# Creating the Shiny APP

This directory contains all files related in the creating of the Shiny web app.

## Contents

| file | Description |
|----------------|-------------|
| `app.R` | The UI and SERVER of the Shiny App. Includes KNN model aswell |
| `Dockerfile` | file to create a docker container locally |
| `docker-compose.yml` | yml file to compose docker |
| `fbi_name_features.csv` | Dataset obtained from FBI Wanted API |


## Local Deployment

1. Download this file to your local computer
2. Build and run docker container + image
```bash
docker compose up -d
```

3. Check if docker container is running properly

Access your local host

`http://localhost:8080`

The Shiny Application should show up, interactable. 

The prediction may take some time to react, from API speed issues using Google Cloud Run.


## Deploying online

The Docker Image created locally can be pushed to Docker hub repository, and that could be used in Google Cloud Run to be accessable online.

