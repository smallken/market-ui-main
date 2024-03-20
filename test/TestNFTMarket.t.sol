pragma solidity 0.8.20;

import "forge-std/Test.sol";
import "../contract/v2-swap/MyEIP2612.sol";
import "../contract/v2-swap/libraries/SigUtils.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";


contract TestNFTMarket is Test {
    MyEIP2612 token;
    address admin;
    address user;
    SigUtils internal sigUtils;
    uint256 internal ownerprivatekey;
    uint256 internal userprivateKey;

    function setUp() public {
        ownerprivatekey = 0xABCD;
        userprivateKey = 0xB0B;
        admin = vm.addr(ownerprivatekey);
        user  = vm.addr(userprivateKey);
        vm.startPrank(admin);
        token = new MyEIP2612("Dragon", "DRG");
        vm.stopPrank();
        user = makeAddr("user");
        sigUtils = new SigUtils(token.DOMAIN_SEPARATOR());
    }

    function test() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: admin,
            spender: user,
            value: 1e18,
            nonce: 0,
            deadline: block.timestamp + 1 days
        });
        bytes32 digest = sigUtils.getTypedDataHash(permit);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerprivatekey, digest);
        token.permit(permit.owner, permit.spender, permit.value, permit.deadline, v, r, s);
        address signer = ECDSA.recover(digest, v, r, s);
        console.log("admin:",admin);
        console.log("signer:", signer);
        assertEq(signer, admin);
        assertEq(token.allowance(admin, user), 1e18);
        assertEq(token.nonces(admin), 1);
    }



}