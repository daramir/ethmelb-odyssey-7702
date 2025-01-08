import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';
import { resolve } from "path";

export default defineConfig({
	plugins: [sveltekit()],
	resolve: {
		alias: {
			"#sol": resolve(__dirname, "./solidity/out")
		}
	}
});
