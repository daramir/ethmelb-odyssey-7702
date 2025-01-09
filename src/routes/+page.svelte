<script lang="ts">

	import { ethSk, init, p256Sk } from '$lib/stores';
	import { privateKeyToAccount } from "viem/accounts";
	import { P256 } from 'ox';
	import { onMount } from 'svelte';
	import { createClient, formatEther, type Hex, http, toHex } from 'viem';
	import { getBalance, getCode } from 'viem/actions';
	import { odysseyTestnet } from 'viem/chains';

	// Initialize the local storage keys if needed
	onMount(()=>init());

	// for forcing balance / state refreshing
	let refreshing = $state(true);

	// Account keys and viem client
	const privateKey = $derived($ethSk ? $ethSk : null);
	const account = $derived($ethSk ? privateKeyToAccount($ethSk) : null);
	const p256Pub = $derived($p256Sk ? P256.getPublicKey({privateKey: $p256Sk}) : null);
	const client = $derived(account ?
		createClient({
			account,
			chain: odysseyTestnet,
			transport: http()
		}) : null
	);
	// Derive balance promise
	let ourBalance = $state(Promise.resolve(0n));
	let ourCode: Promise<Hex|undefined> = $state(Promise.resolve(undefined));

	// trigger refreshing :shrug:
	$effect(() => {
		// only run subsequent code if triggered refreshing
		if (refreshing) {
			refreshing = false;
		} else {
			return;
		}
		// type check
		if (!account || !client) {
			return;
		}

		ourBalance = getBalance(client, { address: account.address });
		ourCode = getCode(client, { address: account.address });

	})

</script>

{#if privateKey}
	<p>eth sk:</p><pre>{privateKey}</pre>
{/if}

{#if account}
	<p>account: {account.address}</p>
{/if}

{#if p256Pub}
	<p>p256Pub: {JSON.stringify({prefix: p256Pub.prefix, x: toHex(p256Pub.x), y: toHex(p256Pub.y) })}</p>
{/if}

<p>Our balance: {#await ourBalance}[loading...]{:then balance}{formatEther(balance)}{/await}</p>
<p>Our code: {#await ourCode}[loading...]{:then code}{code ? code : "no code in our account"}{/await}</p>