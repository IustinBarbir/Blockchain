// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0 <=0.8.21;

contract ProductDeposit {
    address public owner;
    uint public depositFee;  // Taxa de depozit pe unitate de volum
    uint public maxVolume;  // Volumul maxim al depozitului
    
    struct Product {
        uint availableVolume;
    }
    
    struct Store {
        address storeAddress;
        bool isAuthorized;
    }
    
    mapping(bytes32 => Product) public products;
    mapping(address => Store) public authorizedStores;
    
    constructor(uint _depositFee, uint _maxVolume) {
        owner = msg.sender;
        depositFee = _depositFee;
        maxVolume = _maxVolume;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Doar proprietarul poate apela aceasta functie");
        _;
    }
    
    modifier onlyAuthorizedStore(bytes32 productId) {
        require(authorizedStores[msg.sender].isAuthorized, "Doar magazinele autorizate pot apela aceasta functie");
        require(products[productId].availableVolume > 0, "Produsul nu exista sau stocul este epuizat");
        _;
    }
    
    function setDepositFee(uint _newFee) public onlyOwner {
        depositFee = _newFee;
    }
    
    function setMaxVolume(uint _newMaxVolume) public onlyOwner {
        maxVolume = _newMaxVolume;
    }
    
    function addProduct(bytes32 productId, uint initialVolume) public onlyOwner {
        require(products[productId].availableVolume == 0, "Produsul exista deja");
        require(initialVolume <= maxVolume, "Volumul initial depaseste volumul maxim");
        products[productId].availableVolume = initialVolume;
    }
    
    function authorizeStore(address storeAddress) public onlyOwner {
        authorizedStores[storeAddress] = Store(storeAddress, true);
    }
    
    function deauthorizeStore(address storeAddress) public onlyOwner {
        authorizedStores[storeAddress] = Store(storeAddress, false);
    }
    
    function depositProduct(bytes32 productId, uint depositVolume) public payable {
        require(msg.value == depositFee * depositVolume, "Suma depusa nu corespunde taxei");
        require(products[productId].availableVolume + depositVolume <= maxVolume, "Depunerea depaseste volumul maxim");
        
        products[productId].availableVolume += depositVolume;
    }
    
    function withdrawProduct(bytes32 productId, uint withdrawVolume) public onlyAuthorizedStore(productId) {
        require(withdrawVolume <= products[productId].availableVolume, "Nu exista suficient volum pentru retragere");
        products[productId].availableVolume -= withdrawVolume;
    }
}