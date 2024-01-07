// SPDX-License-Identifier: MIT
pragma solidity 0.8;
contract Petshop{

address payable private owner;
    struct Pets{
        string animal;
        uint age;
        uint256 price;
        bool isAdopted;
        address owner;
    }
    uint256 count;
    mapping(uint256 => Pets) private _pets; //for each pet that is added we store the id
    // and information here
    mapping(uint256 => address) private ownerOf;
    event PetAdded(
        uint256 petId
    );
    event Adopted(
        uint256 petId,
        address indexed owner
    );

    bool locked;

    constructor(){
      owner = payable(msg.sender);
    }

    modifier onlyOwner(){
        require(owner == msg.sender, "Not owner");
        _;
    }

    modifier lock(){
    require(!locked, "ReentrancyGuard: reentrant call");
    locked = true;
    _;
    locked = false;
}


    function addPet(string memory breed, uint256 age, uint256 price) public onlyOwner{
        uint256 petId = count++;
        _pets[petId] = Pets(breed, age, price, false, owner);
        emit PetAdded(petId);
    }

    function adopt(uint256 petId) public payable {
         Pets storage pet = _pets[petId];
        require(msg.value == pet.price, "Insufficient fund to purchase");
        require(petId <= count, "Invalid id");
        require(!pet.isAdopted, "Already adopted");
        pet.isAdopted = true;
        pet.owner = msg.sender;
        ownerOf[petId] = msg.sender;
        emit Adopted(petId, msg.sender);
    }
    function getPetInfo(uint256 petId) public view returns(string memory, uint256, bool, address){
       require(petId < count, "Invalid id");
       Pets storage pet = _pets[petId];
       return (pet.animal, pet.age, pet.isAdopted, pet.owner);
    }

    function withdraw() public onlyOwner lock{
      require(address(this).balance > 0, "Insuffiencient contract balance");
      payable(owner).transfer(address(this).balance);
    }
}