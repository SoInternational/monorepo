# Monorepo

## Setup

1. Setup an AWS CLI credentials for account 433680868508.
2. Run the `npm i` command to restore dependencies.
3. Run the `npm run init` command to "enlist" (terraform init, etc.)

## Test

Run the `npm test` command to run all tests.

This includes:

- Linting
- Building
- JS/TS Testing
- Validating Terraform Templates

### Validate Terraform Only

Run the `npm run plan` command to validate all terraform templates. This is a readonly operation and does not change any infrastructure.

## Release and Deploy

Push to the main branch to release and deploy all changes.
