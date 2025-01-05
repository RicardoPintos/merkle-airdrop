# Merkle Airdrop

With this Foundry project you can create an Airdrop token with Merkle proofs. It was made for the Advanced Foundry course of Cyfrin Updraft.

<br>

- [Merkle Airdrop](#merkle-airdrop)
- [Getting Started](#getting-started)
  - [Requirements](#requirements)
  - [Quickstart](#quickstart)
- [Usage](#usage)
  - [Libraries](#libraries)
  - [Testing](#testing)
    - [Test Coverage](#test-coverage)
  - [Estimate gas](#estimate-gas)
  - [Formatting](#formatting)
- [Notice](#notice)
  - [Modifications to the original project](#modifications-to-the-original-project)
  - [Generate Input and Output](#generate-input-and-output)
- [Deploy](#deploy)
  - [Private Key Encryption](#private-key-encryption)
  - [Deployment to local Anvil](#deployment-to-local-anvil)
    - [Deploy](#deploy-1)
    - [Claim](#claim)
    - [Balance](#balance)
  - [Deployment to Sepolia testnet](#deployment-to-sepolia-testnet)
    - [Deploy](#deploy-2)
    - [Claim](#claim-1)
    - [Balance](#balance-1)
- [Acknowledgments](#acknowledgments)
- [Thank you](#thank-you)

<br>

![EthereumBanner](https://github.com/user-attachments/assets/8a1c6e53-2e66-4256-9312-252a0360b7df)

<br>

# Getting Started

## Requirements

- [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
  - You'll know you did it right if you can run `git --version` and you see a response like `git version x.x.x`
- [foundry](https://getfoundry.sh/)
  - You'll know you did it right if you can run `forge --version` and you see a response like `forge 0.2.0 (816e00b 2023-03-16T00:05:26.396218Z)`

## Quickstart

```
git clone https://github.com/RicardoPintos/merkle-airdrop
cd merkle-airdrop
forge build
```

<br>

# Usage

## Libraries

This project uses the following libraries:

- [Openzeppelin-contracts](https://github.com/OpenZeppelin/openzeppelin-contracts)
- [Cyfrin-foundry-devops](https://github.com/Cyfrin/foundry-devops)
- [Foundry-forge-std](https://github.com/foundry-rs/forge-std)
- [Murky](https://github.com/dmfxyz/murky)

You can install all of them with the following Makefile command:

```
make install
```

## Testing

To run every test:

```
forge test
```

You can also perform a **forked test**. If you have an [Alchemy](https://www.alchemy.com) account, you can set up a Sepolia node, add it to your .env file with the flag $SEPOLIA_RPC_URL and run:

```
make fork-test
```

If you have Foundry-ZkSync installed, you can perform the tests on zkSync with this command:

```
make zktest
```

### Test Coverage

To check the test coverage of this project, run:

```
forge coverage
```

## Estimate gas

You can estimate how much gas things cost by running:

```
forge snapshot
```

And you'll see an output file called `.gas-snapshot`

## Formatting

To run code formatting:

```
forge fmt
```

<br>

# Notice

## Modifications to the original project

The original Cyfrin Updraft project works with a fixed signature on the code. When I was trying to make integration tests, that signature failed because it didn't have the recently deployed airdrop address, therefore the values were different.
<br>
So, I made a `GenerateSignature` script to give modularity to the signature. This allows for proper integration tests and also fixes the receiving address of the token on networks different from Anvil.
<br>
This comes at the cost of working with private keys on the code. I'm aware that the recommended solution is to use the `--account` flag on the terminal instead of saving it on the .env file.
<br>
Also, this project does not do the full implementation on zkSync of the original project. You can learn all those details with the **awesome Ciara** on the [Cyfrin Updraft](https://github.com/Cyfrin/foundry-merkle-airdrop-cu) course.

## Generate Input and Output

You can add you **tests accounts** to the Merkle tree with these steps:
1) Open the `GenerateInput` script.
2) Find the `whitelist[2]` and `whitelist[3]` variables and paste your account addresses. 
3) Then you can run the next command to generate a new input with your addresses and a new output with the proper Merkle tree: 

```
make merkle
```

<br>

# Deploy

## Private Key Encryption

It is recommended to work with encrypted private keys for both Anvil and Sepolia. The following method is an example for Anvil. If you want to deploy to Sepolia, repeat this process with the private key and address of your **test wallet**.

In your local terminal, run this:

```
cast wallet import <Choose_Your_Anvil_Account_Name> --interactive
```

Paste your private key, hit enter and then create a password for that key. 

<br>

Now, you can use the `--account` flag instead of `--private-key`. You'll need to type your password when is needed. To check all of your encrypted keys, run this:

```
cast wallet list
```

<br>

## Deployment to local Anvil

### Deploy

First you need to run Anvil on your terminal:

```
anvil
```

Then you open another terminal and run this:

```
forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop --rpc-url http://127.0.0.1:8545 --account <Your_Encrypted_Anvil_Private_Key_Account_Name> --broadcast -vvvv

```

### Claim

To test the airdrop functionality, you can use a **different** Anvil account to claim the token:

```
forge script script/Interactions.s.sol:ClaimAirdrop --rpc-url http://127.0.0.1:8545 --account <Another_Encrypted_Anvil_Private_Key_Account_Name> --broadcast -vvvv
```

### Balance

To check if the token balance was updated, run this:

```
cast call <Deployed_Token_Address> "balanceOf(address)" <Rewarded_Anvil_Address> --rpc-url http://localhost:8545
```

<br>

## Deployment to Sepolia testnet

### Deploy

To deploy to Sepolia run this:

```
forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop --rpc-url <Your_Alchemy_Sepolia_Node_Url> --account <Your_Encrypted_Sepolia_Private_Key_Account_Name> --broadcast -vvvv
```

If you have an Etherscan API key, you can verify your contract alongside the deployment by running this instead:

```
forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop --rpc-url <Your_Alchemy_Sepolia_Node_Url> --account <Your_Encrypted_Sepolia_Private_Key_Account_Name> --broadcast --verify --etherscan-api-key <Your_Etherscan_Api_Key> -vvvv
```

### Claim

To test the airdrop functionality, you can use a **different** Sepolia account to claim the token:

```
forge script script/Interactions.s.sol:ClaimAirdrop --rpc-url <Your_Alchemy_Sepolia_Node_Url> --account <Another_Encrypted_Sepolia_Private_Key_Account_Name> --broadcast -vvvv
```

### Balance

To check if the token balance was updated, run this:

```
cast call <Deployed_Token_Address> "balanceOf(address)" <Rewarded_Sepolia_Address> --rpc-url <Your_Alchemy_Sepolia_Node_Url>
```

<br>

# Acknowledgments

Thanks to the Cyfrin Updraft team, to Ciara Nightingale and to Patrick Collins for their amazing work. Please check out their courses on [Cyfrin Updraft](https://updraft.cyfrin.io/courses).

<br>

# Thank you

If you appreciated this, feel free to follow me!

[![Ricardo Pintos Twitter](https://img.shields.io/badge/Twitter-1DA1F2?style=for-the-badge&logo=x&logoColor=white)](https://x.com/pintosric)
[![Ricardo Pintos Linkedin](https://img.shields.io/badge/LinkedIn-0077B5?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/ricardo-mauro-pintos/)
[![Ricardo Pintos YouTube](https://img.shields.io/badge/YouTube-FF0000?style=for-the-badge&logo=youtube&logoColor=white)](https://www.youtube.com/@PintosRic)