# 7702 Workshop
### Let's build on Ithaca Odyssey testnet's new features

There are some commands you can run in the `./solidity` readme with cast and anvil on an odyssey network.

Run `anvil --odyssey` for a compatible anvil network and pass `--rpc-url anvil` in cast / forge commands to run against the local node.

### Simple web UI:

There's a basic web UI that spins up a fresh eth account and a p256 key to test some functionality via viem.
Currently, this just displays the balance and the set code on refresh of the page or setting `refresh = true` from somewhere.

How can we follow the examples and build upon them in fun and cool ways?

Some content for further reading:

- [EIP 7702 on ethereum.org](https://eips.ethereum.org/EIPS/eip-7702)
- [Ithaca's Odyssey testnet example repo, where some base contracts were copied from](https://github.com/ithacaxyz/odyssey-examples/tree/main/chapter1)
- [Odyssey chapter 1 announcement post](https://www.ithaca.xyz/updates/odyssey)
- [exp-0001 post with some more docs and links to related odyssey and 7702 info](https://www.ithaca.xyz/writings/exp-0001)
- [orc-0001 sequencer-sponsored transactions](https://www.ithaca.xyz/writings/orc-0001)
- [lightclient devcon talk about 7702 from november '24](https://www.youtube.com/watch?v=_k5fKlKBWV4)
- [pectra upgrade info](https://eipsinsight.com/pectra)