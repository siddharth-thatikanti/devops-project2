<<<<<<< HEAD
# MERN Task Manager

A simple MERN application with:
- React + Vite frontend
- Node.js + Express backend
- MongoDB database

## Run locally

Prerequisites: Node.js 20+, npm, and a running MongoDB instance.

1. Start MongoDB and note its connection URI.
2. Start the backend:

```bash
cd backend
cp .env.example .env
npm install
npm run dev
```

3. In another terminal, start the frontend:

```bash
cd frontend
npm install
npm run dev
```

Open the Vite URL shown in the terminal (usually http://localhost:5173).

The backend uses `MONGO_URI` from `backend/.env`. For local MongoDB, the example URI is `mongodb://127.0.0.1:27017/mern_tasks`.

## API endpoints

- `GET /api/health` — health status
- `GET /api/tasks` — list tasks
- `POST /api/tasks` — create a task with `{ "title": "..." }`
- `PATCH /api/tasks/:id` — toggle task completion
- `DELETE /api/tasks/:id` — delete a task

Do not commit real credentials or `.env` files.
=======
# AWS HA Web Infrastructure — Terraform Modules

Starter scaffold for a two-AZ VPC, public/private subnets, Internet Gateway, NAT Gateways, ALB, EC2 Auto Scaling Group, IAM role, private S3 bucket, and S3 Gateway Endpoint.

## Prerequisites
- Terraform >= 1.5 and AWS credentials configured.
- Review `terraform.tfvars.example`; copy it to `terraform.tfvars`.
- Set a valid Amazon Linux 2023 `ami_id` for your selected region and a globally unique S3 bucket name.

## Run
```bash
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```
Destroy when finished to avoid ongoing charges:
```bash
terraform destroy
```

## Notes
This is a learning scaffold, not production-hardened. NAT Gateways, ALB, EC2, and public IPv4 resources incur charges. The EC2 user data installs Nginx and serves a test page. Instances have no inbound SSH rule; the IAM profile includes SSM core permissions, but SSM connectivity also requires working outbound access. Terraform remote state backend is not preconfigured; create and configure a dedicated state bucket before adding an S3 backend. Review all resources before applying.
>>>>>>> dff3dc8 (Configured IAC)
