// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script, console} from "forge-std/Script.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {GenerateSignature} from "../script/GenerateSignature.s.sol";

/**
 * @title Interactions
 * @author Ricardo Pintos
 * @notice This contract is used to interact with the MerkleAirdrop contract.
 * @dev THIS CONTRACT IS NOT FOR PRODUCTION. It uses a `GenerateSignature` script instead of the `splitSignature` function. This gives modularity to the signature, but at the cost of using the private key of the address that will receive the airdrop. I'm aware that the recommended solution is to use the `account` flag on the terminal instead of saving it on the .env file.
 * @dev This change allows for integration tests improving code coverage. Also, the receiver will be the proper account in Sepolia and not the first Anvil account. The `splitSignature` function is not used directly.
 */
contract ClaimAirdrop is Script {
    error Interactions__InvalidSignatureLength();

    address ANVIL_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    bytes32 ANVIL_PROOF_ONE = 0xd1445c931158119b00449ffcac3c947d028c0c359c34a6646d95962b3b55c6ad;
    bytes32 ANVIL_PROOF_TWO = 0x454b420977b4a459b63b973ec7f88d95f2b04c48a8cb8edecd4c05b0a0b9ef77;

    address SEPOLIA_ADDRESS = 0x39Bd89bfBF5f01C8465F0F88Fd6Fb83c493A2f1b;
    bytes32 SEPOLIA_PROOF_ONE = 0x056690e6132bd2e01881dcc9f64b9e208450062abd0a8564f56b7aa8d133c737;
    bytes32 SEPOLIA_PROOF_TWO = 0x81f0e530b56872b6fc3e10f8873804230663f8407e21cef901b8aeb06a25e5e2;

    uint256 CLAIMING_AMOUNT = 25e18;
    address CLAIMING_ADDRESS;
    bytes32[] proof;
    bytes private SIGNATURE =
        hex"12e145324b60cd4d302bfad59f72946d45ffad8b9fd608e672fd7f02029de7c438cfa0b8251ea803f361522da811406d441df04ee99c3dc7d65f8550e12be2ca1c";

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }

    function claimAirdrop(address airdrop) public {
        if (block.chainid == 31337) {
            CLAIMING_ADDRESS = ANVIL_ADDRESS;
            proof = [ANVIL_PROOF_ONE, ANVIL_PROOF_TWO];
        } else {
            CLAIMING_ADDRESS = SEPOLIA_ADDRESS;
            proof = [SEPOLIA_PROOF_ONE, SEPOLIA_PROOF_TWO];
        }
        GenerateSignature generateSignature = new GenerateSignature();
        (uint8 v, bytes32 r, bytes32 s) = generateSignature.generateSignature(airdrop);

        vm.startBroadcast();
        console.log("Claiming Airdrop");
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, proof, v, r, s);
        vm.stopBroadcast();
        console.log("Claimed Airdrop");
    }

    function recombineSignature(uint8 v, bytes32 r, bytes32 s) public pure returns (bytes memory) {
        return abi.encodePacked(r, s, v);
    }

    function splitSignature(bytes memory sig) public pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) {
            revert Interactions__InvalidSignatureLength();
        }
        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }
    }
}
