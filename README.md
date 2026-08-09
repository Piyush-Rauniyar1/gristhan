# Grihastha - Full Stack Property Rental App

## Docker Setup

This project is fully containerized using Docker, providing a self-contained environment with PostgreSQL, an Express API, and a React frontend.

### Prerequisites
- Docker and Docker Compose installed on your system.

### Running Locally

1. **Clone the repository**

2. **Configure Environment Variables**
   Copy the example Docker environment file:
   ```bash
   cp .env.docker.example .env.docker
   ```
   Open `.env.docker` and fill in your actual credentials (SMTP, Cloudinary, Stripe, Khalti, Firebase, etc.).

3. **Start the Application**
   Run the following command in the root directory:
   ```bash
   docker compose --env-file .env.docker up -d
   ```
   *Note: If you run into socket permission issues on macOS/Linux, you might need to specify the Docker host:*
   `DOCKER_HOST=unix://$HOME/.docker/run/docker.sock docker compose --env-file .env.docker up -d`

4. **Initialize the Database**
   Since the database container starts empty, you need to import the full schema:
   ```bash
   docker exec -i stack-rebels-db-1 psql -U grihastha -d grihastha < server/database_full.sql
   ```

5. **Access the Application**
   - **Frontend:** http://localhost
   - **API Health Check:** http://localhost/health
   - **Swagger Documentation:** http://localhost/api-docs

### Stopping the Application

To stop the containers without deleting the database data:
```bash
docker compose --env-file .env.docker down
```

To stop and **completely remove** the database data (full reset):
```bash
docker compose --env-file .env.docker down -v
```
