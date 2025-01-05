// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";

/**
 * @title GenerateSignature
 * @author Ricardo Pintos
 * @notice THIS CONTRACT IS NOT FOR PRODUCTION. This is an auxiliary contract used to generate the signature needed to claim the airdrop. It is used in the Interactions contract. It was not used in the original project of Cyfrin Updraft.
 * @dev I made this contract to give modularity to the signature. On the original project, it was fixed and it didn't allow for integration tests because you need the recently deployed airdrop address. Also, the receiver would always be the first anvil address, regardless of the chainid.
 * @dev IT HAS A MAYOR FLAW: requires the private key of the address that will receive the airdrop to make the signature. I'm aware that the recommended solution is to use the `account` flag on the terminal instead of saving it on the .env file.
 */
contract GenerateSignature is Script {
    address public CLAIMING_ADDRESS;
    uint256 public CLAIMING_ADDRESS_KEY;
    uint256 public constant CLAIMING_AMOUNT = 25e18;
    address internal constant ANVIL_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address internal constant SEPOLIA_ADDRESS = 0x39Bd89bfBF5f01C8465F0F88Fd6Fb83c493A2f1b;
    uint256 internal ANVIL_KEY = 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80;
    uint256 internal SEPOLIA_KEY = vm.envUint("SEPOLIA_KEY");

    function run() external view {}

    function generateSignature(address airdrop) public returns (uint8 v, bytes32 r, bytes32 s) {
        if (block.chainid == 31337) {
            CLAIMING_ADDRESS = ANVIL_ADDRESS;
            CLAIMING_ADDRESS_KEY = ANVIL_KEY;
        } else {
            CLAIMING_ADDRESS = SEPOLIA_ADDRESS;
            CLAIMING_ADDRESS_KEY = SEPOLIA_KEY;
        }
        bytes32 digest = MerkleAirdrop(airdrop).getMessageHash(CLAIMING_ADDRESS, CLAIMING_AMOUNT);
        (v, r, s) = vm.sign(CLAIMING_ADDRESS_KEY, digest);
        return (v, r, s);
    }
}
