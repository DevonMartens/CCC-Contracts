// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract InvestorToken is ERC20, ERC20Burnable, Ownable {
    
    // Initialize address for awarding tokens
    address cccGovernance = address(0);
    // Constructor to set token name and symbol
    constructor() ERC20("DeveloperToken", "DEV") {}

    // Function to assign cccGovernance address, can only be called by contract owner
    function setCCCGovernance(address _cccGovernance) public onlyOwner {
      cccGovernance = _cccGovernance;
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = cccGovernance;
        require (msg.sender == owner);
        _transfer(owner, to, amount);
        return true;
    }

    function approve(address spender, uint256 amount) public virtual override onlyOwner returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override onlyOwner returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

}

