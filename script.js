const sceneCatalog = [
  {key:'non_ideal_box_flow', fallback:'assets/originals/non_ideal_box_flow.mp4', title:'Non-ideal cargo flow', text:'Boxes are moving, but the system sees deviation before it becomes a downstream failure.', speed:1.45, agent:'Cargo flow anomaly detected. SLA risk signal created.'},
  {key:'non_ideal_baggage_flow', fallback:'assets/originals/non_ideal_baggage_flow.mp4', title:'Non-ideal baggage flow', text:'A small irregularity in baggage movement can become a passenger escalation later.', speed:1.35, agent:'Baggage movement irregularity detected. Passenger impact risk rising.'},
  {key:'non_ideal_people_flow', fallback:'assets/originals/non_ideal_people_flow.mp4', title:'People flow intelligence', text:'Cameras detect people, density and movement patterns across the work zone.', speed:1.18, agent:'Workforce flow and zone-density indicators are live.'},
  {key:'box_math_detection', fallback:'assets/originals/box_math_detection.mp4', title:'Cargo damage mathematics', text:'Mathematical models detect damage signatures, score severity and create evidence.', speed:1.2, agent:'Cargo damage scored, timestamped and attached to the shipment journey.'},
  {key:'baggage_math_detection', fallback:'assets/originals/baggage_math_detection.mp4', title:'Passenger baggage damage detection', text:'Cracks, dents, handling impact and abnormal damage patterns become visible before escalation.', speed:1.25, agent:'Baggage damage evidence captured before loading.'},
  {key:'airline_logistics_system', fallback:'assets/originals/airline_logistics_system.webm', title:'AI logistics control tower', text:'Gen BI agents connect video, events, SLA timers, incident signals and corrective actions.', speed:2.35, agent:'Ask anything: highest risk flight, root cause, evidence, and best next action.'},
  {key:'dynamic_pricing', fallback:'assets/originals/dynamic_pricing.webm', title:'Dynamic cargo pricing intelligence', text:'Capacity, demand, load priority and SLA risk become live cargo pricing decisions.', speed:2.55, agent:'Dynamic pricing simulation active. Capacity and risk converted into revenue action.'},
  {key:'happy_box_flow', fallback:'assets/originals/happy_box_flow.mp4', title:'Happy cargo flow', text:'After proactive correction, cargo movement becomes streamlined and predictable.', speed:1.35, agent:'Corrective action successful. Cargo flow stabilized.'},
  {key:'happy_baggage_flow', fallback:'assets/originals/happy_baggage_flow.mp4', title:'Happy baggage flow', text:'Baggage now moves cleanly through the system with lower risk and higher passenger trust.', speed:1.7, agent:'Baggage flow recovered. Passenger escalation risk reduced.'},
  {key:'happy_people_flow', fallback:'assets/originals/happy_people_flow.mp4', title:'Happy people flow', text:'Safer teams, clearer work zones and better throughput create the final SLA recovery.', speed:1.15, agent:'All critical risks resolved. Flight ready within SLA.'}
];

function toDirectDriveUrl(raw) {
  if (!raw || typeof raw !== 'string') return '';
  const value = raw.trim();
  if (!value) return '';

  const fileIdFromPath = value.match(/\/file\/d\/([^/]+)/)?.[1];
  if (fileIdFromPath) {
    return `https://drive.google.com/uc?export=download&id=${fileIdFromPath}`;
  }

  const fromIdParam = value.match(/[?&]id=([^&]+)/)?.[1];
  if (fromIdParam) {
    return `https://drive.google.com/uc?export=download&id=${fromIdParam}`;
  }

  return value;
}

const driveSources = window.DRIVE_VIDEO_SOURCES || {};
const scenes = sceneCatalog.map((scene) => {
  const configured = toDirectDriveUrl(driveSources[scene.key]);
  return {
    ...scene,
    file: configured
  };
});

const missingConfiguredPaths = scenes.filter((scene) => !scene.file).map((scene) => scene.key);
if (missingConfiguredPaths.length) {
  console.error(
    'Missing video path(s) in videos.config.js for key(s):',
    missingConfiguredPaths.join(', ')
  );
}

const player=document.getElementById('player'); const narration=document.getElementById('narration');
const title=document.getElementById('sceneTitle'); const text=document.getElementById('sceneText'); const kicker=document.getElementById('kicker'); const agent=document.getElementById('agentText'); const tl=document.getElementById('timeline');
let idx=0, playing=false;
scenes.forEach((s,i)=>{const row=document.createElement('div');row.className='scene';row.innerHTML=`<div class="dot"></div><div><strong>${String(i+1).padStart(2,'0')} ${s.title}</strong><small>${s.text}</small></div>`;tl.appendChild(row)});
function render(){const s=scenes[idx]; if(!s.file){player.removeAttribute('src'); player.load(); title.textContent=`${s.title} (missing video path)`;} else {player.src=s.file; title.textContent=s.title;} player.playbackRate=s.speed; text.textContent=s.text; kicker.textContent=`Scene ${idx+1} / ${scenes.length}`; agent.textContent=s.agent; [...tl.children].forEach((e,i)=>e.classList.toggle('active',i===idx));}
function next(){idx=(idx+1)%scenes.length; render(); if(playing && scenes[idx].file) player.play().catch(()=>{});}
player.addEventListener('ended', next); player.addEventListener('loadedmetadata',()=>{player.playbackRate=scenes[idx].speed});
document.getElementById('playBtn').onclick=async()=>{playing=true; if(!player.src) render(); if(!scenes[idx].file) return; player.muted=true; await player.play().catch(()=>{}); narration.currentTime=0; narration.play().catch(()=>{});};
document.getElementById('pauseBtn').onclick=()=>{playing=false; player.pause(); narration.pause();};
document.getElementById('restartBtn').onclick=()=>{idx=0; playing=true; render(); if(!scenes[idx].file) return; narration.currentTime=0; narration.play().catch(()=>{}); player.play().catch(()=>{});};
render();
