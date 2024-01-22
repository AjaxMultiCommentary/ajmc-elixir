// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

module.exports = {
	content: ["./js/**/*.js", "../lib/*_web.ex", "../lib/*_web/**/*.*ex"],
	daisyui: {
		themes: ["corporate"],
	},
	theme: {
		extend: {
			fontFamily: {
				// Helvetica messes up kerning when diacritics are involved
				sans: ["Inter", "Arial"],
			},
		},
	},
	plugins: [require("@tailwindcss/typography"), require("daisyui")],
};
