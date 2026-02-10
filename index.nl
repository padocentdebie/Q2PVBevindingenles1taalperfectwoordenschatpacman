<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>BTV OFFLINE DEBUG</title>
    <style>
        body { background: #111; color: white; font-family: sans-serif; text-align: center; margin: 0; }
        #gameCanvas { background: #000; border: 2px solid #0044ff; margin: 20px auto; display: block; }
        .ui { font-size: 20px; font-weight: bold; color: #f0db4f; margin: 10px; }
        #quiz { 
            position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%);
            background: white; color: black; padding: 30px; border-radius: 10px;
            display: none; border: 5px solid #0044ff; box-shadow: 0 0 20px rgba(0,0,0,0.5);
        }
        button { padding: 15px 30px; font-size: 18px; cursor: pointer; background: #0044ff; color: white; border: none; border-radius: 5px; }
        .optie { display: block; width: 100%; margin: 10px 0; background: #eee; color: black; }
    </style>
</head>
<body>

    <div id="start-screen">
        <h1>BTV POLICE TRAINING</h1>
        <p>OFFLINE MODE (GEEN INTERNET NODIG)</p>
        <button onclick="start()">START TRAINING</button>
    </div>

    <div id="game-screen" style="display:none;">
        <div class="ui">SCORE: <span id="score">0</span></div>
        <canvas id="gameCanvas" width="400" height="400"></canvas>
        <div id="quiz">
            <h2 id="vraag">WAT IS DE BETEKENIS?</h2>
            <div id="opties"></div>
        </div>
    </div>

<script>
    // Lokale woordenlijst (Hardcoded)
    const woorden = [
        {v: "Aanhouding", m: "Iemand meenemen naar het bureau"},
        {v: "Proces-verbaal", m: "Een officieel verslag van een overtreding"},
        {v: "Surveillance", m: "Toezicht houden in een wijk"},
        {v: "Fouilleren", m: "Onderzoeken van kleding op verboden spullen"}
    ];

    let canvas, ctx, player, dots = [], score = 0, inGame = false;

    function start() {
        document.getElementById('start-screen').style.display = 'none';
        document.getElementById('game-screen').style.display = 'block';
        
        canvas = document.getElementById('gameCanvas');
        ctx = canvas.getContext('2d');
        player = { x: 200, y: 200, size: 20, speed: 4, dx: 0, dy: 0 };
        
        spawnDots();
        inGame = true;
        gameLoop();
    }

    function spawnDots() {
        dots = [];
        for(let i=0; i<3; i++) {
            dots.push({ x: Math.random()*360+20, y: Math.random()*360+20 });
        }
    }

    function gameLoop() {
        if(!inGame) return;

        // Achtergrond
        ctx.fillStyle = "black";
        ctx.fillRect(0, 0, 400, 400);

        // Beweeg speler
        player.x += player.dx;
        player.y += player.dy;

        // Randen check
        if(player.x < 0) player.x = 400; if(player.x > 400) player.x = 0;
        if(player.y < 0) player.y = 400; if(player.y > 400) player.y = 0;

        // Teken Speler (Agent)
        ctx.fillStyle = "#0044ff";
        ctx.fillRect(player.x-10, player.y-10, 20, 20);
        // Zwaailichtje
        ctx.fillStyle = (Date.now() % 400 < 200) ? "red" : "blue";
        ctx.fillRect(player.x-5, player.y-15, 10, 5);

        // Teken & Check Dots
        ctx.fillStyle = "white";
        dots.forEach((dot, index) => {
            ctx.beginPath();
            ctx.arc(dot.x, dot.y, 6, 0, Math.PI*2);
            ctx.fill();

            // Collision
            let dist = Math.hypot(player.x - dot.x, player.y - dot.y);
            if(dist < 20) {
                dots.splice(index, 1);
                score += 10;
                document.getElementById('score').innerText = score;
                if(dots.length === 0) toonQuiz();
            }
        });

        requestAnimationFrame(gameLoop);
    }

    function toonQuiz() {
        inGame = false;
        const quizDiv = document.getElementById('quiz');
        const vraagH2 = document.getElementById('vraag');
        const optiesDiv = document.getElementById('opties');
        
        const w = woorden[Math.floor(Math.random() * woorden.length)];
        vraagH2.innerText = `BETEKENIS VAN: ${w.v}`;
        optiesDiv.innerHTML = '';

        const btn = document.createElement('button');
        btn.className = 'optie';
        btn.innerText = w.m;
        btn.onclick = () => {
            quizDiv.style.display = 'none';
            spawnDots();
            inGame = true;
            gameLoop();
        };
        optiesDiv.appendChild(btn);
        
        quizDiv.style.display = 'block';
    }

    // Besturing
    window.addEventListener('keydown', e => {
        if(e.key === "ArrowUp")    { player.dx = 0; player.dy = -player.speed; }
        if(e.key === "ArrowDown")  { player.dx = 0; player.dy = player.speed; }
        if(e.key === "ArrowLeft")  { player.dx = -player.speed; player.dy = 0; }
        if(e.key === "ArrowRight") { player.dx = player.speed; player.dy = 0; }
    });
</script>
</body>
</html>
