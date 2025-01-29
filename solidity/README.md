## solidity useful commands

The most useful commands for running these examples / playing around with contracts involves cast running against either local anvil
or the odyssey testnet

By default, the foundry.toml file will use the odyssey testnet remote as the RPC url.
You can change this by specifying `--rpc-url anvil` for the localhost node or any other URL string for a remote rpc (assuming it's odyssey capable).

### Get current code

Getting the current code of an address: (useful for debugging whether it's 0x or 0xef...etc)
```bash
cast code {address}
```

### Set env variables

Setting up the private key to match from the web UI:
```bash
export PRIVATE_KEY=0xwhatever_from_frontend
export ADD={user address of EOA}
export C_ADD={contract address to delegate}
```

### Set EOA contract delegation

Now you can use the private key to set the delegation / perform setup using the private key and target contract for delegation
```bash
cast send $ADD --auth $C_ADD --private-key $PRIVATE_KEY "some_init_function()"
```

This should call `some_init_function()` on your own address after delegating it to use the contract supplied, which should set your EOA code to `0xef0100 || address`.
This can be useful for doing some initialization function that requires a setup like setting a p256 pubkey for authorized signing etc, assuming the contract code contains `require(msg.sender == address(this))` then it should be the equivalent of an `onlyOwner` type call(?). 

You can use this to set `--auth` to the zero address (`0x0000000000000000000000000000000000000000`) to clear the delegation for your EOA as well(?).

### Calling the EOA code with auth

You can generate the signed auth for other bundlers to submit (or yourself via separate account) using
```bash
export SIGNED_AUTH=$(cast wallet sign-auth $C_ADD --private-key $PRIVATE_KEY)
```

This can let you call from different accounts via cast or via viem as the authorization parameter i.e.
```bash
cast send $ADD --auth $SIGNED_AUTH  \
  # --private-key {some other key} or --account {some saved account} \
  "some_function()"
```
Which should call `some_function()` on the user's address with code loaded from the delegated address in auth?
TBH I think maybe the odyssey testnet caches the signed auth's and attaches them to the txs to that address? Let's see?

TODO:
- [x] test what requirements for sending transactions are
- [x] where they originate from via signed auth
- [x] cases to invalidate the signed auth and if relevant
- [x] clearing delegation
- [x] some basic security questions and interactive answers
- [ ] hard mode, p256 delegation and sending a successful tx
- [ ] hell mode, bls multisig delegation and sending a successful tx
- [x] improve blockscout to recognize EOA and delegated contracts better
  - [ ] Build your own explorer to visualise this ??? profit
