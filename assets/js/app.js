// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import hooks from "./hooks";
import uploaders from "./uploaders";

let csrfToken = document
	.querySelector("meta[name='csrf-token']")
	.getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
	params: { _csrf_token: csrfToken },
	hooks,
	metadata: {
		click(e, _el) {
			return {
				altKey: e.altKey,
				ctrlKey: e.ctrlKey,
				metaKey: e.metaKey,
				pageX: e.pageX,
				pageY: e.pageY,
			};
		},
	},
	uploaders,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (info) => topbar.show());
window.addEventListener("phx:page-loading-stop", (info) => topbar.hide());

window.addEventListener("phx:change-locale", (e) => {
	setLocale(e.detail.locale);
});

const validLocales = ["de", "en", "fr", "it"];

function setLocale(locale = "en") {
	if (!validLocales.includes(locale)) {
		return console.error(`Invalid locale: ${locale}.`);
	}

	const searchParams = new URLSearchParams(window.location.search);
	const currentLocale = searchParams.get("locale");

	if (currentLocale === locale) {
		return;
	}

	searchParams.set("locale", locale);

	window.location.search = searchParams;
}

window.addEventListener("phx:highlight-comment", (e) => {
	const el = document.getElementById(e.detail.id);

	if (el) {
		el.scrollIntoView({ behavior: "smooth" });
	}
});

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;
