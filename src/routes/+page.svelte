<script lang="ts">

	const abi = [{ 'type': 'receive', 'stateMutability': 'payable' }, {
		'type': 'function',
		'name': 'currentPending',
		'inputs': [],
		'outputs': [{ 'name': '', 'type': 'uint256', 'internalType': 'uint256' }],
		'stateMutability': 'view'
	}, {
		'type': 'function',
		'name': 'nextPending',
		'inputs': [],
		'outputs': [{
			'name': 'call',
			'type': 'tuple',
			'internalType': 'struct Cheapskate.Call',
			'components': [{ 'name': 'data', 'type': 'bytes', 'internalType': 'bytes' }, {
				'name': 'to',
				'type': 'address',
				'internalType': 'address'
			}, { 'name': 'value', 'type': 'uint256', 'internalType': 'uint256' }]
		}],
		'stateMutability': 'view'
	}, {
		'type': 'function',
		'name': 'pending',
		'inputs': [{ 'name': '', 'type': 'uint256', 'internalType': 'uint256' }],
		'outputs': [{ 'name': 'data', 'type': 'bytes', 'internalType': 'bytes' }, {
			'name': 'to',
			'type': 'address',
			'internalType': 'address'
		}, { 'name': 'value', 'type': 'uint256', 'internalType': 'uint256' }],
		'stateMutability': 'view'
	}, {
		'type': 'function',
		'name': 'schedule',
		'inputs': [{
			'name': 'newCall',
			'type': 'tuple',
			'internalType': 'struct Cheapskate.Call',
			'components': [{ 'name': 'data', 'type': 'bytes', 'internalType': 'bytes' }, {
				'name': 'to',
				'type': 'address',
				'internalType': 'address'
			}, { 'name': 'value', 'type': 'uint256', 'internalType': 'uint256' }]
		}],
		'outputs': [],
		'stateMutability': 'nonpayable'
	}, {
		'type': 'event',
		'name': 'CallEvent',
		'inputs': [{ 'name': 'data', 'type': 'bytes', 'indexed': false, 'internalType': 'bytes' }, {
			'name': 'to',
			'type': 'address',
			'indexed': false,
			'internalType': 'address'
		}, { 'name': 'value', 'type': 'uint256', 'indexed': false, 'internalType': 'uint256' }, {
			'name': 'success',
			'type': 'bool',
			'indexed': false,
			'internalType': 'bool'
		}],
		'anonymous': false
	}];

	import { ethSk, init, p256Sk } from '$lib/stores';
	import { privateKeyToAccount } from 'viem/accounts';
	import { P256 } from 'ox';
	import { onMount } from 'svelte';
	import { createClient, formatEther, type Hex, http, parseEther, toHex } from 'viem';
	import { getBalance, getCode, readContract } from 'viem/actions';
	import { odysseyTestnet } from 'viem/chains';
	import { sendTransaction } from 'viem/zksync';

	// Initialize the local storage keys if needed
	onMount(() => init());

	// for forcing balance / state refreshing
	let refreshing = $state(true);

	let toUser = $state('0x0000000000000000000000000000000000000000');
	let value = $state('0.01');

	// Account keys and viem client
	const privateKey = $derived($ethSk ? $ethSk : null);
	const account = $derived($ethSk ? privateKeyToAccount($ethSk) : null);
	const p256Pub = $derived($p256Sk ? P256.getPublicKey({ privateKey: $p256Sk }) : null);
	const client = $derived(account ?
		createClient({
			account,
			chain: odysseyTestnet,
			transport: http()
		}) : null
	);
	// Derive balance promise
	let ourBalance = $state(Promise.resolve(0n));
	let ourCode: Promise<Hex | undefined> = $state(Promise.resolve(undefined));
	let ourPending: Promise<{ data: Uint8Array, to: Hex, value: bigint } | undefined> = $state(Promise.resolve(undefined));

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
		ourPending = readContract(client, {
			address: account.address,
			abi,
			functionName: 'nextPending'
		});

	});

	const sendEth = () => {
		if (!account || !client) return;
		const weiValue = parseEther(value);
		sendTransaction(client, {
			to: account.address,
			value: weiValue
		});
	};

</script>

{#if privateKey}
	<p>eth sk:</p>
	<pre>{privateKey}</pre>
{/if}

{#if account}
	<p>account: {account.address}</p>
{/if}

{#if p256Pub}
	<p>p256Pub: {JSON.stringify({ prefix: p256Pub.prefix, x: toHex(p256Pub.x), y: toHex(p256Pub.y) })}</p>
{/if}

<p>Our balance:
	{#await ourBalance}[loading...]{:then balance}{formatEther(balance)}{/await}
</p>
<p>Our code:
	{#await ourCode}[loading...]{:then code}{code ? code : "no code in our account"}{/await}
</p>
<p>Our pending:
	{#await ourPending}[loading...]{:then pending}{pending ? JSON.stringify({data: pending.data, to: pending.to, value: pending.value.toString()}) : "no pendings in our account"}{/await}
</p>

<input type="text" class="cs-input" bind:value={value} />
<div>
	<button class="cs-btn" onclick={sendEth}>send eth</button>
</div>
