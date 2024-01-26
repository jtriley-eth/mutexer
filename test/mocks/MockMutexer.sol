// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.24;

import {Mutexer} from "../../src/Mutexer.sol";

enum Access {
    Contract,
    Function,
    Custom
}

contract MockMutexer is Mutexer {
    event Accessed(Access indexed access);

    function contractLevelAccess() external contractLock {
        emit Accessed(Access.Contract);
    }

    function functionLevelAccess() external functionLock(msg.sig) {
        emit Accessed(Access.Function);
    }

    function customLevelAccess(uint256 key) external customLock(key) {
        emit Accessed(Access.Custom);
    }

    function contractLockToContractAccess() external contractLock {
        this.contractLevelAccess();
    }

    function functionLockToContractAccess() external functionLock(msg.sig) {
        this.contractLevelAccess();
    }

    function customLocktoContractAccess(uint256 key) external customLock(key) {
        this.contractLevelAccess();
    }

    function contractLockToFunctionAccess() external contractLock {
        this.functionLevelAccess();
    }

    function functionLockToFunctionAccess() external functionLock(msg.sig) {
        this.functionLevelAccess();
    }

    function functionLockToFunctionAccessMatch() external functionLock(this.functionLevelAccess.selector) {
        this.functionLevelAccess();
    }

    function customLockToFunctionAccess(uint256 key) external customLock(key) {
        this.functionLevelAccess();
    }

    function contractLockToCustomAccess(uint256 key) external contractLock {
        this.customLevelAccess(key);
    }

    function functionLockToCustomAccess(uint256 key) external functionLock(this.customLevelAccess.selector) {
        this.customLevelAccess(key);
    }

    function customLockToCustomAccess(uint256 key0, uint256 key1) external customLock(key0) {
        this.customLevelAccess(key1);
    }

    function customLockToCustomAccessMatch(uint256 key) external customLock(key) {
        this.customLevelAccess(key);
    }
}
