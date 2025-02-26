// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

import "../ERC20Interface.sol";

contract FlipCoinLogToken is ERC20Interface {
    string public symbol;
    string public name;
    uint8 public decimals;

    uint256 public _totalSupply;
    address public OWNER; // default address for token.

    // bonding curve
    uint256 public m; // Slope of bonding curve
    uint256 public b; // intercept of bonding curve

    mapping(address => uint256) balances; // wallet to balance mapping
    mapping(address => mapping(address => uint256)) allowed;

    constructor() {
        symbol = "FLG";
        name = "Flip Log Coin";
        decimals = 0;

        _totalSupply = 100; // initial supply 100 attoFLP
        OWNER = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

        // Initial coin creation.
        balances[OWNER] = _totalSupply;
        emit Transfer(address(0x0), OWNER, _totalSupply); // all token are sent from mint (0x0) to owner.

        m = 1;
        b = 1;
    }

    // get maximum number of token
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // get the balance from account (FLP)
    function balanceOf(address account) public view returns (uint256 balance) {
        return balances[account];
    }

    // transfer from message sender to receiver the amount
    function transfer(address receipient, uint256 amount)
        public
        returns (bool success)
    {
        balances[msg.sender] = balances[msg.sender] - amount;
        balances[receipient] = balances[receipient] + amount;
        emit Transfer(msg.sender, receipient, amount);
        return true;
    }

    // approve a spender to spend an amount
    function approve(address spender, uint256 amount)
        public
        returns (bool success)
    {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // transfer from an approved sender to receipient
    function transferFrom(
        address sender,
        address receipient,
        uint256 amount
    ) public returns (bool success) {
        balances[sender] = balances[sender] - amount;
        allowed[sender][msg.sender] = allowed[sender][msg.sender] - amount;
        balances[receipient] = balances[receipient] + amount;
        emit Transfer(sender, receipient, amount);
        return true;
    }

    // view allowance for spender
    function allowance(address owner, address spender)
        public
        view
        returns (uint256 remaining)
    {
        return allowed[owner][spender];
    }

    // to mint new tokens
    function mint(address to, uint256 amount)
        public
        payable
        returns (bool success)
    {
        // Calculate the price based on bonding curve
        uint256 currentSupply = _totalSupply;

        uint256 totalCost = 0;
        for (uint256 i = 0; i < amount; i++) {
            uint256 currentPrice = calculatePrice(currentSupply + i);
            totalCost += currentPrice; // totalCost is the sum of all prices along the curve.
        }

        require(msg.value >= totalCost, "Insuffienct funds for transaction");

        // transfer the mining cost to contract
        // and return the change to miner

        if (msg.value > totalCost) {
            payable(msg.sender).transfer(msg.value - totalCost);
        }

        uint256 newSupply = currentSupply + amount;
        uint256 newPrice = calculatePrice(newSupply);

        // Mint new tokens
        _totalSupply = newSupply;
        balances[to] += amount;

        emit Mint(to, amount, newPrice);
        emit Transfer(address(0x0), to, amount); // Mint at address 0

        return true;
    }

    // to burn tokens
    function burn(uint256 amount) public returns (bool success) {
        require(balances[msg.sender] >= amount, "Insufficiet balance to burn");

        uint256 currentSupply = _totalSupply;
        uint256 totalPayout = 0;

        // Calculate the price based on the bonding curve
        for (uint256 i = 0; i < amount; i++) {
            uint256 currentPrice = calculatePrice(currentSupply - i - 1);
            totalPayout += currentPrice;
        }

        uint256 newSupply = currentSupply - amount;
        uint256 newPrice = calculatePrice(newSupply);

        payable(msg.sender).transfer(totalPayout);

        // Burn the tokens
        _totalSupply = newSupply;
        balances[msg.sender] -= amount;

        emit Burn(msg.sender, amount, newPrice);
        emit Transfer(msg.sender, address(0x0), amount);

        return true;
    }

    // to calculate prices based on the bonding curve
    // price(FLP) = m.S + b
    function calculatePrice(uint256 supply) internal view returns (uint256) {
        return log_2(supply) + b;
    }

    // check the balance of ETH with contract
    function getContractBalance() public view returns (uint256) {
        uint256 balance = address(this).balance;
        return balance;
    }

    // Calculate the ceil log_2 of an integer
    function log_2(uint256 x) public pure returns (uint256) {
        if (x == 0) return 0; // Handle 0 separately
        if (x == 1) return 0; // Handle 1 separately

        uint256 result = 0;
        uint256 power = 1;

        // Count number of bits
        while (power <= x / 2) {
            power *= 2;
            result++;
        }
        return result;
    }
}
