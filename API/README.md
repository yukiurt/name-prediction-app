# Creating the API

This directory contains all files related in the deployment of the flask API.

## Contents

| file | Description |
|----------------|-------------|
| `Dockerfile` | file to create a docker container locally |
| `docker-compose.yml` | yml file to compose docker |
| `fbi_name_features.csv` | Dataset obtained from FBI Wanted API |
| `prediction.py` | python file containing the RandomForest models |
| `requirements.txt` | contains all python libraries needed |
| `server.py` | python file of the flask API to GET/POST |

## Local Deployment

1. Download this file to your local computer
2. Build and run docker container + image
```bash
docker compose up -d
```

3. Check if docker container is running properly

Access your local host

`http://localhost:5001`

or check API
 ```bash
curl -H "Content-Type: application/json" -X POST -d '{"mode": "sex", "name": "Johnny Depp"}' "http://localhost:5001/predict"
```

Expected output:

```
{
  "prediction": male
}

```

## Deploying online

The Docker Image created locally can be pushed to Docker hub repository, and that could be used in Google Cloud Run to be accessable online.

