const sceneCatalog = [
  {
    key: 'non_ideal_box_flow',
    title: 'Non-ideal cargo flow',
    text: 'Boxes are moving, but the system sees deviation before it becomes a downstream failure.',
    speed: 1.2,
    trimStart: 0.25,
    section: 'opening_problem',
    agent: 'Cargo flow anomaly detected. SLA risk signal created.'
  },
  {
    key: 'non_ideal_baggage_flow',
    title: 'Non-ideal baggage flow',
    text: 'A small irregularity in baggage movement can become a passenger escalation later.',
    speed: 1.15,
    trimStart: 0.2,
    section: 'opening_problem',
    agent: 'Baggage movement irregularity detected. Passenger impact risk rising.'
  },
  {
    key: 'non_ideal_people_flow',
    title: 'People flow intelligence',
    text: 'People, congestion and zone movement patterns reveal hidden operational risk.',
    speed: 1.1,
    trimStart: 0.15,
    section: 'opening_problem',
    agent: 'Workforce flow and zone-density indicators are live.'
  },
  {
    key: 'box_math_detection',
    title: 'Cargo damage mathematics',
    text: 'Mathematical models detect damage signatures, score severity and create evidence.',
    speed: 1.05,
    trimStart: 0.2,
    section: 'cargo_detection',
    agent: 'Cargo damage scored, timestamped and attached to the shipment journey.'
  },
  {
    key: 'baggage_math_detection',
    title: 'Passenger baggage damage detection',
    text: 'Cracks, dents and handling impact patterns are detected before escalation.',
    speed: 1.05,
    trimStart: 0.2,
    section: 'baggage_detection',
    agent: 'Baggage damage evidence captured before loading.'
  },
  {
    key: 'airline_logistics_system',
    title: 'AI logistics control tower',
    text: 'Gen BI agents connect video, events, SLA timers, incident signals and corrective actions.',
    speed: 1.0,
    trimStart: 0.15,
    section: 'integrated_command',
    agent: 'Ask anything: highest risk flight, root cause, evidence, and best next action.'
  },
  {
    key: 'dynamic_pricing',
    title: 'Dynamic cargo pricing intelligence',
    text: 'Capacity, demand, load priority and SLA risk become live pricing decisions.',
    speed: 1.0,
    trimStart: 0.1,
    section: 'commercial_optimization',
    agent: 'Dynamic pricing simulation active. Capacity and risk converted into revenue action.'
  },
  {
    key: 'happy_box_flow',
    title: 'Happy cargo flow',
    text: 'After proactive correction, cargo movement becomes streamlined and predictable.',
    speed: 1.1,
    trimStart: 0.1,
    section: 'transformation',
    agent: 'Corrective action successful. Cargo flow stabilized.'
  },
  {
    key: 'happy_baggage_flow',
    title: 'Happy baggage flow',
    text: 'Baggage now moves cleanly with lower risk and higher passenger trust.',
    speed: 1.1,
    trimStart: 0.1,
    section: 'transformation',
    agent: 'Baggage flow recovered. Passenger escalation risk reduced.'
  },
  {
    key: 'happy_people_flow',
    title: 'Happy people flow',
    text: 'Safer teams and clearer work zones complete the SLA recovery story.',
    speed: 1.05,
    trimStart: 0.1,
    section: 'transformation',
    agent: 'All critical risks resolved. Flight ready within SLA.'
  }
];

const sectionTargets = {
  opening_problem: 0.29,
  cargo_detection: 0.11,
  baggage_detection: 0.11,
  integrated_command: 0.2,
  commercial_optimization: 0.11,
  transformation: 0.18
};

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
const scenes = sceneCatalog.map((scene) => ({
  ...scene,
  file: toDirectDriveUrl(driveSources[scene.key])
}));

const missingConfiguredPaths = scenes.filter((scene) => !scene.file).map((scene) => scene.key);
if (missingConfiguredPaths.length) {
  console.error('Missing video path(s) in videos.config.js for key(s):', missingConfiguredPaths.join(', '));
}

