// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.21;

contract ProductIdentification {
    address public owner;
    uint public registrationFee;
    
    struct Producer {
        bool isRegistered;
        string name;
    }
    
    struct Product {
        address producerAddress;
        string name;
        uint volume;
    }
    
    mapping(address => Producer) public producers;
    mapping(uint => Product) public products;
    uint public productCount;
    
    event ProducerRegistered(address producerAddress, string name);
    event ProductRegistered(uint productId, address producerAddress, string name, uint volume);
    
    // Initializarea proprietarului si a taxei de inregistrare de catre constructorul contractului
    constructor(uint _registrationFee) {
        owner = msg.sender;
        registrationFee = _registrationFee;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    modifier onlyRegisteredProducer() {
        require(producers[msg.sender].isRegistered, "Producer is not registered");
        _;
    }
    
    // Modificarea taxei de inregistrare de catre proprietar
    function setRegistrationFee(uint _fee) public onlyOwner {
        registrationFee = _fee;
    }
    
    // Inregistrarea unui nou producator si taxa de inscriere
    function registerProducer(string memory _name) public payable {
        require(msg.value >= registrationFee, "Insufficient registration fee");
        require(!producers[msg.sender].isRegistered, "Producer is already registered");
        
        producers[msg.sender] = Producer(true, _name);
        emit ProducerRegistered(msg.sender, _name);
    }
    
    // Inregistrarea unui nou produs de catre un producator inregistrat
    function registerProduct(string memory _name, uint _volume) public onlyRegisteredProducer {
        require(_volume > 0, "Volume must be greater than 0");
        
        products[productCount] = Product(msg.sender, _name, _volume);
        emit ProductRegistered(productCount, msg.sender, _name, _volume);
        productCount++;
    }
    
    // Verificare pe baza adresei daca un producator este inregistrat
    function isProducerRegistered(address _producerAddress) public view returns (bool) {
        return producers[_producerAddress].isRegistered;
    }
    
    // Returnarea informatiilor depsre un produs pe baza id-ului
    function getProductInfo(uint _productId) public view returns (address, string memory, uint) {
        require(_productId < productCount, "Product with this ID does not exist");
        
        Product storage product = products[_productId];
        return (product.producerAddress, product.name, product.volume);
    }
}
