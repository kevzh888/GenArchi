const http = require('http');

let counter = 0;

const server = http.createServer((req, res) => {
    res.setHeader('Content-Type', 'application/json');
    
    const { url, method } = req;

    if (url === '/increment' && method === 'POST') {
        counter++;
        res.writeHead(200);
        res.end(JSON.stringify({ counter }));
    }
    else if (url === '/decrement' && method === 'POST') {
        counter--;
        res.writeHead(200);
        res.end(JSON.stringify({ counter }));
    }
    else if (url === '/counter' && method === 'GET') {
        res.writeHead(200);
        res.end(JSON.stringify({ counter }));
    }
    else {
        res.writeHead(404, { 'Content-Type': 'text/plain' });
        res.end('404 Not Found');
    }
});

const PORT = 3000;
server.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}/`);
});
