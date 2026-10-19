import { useCallback, useEffect, useMemo, useState } from 'react';

export default function App() {
  const [tasks, setTasks] = useState([]);
  const [title, setTitle] = useState('');
  const [filter, setFilter] = useState('all');
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(true);

  const loadTasks = useCallback(async () => {
    try {
      setError('');
      const response = await fetch('/api/tasks');
      if (!response.ok) throw new Error('Could not load tasks.');
      setTasks(await response.json());
    } catch (err) { setError(err.message || 'API unavailable.'); }
    finally { setLoading(false); }
  }, []);

  useEffect(() => { loadTasks(); }, [loadTasks]);

  async function addTask(event) {
    event.preventDefault();
    const clean = title.trim();
    if (!clean) return;
    try {
      setError('');
      const response = await fetch('/api/tasks', {
        method: 'POST', headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ title: clean }),
      });
      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'Could not add task.');
      setTasks(current => [data, ...current]);
      setTitle('');
    } catch (err) { setError(err.message); }
  }

  async function toggleTask(task) {
    try {
      const response = await fetch(`/api/tasks/${task._id}`, { method: 'PATCH' });
      const data = await response.json();
      if (!response.ok) throw new Error(data.error || 'Could not update task.');
      setTasks(current => current.map(item => item._id === data._id ? data : item));
    } catch (err) { setError(err.message); }
  }

  async function deleteTask(id) {
    try {
      const response = await fetch(`/api/tasks/${id}`, { method: 'DELETE' });
      if (!response.ok) {
        const data = await response.json();
        throw new Error(data.error || 'Could not delete task.');
      }
      setTasks(current => current.filter(task => task._id !== id));
    } catch (err) { setError(err.message); }
  }

  const visibleTasks = useMemo(() => tasks.filter(task =>
    filter === 'all' || (filter === 'active' && !task.completed) || (filter === 'done' && task.completed)
  ), [tasks, filter]);
  const completed = tasks.filter(task => task.completed).length;

  return (
    <main className="page">
      <nav className="topbar">
        <a className="brand" href="#"><span className="brand-icon">T</span> TaskFlow</a>
        <span className="stack-label"><span className="live-dot" /> MERN STACK DEMO</span>
      </nav>
      <section className="hero">
        <div className="eyebrow"><span /> YOUR WORKSPACE</div>
        <h1>Make room for<br /><span>great work.</span></h1>
        <p>A simple place to track what matters, one task at a time.</p>
      </section>
      <section className="workspace">
        <div className="section-head">
          <div><div className="section-kicker">OVERVIEW</div><h2>Your tasks</h2></div>
          <div className="count-pill">{tasks.length} total</div>
        </div>
        <div className="stats">
          <div className="stat-card"><span className="stat-label">ALL TASKS</span><strong>{tasks.length}</strong><span className="stat-foot">In your workspace</span></div>
          <div className="stat-card"><span className="stat-label">COMPLETED</span><strong>{completed}</strong><span className="stat-foot">Nicely done</span></div>
          <div className="stat-card"><span className="stat-label">REMAINING</span><strong>{tasks.length - completed}</strong><span className="stat-foot">One step at a time</span></div>
        </div>
        <form className="add-form" onSubmit={addTask}>
          <label className="input-label" htmlFor="task-title">ADD A NEW TASK</label>
          <div className="input-row">
            <input id="task-title" value={title} onChange={event => setTitle(event.target.value)} maxLength={160} placeholder="e.g. Deploy my first application..." />
            <button type="submit" disabled={!title.trim()}>+ Add task</button>
          </div>
        </form>
        {error && <div className="error" role="alert">{error} <button onClick={loadTasks} className="retry">Retry</button></div>}
        <div className="list-head">
          <h3>Task list <span>{visibleTasks.length}</span></h3>
          <div className="filters">
            {[['all', 'All'], ['active', 'In progress'], ['done', 'Completed']].map(([key, label]) =>
              <button key={key} className={filter === key ? 'filter active' : 'filter'} onClick={() => setFilter(key)} type="button">{label}</button>
            )}
          </div>
        </div>
        {loading ? <div className="empty">Loading your tasks…</div> : visibleTasks.length === 0 ?
          <div className="empty"><div className="empty-icon">✓</div><strong>{filter === 'all' ? 'A clean slate.' : 'Nothing here yet.'}</strong><p>Add a task above to get started.</p></div> :
          <ul className="task-list">{visibleTasks.map(task => <li className={task.completed ? 'task completed' : 'task'} key={task._id}>
            <button className="check" aria-label={task.completed ? 'Mark incomplete' : 'Mark complete'} onClick={() => toggleTask(task)}>{task.completed ? '✓' : ''}</button>
            <span className="task-title">{task.title}</span>
            <button className="delete" aria-label={`Delete ${task.title}`} onClick={() => deleteTask(task._id)}>Delete</button>
          </li>)}</ul>}
        <footer className="workspace-footer"><span><span className="live-dot" /> API-connected workspace</span><button onClick={loadTasks} type="button">↻ Refresh</button></footer>
      </section>
      <footer className="page-footer">BUILT WITH REACT · NODE.JS · EXPRESS · MONGODB</footer>
    </main>
  );
}
