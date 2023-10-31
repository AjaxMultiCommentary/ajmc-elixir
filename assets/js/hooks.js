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
		OpenSeadragon({
			id: "iiif-viewer",
			prefixUrl: "https://cdnjs.cloudflare.com/ajax/libs/openseadragon/4.1.0/images/",
			preserveViewport: true,
			tileSources: {
				type: 'image',
				url: 'https://ajaxmulticommentary.github.io/ajmc_iiif/sophoclesplaysa05campgoog/sophoclesplaysa05campgoog_0236/full/max/0/default.png',
				crossOriginPolicy: 'Anonymous',
				ajaxWithCredentials: false
			}
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

const elCache = new Set();

function applyLemma(lemma) {
	// "tei-l@n=75[32]:tei-l@n=75[0]"
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

	const startSelector = `${startName}[n='${startN}']`
	const startEl = document.querySelector(startSelector);

	const endSelector = `${endName}[n='${endN}']`;
	const endEl = document.querySelector(endSelector);

	if (startEl === endEl && !elCache.has(startN)) {
		elCache.add(startN);

		let innerHTML = startEl.innerHTML;
		innerHTML =
			`${innerHTML.substring(0, startIdx)}<span class="inline-block bg-sky-400">${innerHTML.substring(startIdx, endIdx)}</span>${innerHTML.substring(endIdx, innerHTML.length)}`;

		startEl.innerHTML = innerHTML;
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
		await replaceRawTei(this.el);

		const lemmas = JSON.parse(this.lemmas());

		elCache.clear();

		lemmas.forEach(applyLemma);
	},
};

export default {
	DragHook,
	IIIFHook,
	TEIHook,
};
