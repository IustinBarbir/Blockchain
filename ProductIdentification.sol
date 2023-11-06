// SPDX-License-Identifier: MIT

pragma solidity >=0.8.0 <=0.8.21;

//definitie contract
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
    
    // Constructorul contractului inițializează proprietarul și taxa de înregistrare.
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
    
    // Funcția permite proprietarului să modifice taxa de înregistrare.
    function setRegistrationFee(uint _fee) public onlyOwner {
        registrationFee = _fee;
    }
    
    // Funcția permite înregistrarea unui producător și percepe taxa de înregistrare.
    function registerProducer(string memory _name) public payable {
        require(msg.value >= registrationFee, "Insufficient registration fee");
        require(!producers[msg.sender].isRegistered, "Producer is already registered");
        
        producers[msg.sender] = Producer(true, _name);
        emit ProducerRegistered(msg.sender, _name);
    }
    
    // Funcția permite înregistrarea unui produs de către un producător înregistrat.
    function registerProduct(string memory _name, uint _volume) public onlyRegisteredProducer {
        require(_volume > 0, "Volume must be greater than 0");
        
        products[productCount] = Product(msg.sender, _name, _volume);
        emit ProductRegistered(productCount, msg.sender, _name, _volume);
        productCount++;
    }
    
    // Funcția verifică dacă un producător este înregistrat pe baza adresei sale.
    function isProducerRegistered(address _producerAddress) public view returns (bool) {
        return producers[_producerAddress].isRegistered;
    }
    
    // Funcția returnează informații despre un produs pe baza id-ului acestuia.
    function getProductInfo(uint _productId) public view returns (address, string memory, uint) {
        require(_productId < productCount, "Product with this ID does not exist");
        
        Product storage product = products[_productId];
        return (product.producerAddress, product.name, product.volume);
    }
}
