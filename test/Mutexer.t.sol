// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.24;

import {Test} from "../lib/forge-std/src/Test.sol";

import {MockMutexer, Access} from "./mocks/MockMutexer.sol";

contract MutexerTest is Test {
    error Locked();

    event Accessed(Access indexed access);

    uint256 internal constant CONTRACT_LOCK = uint256(keccak256("Mutexer.CONTRACT_LOCK")) - 1;
    uint256 internal constant FUNCTION_LOCK_SEED = uint256(keccak256("Mutexer.FUNCTION_LOCK_SEED")) - 1;

    MockMutexer internal mutexer;

    function setUp() public {
        mutexer = new MockMutexer();
    }

    // -- units --

    function testContractLevelAccess() public {
        vm.expectEmit(true, true, true, true);
        emit Accessed(Access.Contract);

        mutexer.contractLevelAccess();
    }

    function testFunctionLevelAccess() public {
        vm.expectEmit(true, true, true, true);
        emit Accessed(Access.Function);

        mutexer.functionLevelAccess();
    }

    function testCustomLevelAccess() public {
        vm.expectEmit(true, true, true, true);
        emit Accessed(Access.Custom);

        mutexer.customLevelAccess(0);
    }

    function testContractLockToContractAccess() public {
        vm.expectRevert(Locked.selector);

        mutexer.contractLockToContractAccess();
    }

    function testFunctionLockToContractAccess() public {
        vm.expectEmit(true, true, true, true);
        emit Accessed(Access.Contract);

        mutexer.functionLockToContractAccess();
    }

    function testCustomLockToContractAccess() public {
        vm.expectEmit(true, true, true, true);
        emit Accessed(Access.Contract);

        mutexer.customLocktoContractAccess(0);
    }

    function testCustomLockToContractAccessMatch() public {
        vm.expectRevert(Locked.selector);

        mutexer.customLocktoContractAccess(CONTRACT_LOCK);
    }

    function testContractLockToFunctionAccess() public {
        vm.expectEmit(true, true, true, true);
        emit Accessed(Access.Function);

        mutexer.contractLockToFunctionAccess();
    }

    function testFunctionLockToFunctionAccess() public {
        vm.expectEmit(true, true, true, true);
        emit Accessed(Access.Function);

        mutexer.functionLockToFunctionAccess();
    }

    function testFunctionLockToFunctionAccessMatch() public {
        vm.expectRevert(Locked.selector);

        mutexer.functionLockToFunctionAccessMatch();
    }

    function testCustomLockToFunctionAccess() public {
        vm.expectEmit(true, true, true, true);
        emit Accessed(Access.Function);

        mutexer.customLockToFunctionAccess(0);
    }

    function testCustomLockToFunctionAccessMatch() public {
        vm.expectRevert(Locked.selector);

        mutexer.customLockToFunctionAccess(
            uint256(keccak256(abi.encode(MockMutexer.functionLevelAccess.selector, FUNCTION_LOCK_SEED)))
        );
    }

    function testContractLockToCustomAccess() public {
        vm.expectEmit(true, true, true, true);
        emit Accessed(Access.Custom);

        mutexer.contractLockToCustomAccess(0);
    }

    function testContractLockToCustomAccessMatch() public {
        vm.expectRevert(Locked.selector);

        mutexer.contractLockToCustomAccess(CONTRACT_LOCK);
    }

    function testFunctionLockToCustomAccess() public {
        vm.expectEmit(true, true, true, true);
        emit Accessed(Access.Custom);

        mutexer.functionLockToCustomAccess(0);
    }

    function testFunctionLockToCustomAccessMatch() public {
        vm.expectRevert(Locked.selector);

        mutexer.functionLockToCustomAccess(
            uint256(keccak256(abi.encode(MockMutexer.customLevelAccess.selector, FUNCTION_LOCK_SEED)))
        );
    }

    function testCustomLockToCustomAccess() public {
        vm.expectEmit(true, true, true, true);
        emit Accessed(Access.Custom);

        mutexer.customLockToCustomAccess(0, 1);
    }

    function testCustomLockToCustomAccessMatch() public {
        vm.expectRevert(Locked.selector);

        mutexer.customLockToCustomAccessMatch(0);
    }

    // -- fuzzies --

    function testFuzzCustomLevelAccess(uint256 key) public {
        vm.expectEmit(true, true, true, true);
        emit Accessed(Access.Custom);

        mutexer.customLevelAccess(key);
    }

    function testFuzzCustomLockToFunctionAccess(uint256 key) public {
        if (key == uint256(keccak256(abi.encode(MockMutexer.functionLevelAccess.selector, FUNCTION_LOCK_SEED)))) {
            vm.expectRevert(Locked.selector);
        } else {
            vm.expectEmit(true, true, true, true);
            emit Accessed(Access.Function);
        }

        mutexer.customLockToFunctionAccess(key);
    }

    function testFuzzContractLockToCustomAccess(uint256 key) public {
        if (key == CONTRACT_LOCK) {
            vm.expectRevert(Locked.selector);
        } else {
            vm.expectEmit(true, true, true, true);
            emit Accessed(Access.Custom);
        }

        mutexer.contractLockToCustomAccess(key);
    }

    function testFuzzFunctionLockToCustomAccess(uint256 key) public {
        if (key == uint256(keccak256(abi.encode(MockMutexer.customLevelAccess.selector, FUNCTION_LOCK_SEED)))) {
            vm.expectRevert(Locked.selector);
        } else {
            vm.expectEmit(true, true, true, true);
            emit Accessed(Access.Custom);
        }

        mutexer.functionLockToCustomAccess(key);
    }

    function testFuzzCustomLockToCustomAccess(uint256 key0, uint256 key1) public {
        if (key0 == key1) {
            vm.expectRevert(Locked.selector);
        } else {
            vm.expectEmit(true, true, true, true);
            emit Accessed(Access.Custom);
        }

        mutexer.customLockToCustomAccess(key0, key1);
    }
}
