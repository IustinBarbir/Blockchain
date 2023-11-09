// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.22;

import "./ProductIdentification.sol";

contract ProductStore {
    address public owner;
    ProductIdentification public identificationContract;
    address public identificationContractAddress;

    struct ProductInStore {
        uint productId;
        uint quantity;
        uint unitPrice;
    }

    mapping(address => mapping(uint => ProductInStore)) public productsInStore;
    uint public productCount;
    mapping(address => bool) public authorizedDeposits;

    event ProductAddedToStore(address indexed producerAddress, uint productId, uint quantity, uint unitPrice);
    event ProductPurchased(address indexed buyer, uint productId, uint quantity, uint totalPrice);

    // Initializarea proprietarului si al adresei contractului ProductIdentification de catre constructor
    constructor(address _depositAddress, address _identificationContractAddress) {
        owner = msg.sender;
        depositAddress = _depositAddress;
        identificationContract = ProductIdentification(_identificationContractAddress);
        identificationContractAddress = _identificationContractAddress;
    }

    function setDepositAddress(address _newDepositAddress) public onlyOwner {
        depositAddress = _newDepositAddress;
    }

    function addAuthorizedDeposit(address _deposit) public onlyOwner {
        authorizedDeposits[_deposit] = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier onlyRegisteredProducer() {
        require(identificationContract.isProducerRegistered(msg.sender), "Producer is not registered");
        _;
    }

    modifier productExists(uint _productId) {
        require(_productId < identificationContract.productCount(), "Product with this ID does not exist");
        _;
    }

    // Adaugare produse in magazin
    function addProductToStore(uint _productId, uint _quantity, uint _unitPrice) public onlyOwner productExists(_productId) {
        productsInStore[msg.sender][_productId] = ProductInStore(_productId, _quantity, _unitPrice);
        emit ProductAddedToStore(msg.sender, _productId, _quantity, _unitPrice);
    }

    // Verificarea disponibilitatii si a pretului unui produs
    function checkProductAvailability(uint _productId) public view productExists(_productId) returns (uint, uint) {
        ProductInStore storage productInStore = productsInStore[msg.sender][_productId];
        if (productInStore.productId == _productId) {
            return (productInStore.quantity, productInStore.unitPrice);
        }
        return (0, 0);
    }

    // Achizitionarea unui produs
    function purchaseProduct(uint _productId, uint _quantity) public payable productExists(_productId) {
        ProductInStore storage productInStore = productsInStore[msg.sender][_productId];
        require(productInStore.productId == _productId, "Product not available in the store");
        require(productInStore.quantity >= _quantity, "Insufficient quantity in the store");
        require(msg.value >= _quantity * productInStore.unitPrice, "Insufficient payment for the purchase");

        // Transfera jumatate din pretul total catre producator
        uint totalPrice = _quantity * productInStore.unitPrice;
        (address producerAddress, , ) = identificationContract.getProductInfo(_productId);
        address payable producerPayable = payable(producerAddress);
        producerPayable.transfer(totalPrice / 2);


        // Actualizarea cantitatii disponibile in magazin
        productInStore.quantity -= _quantity;

        emit ProductPurchased(msg.sender, _productId, _quantity, totalPrice);
    }
}
