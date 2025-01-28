// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

// trick our friends into paying gas for us, abusing the EOA flag on explorers
// why does it cost 100k gas to send you eth bro?
// don't worry about it bro
contract Cheapskate {

    struct Call {
        bytes data;
        address to;
        uint256 value;
    }

    event CallEvent(bytes data, address to, uint256 value, bool success);

    Call[] public pending;
    uint256 public currentPending = 0;

    function schedule(Call memory newCall) public {
        require(msg.sender == address(this));
        pending.push(newCall);
    }

    function nextPending() external view returns (Call memory call) {
        call = pending[currentPending];
    }

    receive() external payable {
        // take at most 5 calls from pending per receive
        uint256 difference = pending.length - currentPending;
        uint256 buffered = difference >= 5 ? 5 : difference;
        if (buffered == 0) {
            return;
        }
        for (uint256 i = 0; i < buffered; i++) {
            // these should be fallible so we don't block receiving eth from failed calls?
            Call memory next = pending[currentPending++];
            (bool success,) = next.to.call{value: next.value}(next.data);
            emit CallEvent(next.data, next.to, next.value, success);
        }
    }

}
