
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

contract MyToken{

    // token metadata

    string public name = "Mitisha"; // the full name of the token
    string public symbol = "MITU"; // the short ticker like ETH or DAI
    uint8 public decimals = 18; // defines how divisible it is
    uint256 public totalSupply; // this tracks tge total number of tokens that exist

    mapping(address => uint256) public balanceOf; // tells you how many tokens each address holds
    mapping(address => mapping (address  => uint256)) public allowance; // is a nested mapping that tracks who's allowed to spend tokens on behalf of whom and how much

    event Transfer(address indexed from, address indexed to, uint256 value); // fires whenever tokens move from one address to another. wallets and explorers rely on this to display transaction histories
    event Approval(address indexed owner, address indexed spender, uint256 value); // triggered when someone gives another address permission to spend tokens on theri behalf

    constructor(uint256 _initialSupply){
        totalSupply = _initialSupply * (10 ** decimals);
        balanceOf[msg.sender] = totalSupply; // the entire supply is given to the person who deployed the contract
        emit Transfer(address(0), msg.sender, _initialSupply);
    } 

    function _transfer(address _from, address _to, uint256 _value)internal virtual{ 
        require(_to != address(0), "Cannot transfer to the zero address");
        balanceOf[_from]-= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        
//  ✅ Check    | Make sure receiver isn’t a zero address 
//  ➖ Subtract | Tokens from sender                      
//  ➕ Add      | Tokens to receiver                      
//  📢 Emit    | Transfer event so others can see it     

    }
     function transfer(address _to, uint256 _value)public virtual returns (bool success){ 
        require(balanceOf[msg.sender] >= _value , "Not enough balance");
        _transfer(msg.sender, _to, _value);
        return true;
    
    }

    function transferFrom(address _from, address _to, uint256 _value)public virtual returns(bool){  //It allows someone else (like a smart contract or a dApp) to spend tokens on your behalf — but only up to an approved limit.
        require(balanceOf[_from] >= _value, "Not enough balance"); 
        require(allowance[_from][msg.sender]>= _value, "Not enough allowence");
        allowance[_from][msg.sender]-= _value;
        _transfer(_from, _to, _value); //Calls the internal _transfer() function to actually move the tokens.
        return true;

    }

    function approve(address _spender, uint256 _value)public returns(bool){
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
     // spender is the address you're authorizing
     // value is the max amount allowed to spend
    }




}
