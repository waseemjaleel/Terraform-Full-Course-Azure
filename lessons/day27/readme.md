# DevOps Project

A Go application that can be run using Docker and Docker Compose.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) (version 20.10+)
- [Docker Compose](https://docs.docker.com/compose/install/) (version 2.0+)

## Project Structure

```
devops-project/
│
├── Dockerfile          # Docker build instructions
├── go.mod              # Go module definition
├── go.sum              # Go module checksums
├── main.go             # Main application entry point
└── kodata/             # Static data directory
```

## Running Locally with Docker Compose

### Step 1: Create a docker-compose.yml file

Create a `docker-compose.yml` file in the project root with the following content:

```yaml
version: '3.8'

services:
    app:
        build:
            context: .
            dockerfile: Dockerfile
        ports:
            - "8080:8080"
        environment:
            - KO_DATA_PATH=/kodata
        volumes:
            - ./kodata:/kodata
```

### Step 2: Build and run with Docker Compose

```bash
# Build and start the container
docker-compose up --build

# Or run in detached mode
docker-compose up -d --build
```

### Step 3: Access the application

Once running, the application will be accessible at:
```
http://localhost:8080
```

## Additional Commands

```bash
# Stop the containers
docker-compose down

# View logs
docker-compose logs -f

# Restart the service
docker-compose restart app
```

## Troubleshooting

- If you encounter build errors, ensure you have the correct Go version (1.23) or update the Dockerfile accordingly.
- Check container logs for any runtime errors: `docker-compose logs -f app`
- Verify the port 8080 isn't already in use on your host machine.