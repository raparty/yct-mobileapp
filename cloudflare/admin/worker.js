// YCT Admin Panel Worker
// Serves the admin panel HTML at crimson-art-feea.yct-app.workers.dev

const HTML = `<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>YCT Admin — Content Manager</title>
<style>
  *{box-sizing:border-box;margin:0;padding:0}
  body{font-family:-apple-system,BlinkMacSystemFont,'Segoe UI',sans-serif;background:#f0f4f0;color:#2c2c2a}
  .hdr{background:#2d5a2d;color:white;padding:14px 24px;display:flex;align-items:center;gap:12px}
  .hdr h1{font-size:17px;font-weight:600}
  .wrap{max-width:900px;margin:0 auto;padding:20px 16px}
  .tabs{display:flex;gap:4px;margin-bottom:18px;background:white;padding:4px;border-radius:10px;border:1px solid #d3d1c7}
  .tab{flex:1;padding:9px;text-align:center;border-radius:7px;cursor:pointer;font-size:13px;font-weight:500;color:#888}
  .tab.active{background:#2d5a2d;color:white}
  .panel{display:none}.panel.active{display:block}
  .card{background:white;border-radius:12px;border:1px solid #d3d1c7;padding:18px;margin-bottom:14px}
  .card h3{font-size:13px;font-weight:600;color:#2d5a2d;margin-bottom:14px}
  .row{display:grid;grid-template-columns:1fr 1fr;gap:12px;margin-bottom:12px}
  .row3{grid-template-columns:1fr 1fr 1fr}.row1{grid-template-columns:1fr}
  label{display:block;font-size:10px;font-weight:600;color:#5f5e5a;margin-bottom:4px;text-transform:uppercase}
  input,select,textarea{width:100%;padding:8px 11px;border:1px solid #d3d1c7;border-radius:7px;font-size:13px}
  input:focus,select:focus{outline:none;border-color:#2d5a2d}
  .dz{border:2px dashed #d3d1c7;border-radius:9px;padding:16px;text-align:center;cursor:pointer;background:#fafafa;font-size:12px;color:#888}
  .dz:hover{border-color:#2d5a2d;background:#e8f5e8}
  .dz strong{color:#2d5a2d}
  .sf{background:#e8f5e8;border:1px solid #2d5a2d;border-radius:7px;padding:7px 11px;margin-top:5px;display:none;font-size:12px;color:#2d5a2d}
  .prev{width:70px;height:90px;object-fit:cover;border-radius:5px;border:1px solid #d3d1c7;display:none;margin-top:7px}
  .btn{background:#2d5a2d;color:white;border:none;border-radius:8px;padding:10px;font-size:13px;font-weight:600;cursor:pointer;width:100%;margin-top:10px}
  .btn:hover{background:#3c783c}.btn:disabled{background:#b4b2a9;cursor:not-allowed}
  .pw{margin-top:9px;display:none}
  .pb{height:6px;background:#e8f5e8;border-radius:3px;overflow:hidden}
  .pf{height:100%;background:#2d5a2d;transition:width .3s;border-radius:3px;width:0%}
  .pl{font-size:10px;color:#5f5e5a;margin-top:3px}
  .res{margin-top:9px;padding:9px 13px;border-radius:7px;font-size:12px;display:none}
  .ok{background:#e8f5e8;color:#2d5a2d;border:1px solid #b8d8b8}
  .er{background:#fdecea;color:#c0392b;border:1px solid #f5c6c2}
  .info{padding:9px 13px;border-radius:7px;font-size:12px;margin-bottom:14px;background:#e6f1fb;color:#185fa5;border:1px solid #b8d4f0}
  /* List */
  .clist{margin-top:10px}
  .ci{display:flex;align-items:center;gap:10px;padding:9px 11px;border:1px solid #d3d1c7;border-radius:8px;margin-bottom:5px;background:white}
  .ci img{width:34px;height:44px;object-fit:cover;border-radius:3px}
  .cp{width:34px;height:44px;border-radius:3px;background:#2d5a2d;display:flex;align-items:center;justify-content:center;font-size:9px;color:white;font-weight:bold;text-align:center;line-height:1.2}
  .ci .inf{flex:1;min-width:0}
  .ci .inf strong{display:block;font-size:13px;color:#2c2c2a;white-space:nowrap;overflow:hidden;text-overflow:ellipsis}
  .ci .inf span{font-size:11px;color:#888}
  .db{background:none;border:1px solid #e74c3c;color:#e74c3c;padding:4px 10px;border-radius:5px;cursor:pointer;font-size:11px;white-space:nowrap}
  .db:hover{background:#fdecea}
  /* Auth */
  #lov{position:fixed;inset:0;background:#2d5a2d;display:flex;align-items:center;justify-content:center;z-index:100}
  .lc{background:white;padding:28px;border-radius:14px;width:300px;text-align:center}
  .lc h2{margin-bottom:3px;color:#2d5a2d;font-size:20px}
  .lc p{font-size:12px;color:#888;margin-bottom:18px}
  .lc input{margin-bottom:9px}
  .lb{background:#2d5a2d;color:white;border:none;border-radius:8px;padding:10px;font-size:14px;font-weight:600;cursor:pointer;width:100%;margin-top:3px}
  #le2{color:#c0392b;font-size:11px;margin-top:6px}
  /* Bulk */
  .bl{max-height:180px;overflow-y:auto;margin-top:7px}
  .fi{display:flex;align-items:center;gap:7px;padding:4px 7px;border-radius:5px;margin-bottom:3px;background:#fafafa;font-size:11px}
  .fn{flex:1;overflow:hidden;text-overflow:ellipsis;white-space:nowrap}
  .fs{font-size:10px;min-width:60px;text-align:right;color:#888}
  .fs.done{color:#2d5a2d;font-weight:600}.fs.fail{color:#c0392b}.fs.up{color:#f0a03c}
</style>
</head>
<body>
<div id="lov">
  <div class="lc">
    <div style="font-size:38px;margin-bottom:8px">🪷</div>
    <h2>YCT Admin</h2>
    <p>Content Manager — Yoga Consciousness Trust</p>
    <label>Email</label><input type="email" id="le">
    <label>Password</label><input type="password" id="lp" onkeydown="if(event.key==='Enter')doLogin()">
    <button class="lb" onclick="doLogin()">Sign In</button>
    <div id="le2"></div>
  </div>
</div>

<div class="hdr">
  <div style="width:34px;height:34px;background:rgba(255,255,255,.2);border-radius:50%;display:flex;align-items:center;justify-content:center;font-weight:bold;font-size:11px">YCT</div>
  <div><h1>Content Manager</h1><div id="ui" style="font-size:10px;opacity:.7"></div></div>
  <button onclick="doLogout()" style="margin-left:auto;background:rgba(255,255,255,.15);color:white;border:none;padding:5px 12px;border-radius:5px;cursor:pointer;font-size:11px">Sign out</button>
</div>

<div class="wrap">
  <div class="info">📱 Upload here → file goes to Cloudflare R2 + database entry created automatically. One click does it all.</div>
  <div class="tabs">
    <div class="tab active" onclick="st('magazine')">📰 Magazine</div>
    <div class="tab" onclick="st('audio')">🎵 Audio</div>
    <div class="tab" onclick="st('book')">📚 Book</div>
    <div class="tab" onclick="st('settings')">⚙️ Settings</div>
  </div>

  <!-- MAGAZINE -->
  <div class="panel active" id="panel-magazine">
    <div class="card">
      <h3>Upload Magazine Issue</h3>
      <div class="row row3">
        <div><label>Month</label>
          <select id="mm" onchange="ut()">
            <option value="1">January — జనవరి</option><option value="2">February — ఫిబ్రవరి</option>
            <option value="3">March — మార్చి</option><option value="4">April — ఏప్రిల్</option>
            <option value="5">May — మే</option><option value="6">June — జూన్</option>
            <option value="7">July — జులై</option><option value="8">August — ఆగస్టు</option>
            <option value="9">September — సెప్టెంబర్</option><option value="10">October — అక్టోబర్</option>
            <option value="11">November — నవంబర్</option><option value="12">December — డిసెంబర్</option>
          </select></div>
        <div><label>Year</label><input type="number" id="my" value="2026" oninput="ut()"></div>
        <div><label>Volume & Pages</label>
          <div style="display:grid;grid-template-columns:1fr 1fr;gap:6px">
            <input type="number" id="mv" value="28" placeholder="Vol">
            <input type="number" id="mp" value="34" placeholder="Pgs">
          </div></div>
      </div>
      <div class="row">
        <div>
          <label>PDF File *</label>
          <div class="dz" onclick="document.getElementById('mf').click()">Drop PDF or <strong>browse</strong></div>
          <div class="sf" id="mfs"></div>
          <input type="file" id="mf" accept=".pdf" style="display:none" onchange="sf(this,'mfs')">
        </div>
        <div>
          <label>Cover Image (optional)</label>
          <div class="dz" onclick="document.getElementById('mi').click()">Drop image or <strong>browse</strong></div>
          <div class="sf" id="mis"></div>
          <img id="mip" class="prev">
          <input type="file" id="mi" accept="image/*" style="display:none" onchange="si(this,'mis','mip')">
        </div>
      </div>
      <button class="btn" id="mb" onclick="uploadMag()">⬆ Upload Magazine</button>
      <div class="pw" id="mpw"><div class="pb"><div class="pf" id="mpf"></div></div><div class="pl" id="mpl"></div></div>
      <div class="res" id="mr"></div>
    </div>
    <div class="card">
      <h3>Existing Magazines <span style="font-size:11px;font-weight:400;color:#888">(click 🗑 to delete)</span></h3>
      <div class="clist" id="mlist"><p style="color:#888;font-size:12px">Loading...</p></div>
    </div>
  </div>

  <!-- AUDIO -->
  <div class="panel" id="panel-audio">
    <div class="card">
      <h3>Upload Audio Discourses</h3>
      <p style="font-size:12px;color:#888;margin-bottom:10px">Select multiple MP3s — all upload automatically in one click.</p>
      <div class="dz" onclick="document.getElementById('af').click()">Drop MP3 files or <strong>click to browse</strong> (select hundreds at once)</div>
      <input type="file" id="af" accept=".mp3,.m4a,.wav" multiple style="display:none" onchange="sa(this)">
      <div class="bl" id="al"></div>
      <div id="as2" style="font-size:11px;color:#888;margin-top:5px"></div>
      <button class="btn" id="ab" style="display:none" onclick="uploadAudio()">⬆ Upload All Audio</button>
      <div class="pw" id="apw"><div class="pb"><div class="pf" id="apf"></div></div><div class="pl" id="apl"></div></div>
      <div class="res" id="ar"></div>
    </div>
    <div class="card">
      <h3>Existing Discourses <span style="font-size:11px;font-weight:400;color:#888">(click 🗑 to delete)</span></h3>
      <div class="clist" id="alist2"><p style="color:#888;font-size:12px">Loading...</p></div>
    </div>
  </div>

  <!-- BOOK -->
  <div class="panel" id="panel-book">
    <div class="card">
      <h3>Upload Book</h3>
      <div class="row">
        <div><label>Title (English) *</label><input id="bt"></div>
        <div><label>Title (Telugu)</label><input id="bte"></div>
      </div>
      <div class="row">
        <div><label>Language</label><select id="bl"><option>English</option><option>Telugu</option><option>Bilingual</option></select></div>
        <div><label>Sort Order</label><input type="number" id="bo" value="1"></div>
      </div>
      <div class="row row1"><div><label>Description</label><textarea id="bd" rows="2"></textarea></div></div>
      <div class="row">
        <div>
          <label>PDF File *</label>
          <div class="dz" onclick="document.getElementById('bf').click()">Drop PDF or <strong>browse</strong></div>
          <div class="sf" id="bfs"></div>
          <input type="file" id="bf" accept=".pdf" style="display:none" onchange="sf(this,'bfs')">
        </div>
        <div>
          <label>Cover Image (optional)</label>
          <div class="dz" onclick="document.getElementById('bi').click()">Drop image or <strong>browse</strong></div>
          <div class="sf" id="bis"></div>
          <img id="bip" class="prev">
          <input type="file" id="bi" accept="image/*" style="display:none" onchange="si(this,'bis','bip')">
        </div>
      </div>
      <button class="btn" id="bb" onclick="uploadBook()">⬆ Upload Book</button>
      <div class="pw" id="bpw"><div class="pb"><div class="pf" id="bpf"></div></div><div class="pl" id="bpl"></div></div>
      <div class="res" id="br"></div>
    </div>
    <div class="card">
      <h3>Existing Books <span style="font-size:11px;font-weight:400;color:#888">(click 🗑 to delete)</span></h3>
      <div class="clist" id="blist"><p style="color:#888;font-size:12px">Loading...</p></div>
    </div>
  </div>

  <!-- SETTINGS -->
  <div class="panel" id="panel-settings">
    <div class="card">
      <h3>App Settings</h3>
      <div class="row row1"><div><label>Daily Quote (English)</label><textarea id="sq" rows="3"></textarea></div></div>
      <div class="row row1"><div><label>Daily Quote (Telugu)</label><textarea id="sqt" rows="3"></textarea></div></div>
      <div class="row">
        <div><label>Contact Email</label><input type="email" id="se"></div>
        <div><label>WhatsApp Number</label><input id="sw"></div>
      </div>
      <button class="btn" onclick="saveSettings()">💾 Save Settings</button>
      <div class="res" id="sr"></div>
    </div>
  </div>
</div>

<script type="module">
import { initializeApp } from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-app.js';
import { getFirestore, collection, addDoc, doc, setDoc, getDoc, getDocs, deleteDoc, serverTimestamp }
  from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-firestore.js';
import { getAuth, signInWithEmailAndPassword, signOut, onAuthStateChanged }
  from 'https://www.gstatic.com/firebasejs/10.12.0/firebase-auth.js';

const WK = 'https://yct-upload.yct-app.workers.dev';
const R2 = 'https://pub-360b7b3324fb4f22bb35e656f476062a.r2.dev';
const TM = ['','జనవరి','ఫిబ్రవరి','మార్చి','ఏప్రిల్','మే','జూన్','జులై','ఆగస్టు','సెప్టెంబర్','అక్టోబర్','నవంబర్','డిసెంబర్'];
const EN = ['','January','February','March','April','May','June','July','August','September','October','November','December'];

const app = initializeApp({apiKey:"AIzaSyBF7Qn4Ytrys9WLuBU41G2KOuxBN0GWGO8",authDomain:"yct-app.firebaseapp.com",projectId:"yct-app",storageBucket:"yct-app.firebasestorage.app",messagingSenderId:"881638212469",appId:"1:881638212469:web:61a9f6121c0a346cb7893c"});
const db = getFirestore(app);
const auth = getAuth(app);

onAuthStateChanged(auth, u => {
  document.getElementById('lov').style.display = u ? 'none' : 'flex';
  if (u) { document.getElementById('ui').textContent = u.email; loadAll(); loadSettings(); }
});
window.doLogin = async () => {
  document.getElementById('le2').textContent = '';
  try { await signInWithEmailAndPassword(auth, document.getElementById('le').value, document.getElementById('lp').value); }
  catch { document.getElementById('le2').textContent = 'Invalid email or password.'; }
};
window.doLogout = () => signOut(auth);
window.st = n => {
  document.querySelectorAll('.tab').forEach((t,i)=>t.classList.toggle('active',['magazine','audio','book','settings'][i]===n));
  document.querySelectorAll('.panel').forEach(p=>p.classList.remove('active'));
  document.getElementById('panel-'+n).classList.add('active');
};

// Title auto-fill
window.ut = () => {
  // no separate title field now - used inline
};

// File helpers
window.sf = (inp, sid) => {
  const f = inp.files[0]; if(!f) return;
  const el = document.getElementById(sid);
  el.style.display = 'block';
  el.textContent = \`✓ \${f.name} (\${(f.size/1024/1024).toFixed(1)} MB)\`;
};
window.si = (inp, sid, pid) => {
  const f = inp.files[0]; if(!f) return;
  document.getElementById(sid).style.display = 'block';
  document.getElementById(sid).textContent = \`✓ \${f.name}\`;
  const p = document.getElementById(pid);
  p.style.display = 'block'; p.src = URL.createObjectURL(f);
};

// R2 upload
async function r2up(file, path, onP) {
  return new Promise((res,rej) => {
    const fd = new FormData(); fd.append('file',file); fd.append('path',path);
    const xhr = new XMLHttpRequest();
    xhr.open('POST', WK+'/upload');
    if(onP) xhr.upload.onprogress = e => { if(e.lengthComputable) onP(e.loaded/e.total); };
    xhr.onload = () => xhr.status<300 ? res(JSON.parse(xhr.responseText).url||\`\${R2}/\${path}\`) : rej(new Error(\`\${xhr.status}\`));
    xhr.onerror = () => rej(new Error('Network error'));
    xhr.send(fd);
  });
}

// R2 delete (best-effort)
async function r2del(path) {
  if(!path) return;
  try { await fetch(\`\${WK}/delete\`,{method:'DELETE',headers:{'Content-Type':'application/json'},body:JSON.stringify({path})}); } catch(_){}
}

function sp(id,pct,lbl){
  document.getElementById(id+'pw').style.display='block';
  document.getElementById(id+'pf').style.width=pct+'%';
  document.getElementById(id+'pl').textContent=lbl;
}
function sr2(id,ok,msg){
  const el=document.getElementById(id+'r'||id);
  el.style.display='block'; el.className='res '+(ok?'ok':'er');
  el.textContent=(ok?'✅ ':'❌ ')+msg;
}

// ── LOAD ALL LISTS ───────────────────────────────────────────────────────────
function loadAll(){ loadMags(); loadAudio2(); loadBooks(); }

async function loadMags(){
  const el=document.getElementById('mlist');
  el.innerHTML='<p style="color:#888;font-size:12px">Loading...</p>';
  try{
    const snap=await getDocs(collection(db,'magazines'));
    const docs=snap.docs.map(d=>({id:d.id,...d.data()})).sort((a,b)=>(b.year-a.year)||(b.month-a.month));
    if(!docs.length){el.innerHTML='<p style="color:#888;font-size:12px">No magazines yet.</p>';return;}
    el.innerHTML=docs.map(d=>\`
      <div class="ci">
        \${d.cover_image_url?\`<img src="\${d.cover_image_url}">\`:'<div class="cp">YCT</div>'}
        <div class="inf"><strong>\${d.title_english||''}</strong><span>\${d.title_telugu||''} · \${d.pages||0}pp · Vol.\${d.volume||0}</span></div>
        <button class="db" onclick="delMag('\${d.id}','\${d.pdf_path||''}','\${d.cover_image_path||''}','\${(d.title_english||'').replace(/'/g,"\\\\'")}')">🗑 Delete</button>
      </div>\`).join('');
  }catch(e){el.innerHTML=\`<p style="color:#c0392b;font-size:12px">Error: \${e.message}</p>\`;}
}
window.delMag = async(id,pp,cp,label)=>{
  if(!confirm(\`Delete "\${label}"?\\nThis removes the file from R2 and the database. Cannot be undone.\`)) return;
  await deleteDoc(doc(db,'magazines',id));
  await r2del(pp); await r2del(cp);
  loadMags();
};

async function loadAudio2(){
  const el=document.getElementById('alist2');
  el.innerHTML='<p style="color:#888;font-size:12px">Loading...</p>';
  try{
    const snap=await getDocs(collection(db,'audio'));
    const docs=snap.docs.map(d=>({id:d.id,...d.data()})).sort((a,b)=>(a.title||'').localeCompare(b.title||''));
    if(!docs.length){el.innerHTML='<p style="color:#888;font-size:12px">No audio yet.</p>';return;}
    el.innerHTML=docs.map(d=>\`
      <div class="ci">
        <div class="cp">🎵</div>
        <div class="inf"><strong>\${d.title||d.file_name||''}</strong><span>\${d.title_telugu||''} \${d.topic?'· '+d.topic:''}</span></div>
        <button class="db" onclick="delAudio('\${d.id}','\${d.audio_path||''}','\${(d.title||'').replace(/'/g,"\\\\'")}')">🗑 Delete</button>
      </div>\`).join('');
  }catch(e){el.innerHTML=\`<p style="color:#c0392b;font-size:12px">Error: \${e.message}</p>\`;}
}
window.delAudio = async(id,ap,label)=>{
  if(!confirm(\`Delete "\${label}"?\`)) return;
  await deleteDoc(doc(db,'audio',id));
  await r2del(ap);
  loadAudio2();
};

async function loadBooks(){
  const el=document.getElementById('blist');
  el.innerHTML='<p style="color:#888;font-size:12px">Loading...</p>';
  try{
    const snap=await getDocs(collection(db,'books'));
    const docs=snap.docs.map(d=>({id:d.id,...d.data()})).sort((a,b)=>(a.sort_order||0)-(b.sort_order||0));
    if(!docs.length){el.innerHTML='<p style="color:#888;font-size:12px">No books yet.</p>';return;}
    el.innerHTML=docs.map(d=>\`
      <div class="ci">
        \${d.cover_image_url?\`<img src="\${d.cover_image_url}">\`:'<div class="cp">📚</div>'}
        <div class="inf"><strong>\${d.title||''}</strong><span>\${d.title_telugu||''} · \${d.language||''}</span></div>
        <button class="db" onclick="delBook('\${d.id}','\${d.pdf_path||''}','\${d.cover_image_path||''}','\${(d.title||'').replace(/'/g,"\\\\'")}')">🗑 Delete</button>
      </div>\`).join('');
  }catch(e){el.innerHTML=\`<p style="color:#c0392b;font-size:12px">Error: \${e.message}</p>\`;}
}
window.delBook = async(id,pp,cp,label)=>{
  if(!confirm(\`Delete "\${label}"?\`)) return;
  await deleteDoc(doc(db,'books',id));
  await r2del(pp); await r2del(cp);
  loadBooks();
};

// ── MAGAZINE UPLOAD ──────────────────────────────────────────────────────────
window.uploadMag = async()=>{
  const m=parseInt(document.getElementById('mm').value);
  const y=parseInt(document.getElementById('my').value);
  const v=parseInt(document.getElementById('mv').value);
  const p=parseInt(document.getElementById('mp').value);
  const f=document.getElementById('mf').files[0];
  const img=document.getElementById('mi').files[0];
  if(!f){sr2('m',false,'Please select a PDF file');return;}
  document.getElementById('mb').disabled=true;
  const mm2=String(m).padStart(2,'0');
  const base=\`publications/magazines/\${y}/\${y}-\${mm2}-\${EN[m]}\`;
  try{
    sp('m',5,'Uploading PDF...');
    const pu=await r2up(f,\`\${base}.pdf\`,pg=>sp('m',5+pg*60,\`PDF \${Math.round(pg*100)}%\`));
    let iu='',ip='';
    if(img){
      sp('m',68,'Uploading cover image...');
      const ext=img.name.split('.').pop();
      ip=\`\${base}-cover.\${ext}\`;
      iu=await r2up(img,ip,pg=>sp('m',68+pg*20,\`Cover \${Math.round(pg*100)}%\`));
    }
    sp('m',90,'Saving to database...');
    await addDoc(collection(db,'magazines'),{
      title_telugu:\`\${TM[m]} \${y}\`,title_english:\`\${EN[m]} \${y}\`,
      month:m,year:y,volume:v,pages:p,
      pdf_path:\`\${base}.pdf\`,pdf_url:pu,
      cover_image_path:ip,cover_image_url:iu,
      is_published:true,created_at:serverTimestamp()
    });
    sp('m',100,'Done!');
    sr2('m',true,\`"\${EN[m]} \${y}" uploaded and live in the app!\`);
    ['mf','mi'].forEach(id=>{document.getElementById(id).value='';});
    ['mfs','mis'].forEach(id=>{document.getElementById(id).style.display='none';});
    document.getElementById('mip').style.display='none';
    loadMags();
  }catch(e){sr2('m',false,e.message);}
  document.getElementById('mb').disabled=false;
};

// ── AUDIO UPLOAD ─────────────────────────────────────────────────────────────
let audioFiles=[];
window.sa = inp=>{
  audioFiles=Array.from(inp.files);
  document.getElementById('al').innerHTML=audioFiles.map((f,i)=>
    \`<div class="fi"><span>🎵</span><span class="fn">\${cn(f.name)}</span><span class="fs" id="af\${i}">\${(f.size/1024/1024).toFixed(1)} MB</span></div>\`).join('');
  document.getElementById('as2').textContent=\`\${audioFiles.length} files · \${(audioFiles.reduce((s,f)=>s+f.size,0)/1024/1024).toFixed(1)} MB total\`;
  document.getElementById('ab').style.display='block';
};
function cn(fn){return fn.replace(/\\.(mp3|m4a|wav)$/i,'').replace(/[_\\-]+/g,' ').trim().split(' ').map(w=>w?w[0].toUpperCase()+w.slice(1).toLowerCase():'').join(' ');}
window.uploadAudio = async()=>{
  if(!audioFiles.length) return;
  document.getElementById('ab').disabled=true;
  let done=0,fail=0;
  for(let i=0;i<audioFiles.length;i++){
    const f=audioFiles[i];
    const st=document.getElementById('af'+i);
    st.textContent='Uploading...';st.className='fs up';
    try{
      const rp=\`audio/discourses/\${f.name}\`;
      const url=await r2up(f,rp,null);
      await addDoc(collection(db,'audio'),{title:cn(f.name),title_telugu:'',topic:'',year:0,duration_mins:0,audio_path:rp,audio_url:url,file_name:f.name,is_published:true,created_at:serverTimestamp()});
      done++;st.textContent='✅ Done';st.className='fs done';
    }catch(e){fail++;st.textContent='❌ Failed';st.className='fs fail';}
    sp('a',((i+1)/audioFiles.length*100).toFixed(0),\`\${i+1} / \${audioFiles.length}\`);
  }
  sr2('a',fail===0,fail===0?\`All \${done} uploaded!\`:\`\${done} uploaded, \${fail} failed.\`);
  document.getElementById('ab').disabled=false;
  loadAudio2();
};

// ── BOOK UPLOAD ──────────────────────────────────────────────────────────────
window.uploadBook = async()=>{
  const t=document.getElementById('bt').value.trim();
  const f=document.getElementById('bf').files[0];
  const img=document.getElementById('bi').files[0];
  if(!t){sr2('b',false,'Enter a title');return;}
  if(!f){sr2('b',false,'Select a PDF');return;}
  document.getElementById('bb').disabled=true;
  const lang=document.getElementById('bl').value;
  const safe=t.toLowerCase().replace(/[^a-z0-9]+/g,'-');
  const base=\`publications/books/\${lang.toLowerCase()}/\${safe}\`;
  try{
    sp('b',5,'Uploading PDF...');
    const pu=await r2up(f,\`\${base}.pdf\`,pg=>sp('b',5+pg*60,\`PDF \${Math.round(pg*100)}%\`));
    let iu='',ip='';
    if(img){
      sp('b',68,'Uploading cover...');
      const ext=img.name.split('.').pop();
      ip=\`\${base}-cover.\${ext}\`;
      iu=await r2up(img,ip,pg=>sp('b',68+pg*20,\`Cover \${Math.round(pg*100)}%\`));
    }
    sp('b',90,'Saving...');
    await addDoc(collection(db,'books'),{title:t,title_telugu:document.getElementById('bte').value,language:lang,description:document.getElementById('bd').value,sort_order:parseInt(document.getElementById('bo').value),pdf_path:\`\${base}.pdf\`,pdf_url:pu,cover_image_path:ip,cover_image_url:iu,is_published:true,created_at:serverTimestamp()});
    sp('b',100,'Done!');
    sr2('b',true,\`"\${t}" uploaded!\`);
    ['bf','bi'].forEach(id=>{document.getElementById(id).value='';});
    ['bfs','bis'].forEach(id=>{document.getElementById(id).style.display='none';});
    document.getElementById('bip').style.display='none';
    loadBooks();
  }catch(e){sr2('b',false,e.message);}
  document.getElementById('bb').disabled=false;
};

// ── SETTINGS ──────────────────────────────────────────────────────────────────
async function loadSettings(){
  try{
    const snap=await getDoc(doc(db,'settings','main'));
    if(!snap.exists()) return;
    const d=snap.data();
    document.getElementById('sq').value=d.daily_quote||'';
    document.getElementById('sqt').value=d.daily_quote_telugu||'';
    document.getElementById('se').value=d.contact_email||'';
    document.getElementById('sw').value=d.whatsapp_number||'';
  }catch(_){}
}
window.saveSettings = async()=>{
  try{
    await setDoc(doc(db,'settings','main'),{daily_quote:document.getElementById('sq').value,daily_quote_telugu:document.getElementById('sqt').value,contact_email:document.getElementById('se').value,whatsapp_number:document.getElementById('sw').value,updated_at:serverTimestamp()});
    document.getElementById('sr').style.display='block';
    document.getElementById('sr').className='res ok';
    document.getElementById('sr').textContent='✅ Settings saved!';
  }catch(e){
    document.getElementById('sr').style.display='block';
    document.getElementById('sr').className='res er';
    document.getElementById('sr').textContent='❌ '+e.message;
  }
};
</script>
</body>
</html>
`;

export default {
  async fetch(request) {
    return new Response(HTML, {
      headers: {
        'Content-Type': 'text/html;charset=UTF-8',
        'Cache-Control': 'no-cache',
      },
    });
  }
};
