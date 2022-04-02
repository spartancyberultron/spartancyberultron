// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.7.0 <0.9.0;

/**
 * @title crypto payments
 * @dev process crypto payment
 */
contract CryptoPayments  {

    address public owner;
    
    // Mapping from address to bool
    mapping(address => bool) public _admins;
    
    // event for EVM logging
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    event AdminSet(address, bool);
    
    event Sale(string itemId, string saleId, uint256 sellerAmount, address seller,string randomHex, uint256 amount, address buyer);
    
    event Bid(string itemId, string saleId,string auctionId,string userId, uint256 amount, address buyer, string txnHex);

    event Offer(string itemId, uint256 quantity, string userId, string randomHex, uint256 amount, address initatedBy);
    
     /**
     * @dev Throws if called by any account other than the admin.
     */
    modifier isAdmin() {
        bool admin = _admins[msg.sender];
        require(admin == true, "Caller is not admin");
        _;
    }
    
    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        setAdmin(owner);
        emit OwnerSet(address(0), owner);
    }

    /**
     * @dev Return owner address 
     * @return address of owner
     */
    function getOwner() external view returns (address) {
        return owner;
    }
    
    /**
    * Set an User as admin
    * Can only called by owner
    */
    function setAdmin(address admin) public onlyOwner {
        require(admin != address(0), "setAdmin: new admin is the zero address");
        _admins[admin] = true;
        emit AdminSet(admin, true);
    }
    
    /**
    * Remove an User as admin
    * Can only called by owner
    */
    function removeAdmin(address admin) external onlyOwner {
        require(admin != address(0), "removeAdmin: admin is the zero address");
        _admins[admin] = false;
        emit AdminSet(admin, false);
    }
    
    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function _setOwner(address newOwner) external onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
    
    /**
     * @dev To get the contract balance.
     */
    function getBalance() public view returns(uint) {
        return address(this).balance;
    }

    /**
     * @dev Transfers ether from smart contract to address (_to).
     * Can only be called by the admin.
     */
    function withdraw(address payable _to, uint256 amount) public payable isAdmin {
        require(_to != address(0), "withdrawal: _to is the zero address");
        
        uint contractBalance = address(this).balance;
        
        require(contractBalance >= amount, "contract balance is less than withdrawal amount");

        (bool sent, ) = _to.call{value: amount}("");
        require(sent, "Failed to send Ether");
    }
    

    // Function to buy crypto.
    function buyCrypto(string memory itemId, string memory saleId, address seller, uint256 sellerAmount, string memory randomHex) public payable {
        require(seller != address(0), "buyCrypto: seller is the zero address");
        
        (bool success,) = seller.call{value: sellerAmount}("");
        require(success, "Failed to send Ether to seller");
        
        emit Sale(itemId, saleId, sellerAmount, seller, randomHex, msg.value, msg.sender);
    }

    /**
     * @dev Deposits ether to the contract address.
     */
    function depositEther(string memory itemId, string memory saleId,string memory auctionId, string memory userId, string memory txnHex) public payable {
        emit Bid(itemId, saleId, auctionId, userId, msg.value, msg.sender, txnHex);
    }

    /**
     * @dev Deposits ether to the contract address for the offer functionality
     */
    function hasOffer(string memory itemId, uint256 quantity, string memory userId, string memory randomHex) public payable {
        emit Offer(itemId, quantity, userId, randomHex, msg.value, msg.sender);
    }
}