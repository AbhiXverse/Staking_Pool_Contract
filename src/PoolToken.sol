// SPDX-License-Identifier: MIT 

pragma solidity ^0.8.19;

contract PoolToken {

    // owner of the contract
    address public owner;

    // ERC20 token properties
    string public name = "Pool Token";
    string public symbol = "PTN";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;

    // mappings to track balances and allowances
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // events for transfer and approval
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    // modifier to restrict minting to the owner
    modifier onlyowner() {
        require(msg.sender == owner, "only owner can mint");
        _;
    }

    // constructor to initialize the contract
    constructor() {
        owner = msg.sender;
        totalSupply = 1000 * 10 ** decimals;
        balanceOf[msg.sender] = totalSupply;
        emit Transfer(address(0), msg.sender, totalSupply);
    }

    // Transfer tokens from msg.sender to another address
    function transfer(address _to, uint256 _value) external returns(bool) {
        require((balanceOf[msg.sender] >= _value), "Balance is low");
        balanceOf[msg.sender] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    // Approve another address to spend a specific amount of your tokens
    function approve(address spender, uint256 _value) external returns(bool) {
        allowance[msg.sender][spender] = _value;
        emit Approval(msg.sender, spender, _value);
        return true;
    }

    // Transfer tokens on behalf of another address (with prior approval)
    function transferFrom(address _from, address _to, uint256 _value) external returns(bool) {
        require(balanceOf[_from] >= _value, "Insufficient balance");
        require(allowance[_from][msg.sender] >= _value, "Insufficient allownace");

        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        allowance[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    // Function to mint new tokens (only owner can call this)
    function mint(address _to, uint256 _value) external onlyowner {
        totalSupply += _value;
        balanceOf[_to] += _value;
        emit Transfer(address(0), _to, _value);
    }
}

