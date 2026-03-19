(function () {
  const root = document.getElementById("landingWrapper");
  const config = window.SITE_CONFIG;
  const studio = config?.studio || {};

  if (!root || !config || !Array.isArray(config.events)) {
    return;
  }

  const siteTitle = config.site?.pageTitle;

  if (siteTitle) {
    document.title = siteTitle;
  }

  const fragment = document.createDocumentFragment();

  config.events.forEach((event) => {
    const href = event.redirectPages?.[0] || `invite.html?event=${encodeURIComponent(event.key)}`;
    const card = document.createElement("a");
    const image = document.createElement("img");
    const label = document.createElement("div");

    card.className = "invite-card ripple";
    card.href = href;

    image.src = event.cardImage;
    image.alt = event.cardAlt || `${event.cardLabel || event.title} Invite`;

    label.className = `invite-label ${event.labelClass || ""}`.trim();
    label.textContent = event.cardLabel || event.title;

    card.append(image, label);
    fragment.appendChild(card);
  });

  root.replaceChildren(fragment);

  if (!studio.enabled || !studio.name || !studio.url) {
    return;
  }

  const sanitizedName = String(studio.name).replace(/^@+/, "").trim();

  if (!sanitizedName) {
    return;
  }

  const link = document.createElement("a");
  const label = document.createElement("span");
  const pill = document.createElement("span");
  const row = document.createElement("span");
  const icon = document.createElementNS("http://www.w3.org/2000/svg", "svg");
  const rect = document.createElementNS("http://www.w3.org/2000/svg", "rect");
  const circleMain = document.createElementNS("http://www.w3.org/2000/svg", "circle");
  const circleDot = document.createElementNS("http://www.w3.org/2000/svg", "circle");
  const name = document.createElement("span");

  link.className = "studio-link landing-studio-link";
  link.href = studio.url;
  link.target = "_blank";
  link.rel = "noopener";

  label.className = "studio-link__label";
  label.textContent = studio.label || "Crafted by";

  pill.className = "studio-link__pill";
  row.className = "studio-link__row";

  icon.classList.add("studio-link__icon");
  icon.setAttribute("viewBox", "0 0 24 24");
  icon.setAttribute("aria-hidden", "true");
  icon.setAttribute("focusable", "false");

  rect.setAttribute("x", "3.5");
  rect.setAttribute("y", "3.5");
  rect.setAttribute("width", "17");
  rect.setAttribute("height", "17");
  rect.setAttribute("rx", "5");

  circleMain.setAttribute("cx", "12");
  circleMain.setAttribute("cy", "12");
  circleMain.setAttribute("r", "4.1");

  circleDot.setAttribute("cx", "17.2");
  circleDot.setAttribute("cy", "6.8");
  circleDot.setAttribute("r", "1.1");

  icon.append(rect, circleMain, circleDot);

  name.className = "studio-link__name";
  name.textContent = sanitizedName;

  row.append(icon, name);
  pill.appendChild(row);
  link.append(label, pill);

  root.insertAdjacentElement("afterend", link);
})();
