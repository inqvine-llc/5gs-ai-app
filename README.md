# whatsapp_ai

A new Flutter project.

## Local Development Setup

For developers wishing to use a local instance of Redis through Docker, follow the instructions below. This setup requires Docker and Docker Compose to be installed on your development machine.

### Setting Up Redis with Docker Compose

1. **Start Redis Container**: Navigate to the project's root directory in your terminal and run the following command to start the Redis container in detached mode:

    ```bash
    docker-compose up -d
    ```

    This command reads the `docker-compose.yml` file in your project's root directory and starts a Redis instance as defined. The Redis server will be accessible on `localhost:6379`.

2. **Stopping Redis Container**: When you're done with development, you can stop the Redis container by running:

    ```bash
    docker-compose down
    ```

    This command stops and removes the containers defined in the `docker-compose.yml` file. If you have used a volume for data persistence, the data will be saved and available for the next time you start the container.

### Configuring Your Development Environment

To integrate this local Redis instance with your application, you may need to adjust your application's configuration to use Redis on `localhost:6379`.

#### Updating the `launch.json` for Debugging

If you are using Visual Studio Code for development, you might have a `launch.json` file under the `.vscode` directory for debugging configurations. Update this file to include the necessary environment variables or configuration settings that point to the local Redis instance. Here is an example snippet you might add to your `launch.json`:

```json
{
    "configurations": [
        {
            "type": "node",
            "request": "launch",
            "name": "Debug Local",
            "env": {
                "REDIS_HOST": "localhost",
                "REDIS_PORT": "6379"
            },
            "program": "lib/main-dev.dart"
        }
    ]
}
```

### Running the langchain server

#### Setup your Anaconda environment (Langchain)
*) Download Anaconda (https://conda.io/projects/conda/en/latest/index.html)
*) Create a virtual environment (conda create --name nameMeSomething)
*) Install the langchain package from conda forge (conda install langchain -c conda-forge)
*) conda activate nameMeSomething
*) conda install -r requirements.txt
*) flask run --port=5001