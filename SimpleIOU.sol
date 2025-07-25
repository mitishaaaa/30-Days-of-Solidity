//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract SimpleIOU{
    address public owner;
    
    // Track registered friends
    mapping(address => bool) public registeredFriends;
    address[] public friendList;
    
    // Track balances
    mapping(address => uint256) public balances;
    
    // Simple debt tracking
    mapping(address => mapping(address => uint256)) public debts; // debtor -> creditor -> amount
    
    constructor() {
        owner = msg.sender;
        registeredFriends[msg.sender] = true;
        friendList.push(msg.sender);
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }
    
    modifier onlyRegistered() {
        require(registeredFriends[msg.sender], "You are not registered");
        _;
    }
    
    // Register a new friend
    function addFriend(address _friend) public onlyOwner {
        require(_friend != address(0), "Invalid address");
        require(!registeredFriends[_friend], "Friend already registered");
        
        registeredFriends[_friend] = true;
        friendList.push(_friend);
    }
    
    // Deposit funds to your balance
    function depositIntoWallet() public payable onlyRegistered {
        require(msg.value > 0, "Must send ETH");
        balances[msg.sender] += msg.value;
    }
    
    // Record that someone owes you money
    function recordDebt(address _debtor, uint256 _amount) public onlyRegistered {
        require(_debtor != address(0), "Invalid address");
        require(registeredFriends[_debtor], "Address not registered");
        require(_amount > 0, "Amount must be greater than 0");
        
        debts[_debtor][msg.sender] += _amount;
    }
    
    // Pay off debt using internal balance transfer

    function payFromWallet(address _creditor, uint256 _amount) public onlyRegistered {  //creditor = you owe money to, amount = how much you're paying
        //Validations

        require(_creditor != address(0), "Invalid address");
        //Prevents sending money to zero address

        require(registeredFriends[_creditor], "Creditor not registered");
        //Makes sure ur only  interacting with registered

        require(_amount > 0, "Amount must be greater than 0");
        // no zero or negative numbers

        require(debts[msg.sender][_creditor] >= _amount, "Debt amount incorrect");
        // checks you're not paying more than you owe

        require(balances[msg.sender] >= _amount, "Insufficient balance");
        // checks if you have enough money to pay
        
        // ACTUAL LOGIC
        balances[msg.sender] -= _amount;
        // Deducts the amount from your wallet

        balances[_creditor] += _amount;
        // Credits to the creditor

        debts[msg.sender][_creditor] -= _amount;
        // Updates your debt record

    }
    
    // Direct transfer method using transfer()
    function transferEther(address payable _to, uint256 _amount) public onlyRegistered {
        require(_to != address(0), "Invalid address");
        require(registeredFriends[_to], "Recipient not registered");
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        balances[msg.sender] -= _amount;
        _to.transfer(_amount);
        balances[_to]+=_amount;
    }
    
    // Alternative transfer method using call()
    function transferEtherViaCall(address payable _to, uint256 _amount) public onlyRegistered {
        require(_to != address(0), "Invalid address");
        require(registeredFriends[_to], "Recipient not registered");
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        balances[msg.sender] -= _amount;
        
        (bool success, ) = _to.call{value: _amount}("");
        balances[_to]+=_amount;
        require(success, "Transfer failed");
    }
    
    // Withdraw your balance
    function withdraw(uint256 _amount) public onlyRegistered {
        require(balances[msg.sender] >= _amount, "Insufficient balance");
        
        balances[msg.sender] -= _amount;
        
        (bool success, ) = payable(msg.sender).call{value: _amount}("");
        require(success, "Withdrawal failed");
    }
    
    // Check your balance
    function checkBalance() public view onlyRegistered returns (uint256) {
        return balances[msg.sender];
    }
}