console.info('Scene to videos.config.js key mapping:');
scenes.forEach((scene, i) => {
  console.info(`${String(i + 1).padStart(2, '0')} ${scene.title} -> ${scene.key}`);
});

const player = document.getElementById('player');
const narration = document.getElementById('narration');
const title = document.getElementById('sceneTitle');
const text = document.getElementById('sceneText');
const kicker = document.getElementById('kicker');
const agent = document.getElementById('agentText');
const tl = document.getElementById('timeline');

let idx = 0;
let playing = false;
let cuePoints = [];
let rafId = null;

function buildTimeline() {
  tl.innerHTML = '';
  scenes.forEach((s, i) => {
    const row = document.createElement('div');
    row.className = 'scene';
    row.innerHTML = `<div class="dot"></div><div><strong>${String(i + 1).padStart(2, '0')} ${s.title}</strong><small>${s.text}</small></div>`;
    tl.appendChild(row);
  });
}

function computeSceneCues(durationSeconds) {
  const sectionDurations = Object.fromEntries(
    Object.entries(sectionTargets).map(([section, ratio]) => [section, Math.max(4, durationSeconds * ratio)])
  );

  const result = [];
  let cursor = 0;
  Object.keys(sectionTargets).forEach((section) => {
    const sectionScenes = scenes.filter((scene) => scene.section === section);
    if (!sectionScenes.length) return;
    const each = sectionDurations[section] / sectionScenes.length;
    sectionScenes.forEach((scene) => {
      result.push({ key: scene.key, start: cursor, end: cursor + each });
      cursor += each;
    });
  });

  const normalizer = durationSeconds / Math.max(cursor, 0.1);
  return result.map((item) => ({
    ...item,
    start: item.start * normalizer,
    end: item.end * normalizer
  }));
}

function setScene(targetIdx) {
  idx = Math.max(0, Math.min(targetIdx, scenes.length - 1));
  const s = scenes[idx];
  if (!s.file) {
    player.removeAttribute('src');
    player.load();
    title.textContent = `${s.title} (missing video path)`;
  } else {
    player.src = s.file;
    player.playbackRate = s.speed;
    player.onloadedmetadata = () => {
      if (s.trimStart > 0 && Number.isFinite(player.duration) && player.duration > s.trimStart) {
        player.currentTime = s.trimStart;
      }
      if (playing) player.play().catch(() => {});
    };
  }

  title.textContent = s.title;
  text.textContent = s.text;
  kicker.textContent = `Scene ${idx + 1} / ${scenes.length}`;
  agent.textContent = s.agent;
  [...tl.children].forEach((e, i) => e.classList.toggle('active', i === idx));
}

function syncVisualToNarration() {
  if (!playing) return;
  const t = narration.currentTime;
  const nextIdx = cuePoints.findIndex((cp, i) => t >= cp.start && (i === cuePoints.length - 1 || t < cuePoints[i + 1].start));
  if (nextIdx >= 0 && nextIdx !== idx) {
    setScene(nextIdx);
  }
  rafId = requestAnimationFrame(syncVisualToNarration);
}

function startPlayback(fromStart = false) {
  if (missingConfiguredPaths.length) return;
  playing = true;

  if (fromStart) narration.currentTime = 0;
  const totalDuration = narration.duration || 240;
  cuePoints = computeSceneCues(totalDuration);

  setScene(fromStart ? 0 : idx);
  narration.play().catch(() => {});
  player.play().catch(() => {});

  cancelAnimationFrame(rafId);
  rafId = requestAnimationFrame(syncVisualToNarration);
}

function pausePlayback() {
  playing = false;
  narration.pause();
  player.pause();
  cancelAnimationFrame(rafId);
}

narration.addEventListener('ended', () => {
  pausePlayback();
});

buildTimeline();
setScene(0);

document.getElementById('playBtn').onclick = () => startPlayback(false);
document.getElementById('pauseBtn').onclick = pausePlayback;
document.getElementById('restartBtn').onclick = () => startPlayback(true);
