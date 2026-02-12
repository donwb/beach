const REFRESH_MS = 2 * 60 * 1000;
const CLOCK_MS = 15 * 1000;

const FOCUS_RAMPS = ["3RD AV", "CRAWFORD RD", "FLAGLER AV", "BEACHWAY AV"];

const tideDirectionEl = document.getElementById("tideDirection");
const tidePercentEl = document.getElementById("tidePercent");
const waterTempEl = document.getElementById("waterTemp");
const lastUpdatedEl = document.getElementById("lastUpdated");
const clockEl = document.getElementById("clock");
const rampListEl = document.getElementById("rampList");
const errorEl = document.getElementById("errorMessage");

function normalize(value) {
  return String(value || "").trim().toUpperCase();
}

function formatShortTime(date = new Date()) {
  return date.toLocaleTimeString([], { hour: "numeric", minute: "2-digit" });
}

function statusClass(accessStatus) {
  const value = normalize(accessStatus);
  if (value === "OPEN") return "open";
  if (value.includes("CLOSED")) return "closed";
  if (value.includes("4X4") || value.includes("ENTRANCE") || value.includes("CAPACITY")) return "limited";
  return "other";
}

function tidyStatus(accessStatus) {
  const value = normalize(accessStatus);
  if (value === "OPEN") return "Open";
  if (value.includes("CLOSED")) return "Closed";
  if (value.includes("4X4")) return "4x4 Only";
  if (value.includes("AT CAPACITY")) return "At Capacity";
  return accessStatus || "Unknown";
}

function parseRampsText(text) {
  const lines = String(text || "").split("\n");
  const records = [];

  lines.forEach((line) => {
    const trimmed = line.trim();
    if (!trimmed) return;

    const match = trimmed.match(/^(.*?)\s+is\s+:\s+(.*?)$/i);
    if (!match) return;

    records.push({
      rampName: match[1],
      accessStatus: match[2],
    });
  });

  return records;
}

function orderAndFilterRamps(ramps) {
  const byName = new Map(ramps.map((ramp) => [normalize(ramp.rampName), ramp]));
  const preferred = FOCUS_RAMPS.map((name) => byName.get(name)).filter(Boolean);

  if (preferred.length > 0) return preferred;

  return ramps
    .slice()
    .sort((a, b) => normalize(a.rampName).localeCompare(normalize(b.rampName)))
    .slice(0, 6);
}

function renderRamps(ramps) {
  rampListEl.innerHTML = "";

  if (!ramps.length) {
    const empty = document.createElement("li");
    empty.className = "empty";
    empty.textContent = "No ramp data available.";
    rampListEl.appendChild(empty);
    return;
  }

  const chosen = orderAndFilterRamps(ramps);

  chosen.forEach((ramp) => {
    const cls = statusClass(ramp.accessStatus);
    const item = document.createElement("li");
    item.className = `ramp-item ${cls}`;

    const rampName = document.createElement("p");
    rampName.className = "ramp-name";
    rampName.textContent = ramp.rampName;

    const rampStatus = document.createElement("p");
    rampStatus.className = `ramp-status ${cls}`;
    rampStatus.textContent = tidyStatus(ramp.accessStatus);

    item.appendChild(rampName);
    item.appendChild(rampStatus);
    rampListEl.appendChild(item);
  });
}

async function getRamps() {
  const textResponse = await fetch("/ramps");
  if (textResponse.ok) {
    const text = await textResponse.text();
    const parsed = parseRampsText(text);
    if (parsed.length) return parsed;
  }

  const jsonResponse = await fetch("/rampstatus");
  if (!jsonResponse.ok) throw new Error("Failed loading ramp status");
  return jsonResponse.json();
}

async function getTides() {
  const response = await fetch("/tides");
  if (!response.ok) throw new Error("Failed loading tide status");
  return response.json();
}

function renderTide(tide) {
  const direction = tide?.currentTideHighOrLow || "--";
  const progress = Number.isFinite(tide?.tideLevelPercentage) ? `${tide.tideLevelPercentage}%` : "--%";
  const water = Number.isFinite(tide?.waterTemp) ? `${tide.waterTemp}F` : "--F";

  tideDirectionEl.textContent = direction;
  tidePercentEl.textContent = progress;
  waterTempEl.textContent = water;
}

function showError(show) {
  errorEl.classList.toggle("hidden", !show);
}

function updateClock() {
  clockEl.textContent = formatShortTime();
}

async function refresh() {
  try {
    showError(false);
    const [ramps, tide] = await Promise.all([getRamps(), getTides()]);
    renderRamps(Array.isArray(ramps) ? ramps : []);
    renderTide(tide);
    lastUpdatedEl.textContent = formatShortTime();
  } catch (error) {
    showError(true);
    console.error(error);
  }
}

updateClock();
refresh();
setInterval(updateClock, CLOCK_MS);
setInterval(refresh, REFRESH_MS);
