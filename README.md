# DLAN Network

The decentralized network sharing solution.

### How to run

Install `ganache-cli`

```bash
$ npm install -g ganache-cli
```

Reference: https://github.com/trufflesuite/ganache-cli

Install `truffle`

```bash
$ npm install -g truffle
```

Reference: https://www.trufflesuite.com/docs/truffle/getting-started/installation

Start the blockchain by running `start_chain.sh`.

Deploy the contracts (in another terminal):

```bash
$ truffle migrate
```

It's recommended you run the blockchain on the same machine as the AAA service and the operator service.

 