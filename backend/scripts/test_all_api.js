const http = require('http');

// Couleurs pour les logs
const colors = {
    reset: '\x1b[0m',
    green: '\x1b[32m',
    red: '\x1b[31m',
    yellow: '\x1b[33m',
    blue: '\x1b[34m'
};

let testsResults = [];
let accessToken = '';
let refreshToken = '';

function makeRequest(method, path, data = null, token = null) {
    return new Promise((resolve, reject) => {
        const postData = data ? JSON.stringify(data) : null;

        const options = {
            hostname: 'localhost',
            port: 3000,
            path: path,
            method: method,
            headers: {
                'Content-Type': 'application/json',
                ...(postData && { 'Content-Length': Buffer.byteLength(postData) }),
                ...(token && { 'Authorization': `Bearer ${token}` })
            }
        };

        const req = http.request(options, (res) => {
            let body = '';
            res.on('data', (chunk) => { body += chunk; });
            res.on('end', () => {
                try {
                    resolve({ status: res.statusCode, data: JSON.parse(body) });
                } catch (e) {
                    resolve({ status: res.statusCode, data: body });
                }
            });
        });

        req.on('error', reject);
        if (postData) req.write(postData);
        req.end();
    });
}

function logTest(name, success, details = '') {
    const status = success ? `${colors.green}✅ PASS${colors.reset}` : `${colors.red}❌ FAIL${colors.reset}`;
    console.log(`${status} - ${name}`);
    if (details) console.log(`   ${colors.yellow}${details}${colors.reset}`);
    testsResults.push({ name, success, details });
}

async function runTests() {
    console.log(`\n${colors.blue}=== TESTS DE L'API SMART VISION ===${colors.reset}\n`);

    // 1. Test de connexion
    console.log(`${colors.blue}📌 Tests d'Authentification${colors.reset}`);
    try {
        const loginRes = await makeRequest('POST', '/auth/login', {
            email: 'admin@smartvision.com',
            password: 'admin123'
        });

        if (loginRes.status === 200 && loginRes.data.accessToken) {
            accessToken = loginRes.data.accessToken;
            refreshToken = loginRes.data.refreshToken;
            logTest('Login Admin', true, `Token reçu: ${accessToken.substring(0, 20)}...`);
        } else {
            logTest('Login Admin', false, `Status ${loginRes.status}`);
        }
    } catch (e) {
        logTest('Login Admin', false, e.message);
    }

    // 2. Test inscription
    try {
        const randomEmail = `test${Date.now()}@test.com`;
        const registerRes = await makeRequest('POST', '/auth/register', {
            name: 'Test User',
            email: randomEmail,
            password: 'Test123!'
        });

        logTest('Register nouveau compte', registerRes.status === 201, `Status: ${registerRes.status}`);
    } catch (e) {
        logTest('Register nouveau compte', false, e.message);
    }

    // 3. Test refresh token
    try {
        const refreshRes = await makeRequest('POST', '/auth/refresh', {
            refreshToken: refreshToken
        });

        logTest('Refresh Token', refreshRes.status === 200 && refreshRes.data.accessToken, `Status: ${refreshRes.status}`);
    } catch (e) {
        logTest('Refresh Token', false, e.message);
    }

    // 4. Test profil (avec token)
    try {
        const profileRes = await makeRequest('GET', '/auth/profile', null, accessToken);
        logTest('Get Profile', profileRes.status === 200, `User: ${profileRes.data?.user?.name || 'N/A'}`);
    } catch (e) {
        logTest('Get Profile', false, e.message);
    }

    // 5. Tests Montures
    console.log(`\n${colors.blue}📌 Tests Montures (Frames)${colors.reset}`);
    try {
        const framesRes = await makeRequest('GET', '/frames');
        logTest('Get toutes les montures', framesRes.status === 200, `${Array.isArray(framesRes.data) ? framesRes.data.length : 0} montures`);
    } catch (e) {
        logTest('Get toutes les montures', false, e.message);
    }

    // 6. Tests Assurances
    console.log(`\n${colors.blue}📌 Tests Assurances${colors.reset}`);
    try {
        const insuranceRes = await makeRequest('GET', '/insurances');
        logTest('Get toutes les assurances', insuranceRes.status === 200, `${Array.isArray(insuranceRes.data) ? insuranceRes.data.length : 0} assurances`);
    } catch (e) {
        logTest('Get toutes les assurances', false, e.message);
    }

    try {
        const validateRes = await makeRequest('POST', '/insurances/validate', {
            insuranceName: 'Harmonie',
            totalPrice: 200
        });
        logTest('Validation assurance', validateRes.status === 200, `Couverture: ${validateRes.data?.coverage || 'N/A'}%`);
    } catch (e) {
        logTest('Validation assurance', false, e.message);
    }

    // 7. Tests Admin
    console.log(`\n${colors.blue}📌 Tests Admin${colors.reset}`);
    try {
        const statsRes = await makeRequest('GET', '/admin/dashboard/stats', null, accessToken);
        logTest('Dashboard Stats', statsRes.status === 200, `Users: ${statsRes.data?.users || 'N/A'}`);
    } catch (e) {
        logTest('Dashboard Stats', false, e.message);
    }

    // 8. Résumé
    console.log(`\n${colors.blue}=== RÉSUMÉ DES TESTS ===${colors.reset}`);
    const passed = testsResults.filter(t => t.success).length;
    const failed = testsResults.filter(t => !t.success).length;

    console.log(`${colors.green}✅ Réussis: ${passed}${colors.reset}`);
    console.log(`${colors.red}❌ Échoués: ${failed}${colors.reset}`);
    console.log(`📊 Total: ${testsResults.length}\n`);

    if (failed > 0) {
        console.log(`${colors.red}Tests échoués:${colors.reset}`);
        testsResults.filter(t => !t.success).forEach(t => {
            console.log(`  - ${t.name}: ${t.details}`);
        });
    }

    process.exit(failed > 0 ? 1 : 0);
}

runTests().catch(error => {
    console.error(`${colors.red}Erreur fatale:${colors.reset}`, error);
    process.exit(1);
});
