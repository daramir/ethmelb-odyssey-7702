import { persist, createLocalStorage } from "@macfja/svelte-persistent-store";
import { Secp256k1, P256 } from 'ox';
import { get, writable } from 'svelte/store';
import type { Hex } from 'viem';

/// Call this to set up persistent values
export function init() {
	if (get(ethSk) === null) {
		ethSk.set(Secp256k1.randomPrivateKey());
	}
	if (get(p256Sk) === null) {
		p256Sk.set(P256.randomPrivateKey());
	}
}

export const ethSk = persist(writable(null as Hex | null), createLocalStorage(), "ethSk");
export const p256Sk = persist(writable(null as Hex | null), createLocalStorage(), "p256Sk");