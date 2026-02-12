const DEFAULT_CITY = "NEW SMYRNA BEACH";

const state = {
  allRamps: [],
  filteredRamps: [],
  filters: {
    city: DEFAULT_CITY,
    status: "all",
  },
};

const cityFilterList = document.getElementById("cityFilterList");
const statusFilterList = document.getElementById("statusFilterList");

const rampGrid = document.getElementById("rampGrid");
const emptyState = document.getElementById("emptyState");
const loadingState = document.getElementById("loadingState");
const errorBanner = document.getElementById("errorBanner");
const resultCount = document.getElementById("resultCount");
const tideDirection = document.getElementById("tideDirection");
const tideProgress = document.getElementById("tideProgress");
const waterTemp = document.getElementById("waterTemp");

const shownCount = document.getElementById("shownCount");
const openCount = document.getElementById("openCount");
const limitedCount = document.getElementById("limitedCount");
const closedCount = document.getElementById("closedCount");

const STATUS_OPTIONS = [
  { value: "all", label: "All Statuses" },
  { value: "open", label: "Open" },
  { value: "limited", label: "Limited" },
  { value: "closed", label: "Closed" },
  { value: "other", label: "Other" },
];

function normalizeText(value) {
  return String(value || "").trim().toUpperCase();
}

function mapStatusGroup(rawStatus) {
  const status = normalizeText(rawStatus);

  if (status === "OPEN") {
    return "open";
  }

  if (
    status.includes("4X4") ||
    status.includes("CLOSING") ||
    status.includes("ENTRANCE ONLY")
  ) {
    return "limited";
  }

  if (status.includes("CLOSED")) {
    return "closed";
  }

  return "other";
}

function toTitleCase(value) {
  return String(value || "")
    .toLowerCase()
    .split(" ")
    .filter(Boolean)
    .map((segment) => segment.charAt(0).toUpperCase() + segment.slice(1))
    .join(" ");
}

function updateActiveButtons(container, activeValue) {
  container.querySelectorAll("button").forEach((button) => {
    const isActive = button.dataset.value === activeValue;
    button.classList.toggle("active", isActive);
    button.setAttribute("aria-pressed", isActive ? "true" : "false");
  });
}

function renderCityPickList(ramps) {
  const uniqueCities = [...new Set(ramps.map((ramp) => normalizeText(ramp.city)))].sort();
  cityFilterList.innerHTML = "";

  const cityOptions = [
    { value: "all", label: "All Cities" },
    ...uniqueCities.map((city) => ({ value: city, label: toTitleCase(city) })),
  ];

  if (uniqueCities.includes(DEFAULT_CITY)) {
    state.filters.city = DEFAULT_CITY;
  } else {
    state.filters.city = "all";
  }

  cityOptions.forEach((option) => {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "pick-btn";
    button.dataset.value = option.value;
    button.textContent = option.label;
    button.addEventListener("click", () => {
      state.filters.city = option.value;
      updateActiveButtons(cityFilterList, state.filters.city);
      applyFiltersAndRender();
    });
    cityFilterList.appendChild(button);
  });

  updateActiveButtons(cityFilterList, state.filters.city);
}

function renderStatusPickList() {
  statusFilterList.innerHTML = "";

  STATUS_OPTIONS.forEach((option) => {
    const button = document.createElement("button");
    button.type = "button";
    button.className = "pick-btn";
    button.dataset.value = option.value;
    button.textContent = option.label;
    button.addEventListener("click", () => {
      state.filters.status = option.value;
      updateActiveButtons(statusFilterList, state.filters.status);
      applyFiltersAndRender();
    });
    statusFilterList.appendChild(button);
  });

  updateActiveButtons(statusFilterList, state.filters.status);
}

function filterRamps(ramps, filters) {
  return ramps.filter((ramp) => {
    const cityMatch =
      filters.city === "all" || normalizeText(ramp.city) === normalizeText(filters.city);

    const statusMatch =
      filters.status === "all" || mapStatusGroup(ramp.accessStatus) === filters.status;

    return cityMatch && statusMatch;
  });
}

