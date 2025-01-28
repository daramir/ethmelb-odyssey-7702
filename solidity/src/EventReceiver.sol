// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.10;

// Does this even work?
contract EventReceiver {

    event Received(address indexed from, uint256 value);
    event Fallback(address indexed from, uint256 value);

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }

    fallback() external payable {
        emit Fallback(msg.sender, msg.value);
    }

}
