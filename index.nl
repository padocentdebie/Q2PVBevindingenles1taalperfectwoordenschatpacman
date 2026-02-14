<!DOCTYPE html>
<html lang="nl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Q2les1PVBevindingen</title>
    <script src="https://cdn.tailwindcss.com"></script>
    
    <script type="module">
        import { initializeApp } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-app.js";
        import { getFirestore, collection, addDoc, query, where, getDocs, deleteDoc, doc, updateDoc, serverTimestamp } from "https://www.gstatic.com/firebasejs/10.7.1/firebase-firestore.js";

        const firebaseConfig = {
            apiKey: "AIzaSyBRq1HFmhrpW_EMMZwpURrbTArz-L5iWT4",
            authDomain: "pvaangifteinleveren-77dbe.firebaseapp.com",
            databaseURL: "https://pvaangifteinleveren-77dbe-default-rtdb.europe-west1.firebasedatabase.app",
            projectId: "pvaangifteinleveren-77dbe",
            storageBucket: "pvaangifteinleveren-77dbe.firebasestorage.app",
            messagingSenderId: "20239054410",
            appId: "1:20239054410:web:264b3c759312248d9f18b3"
        };

        const app = initializeApp(firebaseConfig);
        const db = getFirestore(app);

        window.onload = () => {
            alert("VEILIGHEIDSMELDING: U betreedt een beveiligde werkomgeving. Ga vertrouwelijk om met de gegevens van medestudenten en de casuïstiek.");
        };

        async function wijsPartnerToe() {
            const klas = document.getElementById('klas').value;
            const eigenNaam = document.getElementById('naam').value;
            const partnerDisplay = document.getElementById('partnerDisplay');
            if(!eigenNaam) return alert("Voer eerst uw eigen voornaam in.");
            partnerDisplay.innerText = "Zoeken...";
            try {
                const q = query(collection(db, "casus_inzendingen"), where("klas", "==", klas));
                const snap = await getDocs(q);
                let studenten = [];
                snap.forEach(docSnap => {
                    if(docSnap.data().student !== eigenNaam) studenten.push(docSnap.data().student);
                });
                if(studenten.length > 0) {
                    const partner = studenten[Math.floor(Math.random() * studenten.length)];
                    partnerDisplay.innerText = partner;
                    document.getElementById('hiddenPartner').value = partner;
                } else {
                    partnerDisplay.innerText = "Geen klasgenoten online";
                }
            } catch (e) { console.error(e); }
        }

        async function submitCasus() {
            const naam = document.getElementById('naam').value;
            const klas = document.getElementById('klas').value;
            const partner = document.getElementById('hiddenPartner').value;
            const daa = document.getElementById('daaText').value;
            const pv = document.getElementById('pvText').value;
            if(!naam || !daa || !pv) return alert("FOUT: Alle velden zijn verplicht.");
            if(confirm("Bevestig: U staat op het punt uw DAA en PV definitief in te leveren.")) {
                try {
                    await addDoc(collection(db, "casus_inzendingen"), {
                        student: naam, partner, klas, daa, pv, timestamp: serverTimestamp()
                    });
                    alert("Systeemmelding: Inzending succesvol opgeslagen.");
                    location.reload();
                } catch (e) { console.error(e); }
            }
        }

        async function updateFeedback(docId, criteriaIndex, isChecked) {
            try {
                const docRef = doc(db, "casus_inzendingen", docId);
                await updateDoc(docRef, { [`feedback_${criteriaIndex}`]: isChecked });
            } catch (e) { console.error(e); }
        }

        async function laadKlas(gekozenKlas) {
            const lijst = document.getElementById('feedbackLijst');
            lijst.innerHTML = "<p class='text-center p-4 italic'>Inzendingen worden geladen...</p>";
            const q = query(collection(db, "casus_inzendingen"), where("klas", "==", gekozenKlas));
            const snap = await getDocs(q);
            lijst.innerHTML = "";
            if(snap.empty) {
                lijst.innerHTML = "<p class='text-center p-4 text-gray-500'>Geen inzendingen gevonden voor deze klas.</p>";
                return;
            }
            snap.forEach(docSnap => {
                const d = docSnap.data();
                const id = docSnap.id;
                const criteria = ["Positionering voertuig", "Veiligheidsmaatregelen", "METHANE-methode", "Strafbaar feit", "Partners (VOA/Ambu)", "Opsporingstaken"];
                let feedbackHtml = "";
                criteria.forEach((label, index) => {
                    const isChecked = d[`feedback_${index}`] ? "checked" : "";
                    feedbackHtml += `<label class="flex items-center p-1 cursor-pointer no-print"><input type="checkbox" class="mr-2" ${isChecked} onchange="updateFeedback('${id}', ${index}, this.checked)"> ${label}</label>`;
                });

                lijst.innerHTML += `
                    <div class="bg-white border-2 p-8 mb-8 shadow-sm text-left print-section">
                        <div class="flex justify-between border-b pb-2 mb-6 bg-gray-50 px-2 py-1 print:bg-white">
                            <span class="font-bold text-blue-900 uppercase text-xs print:text-sm">Auteur: ${d.student}</span>
                            <span class="text-[10px] text-gray-500 italic uppercase print:text-sm">Partner: ${d.partner || 'N.V.T.'}</span>
                        </div>
                        <div class="mb-8">
                            <h4 class="text-[10px] font-bold uppercase text-gray-400 mb-2">Doel Aanpak Analyse (DAA)</h4>
                            <div class="text-sm whitespace-pre-wrap text-gray-800 leading-relaxed font-serif print:text-base print:text-black">${d.daa}</div>
                        </div>
                        <div class="mb-8">
                            <h4 class="text-[10px] font-bold uppercase text-gray-400 mb-2">Proces-verbaal van Bevindingen</h4>
                            <div class="text-sm whitespace-pre-wrap text-gray-800 leading-relaxed font-serif print:text-base print:text-black">${d.pv}</div>
                        </div>
                        <div class="bg-slate-50 p-4 border rounded text-[11px] no-print mb-4">
                            <p class="font-bold mb-2 uppercase text-blue-900">Peer Feedback Aandachtspunten:</p>
                            <div class="grid grid-cols-2 gap-1">${feedbackHtml}</div>
                        </div>
                        <div class="flex gap-4 no-print">
                            <button onclick="window.print()" class="bg-blue-900 text-white px-4 py-2 text-[10px] font-bold uppercase hover:bg-black transition">Exporteer als PV</button>
                        </div>
                    </div>`;
            });
        }

        async function resetKlas(gekozenKlas) {
            if(!confirm(`AUTORISATIE: Wilt u alle data van klas ${gekozenKlas} definitief wissen?`)) return;
            const q = query(collection(db, "casus_inzendingen"), where("klas", "==", gekozenKlas));
            const snap = await getDocs(q);
            const promises = snap.docs.map(d => deleteDoc(doc(db, "casus_inzendingen", d.id)));
            await Promise.all(promises);
            location.reload();
        }

        window.submitCasus = submitCasus; window.laadKlas = laadKlas; window.wijsPartnerToe = wijsPartnerToe; window.resetKlas = resetKlas; window.updateFeedback = updateFeedback;
    </script>

    <style>
        body { background-color: #f8f9fa; color: #1a1a1a; font-family: ui-sans-serif, system-ui, sans-serif; }
        .police-blue { background-color: #002d5e; }
        .police-border { border-color: #002d5e; }
        .text-police { color: #002d5e; }
        
        @media print {
            body { background-color: white !important; padding: 0 !important; }
            .no-print, header, .oc-box, button, select, input, label { display: none !important; }
            .print-section { 
                border: none !important; 
                box-shadow: none !important; 
                margin: 0 !important; 
                padding: 2cm !important; 
                page-break-after: always;
                width: 100% !important;
            }
            .max-w-4xl { max-width: 100% !important; }
            h4 { color: black !important; font-size: 10pt !important; border-bottom: 1px solid #ccc; margin-bottom: 10pt; }
        }
    </style>
</head>
<body class="p-4 md:p-12">

    <div class="max-w-4xl mx-auto">
        <header class="no-print">
            <h1 class="text-center text-xl font-bold uppercase tracking-[0.2em] text-police mb-10">Q2les1PVBevindingen</h1>

            <div class="bg-white border-y-4 police-border p-8 mb-12 text-center shadow-sm oc-box">
                <h2 class="text-[10px] font-black uppercase text-blue-900 mb-3 tracking-widest">Bericht Operationeel Centrum</h2>
                <p class="italic text-lg text-gray-700 leading-relaxed mb-6">
                    “Wilt u gaan naar kruising Vincent van Goghweg met de Westzijde, 1506 GC Zaandam. Hier is een motorrijder gevallen. Het slachtoffer is aanspreekbaar en heeft mogelijk letsel. De ambulance is onderweg en u heeft toestemming.”
                </p>
                <div class="grid grid-cols-1 md:grid-cols-3 gap-4 mt-8 border-t pt-8">
                    <div class="space-y-1">
                        <img src="Screenshot%202026-02-14%2008.16.11.png" alt="A1" class="w-full h-32 object-contain bg-gray-50 border rounded">
                        <p class="text-[8px] uppercase text-gray-400">RVV A1 (50km/h)</p>
                    </div>
                    <div class="space-y-1">
                        <img src="Screenshot%202026-02-14%2008.15.53.png" alt="Streetview" class="w-full h-32 object-cover bg-gray-50 border rounded">
                        <p class="text-[8px] uppercase text-gray-400">Streetview</p>
                    </div>
                    <div class="space-y-1">
                        <img src="Screenshot%202026-02-14%2008.15.26.png" alt="Maps Overzicht" class="w-full h-32 object-cover bg-gray-50 border rounded">
                        <p class="text-[8px] uppercase text-gray-400">Maps Overzicht</p>
                    </div>
                </div>
            </div>

            <div class="bg-white p-8 border border-gray-200 shadow-sm mb-16">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6 mb-6">
                    <div>
                        <label class="block text-[10px] font-bold uppercase mb-1 text-gray-400 text-left">Naam Student</label>
                        <input type="text" id="naam" placeholder="Voornaam Student" class="w-full border p-2 text-sm outline-none focus:border-blue-900 bg-gray-50">
                    </div>
                    <div>
                        <label class="block text-[10px] font-bold uppercase mb-1 text-gray-400 text-left">Klasgroep (Nato)</label>
                        <select id="klas" class="w-full border p-2 text-sm outline-none focus:border-blue-900 bg-gray-50">
                            <option value="Delta">Delta</option><option value="Echo">Echo</option><option value="Foxtrot">Foxtrot</option><option value="Mike">Mike</option><option value="Lima">Lima</option>
                        </select>
                    </div>
                </div>

                <div class="bg-slate-100 p-3 border-l-4 border-blue-900 mb-8 flex justify-between items-center text-xs">
                    <span>Gekoppelde collega voor DAA: <span id="partnerDisplay" class="font-bold text-blue-900">-</span></span>
                    <button onclick="wijsPartnerToe()" class="police-blue text-white px-4 py-1 uppercase text-[10px] font-bold hover:bg-blue-800 transition">Koppel Collega</button>
                    <input type="hidden" id="hiddenPartner">
                </div>

                <div class="space-y-6 text-left">
                    <div>
                        <label class="block text-[10px] font-bold uppercase mb-1 text-police">1. Doel Aanpak Analyse (DAA)</label>
                        <textarea id="daaText" rows="4" class="w-full border p-3 text-sm outline-none focus:bg-white bg-gray-50 transition-all"></textarea>
                    </div>
                    <div>
                        <label class="block text-[10px] font-bold uppercase mb-1 text-police">2. Proces-verbaal van Bevindingen</label>
                        <textarea id="pvText" rows="6" class="w-full border p-3 text-sm outline-none focus:bg-white bg-gray-50 transition-all"></textarea>
                    </div>
                    <button onclick="submitCasus()" class="w-full police-blue text-white font-bold py-4 uppercase tracking-[0.2em] text-sm hover:bg-black transition shadow-lg">Inleveren in Systeem</button>
                </div>
            </div>
        </header>

        <div class="border-t-2 border-gray-200 pt-10 no-print">
            <h2 class="text-center font-bold uppercase text-xs tracking-widest mb-8 text-police">Peer Feedback & Resultaten</h2>
            <div class="flex flex-wrap justify-center gap-4 mb-12">
                <div class="text-center space-y-1">
                    <button onclick="laadKlas('Delta')" class="w-20 border border-blue-900 py-1 text-[9px] font-bold hover:bg-blue-50">DELTA</button>
                    <button onclick="resetKlas('Delta')" class="block mx-auto text-[7px] text-red-400 font-bold uppercase">Reset</button>
                </div>
                <div class="text-center space-y-1">
                    <button onclick="laadKlas('Echo')" class="w-20 border border-blue-900 py-1 text-[9px] font-bold hover:bg-blue-50">ECHO</button>
                    <button onclick="resetKlas('Echo')" class="block mx-auto text-[7px] text-red-400 font-bold uppercase">Reset</button>
                </div>
                <div class="text-center space-y-1">
                    <button onclick="laadKlas('Foxtrot')" class="w-20 border border-blue-900 py-1 text-[9px] font-bold hover:bg-blue-50">FOXTROT</button>
                    <button onclick="resetKlas('Foxtrot')" class="block mx-auto text-[7px] text-red-400 font-bold uppercase">Reset</button>
                </div>
                <div class="text-center space-y-1">
                    <button onclick="laadKlas('Mike')" class="w-20 border border-blue-900 py-1 text-[9px] font-bold hover:bg-blue-50">MIKE</button>
                    <button onclick="resetKlas('Mike')" class="block mx-auto text-[7px] text-red-400 font-bold uppercase">Reset</button>
                </div>
                <div class="text-center space-y-1">
                    <button onclick="laadKlas('Lima')" class="w-20 border border-blue-900 py-1 text-[9px] font-bold hover:bg-blue-50">LIMA</button>
                    <button onclick="resetKlas('Lima')" class="block mx-auto text-[7px] text-red-400 font-bold uppercase">Reset</button>
                </div>
            </div>
        </div>
        
        <div id="feedbackLijst" class="max-w-3xl mx-auto pb-20"></div>
    </div>
</body>
</html>
