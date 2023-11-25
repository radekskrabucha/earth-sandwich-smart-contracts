# EarthSandwich Smart Contract

## Overview
EarthSandwich is an innovative platform on the Lukso blockchain that allows users to connect globally and create virtual "sandwiches" with other users. This repository contains the smart contract code for EarthSandwich, built on the Lukso blockchain using LSP8 Identifiable Digital Asset standard.

## Features
- Initiate sandwich-making sessions with users worldwide.
- Accept invitations and contribute to sandwich creations.
- Mint unique NFTs representing completed EarthSandwiches.
- Query sandwich details and participant information.

## Technology Stack
- Solidity ^0.8.17
- Lukso LSP8 Identifiable Digital Asset Standard

## Prerequisites
- Node.js
- npm
- Hardhat

## Getting Started

To get started with this template, follow the steps below:

1. **Clone the repository**: Clone this repository to your local machine.
2. **Install dependencies**: Install the necessary dependencies by running `npm install`.
3. **Copy environment variables**: Copy the `.env.example` file to `.env` (`cp .env.example .env`) and fill in the required environment variables.
4. **Deploy** : Deploy the smart contract to the Lukso blockchain by running `npx hardhat run scripts/deploy.ts --network lukso`

