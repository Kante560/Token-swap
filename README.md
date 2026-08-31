# SimpleSwap

![CI](https://github.com/Kante560/token-swap/actions/workflows/test.yml/badge.svg)

A minimal fixed-ratio token swap built with Foundry. Two ERC-20 tokens,
a shared liquidity pool, and bidirectional swaps at a 2:1 ratio.

## Design

`SimpleSwap` holds no reserve state of its own. Balances are read live
from each token contract via `balanceOf`, so there is nothing cached to
desynchronise and no reentrancy surface in the swap path.

Approvals follow the standard ERC-20 two-step: a caller approves the
swap contract on the token, then calls the swap, which pulls via
`transferFrom`. All token movements use OpenZeppelin's `SafeERC20` to
handle tokens that return `false` rather than reverting.


## Liquidity provision

Depositors receive `SS-LP` tokens representing a proportional claim on
the pool. The first depositor sets the baseline; subsequent deposits mint
`(amountA * totalSupply) / reserveA`. Burning LP tokens via
`removeLiquidity` returns that fraction of both reserves as they stand at
withdrawal time — which may differ in composition from what was deposited
if trades occurred in between.
## Known limitations

These are deliberate scope choices, not oversights:

- **Fixed ratio.** Price is a hardcoded constant, not a function of
  reserves. A real AMM would use constant product (`x * y = k`).
- **No LP tokens.** Liquidity deposits are permanent — there is no
  `removeLiquidity` and no receipt tracking pool share.
- **No fees.** Real LPs are compensated for inventory risk with a
  per-trade fee (typically 0.3%). Nothing here compensates them.
- **Integer truncation.** Odd-numbered TokenA inputs leave dust in the
  pool. Guarded against zero-output trades, not against rounding loss.

## Tests

7 tests covering both swap directions, liquidity provision, third-party
users via `vm.prank`, all revert paths, and a 256-run fuzz of the swap
math.

    forge test -vv

## Deploy

    anvil
    forge script script/Deploy.s.sol --rpc-url http://localhost:8545 \
      --private-key <key> --broadcast

## Github Actions

```bash
# Trigger tests
  gh workflow run test.yml

# View workflow status
  gh workflow view test.yml
```

# Token-swap

## Last Updated

<!-- daily-timestamp -->
Last updated: 2026-08-31T16:41:49Z
<!-- /daily-timestamp -->
