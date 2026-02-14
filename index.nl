<!DOCTYPE html>
<html lang="nl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>BTV Woordenschat & Surveillance</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <style>
        body { background-color: #0f172a; touch-action: manipulation; }
        .bg-police { background-color: #002d5e; }
        canvas { background: #000; border: 4px solid #1e40af; border-radius: 12px; }
        .quiz-card { background: white; color: #1e293b; padding: 2rem; rounded: 1rem; box-shadow: 0 10px 25px rgba(0,0,0,0.3); }
    </style>
</head>
<body class="text-slate-200 font-sans">

    <div id="loginOverlay" class="fixed inset-0 bg-police z-50 flex items-center justify-center p-4">
        <div class="bg-white p-8 rounded shadow-2xl w-full max-w-sm text-center border-t-8 border-yellow-500 text-slate-900">
            <h1 class="font-black text-2xl mb-6 italic uppercase text-police">BTV Surveillance 2026</h1>
            <input type="text" id="uNaam" placeholder="Naam Agent" class="w-full border-2 p-3 rounded mb-4 font-bold text-center outline-none focus:border-blue-900">
            <select id="uKlas" class="w-full border-2 p-3 rounded mb-8 font-bold text-center outline-none focus:border-blue-900">
                <option value="">Kies Eenheid</option>
                <option>Delta</option><option>Echo</option><option>Foxtrot</option>
            </select>
            <button onclick="startQuiz()" class="w-full bg-police text-white p-4 rounded font-black uppercase tracking-widest hover:bg-blue-900">Start Selectie</button>
        </div>
    </div>

    <div id="quizOverlay" class="hidden fixed inset-0 bg-slate-900 z-40 flex items-center justify-center p-4">
        <div class="quiz-card w-full max-w-lg text-center">
            <h2 class="text-blue-900 font-black uppercase text-sm mb-2">Woordenschat Controle</h2>
            <div class="text-xs mb-4 text-slate-500 uppercase font-bold">Voortgang: <span id="qCount" class="text-blue-600">0</span> / 5</div>
            <p id="qText" class="text-xl font-bold mb-6 text-slate-800 italic">Laden...</p>
            <div id="qOptions" class="grid grid-cols-1 gap-3"></div>
            <p id="qFeedback" class="mt-4 font-bold text-sm hidden"></p>
        </div>
    </div>

    <div id="mainContent" class="hidden max-w-4xl mx-auto p-4 space-y-6">
        <header class="flex justify-between items-center bg-police p-4 rounded-xl border-b-4 border-yellow-500 shadow-lg">
            <div class="font-black italic uppercase text-xs">Eenheid: <span id="displayKlas" class="text-yellow-400"></span></div>
            <div class="text-white font-mono text-sm bg-blue-900/50 px-3 py-1 rounded-full border border-blue-500">
                PV Punten: <span id="pScore" class="text-yellow-400">0</span>
            </div>
        </header>

        <section class="bg-slate-900 p-6 rounded-3xl border-2 border-white/10 shadow-2xl relative">
            <div class="flex justify-center">
                <canvas id="pacCanvas" width="380" height="300"></canvas>
            </div>
            <div id="gameMsg" class="hidden absolute inset-0 bg-black/90 flex flex-col items-center justify-center text-center rounded-xl">
                <h3 class="text-red-500 font-black text-3xl mb-4 italic">CRASH!</h3>
                <button onclick="startQuiz()" class="bg-yellow-500 text-black px-8 py-3 rounded-full font-black uppercase">Nieuwe Test</button>
            </div>
        </section>
    </div>

    <script>
        // --- WOORDENSCHAT DATA ---
        const vragen = [
            { q: "Wat betekent 'adequaat'?", a: ["Snel", "Passend", "Gevaarlijk", "Langzaam"], c: 1 },
            { q: "Wat is een 'incident'?", a: ["Een plan", "Een gebeurtenis", "Een voertuig", "Een beloning"], c: 1 },
            { q: "Wat betekent 'preventief'?", a: ["Achteraf", "Ter voorkoming", "Heel streng", "Tijdelijk"], c: 1 },
            { q: "Wat is 'legitimeren'?", a: ["Weglopen", "Bewijzen wie je bent", "Iets stelen", "Hulp roepen"], c: 1 },
            { q: "Wat betekent 'escaleren'?", a: ["Kleiner worden", "Erger worden", "Stoppen", "Blijven praten"], c: 1 },
            { q: "Wat is 'consistent'?", a: ["Steeds anders", "Hetzelfde blijven", "Zwak", "Heel boos"], c: 1 },
            { q: "Wat betekent 'verifiëren'?", a: ["Controleren", "Verliezen", "Verstoppen", "Vergeten"], c: 0 }
        ];

        let quizProgress = 0;
        let currentKlas = "";

        // --- QUIZ FUNCTIES ---
        function startQuiz() {
            const naam = document.getElementById('uNaam').value;
            currentKlas = document.getElementById('uKlas').value;
            if(!naam || !currentKlas) return alert("Vul gegevens in!");
            
            document.getElementById('loginOverlay').style.display = 'none';
            document.getElementById('gameMsg').classList.add('hidden');
            document.getElementById('quizOverlay').classList.remove('hidden');
            quizProgress = 0;
            nextQuestion();
        }

        function nextQuestion() {
            if(quizProgress >= 5) {
                document.getElementById('quizOverlay').classList.add('hidden');
                document.getElementById('mainContent').classList.remove('hidden');
                document.getElementById('displayKlas').innerText = currentKlas;
                startPacGame();
                return;
            }

            document.getElementById('qCount').innerText = quizProgress;
            const vraag = vragen[Math.floor(Math.random() * vragen.length)];
            document.getElementById('qText').innerText = vraag.q;
            const optDiv = document.getElementById('qOptions');
            optDiv.innerHTML = "";

            vraag.a.forEach((opt, i) => {
                const btn = document.createElement('button');
                btn.className = "w-full p-3 bg-slate-100 hover:bg-blue-100 text-slate-800 font-bold rounded transition-all";
                btn.innerText = opt;
                btn.onclick = () => {
                    if(i === vraag.c) {
                        quizProgress++;
                        nextQuestion();
                    } else {
                        alert("FOUT! Je woordenschat-kennis schiet tekort. Start opnieuw bij 0.");
                        quizProgress = 0;
                        nextQuestion();
                    }
                };
                optDiv.appendChild(btn);
            });
        }

        // --- PACMAN ENGINE ---
        const canvas = document.getElementById('pacCanvas');
        const ctx = canvas.getContext('2d');
        const size = 20;
        let score = 0, gameActive = false, pac, ghosts, lightOn = false;

        const mapLayout = [
            [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1],
            [1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1],
            [1,0,1,1,0,1,1,1,0,1,0,1,1,1,0,1,1,0,1],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
            [1,0,1,1,0,1,0,1,1,1,1,1,0,1,0,1,1,0,1],
            [1,0,0,0,0,1,0,0,0,1,0,0,0,1,0,0,0,0,1],
            [1,1,1,1,0,1,1,1,2,1,2,1,1,1,0,1,1,1,1],
            [2,2,2,2,0,2,2,2,2,2,2,2,2,2,0,2,2,2,2], // TUNNEL
            [1,1,1,1,0,1,1,1,1,1,1,1,1,1,0,1,1,1,1],
            [1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,1],
            [1,0,1,1,0,1,1,1,0,1,0,1,1,1,0,1,1,0,1],
            [1,0,0,1,0,0,0,0,0,2,0,0,0,0,0,1,0,0,1],
            [1,1,0,1,0,1,0,1,1,1,1,1,0,1,0,1,0,1,1],
            [1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1],
            [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
        ];
        let currentMap = [];

        function startPacGame() {
            gameActive = true; score = 0;
            document.getElementById('pScore').innerText = "0";
            currentMap = JSON.parse(JSON.stringify(mapLayout));
            pac = { x: 9, y: 13, dir: 1, nextDir: 1 };
            ghosts = [
                { x: 1, y: 1, color: '#ff4444', dir: 1 }, 
                { x: 17, y: 1, color: '#ff88ff', dir: 2 }
            ];
            update();
        }

        setInterval(() => { lightOn = !lightOn; }, 150);

        function canMove(e, d) {
            const dirs = [[1,0], [-1,0], [0,1], [0,-1]];
            let nX = e.x + dirs[d][0];
            let nY = e.y + dirs[d][1];
            if(nX < 0) nX = 18; if(nX > 18) nX = 0;
            return currentMap[nY] && currentMap[nY][nX] !== 1;
        }

        function update() {
            if(!gameActive) return;
            ctx.clearRect(0,0,canvas.width,canvas.height);
            for(let y=0; y<currentMap.length; y++) {
                for(let x=0; x<currentMap[y].length; x++) {
                    if(currentMap[y][x] === 1) {
                        ctx.fillStyle = '#1e40af'; ctx.fillRect(x*size, y*size, size-1, size-1);
                    } else if(currentMap[y][x] === 0) {
                        ctx.fillStyle = '#fff'; ctx.beginPath(); ctx.arc(x*size+size/2, y*size+size/2, 2, 0, 7); ctx.fill();
                    }
                }
            }
            if(canMove(pac, pac.nextDir)) pac.dir = pac.nextDir;
            if(canMove(pac, pac.dir)) {
                const dirs = [[1,0], [-1,0], [0,1], [0,-1]];
                pac.x += dirs[pac.dir][0]; pac.y += dirs[pac.dir][1];
                if(pac.x < 0) pac.x = 18; if(pac.x > 18) pac.x = 0;
            }
            if(currentMap[pac.y][pac.x] === 0) {
                currentMap[pac.y][pac.x] = 2; score += 10; document.getElementById('pScore').innerText = score;
            }
            ghosts.forEach(g => {
                if(!canMove(g, g.dir)) {
                    let v = [0,1,2,3].filter(d => canMove(g, d));
                    g.dir = v[Math.floor(Math.random()*v.length)];
                }
                const dirs = [[1,0], [-1,0], [0,1], [0,-1]];
                g.x += dirs[g.dir][0]; g.y += dirs[g.dir][1];
                if(g.x < 0) g.x = 18; if(g.x > 18) g.x = 0;
                if(g.x === pac.x && g.y === pac.y) { gameActive = false; document.getElementById('gameMsg').classList.remove('hidden'); }
            });
            ctx.fillStyle = '#facc15'; ctx.beginPath();
            ctx.arc(pac.x*size+size/2, pac.y*size+size/2, 8, 0.2*Math.PI, 1.8*Math.PI);
            ctx.lineTo(pac.x*size+size/2, pac.y*size+size/2); ctx.fill();
            if(lightOn) {
                ctx.fillStyle = '#3b82f6'; ctx.shadowBlur = 15; ctx.shadowColor = '#00f';
                ctx.beginPath(); ctx.arc(pac.x*size+size/2, pac.y*size+size/2-6, 6, 0, 7); ctx.fill(); ctx.shadowBlur = 0;
            }
            ghosts.forEach(g => { ctx.fillStyle = g.color; ctx.beginPath(); ctx.arc(g.x*size+size/2, g.y*size+size/2, 8, 0, 7); ctx.fill(); });
            setTimeout(update, 150);
        }

        window.addEventListener('keydown', e => {
            if(e.key === 'ArrowRight') pac.nextDir = 0; if(e.key === 'ArrowLeft') pac.nextDir = 1;
            if(e.key === 'ArrowDown') pac.nextDir = 2; if(e.key === 'ArrowUp') pac.nextDir = 3;
            if(e.key.includes('Arrow')) e.preventDefault();
        });
    </script>
</body>
</html>
