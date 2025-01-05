// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../../src/MerkleAirdrop.sol";
import {BagelToken} from "../../src/BagelToken.sol";
import {DeployMerkleAirdrop} from "../../script/DeployMerkleAirdrop.s.sol";
import {ZkSyncChainChecker} from "foundry-devops/src/ZkSyncChainChecker.sol";

contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    error MerkleAirdrop__InvalidProof();
    error MerkleAirdrop__AlreadyClaimed();
    error MerkleAirdrop__InvalidSignature();

    DeployMerkleAirdrop public deployer;
    MerkleAirdrop public airdrop;
    BagelToken public token;

    bytes32 private constant ROOT = 0xfc0bb30bd903aaa2def81d465e1b7eb477bf6b5bfd4671bc6beaea3a011e1fa6;
    uint256 private constant AMOUNT_TO_CLAIM = 25e18;
    uint256 private constant AMOUNT_TO_SEND = 100e18;

    bytes32 private constant proofOne = 0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a;
    bytes32 private constant proofTwo = 0x454b420977b4a459b63b973ec7f88d95f2b04c48a8cb8edecd4c05b0a0b9ef77;
    bytes32[] public PROOF = [proofOne, proofTwo];
    bytes32 private constant proofThree = 0xa5ebd1e1b5a5478a944ecab36a9a954ac3b6b8216875f6524caa7a1d87096576;
    bytes32[] public WRONG_PROOF = [proofOne, proofThree];
    address public user;
    address public gasPayer;
    uint256 public userPrivKey;
    uint256 public gasPayerKey;
    bytes32 public expectedMerkleRoot = 0xfc0bb30bd903aaa2def81d465e1b7eb477bf6b5bfd4671bc6beaea3a011e1fa6;

    function setUp() public {
        if (!isZkSyncChain()) {
            deployer = new DeployMerkleAirdrop();
            (airdrop, token) = deployer.run();
        } else {
            token = new BagelToken();
            airdrop = new MerkleAirdrop(ROOT, token);
            token.mint(token.owner(), AMOUNT_TO_SEND);
            token.transfer(address(airdrop), AMOUNT_TO_SEND);
        }
        (user, userPrivKey) = makeAddrAndKey("user");
        (gasPayer, gasPayerKey) = makeAddrAndKey("gasPayer");
    }

    function testUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);

        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);

        vm.prank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending balance: ", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }

    function testUsersCantClaimTwice() public {
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);

        vm.startPrank(gasPayer);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__AlreadyClaimed.selector);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
        vm.stopPrank();
    }

    function testInvalidSignature() public {
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(gasPayerKey, digest);

        vm.prank(gasPayer);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__InvalidSignature.selector);
        airdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);
    }

    function testInvalidProof() public {
        bytes32 digest = airdrop.getMessageHash(user, AMOUNT_TO_CLAIM);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivKey, digest);

        vm.prank(gasPayer);
        vm.expectRevert(MerkleAirdrop.MerkleAirdrop__InvalidProof.selector);
        airdrop.claim(user, AMOUNT_TO_CLAIM, WRONG_PROOF, v, r, s);
    }

    function testGetMerkleRoot() public view {
        assertEq(airdrop.getMerkleRoot(), expectedMerkleRoot);
    }

    function testGetAirdropToken() public view {
        assert(airdrop.getAirdropToken() == token);
    }
}
