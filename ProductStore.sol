// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.22;

import "./ProductIdentification.sol";

// Definire contract ProductStore
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

    event ProductAddedToStore(address indexed producerAddress, uint productId, uint quantity, uint unitPrice);
    event ProductPurchased(address indexed buyer, uint productId, uint quantity, uint totalPrice);

    // Constructorul contractului ProductStore inițializează proprietarul și adresa contractului de identificare a produselor.
    constructor(address _identificationContractAddress) {
        owner = msg.sender;
        identificationContract = ProductIdentification(_identificationContractAddress);
        identificationContractAddress = _identificationContractAddress;
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

    // Funcția permite proprietarului să adauge produse în magazin.
    function addProductToStore(uint _productId, uint _quantity, uint _unitPrice) public onlyOwner productExists(_productId) {
        productsInStore[msg.sender][_productId] = ProductInStore(_productId, _quantity, _unitPrice);
        emit ProductAddedToStore(msg.sender, _productId, _quantity, _unitPrice);
    }

    // Funcția permite unui client să verifice disponibilitatea și prețul unui produs în magazin.
    function checkProductAvailability(uint _productId) public view productExists(_productId) returns (uint, uint) {
        ProductInStore storage productInStore = productsInStore[msg.sender][_productId];
        if (productInStore.productId == _productId) {
            return (productInStore.quantity, productInStore.unitPrice);
        }
        return (0, 0);
    }

    // Funcția permite unui client să achiziționeze produse din magazin.
    function purchaseProduct(uint _productId, uint _quantity) public payable productExists(_productId) {
        ProductInStore storage productInStore = productsInStore[msg.sender][_productId];
        require(productInStore.productId == _productId, "Product not available in the store");
        require(productInStore.quantity >= _quantity, "Insufficient quantity in the store");
        require(msg.value >= _quantity * productInStore.unitPrice, "Insufficient payment for the purchase");

        // Transferă jumătate din prețul total producătorului
        uint totalPrice = _quantity * productInStore.unitPrice;
        (address producerAddress, , ) = identificationContract.getProductInfo(_productId);
        address payable producerPayable = payable(producerAddress);
        producerPayable.transfer(totalPrice / 2);


        // Actualizează cantitatea disponibilă în magazin
        productInStore.quantity -= _quantity;

        emit ProductPurchased(msg.sender, _productId, _quantity, totalPrice);
    }
}
