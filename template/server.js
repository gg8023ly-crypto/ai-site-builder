const express = require('express');
const path = require('path');
const fs = require('fs');
const Database = require('better-sqlite3');

// Load config
const configPath = path.join(__dirname, 'config.json');
const config = JSON.parse(fs.readFileSync(configPath, 'utf-8'));

const app = express();
app.use(express.json());

// SQLite setup
const dataDir = path.join(__dirname, 'data');
if (!fs.existsSync(dataDir)) fs.mkdirSync(dataDir, { recursive: true });
const db = new Database(path.join(dataDir, 'site.db'));

// Auto-create logs table
db.exec(`
  CREATE TABLE IF NOT EXISTS logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    date TEXT,
    title TEXT,
    excerpt TEXT,
    content TEXT,
    created_at TEXT NOT NULL DEFAULT (datetime('now'))
  )
`);

// Static files
app.use(express.static(path.join(__dirname, 'public')));

// Inject config into HTML pages (replace {{CONFIG_VAR}} placeholders)
function serveHtml(file) {
  return (req, res) => {
    const filePath = path.join(__dirname, 'public', file);
    if (!fs.existsSync(filePath)) {
      return res.status(404).send('Page not found');
    }
    let html = fs.readFileSync(filePath, 'utf-8');
    // Replace template variables
    html = html.replace(/\{\{NAME\}\}/g, config.name || '');
    html = html.replace(/\{\{TITLE\}\}/g, config.title || '');
    html = html.replace(/\{\{DESCRIPTION\}\}/g, config.description || '');
    html = html.replace(/\{\{AVATAR\}\}/g, config.avatar || '🤖');
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.send(html);
  };
}

// Page routes
app.get('/', serveHtml('index.html'));
app.get('/chat', (req, res) => {
  if (!config.features.chat) return res.redirect('/');
  serveHtml('chat.html')(req, res);
});
app.get('/knowledge', (req, res) => {
  if (!config.features.knowledge) return res.redirect('/');
  serveHtml('knowledge.html')(req, res);
});
app.get('/blog', (req, res) => {
  if (!config.features.blog) return res.redirect('/');
  serveHtml('blog.html')(req, res);
});
app.get('/log', (req, res) => {
  if (config.features.log === false) return res.redirect('/');
  serveHtml('log.html')(req, res);
});

// API: Get public config (no apiKey)
app.get('/api/config', (req, res) => {
  const publicConfig = {
    name: config.name,
    title: config.title,
    description: config.description,
    avatar: config.avatar,
    theme: config.theme,
    features: config.features,
    ai: {
      model: config.ai.model
    }
  };
  res.json({ ok: true, data: publicConfig });
});

// API: Status
app.get('/api/status', (req, res) => {
  res.json({
    ok: true,
    data: {
      online: true,
      name: config.name,
      avatar: config.avatar,
      uptime: process.uptime(),
      timestamp: new Date().toISOString()
    }
  });
});

// API: Get recent logs (last 20)
app.get('/api/logs', (req, res) => {
  const rows = db.prepare('SELECT * FROM logs ORDER BY id DESC LIMIT 20').all();
  res.json({ ok: true, data: rows });
});

// API: Post a new log entry
app.post('/api/logs', (req, res) => {
  const { title, excerpt, content } = req.body;
  if (!title) {
    return res.status(400).json({ ok: false, message: 'title is required' });
  }
  const date = req.body.date || new Date().toISOString().slice(0, 10);
  const stmt = db.prepare(
    'INSERT INTO logs (date, title, excerpt, content) VALUES (?, ?, ?, ?)'
  );
  const result = stmt.run(date, title, excerpt || '', content || '');
  const entry = db.prepare('SELECT * FROM logs WHERE id = ?').get(result.lastInsertRowid);
  res.json({ ok: true, data: entry });
});

// API: Chat (proxy to AI provider, streaming)
app.post('/api/chat', async (req, res) => {
  if (!config.features.chat) {
    return res.status(403).json({ ok: false, message: 'Chat feature is disabled' });
  }

  const { messages } = req.body;
  if (!messages || !Array.isArray(messages)) {
    return res.status(400).json({ ok: false, message: 'messages array required' });
  }

  if (!config.ai.apiKey) {
    return res.status(500).json({ ok: false, message: 'AI API key not configured' });
  }

  // Build system prompt
  const systemPrompt = (config.ai.systemPrompt || '').replace(/\{name\}/g, config.name);

  const apiMessages = [
    { role: 'system', content: systemPrompt },
    ...messages
  ];

  try {
    const baseUrl = config.ai.baseUrl.replace(/\/+$/, '');
    const response = await fetch(`${baseUrl}/chat/completions`, {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': `Bearer ${config.ai.apiKey}`
      },
      body: JSON.stringify({
        model: config.ai.model,
        messages: apiMessages,
        stream: true
      })
    });

    if (!response.ok) {
      const errText = await response.text();
      console.error('AI API error:', response.status, errText);
      return res.status(502).json({ ok: false, message: 'AI service error' });
    }

    // Stream response back
    res.setHeader('Content-Type', 'text/event-stream');
    res.setHeader('Cache-Control', 'no-cache');
    res.setHeader('Connection', 'keep-alive');

    const reader = response.body.getReader();
    const decoder = new TextDecoder();

    while (true) {
      const { done, value } = await reader.read();
      if (done) {
        res.write('data: [DONE]\n\n');
        break;
      }
      const chunk = decoder.decode(value, { stream: true });
      res.write(chunk);
    }

    res.end();
  } catch (err) {
    console.error('Chat proxy error:', err.message);
    if (!res.headersSent) {
      res.status(500).json({ ok: false, message: 'Internal server error' });
    } else {
      res.end();
    }
  }
});

// Start server
const PORT = config.port || 8891;
app.listen(PORT, () => {
  console.log(`\n🚀 ${config.title} is running!`);
  console.log(`   Local:   http://localhost:${PORT}`);
  console.log(`   Name:    ${config.name} ${config.avatar}`);
  console.log(`   Theme:   ${config.theme}`);
  console.log(`   Chat:    ${config.features.chat ? 'Enabled' : 'Disabled'}`);
  console.log(`   Log:     ${config.features.log !== false ? 'Enabled' : 'Disabled'}`);
  console.log(`   AI:      ${config.ai.model}`);
  console.log('');
});
