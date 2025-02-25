// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

// ECR-20 token default interface
interface ERC20Interface {

    function totalSupply() external view returns (uint); // returns maximum number of token that can ever be
    function balanceOf(address account) external view returns (uint balance); // returns the balance for the given account
    function transfer(address receipient, uint amount) external returns (bool success);
    function approve(address spender, uint amount) external returns (bool success); // check if the user has enough tokens
    function transferFrom(address spender, address recipient, uint amount) external returns (bool success); // one user to another
    function allowance(address owner, address spender) external view returns (uint remaining);

    // bookkeeping
    event Transfer(address indexed from, address indexed to, uint value); 
    event Approval(address indexed owner, address indexed spender, uint value);
}

contract FlipCoinToken is ERC20Interface {

    string public symbol;
    string public name;
    uint8 public decimals;
    uint public _totalSupply;
    address MY_WALLET; // default address for token.

    mapping(address => uint) balances; // wallet to balance mapping
    mapping(address => mapping(address => uint)) allowed; 

    constructor() {
        
        symbol = "FLP";
        name = "Flip Coin";
        decimals = 18; 
        _totalSupply = 1_000_001_000_000_000_000_000_000; // 10^6 + 1 FLP
        MY_WALLET = 0x11E66b29506B5aEA3149775272d6Ced39079aF7A; 

        balances[MY_WALLET] = _totalSupply;
        emit Transfer(address(0x0), MY_WALLET, _totalSupply); // all token are sent from mint (0x0) to MY_WALLET.
    }

    // get maximum number of token that can ever be
    function totalSupply() public view returns (uint) {
        return _totalSupply;
    }

    // get the balance from account
    function balanceOf(address account) public view returns (uint balance) {
        return balances[account];
    }

    // transfer from message sender to receiver the amount
    function transfer(address receipient, uint amount) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender] - amount;
        balances[receipient] = balances[receipient] + amount;
        emit Transfer(msg.sender, receipient, amount);
        return true;
    }

    // approve a spender to spend an amount
    function approve(address spender, uint amount) public returns (bool success) {
        allowed[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }

    // transfer from an approved sender to receipient 
    function transferFrom(address sender, address receipient, uint amount) public returns (bool success) {
        balances[sender] = balances[sender] - amount;
        allowed[sender][msg.sender] = allowed[sender][msg.sender] - amount;
        balances[receipient] = balances[receipient] + amount;
        emit Transfer(sender, receipient, amount);
        return true;
    }

    // view allowance for spender
    function allowance(address owner, address spender) public view returns (uint remaining) {
        return allowed[owner][spender];
    }
    

}