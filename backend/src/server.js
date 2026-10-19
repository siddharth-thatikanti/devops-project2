import 'dotenv/config';
import express from 'express';
import cors from 'cors';
import mongoose from 'mongoose';

const app = express();
const port = Number(process.env.PORT || 5000);
const mongoUri = process.env.MONGO_URI || 'mongodb://mongodb:27017/mern_tasks';

app.use(cors());
app.use(express.json({ limit: '32kb' }));

const taskSchema = new mongoose.Schema({
  title: { type: String, required: true, trim: true, maxlength: 160 },
  completed: { type: Boolean, default: false },
}, { timestamps: true });
const Task = mongoose.model('Task', taskSchema);

app.get('/api/health', (_req, res) => {
  const connected = mongoose.connection.readyState === 1;
  res.status(connected ? 200 : 503).json({
    status: connected ? 'ok' : 'starting',
    database: connected ? 'connected' : 'disconnected',
  });
});

app.get('/api/tasks', async (_req, res, next) => {
  try {
    const tasks = await Task.find().sort({ createdAt: -1 }).lean();
    res.json(tasks);
  } catch (err) { next(err); }
});

app.post('/api/tasks', async (req, res, next) => {
  try {
    const title = typeof req.body?.title === 'string' ? req.body.title.trim() : '';
    if (!title) return res.status(400).json({ error: 'Task title is required.' });
    if (title.length > 160) return res.status(400).json({ error: 'Task title must be 160 characters or fewer.' });
    const task = await Task.create({ title });
    res.status(201).json(task);
  } catch (err) { next(err); }
});

app.patch('/api/tasks/:id', async (req, res, next) => {
  try {
    const task = await Task.findById(req.params.id);
    if (!task) return res.status(404).json({ error: 'Task not found.' });
    task.completed = !task.completed;
    await task.save();
    res.json(task);
  } catch (err) {
    if (err.name === 'CastError') return res.status(400).json({ error: 'Invalid task ID.' });
    next(err);
  }
});

app.delete('/api/tasks/:id', async (req, res, next) => {
  try {
    const task = await Task.findByIdAndDelete(req.params.id);
    if (!task) return res.status(404).json({ error: 'Task not found.' });
    res.status(204).end();
  } catch (err) {
    if (err.name === 'CastError') return res.status(400).json({ error: 'Invalid task ID.' });
    next(err);
  }
});

app.use((err, _req, res, _next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal server error.' });
});

async function start() {
  try {
    await mongoose.connect(mongoUri, { serverSelectionTimeoutMS: 10000 });
    app.listen(port, '0.0.0.0', () => console.log(`Backend listening on ${port}`));
  } catch (err) {
    console.error('Could not connect to MongoDB:', err.message);
    process.exit(1);
  }
}
start();
