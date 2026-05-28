# Complete Step-by-Step Azure Database & Virtual Machine Hosting Guide (with GitHub Actions)

This guide provides a comprehensive walkthrough to:
1. Migrate your local PostgreSQL database (`grihastha`) to **Azure Database for PostgreSQL (Flexible Server)**.
2. Provision and configure an **Azure Linux Virtual Machine (VM)**.
3. Set up **Nginx** and **PM2** on the VM to serve both the Express API and the Vite React frontend.
4. Configure **GitHub Actions** for fully automated CI/CD deployments directly to the VM on every push to `main`.

---

## Table of Contents
1. [Prerequisites](#prerequisites)
2. [Step 1: Provision Azure Database for PostgreSQL](#step-1-provision-azure-database-for-postgresql)
3. [Step 2: Migrate (Sift) Your Local Database to Azure](#step-2-migrate-sift-your-local-database-to-azure)
4. [Step 3: Provision and Configure Azure Virtual Machine (VM)](#step-3-provision-and-configure-azure-virtual-machine-vm)
5. [Step 4: Configure VM Software (Node.js, PM2, Nginx)](#step-4-configure-vm-software-nodejs-pm2-nginx)
6. [Step 5: Set Up GitHub Actions CI/CD Workflow](#step-5-set-up-github-actions-cicd-workflow)
7. [Step 6: Updating Local Development Config](#step-6-updating-local-development-config)

---

## Prerequisites
Before starting, ensure you have:
*   An active **Microsoft Azure Account** ([Sign up free here](https://azure.microsoft.com/free/)).
*   **PostgreSQL Client Tools** (`psql`) installed on your local machine.
*   Your local database dump successfully exported at `server/database_full.sql`.
*   A **GitHub Repository** housing your codebase.

---

## Step 1: Provision Azure Database for PostgreSQL

### 1. Create the Database Instance
1. Log in to the [Azure Portal](https://portal.azure.com/).
2. In the top search bar, type **Azure Database for PostgreSQL servers** and select it.
3. Click **+ Create** and choose **Flexible Server**.
4. Fill in the **Basics** tab:
   * **Subscription**: Select your active subscription.
   * **Resource Group**: Click *Create new* and name it `grihastha-group`.
   * **Server name**: Enter a unique hostname (e.g., `grihastha-db-server`).
   * **Region**: Choose a region close to your target audience (e.g., `eastus`).
   * **PostgreSQL version**: Select **15** (matching your local environment).
   * **Compute + storage**: Click *Configure server*. Choose the **Burstable** tier with `Standard_B1ms` (1 vCPU, 2 GiB RAM, 32 GiB storage) to keep costs extremely low.
   * **High availability**: Leave disabled (keeps costs low).
5. Configure **Administrator Credentials**:
   * **Admin username**: Enter your admin name (e.g., `dbadmin`).
   * **Password**: Set a secure password.
6. Configure **Networking**:
   * Go to the **Networking** tab.
   * **Connectivity method**: Select **Public access (allowed IP addresses)**.
   * **Firewall rules**:
     * Check **Allow public access from any Azure service within Azure to this server** (this allows your Azure VM to connect to the database).
     * Click **+ Add current client IP address** to whitelist your local developer machine.
7. Click **Review + Create**, then **Create** (deployment takes 3–5 minutes).
8. Once complete, click **Go to resource** and copy your **Server name** (host string).

---

## Step 2: Migrate (Sift) Your Local Database to Azure

Once your Azure database server is deployed:
1. Verify you have exported your local database using `pg_dump` version 15:
   ```bash
   /opt/homebrew/opt/postgresql@15/bin/pg_dump -U piyushrauniyar -h localhost -d grihastha -F p -f server/database_full.sql
   ```
2. Import the database dump into Azure using the `psql` command:
   ```bash
   psql -h <your-azure-server-hostname>.postgres.database.azure.com -U <admin-username> -d postgres -f server/database_full.sql
   ```
   *For example:*
   ```bash
   psql -h grihastha-db-server.postgres.database.azure.com -U dbadmin -d postgres -f server/database_full.sql
   ```
3. Type your Azure PostgreSQL admin password when prompted. The import script will recreate all tables, keys, triggers, and populate all local rows.

---

## Step 3: Provision and Configure Azure Virtual Machine (VM)

We will use an Ubuntu Linux Virtual Machine to host both the API and client.

### 1. Create the VM in Azure
1. In the Azure Portal search bar, type **Virtual Machines** and click **+ Create** -> **Azure virtual machine**.
2. Configure **Basics**:
   * **Resource Group**: Select `grihastha-group`.
   * **Virtual machine name**: `grihastha-vm`.
   * **Region**: Same region as your database.
   * **Image**: **Ubuntu Server 22.04 LTS - x64 Gen2** (recommended).
   * **Size**: `Standard_B1ms` or `Standard_B2s` (affordable options for full-stack Node environments).
3. Configure **Administrator Account**:
   * **Authentication type**: **SSH public key**.
   * **Username**: `azureuser`.
   * **SSH public key source**: Select *Generate new key pair*.
   * **Key pair name**: `grihastha-key`.
4. Configure **Inbound Port Rules**:
   * Select **Allow selected ports**.
   * **Inbound ports**: Select **SSH (22)**, **HTTP (80)**, and **HTTPS (443)**.
5. Click **Review + Create**, then **Create**.
6. **IMPORTANT**: Download the private key file (`grihastha-key.pem`) when prompted and save it securely on your local computer.

### 2. Connect to the VM
Open your terminal, set permissions on your downloaded private key, and SSH into your VM:
```bash
chmod 400 ~/Downloads/grihastha-key.pem
ssh -i ~/Downloads/grihastha-key.pem azureuser@<your-vm-ip-address>
```

---

## Step 4: Configure VM Software (Node.js, PM2, Nginx)

Once you are connected to the VM, run the following commands to install and set up your web server.

### 1. Update OS and Install Node.js
```bash
sudo apt update && sudo apt upgrade -y
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs
```
Verify the installation:
```bash
node -v
npm -v
```

### 2. Install Process Manager (PM2) and Nginx
```bash
sudo npm install -g pm2
sudo apt install nginx -y
```

### 3. Create Project Directory & Set Permissions
```bash
sudo mkdir -p /var/www/grihastha
sudo chown -R azureuser:azureuser /var/www/grihastha
```

### 4. Create the Production Environment File on VM
Create a `.env` file inside `/var/www/grihastha` to store your secure production credentials:
```bash
nano /var/www/grihastha/.env
```
Paste and fill in the following:
```env
PORT=5001
NODE_ENV=production
DB_HOST=<your-azure-db-hostname>.postgres.database.azure.com
DB_PORT=5432
DB_NAME=postgres
DB_USER=<your-azure-admin-username>
DB_PASSWORD=<your-azure-admin-password>
DB_SSL=true
JWT_SECRET=your_super_secret_jwt_key
CLIENT_URL=http://<your-vm-ip-address>
SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=piyushrouniyar4@gmail.com
SMTP_PASS=zawcsolpkvunkkwk
EMAIL_FROM=piyushrouniyar4@gmail.com
CLOUDINARY_CLOUD_NAME=djd9xro7e
CLOUDINARY_API_KEY=941137642248279
CLOUDINARY_API_SECRET=z1tnMgnWFyK-kbbkq_KERBKyIBI
STRIPE_SECRET_KEY=sk_test_...
KHALTI_SECRET_KEY=71cf973aa3724b8d99175c3c98bed437
FIREBASE_PROJECT_ID=airbnb-backend-d33f8
GOOGLE_APPLICATION_CREDENTIALS=./firebase-admin-key.json
```
*Press `CTRL+O` and `Enter` to save, then `CTRL+X` to exit.*

---

### 5. Configure Nginx Reverse Proxy
We will configure Nginx to route external requests on port 80:
*   Vite frontend client static assets served directly from `/var/www/html`.
*   Backend API requests (to `/v1/*`) reverse-proxied to the Express API running on port `5001`.

1. Open the default Nginx configuration file:
   ```bash
   sudo nano /etc/nginx/sites-available/default
   ```
2. Replace the file's contents with the following:
   ```nginx
   server {
       listen 80 default_server;
       listen [::]:80 default_server;

       server_name _;

       # Frontend Vite static files location
       root /var/www/html;
       index index.html;

       location / {
           try_files $uri $uri/ /index.html;
       }

       # Backend Express API reverse proxy
       location /v1 {
           proxy_pass http://127.0.0.1:5001;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
           proxy_set_header X-Real-IP $remote_addr;
           proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
       }
   }
   ```
3. Test and restart Nginx:
   ```bash
   sudo nginx -t
   sudo systemctl restart nginx
   ```

---

## Step 5: Set Up GitHub Actions CI/CD Workflow

I have already created the GitHub Actions pipeline file in your repository:
**[.github/workflows/deploy.yml](file:///Users/piyushrauniyar/Desktop/Stack-Rebels/.github/workflows/deploy.yml)**

To activate this automated deployment pipeline, you need to configure **GitHub Secrets** in your repository.

### 1. Configure Repository Secrets on GitHub
Go to your **GitHub Repository** -> **Settings** -> **Secrets and variables** -> **Actions** and click **New repository secret** to add these secrets:

| Secret Name | Description / Value |
| :--- | :--- |
| `VM_HOST` | The **Public IP Address** of your Azure VM. |
| `VM_USER` | `azureuser` |
| `VM_SSH_KEY` | Paste the **entire contents** of your private key `grihastha-key.pem` (including the `-----BEGIN RSA PRIVATE KEY-----` and `-----END RSA PRIVATE KEY-----` tags). |
| `VITE_API_URL` | `http://<your-vm-ip-address>/v1` |
| `VITE_STRIPE_PUBLIC_KEY` | `pk_test_...` |
| `VITE_KHALTI_PUBLIC_KEY` | `57a15255931944dbabac71a8ada8a731` |

### 2. How the Pipeline Works
Every time you push a commit or merge a pull request to the `main` branch:
1. **GitHub Actions** spins up a runner, checks out your code, and installs Node.js.
2. It builds your static Vite frontend files and creates the output bundle (`client/dist`).
3. It securely copies (`SCP`) your server folder and the compiled static client files onto your Azure VM under `/var/www/grihastha`.
4. It logs into your VM via **SSH** and:
   * Installs production-only dependencies (`npm ci --omit=dev`).
   * Copies the production `.env` configuration file.
   * Runs the PostgreSQL database migrations (`npm run migrate`) securely against the Azure Database.
   * Restarts the backend service using **PM2** process manager to apply changes without downtime.
   * Swaps in the new compiled frontend files to `/var/www/html` for Nginx to serve globally.

---

## Step 6: Updating Local Development Config

To connect your local development environment directly to the Azure hosted database:
1. Open your local `.env` file: **[.env](file:///Users/piyushrauniyar/Desktop/Stack-Rebels/.env)**.
2. Update the Database variables:
   ```env
   DB_HOST=<your-azure-db-hostname>.postgres.database.azure.com
   DB_PORT=5432
   DB_NAME=postgres
   DB_USER=<your-azure-admin-username>
   DB_PASSWORD=<your-azure-admin-password>
   DB_SSL=true
   ```
3. Boot the local server:
   ```bash
   npm run dev --prefix server
   ```
   Your app will connect securely using the SSL/TLS modifications we implemented!
