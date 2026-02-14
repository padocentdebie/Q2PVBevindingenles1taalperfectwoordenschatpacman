<!DOCTYPE html>
<html lang="nl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
    <title>BTV Zaandam 2026 - Surveillance Dashboard</title>
    <script src="https://cdn.tailwindcss.com"></script>
    
    <script type="module">
        import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js";
        import { getFirestore, collection, addDoc, query, where, getDocs, deleteDoc, serverTimestamp } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js";

        const firebaseConfig = {
            apiKey: "AIzaSyBRq1HFmhrpW_EMMZwpURrbTArz-L5iWT4",
            authDomain: "pvaangifteinleveren-77dbe.firebaseapp.com",
            projectId: "pvaangifteinleveren-77dbe",
            storageBucket: "pvaangifteinleveren-77dbe.firebasestorage.app",
            messagingSenderId: "20239054410",
            appId: "1:20239054410:web:264b3c759312248d9f18b3"
        };

        // Initialiseer Firebase alleen als het kan
        let db;
        try {
            const app = initializeApp(firebaseConfig);
            db = getFirestore(app);
        } catch (e) {
            console.warn("Firebase kon niet laden, game draait in offline modus.");
        }

        window.saveScore = async () => {
            const naam = document.getElementById('uNaam').value;
            const klas = document.getElementById('uKlas').value;
            const huidigeScore = parseInt(document.getElementById('pScore').innerText);
            if(!db) return alert("Database niet verbonden. Score alleen lokaal zichtbaar.");
            if(huidigeScore > 0) {
                await addDoc(collection(db, "pacman_scores"), { naam, klas, score: huidigeScore, ts: serverTimestamp() });
                alert("PV Punten opgeslagen!");
            }
        };

        window.resetLeaderboard = async () => {
            const klas = document.getElementById('uKlas').value;
            if(!db) return alert("Geen database verbinding.");
            if(!confirm("Leaderboard voor " + klas + " wissen?")) return;
            const q = query(collection(db, "pacman_scores"), where("klas", "==", klas));
            const snapshot = await getDocs(q);
            await Promise.all(snapshot.docs.map(d => deleteDoc(d.ref)));
            alert("Schoon dossier! Leaderboard is leeg.");
        };
    </script>

    <style>
        body { background-color: #0f172a; touch-action: manipulation; }
        .bg-police { background-color: #002d5e; }
        canvas { background: #000; border: 4px solid #1e40af; border-radius: 12px; box-shadow: 0 0 20px rgba(30, 64, 175, 0.4); }
    </style>
</head>
<body class="text-slate-200 font-sans">

    <div id="loginOverlay" class="fixed inset-0 bg-police z-50 flex items-center justify-center p-4">
        <div class="bg-white p-8 rounded shadow-2xl w-full max-w-sm text-center border-t-8 border-yellow-500 text-slate-900">
            <h1 class="font-black text-2xl mb-6 italic uppercase">BTV Surveillance 2026</h1>
            <input type="text" id="uNaam" placeholder="Naam Agent" class="w-full border-2 p-3 rounded mb-4 font-bold text-center outline-none focus:border-blue-900">
            <select id="uKlas" class="w-full border-2 p-3 rounded mb-8 font-bold text-center outline-none focus:border-blue-900">
                <option value="">Kies Eenheid</option>
                <option>Delta</option><option>Echo</option><option>Foxtrot</option>
            </select>
            <button onclick="login()" class="w-full bg-police text-white p-4 rounded font-black uppercase tracking-widest hover:bg-blue-900 transition-all">Start Patrouille</button>
        </div>
    </div>

    <div id="mainContent" class="hidden max-w-4xl mx-auto p-4 space-y-6">
        <header class="flex justify-between items-center bg-police p-4 rounded-xl border-b-4 border-yellow-500 shadow-lg">
            <div class="font-black italic uppercase text-xs">Eenheid: <span id="displayKlas" class="text-yellow-400"></span></div>
            <div class="flex gap-2">
                <button onclick="resetLeaderboard()" class="bg-red-700 px-3 py-1 rounded text-[10px] font-bold uppercase">Wis Dossiers</button>
                <button onclick="location.reload()" class="bg-slate-700 px-3 py-1 rounded text-[10px] font-bold uppercase">Log uit</button>
            </div>
        </header>

        <section class="bg-slate-900 p-6 rounded-3xl border-2 border-white/10 shadow-2xl">
            <div class="flex justify-between items-center mb-6">
                <h2 class="text-yellow-400 font-black italic uppercase text-xl tracking-tighter">BTV Pacman</h2>
                <div class="flex items-center gap-4">
                    <div class="text-right">
                        <div class="text-[10px] text-slate-400 uppercase font-bold">PV Punten</div>
                        <div id="pScore" class="text-2xl font-black text-white leading-none">0</div>
                    </div>
                    <button onclick="saveScore()" class="bg-green-600 px-4 py-2 rounded-lg font-black text-xs uppercase shadow-lg">Opslaan</button>
                </div>
            </div>
            
            <div class="relative flex justify-center">
                <canvas id="pacCanvas" width="380" height="300"></canvas>
                <div id="gameMsg" class="hidden absolute inset-0 bg-black/90 flex flex-col items-center justify-center text-center rounded-xl">
                    <h3 class="text-red-500 font-black text-3xl mb-4 italic">CRASH!</h3>
                    <button onclick="startPacGame()" class="bg-yellow-500 text-black px-8 py-3 rounded-full font-black uppercase">Nieuwe Patrouille</button>
                </div>
            </div>
            <p class="text-blue-400 text-[10px] mt-4 text-center font-bold uppercase tracking-widest animate-pulse">Bestuur de eenheid met de pijltjestoetsen</p>
        </section>
    </div>

    <script>
        // --- GAME LOGICA ---
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

        window.login = () => {
            if(!document.getElementById('uNaam').value || !document.getElementById('uKlas').value) return alert("Vul gegevens in.");
            document.getElementById('loginOverlay').style.display = 'none';
            document.getElementById('mainContent').classList.remove('hidden');
            document.getElementById('displayKlas').innerText = document.getElementById('uKlas').value;
            startPacGame();
        };

        function startPacGame() {
            gameActive = true; score = 0;
            document.getElementById('pScore').innerText = "0";
            document.getElementById('gameMsg').classList.add('hidden');
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
