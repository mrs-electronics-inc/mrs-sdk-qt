// @ts-check
import { defineConfig } from 'astro/config';
import starlight from '@astrojs/starlight';

// https://astro.build/config
export default defineConfig({
	site: 'https://qt.mrs-electronics.dev',
	base: '/',
	outDir: 'public',
	publicDir: 'static',
	integrations: [
		starlight({
			title: 'MRS Qt SDK Docs',
			social: [{ icon: 'github', label: 'GitHub', href: 'https://github.com/mrs-electronics-inc/mrs-sdk-qt' }],
			sidebar: [
				{
					label: 'Guides',
					autogenerate: { directory: 'guides' },
				},
				{
					label: 'Reference',
					autogenerate: { directory: 'reference' },
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
			]
		}),
	],
});
