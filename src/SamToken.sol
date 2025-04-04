// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract SamToken is ERC20 {
    constructor(uint256 _initialSupply) ERC20("Samtoken", "STK") {
        _mint(msg.sender, _initialSupply);
    }
}
