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
	},
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

export const TEIHook = {
	async mounted() {
		return replaceRawTei(this.el);
	},

	async updated() {
		return replaceRawTei(this.el);
	}
}

export default {
	DragHook,
	IIIFHook,
	TEIHook,
};
