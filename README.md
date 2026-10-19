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