function computeStats(ramps) {
  let open = 0;
  let limited = 0;
  let closed = 0;

  ramps.forEach((ramp) => {
    const group = mapStatusGroup(ramp.accessStatus);

    if (group === "open") {
      open += 1;
    } else if (group === "limited") {
      limited += 1;
    } else if (group === "closed") {
      closed += 1;
    }
  });

  return {
    shown: ramps.length,
    open,
    limited,
    closed,
  };
}

function createRampCard(ramp) {
  const group = mapStatusGroup(ramp.accessStatus);

  const cardCol = document.createElement("div");
  cardCol.className = "col-12 col-md-6";

  const card = document.createElement("article");
  card.className = `ramp-card ${group}`;

  const name = document.createElement("h3");
  name.className = "ramp-name";
  name.textContent = ramp.rampName;

  const city = document.createElement("p");
  city.className = "ramp-city";
  city.textContent = toTitleCase(ramp.city);

  const status = document.createElement("span");
  status.className = `status-pill ${group}`;
  status.textContent = ramp.accessStatus;

  const location = document.createElement("p");
  location.className = "ramp-location";
  location.textContent = ramp.location ? `Location: ${ramp.location}` : "Location: Not provided";

  card.appendChild(name);
  card.appendChild(city);
  card.appendChild(status);
  card.appendChild(location);
  cardCol.appendChild(card);

  return cardCol;
}

function renderRamps(ramps) {
  rampGrid.innerHTML = "";

  ramps
    .slice()
    .sort((a, b) => {
      const cityCompare = normalizeText(a.city).localeCompare(normalizeText(b.city));
      if (cityCompare !== 0) {
        return cityCompare;
      }
      return normalizeText(a.rampName).localeCompare(normalizeText(b.rampName));
    })
    .forEach((ramp) => {
      rampGrid.appendChild(createRampCard(ramp));
    });

  emptyState.classList.toggle("d-none", ramps.length !== 0);
}

function renderStats(stats) {
  shownCount.textContent = String(stats.shown);
  openCount.textContent = String(stats.open);
  limitedCount.textContent = String(stats.limited);
  closedCount.textContent = String(stats.closed);
}

function setError(message) {
  if (!message) {
    errorBanner.classList.add("d-none");
    errorBanner.textContent = "";
    return;
  }

  errorBanner.textContent = message;
  errorBanner.classList.remove("d-none");
}

function applyFiltersAndRender() {
  state.filteredRamps = filterRamps(state.allRamps, state.filters);

  const stats = computeStats(state.filteredRamps);
  renderStats(stats);
  renderRamps(state.filteredRamps);
  resultCount.textContent = `${state.filteredRamps.length} ramps shown`;
}

async function fetchRampStatus() {
  const response = await fetch("/rampstatus");
  if (!response.ok) {
    throw new Error("Unable to load ramp status right now.");
  }

  return response.json();
}

async function fetchTideStatus() {
  const response = await fetch("/tides");
  if (!response.ok) {
    throw new Error("Unable to load tide data right now.");
  }

  return response.json();
}

function renderTideHeader(tideData) {
  const directionValue = tideData?.currentTideHighOrLow || "---";
  const progressValue =
    typeof tideData?.tideLevelPercentage === "number" ? `${tideData.tideLevelPercentage}%` : "--";
  const waterTempValue =
    typeof tideData?.waterTemp === "number" ? `${tideData.waterTemp}F` : "--";

  tideDirection.textContent = directionValue;
  tideProgress.textContent = progressValue;
  waterTemp.textContent = waterTempValue;
}

async function initializePage() {
  try {
    setError("");
    loadingState.classList.remove("d-none");

    const [rampResult, tideResult] = await Promise.allSettled([
      fetchRampStatus(),
      fetchTideStatus(),
    ]);

    if (tideResult.status === "fulfilled") {
      renderTideHeader(tideResult.value);
    } else {
      renderTideHeader(null);
    }

    if (rampResult.status !== "fulfilled") {
      throw new Error("Unable to load ramp status right now.");
    }

    const rampData = rampResult.value;
    state.allRamps = Array.isArray(rampData) ? rampData : [];

    renderCityPickList(state.allRamps);
    renderStatusPickList();
    applyFiltersAndRender();
  } catch (error) {
    setError(error.message || "Unable to load data.");
  } finally {
    loadingState.classList.add("d-none");
  }
}

initializePage();
