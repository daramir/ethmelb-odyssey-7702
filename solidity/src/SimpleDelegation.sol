// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

contract SimpleDelegation {

    struct Call {
        bytes data;
        address to;
        uint256 value;
    }

    event Executed(address indexed to, uint256 value, bytes data);

    function execute(Call memory call) external payable {
        (bool success,) = call.to.call{value: call.value}(call.data);
        require(success, "Call failed");
        emit Executed(call.to, call.value, call.data);
    }

    receive() external payable {}

}