// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./sampleToken.sol"; // Actualizați calea importului

contract ProductIdentification {
    address public owner;
    address[] public suppliers;
    mapping(address => uint) public supplierBalances; // Balance of each supplier

    SampleToken public tokenContract; // Actualizare la tipul de token

    struct Product {
        bytes4 id;
        string name;
        uint volume;
        address owner;
    }

    mapping(bytes4 => Product) public products;

    uint public registrationFee;

    constructor(uint _registrationFee, address _tokenContractAddress) payable  {
        owner = msg.sender;
        registrationFee = _registrationFee;
        tokenContract = SampleToken(_tokenContractAddress); // Instantiate the token contract
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function registerSuppliers() external payable {
        require(!supplierIsRegistered(), "Supplier is already registered");
        require(msg.value >= registrationFee, "Value must be greater than or equal to the registration fee");

        uint change = msg.value - registrationFee;
        
        suppliers.push(msg.sender);
        supplierBalances[msg.sender] += registrationFee;

        if (change != 0) {
            payable(msg.sender).transfer(change);
        }

        // Transfer registration fee in tokens to owner
        require(tokenContract.transferFrom(msg.sender, owner, registrationFee), "Token transfer failed");
    }

    function registerProduct(string memory _name, uint _amount) external {
        require(supplierIsRegistered(), "Supplier is not registered");
        
        bytes4 _id = bytes4(keccak256(abi.encodePacked(msg.sender, _name)));
        require(!productExist(_id), "Product is already registered");

        products[_id] = Product(_id, _name, _amount, msg.sender);
    }

    function supplierIsRegistered() public view returns (bool) {
        for (uint i = 0; i < suppliers.length; i++) {
            if (suppliers[i] == msg.sender) {
                return true;
            }
        }

        return false;
    }

    function productExist(bytes4 _id) public view returns (bool) {
        return products[_id].id != 0;
    }

    function getProductInformation(bytes4 _id) external view returns (bytes4, string memory, uint, address) {
        require(productExist(_id), "Product doesn't exist");
        Product memory product = products[_id];
        return (product.id, product.name, product.volume, product.owner);
    }

    function updateQuantity(bytes4 _id, int _quantity) external {
        require(supplierIsRegistered(), "Supplier is not registered");
        require(productExist(_id), "Product doesn't exist");

        products[_id].volume = uint(int(products[_id].volume) + _quantity);
    }

    // Function to withdraw supplier's balance
    function withdrawBalance() external {
        require(supplierIsRegistered(), "Supplier is not registered");
        uint balance = supplierBalances[msg.sender];
        require(balance > 0, "No balance to withdraw");

        supplierBalances[msg.sender] = 0;
        require(tokenContract.transfer(msg.sender, balance), "Token transfer failed");
    }
}
