// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {BagelToken} from "../../src/BagelToken.sol";
import {DeployMerkleAirdrop} from "../../script/DeployMerkleAirdrop.s.sol";
import {ClaimAirdrop} from "../../script/Interactions.s.sol";
import {DevOpsTools} from "foundry-devops/src/DevOpsTools.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";

contract InteractionsTest is ZkSyncChainChecker, Test {
    error Interactions__InvalidSignatureLength();

    MerkleAirdrop public airdrop;
    BagelToken public token;
    DeployMerkleAirdrop public deployer;
    ClaimAirdrop public claimer;

    address private constant s_anvilReceiver = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    address private constant s_sepoliaReceiver = 0x39Bd89bfBF5f01C8465F0F88Fd6Fb83c493A2f1b;
    address public receiver;
    uint8 public v;
    bytes32 public r;
    bytes32 public s;
    bytes private SIGNATURE =
        hex"12e145324b60cd4d302bfad59f72946d45ffad8b9fd608e672fd7f02029de7c438cfa0b8251ea803f361522da811406d441df04ee99c3dc7d65f8550e12be2ca1c";
    bytes private WRONG_SIGNATURE = hex"e1";
    uint8 public constant expectedV = 28;
    bytes32 public constant expectedR = 0x12e145324b60cd4d302bfad59f72946d45ffad8b9fd608e672fd7f02029de7c4;
    bytes32 public constant expectedS = 0x38cfa0b8251ea803f361522da811406d441df04ee99c3dc7d65f8550e12be2ca;
    bool public skipTests;

    function setUp() public {
        // Because zkSync doesn't support scripts, all the test on Interactions.s.sol are skipped
        if (isZkSyncChain()) {
            skipTests = true;
            return;
        } else {
            deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.run();
            claimer = new ClaimAirdrop();
            claimer.claimAirdrop(address(airdrop));
        }
    }

    modifier skipZkSyncTests() {
        if (skipTests) {
            return;
        }
        _;
    }

    function testTokenHasBeenClaimed() public skipZkSyncTests {
        if (block.chainid == 31337) {
            receiver = s_anvilReceiver;
        } else {
            receiver = s_sepoliaReceiver;
        }
        bool claimed = airdrop.getIsTokenAlreadyClaimed(receiver);
        assert(claimed == true);
    }

    function testSplitSignature() public skipZkSyncTests {
        (v, r, s) = claimer.splitSignature(SIGNATURE);
        assert(v == expectedV);
        assert(r == expectedR);
        assert(s == expectedS);
    }

    function testRecombineSignature() public skipZkSyncTests {
        (v, r, s) = claimer.splitSignature(SIGNATURE);
        bytes memory signature = claimer.recombineSignature(v, r, s);
        assert(keccak256(signature) == keccak256(SIGNATURE));
    }

    function testSplitWithInvalidSignatureLength() public skipZkSyncTests {
        vm.expectRevert(ClaimAirdrop.Interactions__InvalidSignatureLength.selector);
        claimer.splitSignature(WRONG_SIGNATURE);
    }
}
