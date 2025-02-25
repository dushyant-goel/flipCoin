// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

// ECR-20 token default interface
interface ERC20Interface {
    function totalSupply() external view returns (uint256); // returns total number of toakens that exist

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
