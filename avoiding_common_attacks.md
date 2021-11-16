# Avoiding common attacks

## Using Specific Compiler Pragma

Specific compiler pragma `0.8.7` used in contracts to avoid accidental bug inclusion through outdated compiler versions.

## Proper Use of Require, Assert and Revert

Use of require is prioritized within all the modifiers and many functions in the contracts developed.

## Use Modifiers Only for Validation

The modifiers in both contracts only validate data with `require` statements.

## Unprotected Link Withdrawal

`withdrawLink` function is protected with `onlyOwner` modifier.

