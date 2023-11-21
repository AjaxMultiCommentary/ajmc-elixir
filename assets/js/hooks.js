import CETEI from 'CETEIcean';
import OpenSeadragon from 'openseadragon'

const DRAG_ATTRIBUTE_NAME = 'phx-drop-target';
const DROP_TARGET_BG = 'bg-slate-50';

/**
 * Begin DragHook
 */

export const DragHook = {
	isDropTarget(event) {
		const target = event.target;
		return target.getAttribute(DRAG_ATTRIBUTE_NAME) !== null;
	},

	mounted() {
		document.addEventListener('dragenter', event => {
			if (this.isDropTarget(event)) {
				event.target.classList.add(DROP_TARGET_BG);
			}
		});

		document.addEventListener('dragleave', event => {
			if (this.isDropTarget(event)) {
				event.target.classList.remove(DROP_TARGET_BG);
			}
		})
	}
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
		const comments = JSON.parse(this.el.dataset.comments);
		const highlightedComments = JSON.parse(this.el.dataset.highlightedComments);
		const tiles = JSON.parse(this.el.dataset.tiles).map(tile => {
			const relevantComments = comments.filter(comment => {
				return comment.image_paths.includes(tile.imagePath);
			});

			const overlays = relevantComments.map(comment => {
				// FIXME: to handle coords better, get the left-most, top-most,
				// right-most, and bottom-most, and built the rectangle out of
				// those points.
				const bboxCoords = comment.words.flatMap(word => word.bbox).sort((a, b) => {
					  if (a[0] === b[0]) {
					    return b[1] - a[1];
					  }
					  return a[0] - b[0];
				});
				
				const topLeft = bboxCoords[0];
				const maxXY = bboxCoords.at(-1);

				const coords = {
					px: topLeft[0], 
					py: topLeft[1], 
					width: maxXY[0] - topLeft[0], 
					height: 50,
					className: highlightedComments.includes(comment.id) ? 'outline outline-yellow-600 opacity-90' : 'outline outline-sky-600 opacity-80',
				}
		
				return coords;
			});

			tile.overlays = overlays;

			return tile;
		});


		this.viewer = OpenSeadragon({
			element: this.el,
			prefixUrl: "https://cdnjs.cloudflare.com/ajax/libs/openseadragon/4.1.0/images/",
			preserveViewport: true,
			tileSources: tiles,
			sequenceMode: true
		});
	}
};

/**
 * 
 * Begin TEIHook
 */
const teiTransformer = new CETEI();

export async function transformTei(raw) {
	if (!raw) {
		return Promise.resolve('');
	}

	return new Promise((resolve, _reject) =>
		teiTransformer.makeHTML5(raw, (data) => resolve(data))
	);
}

async function replaceRawTei(el) {
	const html = await transformTei(el.innerHTML);

	el.replaceChildren(html);
}

function applyLemma(lemma) {
	// tei-l@n=61[0]:tei-l@n=61[14]
	const { selector, text_anchor: textAnchor } = lemma;
	const [startNode, endNode] = selector.split(':');
	const [startName, startSpec] = startNode.split('@');
	const [_startN, _startIdx] = startSpec.split('[');
	const startN = _startN.replace('n=', '');
	const startIdx = _startIdx.replace(']', '');
	const [endName, endSpec] = endNode.split('@');
	const [_endN, _endIdx] = endSpec.split('[');
	const endN = _endN.replace('n=', '');
	const endIdx = _endIdx.replace(']', '');

	const startSelector = `${startName}[n='${startN}'] > tei-w[n='${startIdx}']`
	const startEl = document.querySelector(startSelector);

	if (startEl) {
		startEl.classList.add('bg-sky-200')
	} else {
		// console.warn(`startEl was null. Selector: ${selector}.`)
	}

	const endSelector = `${endName}[n='${endN}'] > tei-w[n='${endIdx}']`;
	const endEl = document.querySelector(endSelector);

	if (endEl) {
		endEl.classList.add('bg-sky-200')
	} else {
		console.warn(`endEl was null. Selector: ${selector} and textAnchor: ${textAnchor}.`)
	}
}

export const TEIHook = {
	lemmas() {
		return this.el.dataset.lemmas;
	},

	async mounted() {
		return replaceRawTei(this.el);
	},

	async updated() {
		return replaceRawTei(this.el);
	},
};

export default {
	DragHook,
	IIIFHook,
	TEIHook,
};
