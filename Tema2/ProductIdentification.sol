// SPDX-License-Identifier: MIT

pragma solidity >=0.8.2 <0.9.0;

import "./SampleToken.sol";

contract ProductIdentification {
    address public owner;

    address[] suppliers;
    Product[] products;
    uint public registrationFee;

    SampleToken public tokenContract; // Adaugă declarația

    struct Product {
        bytes4 id;
        string name;
        uint volume;
        address owner;
    }

    constructor(uint _registrationFee, address _tokenContractAddress) {
        owner = msg.sender;
        registrationFee = _registrationFee;
        tokenContract = SampleToken(_tokenContractAddress); // Instantierea
    }

    function registerSuppliers() public payable {
        require(!supplierIsRegistered(), "Supplier is already registered");
        require(msg.value >= registrationFee, "Value must be greater than 0");

        uint change = msg.value - registrationFee;

        suppliers.push(msg.sender);

        // Actualizare pentru a utiliza transferFrom
        require(tokenContract.transferFrom(owner, msg.sender, registrationFee), "Token transfer failed");

        if (change != 0) {
            payable(msg.sender).transfer(uint(change));
        }
    }

    function registerProduct(string memory _name, uint _amount) public {
        require(supplierIsRegistered(), "Supplier is not registered");

        bytes4 _id = bytes4(keccak256(abi.encodePacked(msg.sender, _name)));
        require(!productExist(_id), "Product is already registered");

        products.push(Product(_id, _name, _amount, msg.sender));
    }

    modifier only_registered_supplier() {
        require(supplierIsRegistered(), "Supplier is not registered");
        _;
    }

    function updateRegistrationFee(uint _newRegistrationFee) external only_owner {
        registrationFee = _newRegistrationFee;
    }

    function getProductCount() public view returns (uint) {
        return products.length;
    }

    function getAllProducts() public view returns (Product[] memory) {
        return products;
    }

    function getProductsBySupplier(address _supplier) public view returns (Product[] memory) {
        Product[] memory supplierProducts;
        for (uint i = 0; i < products.length; i++) {
            if (products[i].owner == _supplier) {
                supplierProducts.push(products[i]);
            }
        }
        return supplierProducts;
    }

    function getProductById(bytes4 _id) public view returns (Product memory) {
        for (uint i = 0; i < products.length; i++) {
            if (products[i].id == _id) {
                return products[i];
            }
        }
        revert("Product not found");
    }

    function updateProductQuantity(bytes4 _id, int _quantity) external only_registered_supplier {
        for (uint i = 0; i < products.length; i++) {
            if (products[i].id == _id) {
                // Actualizare cantitate folosind transferFrom
                require(tokenContract.transferFrom(products[i].owner, msg.sender, uint(_quantity)), "Token transfer failed");
                products[i].volume = uint(int(products[i].volume) + _quantity);
            }
        }
    }

    // Eveniment pentru înregistrarea unui produs
    event ProductRegisteredEvent(bytes4 productId, string name, uint volume, address indexed owner);
}
