const http = require('http');

const data = JSON.stringify({
    email: 'admin@smartvision.com',
    password: 'admin123'
});

const options = {
    hostname: 'localhost',
    port: 3000,
    path: '/auth/login',
    method: 'POST',
    headers: {
        'Content-Type': 'application/json',
        'Content-Length': data.length
    }
};

console.log('🔍 Test de connexion à l\'API...\n');

const req = http.request(options, (res) => {
    let body = '';

    res.on('data', (chunk) => {
        body += chunk;
    });

    res.on('end', () => {
        console.log(`Status: ${res.statusCode}`);
        console.log(`Headers:`, res.headers);
        console.log(`\nBody:`);
        try {
            const parsed = JSON.parse(body);
            console.log(JSON.stringify(parsed, null, 2));
        } catch (e) {
            console.log(body);
        }
        process.exit();
    });
});

req.on('error', (error) => {
    console.error('❌ Erreur:', error);
    process.exit(1);
});

req.write(data);
req.end();
