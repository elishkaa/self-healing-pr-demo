const express = require('express');
const app = express();
const PORT = process.env.PORT || 8080;

app.get('/', (req, res) => res.json({ status: 'ok' }));

app.get('/healthz', (req, res) => res.json({ status: 'healthy', uptime: process.uptime() }));

app.listen(PORT, () => console.log(`api-server listening on port ${PORT}`));
