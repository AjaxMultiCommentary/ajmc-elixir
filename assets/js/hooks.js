import OpenSeadragon from "openseadragon";

const DRAG_ATTRIBUTE_NAME = "phx-drop-target";
const DROP_TARGET_BG = "bg-primary-50";

/**
 * Begin DragHook
 */

export const DragHook = {
	isDropTarget(event) {
		const target = event.target;
		return target.getAttribute(DRAG_ATTRIBUTE_NAME) !== null;
	},

	mounted() {
		document.addEventListener("dragenter", (event) => {
			if (this.isDropTarget(event)) {
				event.target.classList.add(DROP_TARGET_BG);
			}
		});

		document.addEventListener("dragleave", (event) => {
			if (this.isDropTarget(event)) {
				event.target.classList.remove(DROP_TARGET_BG);
			}
		});
	},
};

/**
 * Begin IIIFHook
 */

export const IIIFHook = {
	mounted() {
		this._updateViewer();
	},

	updated() {
		this._updateViewer();
	},

	_updateViewer() {
		const comment = JSON.parse(this.el.dataset.comment);
		const tiles = JSON.parse(this.el.dataset.tiles).map((tile) => {
			const overlays = comment.overlays
				.filter((overlay) => tile.url.indexOf(overlay.page_id) > -1)
				.map((overlay) => ({
					...overlay,
					className: overlayClassName(),
				}));

			tile.overlays = overlays;

			return tile;
		});

		this.viewer = OpenSeadragon({
			element: this.el,
			maxZoomLevel: 4,
			prefixUrl:
				"https://cdnjs.cloudflare.com/ajax/libs/openseadragon/4.1.0/images/",
			preserveViewport: true,
			sequenceMode: true,
			tileSources: tiles,
		});

		this.viewer.addOnceHandler("add-overlay", ({ eventSource }) => {
			window.requestAnimationFrame(() => {
				let overlay = eventSource.currentOverlays.at(1);

				if (overlay == undefined) {
					overlay = eventSource.currentOverlays[0];
				}

				const viewport = eventSource.viewport;

				viewport.fitBoundsWithConstraints(overlay.getBounds(viewport));
			});
		});
	},
};

function overlayClassName() {
	return "bg-sky-400 opacity-50";
}

export default {
	DragHook,
	IIIFHook,
};
