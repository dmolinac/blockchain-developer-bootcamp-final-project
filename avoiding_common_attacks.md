# Avoiding common attacks

## Using Specific Compiler Pragma (SWC-103)

Specific compiler pragma `0.8.7` is used in contracts to avoid accidental bug inclusion through outdated compiler versions.

## Proper Use of Require, Assert and Revert (SWC-123)

Use of require is prioritized within all the modifiers and many functions in the contracts developed.

## Use Modifiers Only for Validation

- The modifiers in both contracts only validate data with `require` statements.
- Modifiers to replace duplicate condition checks

## Unprotected Link Withdrawal (SWC-105)

`withdrawLink` function is protected with `onlyOwner` modifier.

## Re-entrancy (SWC-107)

NFTs are only minted only when the token counter is incremented and the horse ID is pushed into the array registry so it cannot be minted more than once.


