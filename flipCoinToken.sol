// SPDX-License-Identifier: MIT

pragma solidity ^0.8.4;

// ECR-20 token default interface
interface ERC20Interface {
    function totalSupply() external view returns (uint256); // returns maximum number of token that can ever be

    function balanceOf(address account) external view returns (uint256 balance); // returns the balance for the given account

    function transfer(address receipient, uint256 amount)
        external
        returns (bool success);

    function approve(address spender, uint256 amount)
        external
        returns (bool success); // check if the user has enough tokens

    function transferFrom(
        address spender,
        address recipient,
        uint256 amount
    ) external returns (bool success); // one user to another

    function allowance(address owner, address spender)
        external
        view
        returns (uint256 remaining);

    // bookkeeping
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    // minting
    event Mint(address indexed to, uint256 amount, uint256 newPrice);
    event Burn(address indexed from, uint256 amount, uint256 newPrice);
}

contract FlipCoinToken is ERC20Interface {
    string public symbol;
    string public name;
    uint8 public decimals;
    uint256 public _totalSupply;
    address public OWNER; // default address for token.

    uint256 public m; // Slope of bonding curve
    uint256 public b; // intercept of bonding curve

    mapping(address => uint256) balances; // wallet to balance mapping
    mapping(address => mapping(address => uint256)) allowed;

    constructor() {
        symbol = "FLP";
        name = "Flip Coin";
        decimals = 18;
        _totalSupply = 1_000_000_000_000_000_000_000_000; //
        OWNER = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

        balances[OWNER] = _totalSupply;
        emit Transfer(address(0x0), OWNER, _totalSupply); // all token are sent from mint (0x0) to MY_WALLET.

        m = 1;
        b = 1;
    }

    // get maximum number of token that can ever be
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // get the balance from account
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
    function mint(address to, uint256 amount) public returns (bool success) {
        // Calculate the price based on bonding curve
        uint256 currentSupply = _totalSupply;
        uint256 currentPrice = calculatePrice(currentSupply);

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
        require(balances[msg.sender] > amount, "Insufficiet balance to burn");

        // Calculate the price based on the bonding curve
        uint256 currentSupply = _totalSupply;
        uint256 currentPrice = calculatePrice(currentSupply);

        uint256 newSupply = currentSupply - amount;
        uint256 newPrice = calculatePrice(newSupply);

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
        return (m * supply) / (10**decimals) + b;
    }
}
