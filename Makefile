-include .env

.PHONY: build test fork install deploy anvil sepolia

install :; forge install foundry-rs/forge-std@v1.8.2 --no-commit && forge install openzeppelin/openzeppelin-contracts --no-commit && forge install dmfxyz/murky --no-commit && forge install cyfrin/foundry-devops --no-commit

merkle :; forge script script/GenerateInput.s.sol:GenerateInput && forge script script/MakeMerkle.s.sol:MakeMerkle

build :; forge build

test :; forge test

fork-test :; forge test --fork-url $(SEPOLIA_RPC_URL) -vvvv

zktest :; foundryup-zksync && forge test --zksync && foundryup

# ANVIL

deploy-anvil:
	@forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop --rpc-url $(LOCAL_RPC_URL) --account anvilKey --broadcast -vvvv

claim-anvil:
	@forge script script/Interactions.s.sol:ClaimAirdrop --rpc-url $(LOCAL_RPC_URL) --account anvilTwoKey --broadcast -vvvv

# SEPOLIA

deploy-sepolia:
	@forge script script/DeployMerkleAirdrop.s.sol:DeployMerkleAirdrop --rpc-url $(SEPOLIA_RPC_URL) --account testKey --broadcast --verify --etherscan-api-key $(ETHERSCAN_API_KEY) -vvvv

claim-sepolia:
	@forge script script/Interactions.s.sol:ClaimAirdrop --rpc-url $(SEPOLIA_RPC_URL) --account testTwoKey --broadcast -vvvv
