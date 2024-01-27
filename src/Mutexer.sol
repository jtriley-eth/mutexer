// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.24;

/// @title Mutexer
/// @author jtriley.eth
/// @notice Mutli-granularity Mutex
abstract contract Mutexer {
    error Locked();
    error SelectorLocked(bytes4 selector);
    enum Mutex {
        Unlocked,
        Locked
    }

    uint256 internal constant CONTRACT_LOCK = uint256(keccak256("Mutexer.CONTRACT_LOCK")) - 1;
    uint256 internal constant FUNCTION_LOCK_SEED = uint256(keccak256("Mutexer.FUNCTION_LOCK_SEED")) - 1;

    modifier contractLock() {
        if (_tload(CONTRACT_LOCK) == Mutex.Locked) revert Locked();

        _tstore(CONTRACT_LOCK, Mutex.Locked);
        _;
        _tstore(CONTRACT_LOCK, Mutex.Unlocked);
    }

    modifier functionLock(bytes4 selector) {
        uint256 fnLock = uint256(keccak256(abi.encode(selector, FUNCTION_LOCK_SEED)));

        if (_tload(fnLock) == Mutex.Locked) revert SelectorLocked(selector);

        _tstore(fnLock, Mutex.Locked);
        _;
        _tstore(fnLock, Mutex.Unlocked);
    }

    modifier customLock(uint256 key) {
        if (_tload(key) == Mutex.Locked) revert Locked();

        _tstore(key, Mutex.Locked);
        _;
        _tstore(key, Mutex.Unlocked);
    }

    function _tstore(uint256 key, Mutex value) private {
        assembly { tstore(key, value) }
    }

    function _tload(uint256 key) private view returns (Mutex value) {
        assembly { value := tload(key) }
    }
}
