// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';
import starlightImageZoom from 'starlight-image-zoom';
import starlightLinksValidator from 'starlight-links-validator';

// https://astro.build/config
export default defineConfig({
	site: 'https://qt.mrs-electronics.dev',
	base: '/',
	outDir: './dist',
	publicDir: './public',
	integrations: [
		starlight({
			plugins: [starlightImageZoom(), starlightLinksValidator()],
			title: 'MRS Qt SDK',
			social: [{ icon: 'github', label: 'GitHub', href: 'https://github.com/mrs-electronics-inc/mrs-sdk-qt' }],
			sidebar: [
				{
					label: 'Get Started',
					items: [{autogenerate: { directory: 'get-started' }}],
				},
				{
					label: 'Reference',
					items: [{autogenerate: { directory: 'reference' }}],
				},
			],
			head: [
				{
					tag: 'link',
					attrs: {
						rel: 'manifest',
						href: '/site.webmanifest'
					}
				}
			],
			customCss: ['./src/styles/custom.css'],
			expressiveCode: {
				shiki: {
					langAlias: {
						// Make is the closest language to QMake supported by Shiki,
						// so we'll just use that for syntax highlighting.
						qmake: 'make',
					}
				}
			}
		}),
	],
});
