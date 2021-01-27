// SPDX-License-Identifier: MIT
pragma solidity ^0.7.3;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";

contract StartAppBank is ERC20 {

    constructor( ) ERC20("StartAppToken", "SAT") {

    }

    function getFreeTokens(uint256 value) public 
    {
        _mint(msg.sender,value);
    }
    
     function getFreeTokensToAddress(address _addr,uint256 value) public 
    {
        _mint(_addr, value);
    }

    function myBalance() public view returns (uint256)
    {
        return balanceOf(msg.sender);
    }
    
    function contribute(address receiver,uint256 contribution) internal
    {
        transfer(receiver,contribution);
        if(allowance(receiver,_msgSender())==0)
        {
            _approve(receiver,_msgSender(),contribution);
        }
        else
        {
            _approve(receiver,_msgSender(),contribution + allowance(receiver,_msgSender()));
        }
    }
    
    function removeAllowance(address spender) internal
    {
        decreaseAllowance(spender,allowance(_msgSender(),spender));
    }
    
    function refund(address financer,address manager) internal
    {
        transferFrom(manager,financer,allowance(manager,financer));
    }

}

contract BaseContract is StartAppBank{
    
    //Actors
    struct Manager {
        string name ;
        uint reputation;
    }
    
    struct Freelancer {
        string name ;
        uint reputation ;
        uint expertise;
    }
    
   struct Evaluator {
        string name ;
        uint reputation;
        uint expertise;
    }
    
    struct Financier {
        string name ;
    }
    
     struct FinancierAddressAndSum {
         address financierAddress;
         uint sumFinanced;
     }
     
    struct FreelancerAddressAndSum {
         address freelancerAddress;
         uint salaryForDeveloping;
         bool accepted;
     }
     
    struct Product {
        uint id;
        /*
         * phases
         * 0 : founding (after the sum was reached, moneyRaised = devlopingCost + rewardEval, go to phase 1)
         * 1 : freelancers signing up (manager can accept freelancers and decide to go to phase 2)
         * 2 : working, after developing the freelancer set the phase to 3 
         * 3 : manager decides if it's aceepted ( distribute money and send to phase 4), or rejected ( phase 5)
         * 4 : close
         * 5 : evaluated by Evaluator (accept and go to phase 4 or reject and go to 1) 
         *
         */
        uint productPhase;
        string description;
        // DEV 
        uint developingCost ;
        // REV
        uint rewardEval;
        // sponsored by financiers
        uint moneyRaised ;
        uint expertise;
        address managerAddress;
        address evaluatorAddress;
        // the money spent on the selected freelancers before all the dev cost is spent
        uint currentDevCost;
        
        uint freelancersNumber;
        mapping(uint => FreelancerAddressAndSum) freelancersAddressAndSum;
        mapping(address => uint) freelancerAddressToId;
        
        uint financiersNumber;
        mapping(uint => FinancierAddressAndSum) financiersAddressAndSum;
        mapping(address => uint) financiersAddressToId;
    }
    
    // all
    mapping(address => Manager) managers;
    mapping(address => Freelancer) public freelancers;
    mapping(address => Evaluator) evaluators;
    mapping(address => Financier) financiers;
    
    uint public totalProductsNumber = 0;
    mapping(uint => Product) public productList;
    
    // events  
    event NotifyManagerProductFinishDev(uint _productId, address _managerAddress);
    event NotifyEvaluator(uint _productId, address _evaluatorAddress);

    //constructor
    constructor(address _addr0,address _addr1,address _addr2, address _addr3,
    address _addr4, address _addr5 ) StartAppBank() {
        
        initStartApp( _addr0, _addr1,  _addr2, _addr3,  _addr4,  _addr5);
    }
    
    //functions
    
    function registerManager(string memory _name) public returns( string memory)
    {
        require( !isEmpty(_name), "Name cannot be null");
        require( isEmpty( managers[msg.sender].name ), "You have are already registered as a manager.");
         
        saveManager(msg.sender, _name);
        
        return "Manager registerd successfully";
    }
    
    /*
    * Function used internally by the registerManager function and also for the initializatation of the marketplace
    */
    function saveManager(address _managerAddress, string memory _name) private {
        Manager memory manager = Manager(_name, 5);
        managers[_managerAddress] = manager;
    }
    
    
      function registerFreelancer(string memory _name, uint _expertise) public
    {
        require( !isEmpty(_name), "Name cannot be null");
        require( _expertise > 0 && _expertise <4 , "Expertise value must be between 0 and 4.");
        require( isEmpty( freelancers[msg.sender].name ), "You have are already registered as a freelancer.");
         
        saveFreelancer(msg.sender, _name, _expertise);
    }
    
     /*
    * Function used internally by the registerFreelancer function and also for the initializatation of the marketplace
    */
    function saveFreelancer(address _freelancerAddress, string memory _name, uint _expertise) private {
       freelancers[_freelancerAddress].name = _name;
        freelancers[_freelancerAddress].expertise = _expertise;
        freelancers[_freelancerAddress].reputation = 5;
    }
    
    function registerEvaluator(string memory _name, uint _expertise) public
    {
        require(!isEmpty(_name), "Name cannot be null");
        require( _expertise > 0 && _expertise < 4  ,"Expertise must be between 0 and 4");
        require( isEmpty(evaluators[msg.sender].name ),"You have are already registered as an evaluator.");
         
        saveEvaluator(msg.sender, _name,_expertise);
    }
    
      /*
    * Function used internally by the registerEvaluator function and also for the initializatation of the marketplace
    */
    function saveEvaluator(address _evaluatorAddress, string memory _name, uint _expertise) private {
       evaluators[_evaluatorAddress].name = _name;
        evaluators[_evaluatorAddress].expertise = _expertise;
        evaluators[_evaluatorAddress].reputation = 5;
    }
    
     function registerFinancier(string memory _name) public
    {
        require( !isEmpty(_name), "Name cannot be null");
        require( isEmpty(financiers[msg.sender].name), "You have already registered as a financier.");
         
        saveFinancier(msg.sender, _name);
        
        // un finantator primeste 1000 de token-uri la inregistrare
        getFreeTokens(1000);
    }
    
   /*
    * Function used internally by the registerFinancier function and also for the initializatation of the marketplace
    */
    function saveFinancier(address _financierAddres, string memory _name) private {
         financiers[_financierAddres].name = _name;
    }
    
    // checks if a string is empty
    function isEmpty(string memory _stringToCheck) private pure returns (bool)
    {
       if( keccak256(bytes( _stringToCheck )) == keccak256(bytes("")))
       {
           return true;
       }
       return false;
    }
    
    // ** create and finance a product phase **
    
     function addNewProduct( string memory _productDesc, uint _developingCost,
     uint _rewardValue, uint _expertise) public {
         
         require ( !isEmpty(_productDesc), "Description can't be null");
         require ( !isEmpty(managers[msg.sender].name), "You have to be a manager to register a new product");
         require (_developingCost >= 0, "Developing cost needs to be a positive number!");
         require (_rewardValue >= 0, "Reward value needs to be a positive number!");
         require( _expertise > 0 && _expertise < 4  ,"Expertise must be between 0 and 4");
         
         saveProduct(msg.sender,_productDesc, _developingCost, _rewardValue, _expertise);
    }
    
    /*
    * Function used internally by the addNewProduct function and also for the initializatation of the marketplace
    */
    function saveProduct(address _managerAddress,string memory _productDesc, uint _developingCost,
     uint _rewardValue, uint _expertise ) private {
         totalProductsNumber++;
         productList[totalProductsNumber].id = totalProductsNumber;
         productList[totalProductsNumber].productPhase = 0;
         productList[totalProductsNumber].description = _productDesc;
         productList[totalProductsNumber].developingCost = _developingCost;
         productList[totalProductsNumber].rewardEval = _rewardValue;
         productList[totalProductsNumber].moneyRaised = 0;
         productList[totalProductsNumber].expertise = _expertise;
         productList[totalProductsNumber].managerAddress = _managerAddress;
         productList[totalProductsNumber].evaluatorAddress = address(0);
         productList[totalProductsNumber].currentDevCost = 0;
         productList[totalProductsNumber].freelancersNumber = 0;
         productList[totalProductsNumber].financiersNumber = 0 ;
    }
    
    function removeProduct( uint _productId) public
    {
        require( !isEmpty(productList[_productId].description), "The id of the product is not a valid one" );
        require ( msg.sender == productList[_productId].managerAddress, "You can only remove your own products");
        require ( productList[_productId].productPhase == 0, "You can no longer remove a product after it was financed");
        
       
        for(uint count = 0 ; count < productList[_productId].financiersNumber ; count++ )
      {

          address financierAddres = productList[_productId].financiersAddressAndSum[count].financierAddress;
          transfer(financierAddres,productList[_productId].financiersAddressAndSum[count].sumFinanced);
      }
        
        delete productList[_productId];
    }
    
    
    function financeAProduct(uint _productId,uint _sumProvided) public
    {
        require( !isEmpty(productList[_productId].description), "The id of the product is not a valid one" );
        require ( !isEmpty(financiers[msg.sender].name), "You have to be a finaincier.");
        require ( productList[_productId].productPhase == 0, "The funding phase alwready ended.");
        require ( _sumProvided > 0, "Sum financed should be bigger than 0.");
       
       uint neededSum=0;
       if(productList[_productId].moneyRaised + _sumProvided > productList[_productId].developingCost+productList[_productId].rewardEval)
       {
           neededSum=productList[_productId].developingCost+productList[_productId].rewardEval-productList[_productId].moneyRaised;
       }
       else
       {
           neededSum=_sumProvided;
       }
       
       contribute(productList[_productId].managerAddress,neededSum);
       

        uint financerIndex = productList[_productId].financiersAddressToId[msg.sender];
        
        if( productList[_productId].financiersAddressAndSum[financerIndex].financierAddress == msg.sender)
        {
            // if previous financier add to sum
            productList[_productId].financiersAddressAndSum[financerIndex].sumFinanced = productList[_productId].financiersAddressAndSum[financerIndex].sumFinanced + neededSum;
        }
        else
        {
            // if new finaincier 
            financerIndex = productList[_productId].financiersNumber;
            productList[_productId].financiersAddressAndSum[financerIndex] = FinancierAddressAndSum(msg.sender, neededSum);
            productList[_productId].financiersAddressToId[msg.sender] = financerIndex;
            productList[_productId].financiersNumber++;
            
        }
      productList[_productId].moneyRaised = productList[_productId].moneyRaised + neededSum;
      
      if(productList[_productId].moneyRaised == productList[_productId].developingCost + productList[_productId].rewardEval)
      { 
          productList[_productId].productPhase = 1;
      }

    }
    
     function removeFinanceFormProduct(uint _productId) public
    {
        require( !isEmpty(productList[_productId].description), "The id of the product is not a valid one" );
        require ( !isEmpty(financiers[msg.sender].name), "You have to be a finaincier.");
        require ( productList[_productId].productPhase == 0, "The funding phase already ended.");
 
        uint count = productList[_productId].financiersAddressToId[msg.sender];
   
        require(productList[_productId].financiersAddressAndSum[count].financierAddress == msg.sender, "You can remove financing only for the product you previously financed.");

        uint sumToSendBack = productList[_productId].financiersAddressAndSum[count].sumFinanced;
        refund(_msgSender(),productList[_productId].managerAddress);
        productList[_productId].moneyRaised = productList[_productId].moneyRaised - sumToSendBack; 
        
        delete productList[_productId].financiersAddressAndSum[count];
        delete productList[_productId].financiersAddressToId[msg.sender];
    
    }
    
    //** freelancers registration phase **
    
    function applyAsFreelancer(uint _wantedSalary, uint _productId) public
    {
        require( !isEmpty(productList[_productId].description), "The id of the product is not a valid one" );
        require ( !isEmpty(freelancers[msg.sender].name), "You have to be a Freelancer.");
        require ( productList[_productId].productPhase == 1, "The register phase for freelancers already ended.");
        require( _wantedSalary <= productList[_productId].developingCost , "Your wanted salary is too big." );
        require( freelancers[msg.sender].expertise == productList[_productId].expertise, "Your expertise does not match" );
       
       
        uint freelancerId = productList[_productId].freelancerAddressToId[msg.sender] ;
       
        require(productList[_productId].freelancersAddressAndSum[freelancerId].freelancerAddress != msg.sender,"You already registerd as a freelancer for this product.");
        
        
        freelancerId = productList[_productId].freelancersNumber;
        productList[_productId].freelancersAddressAndSum[freelancerId] = FreelancerAddressAndSum(msg.sender, _wantedSalary ,false);
        productList[_productId].freelancerAddressToId[msg.sender] = freelancerId;
        productList[_productId].freelancersNumber++;
    }
    
         function applyAsEvaluator(uint _productId) public
    {
        require( !isEmpty(productList[_productId].description), "The id of the product is not a valid one" );
        require ( !isEmpty(evaluators[msg.sender].name), "You have to be an evaluator.");
        require ( productList[_productId].productPhase == 1, "The register phase for evaluators is not open yet.");
        require ( productList[_productId].evaluatorAddress == address(0), "This product already has an evaluator.");
        require( evaluators[msg.sender].expertise == productList[_productId].expertise , "Your expertise does not match." );
        
        productList[_productId].evaluatorAddress = msg.sender;
        
         if( productList[_productId].currentDevCost ==  productList[_productId].developingCost
               && productList[_productId].evaluatorAddress != address(0))
               {
                    productList[_productId].productPhase = 2;
               }
    }
    
    // ** developing phase **
    
    function selectFreelancersForProduct(uint _productId, address _freelancerAddress) public
    {
        require( !isEmpty(productList[_productId].description), "The id of the product is not a valid one" );
        require ( !isEmpty(managers[msg.sender].name), "You have to be a manager.");
        require( productList[_productId].managerAddress == msg.sender, "You can choose freelancers only for your own products." );
        require ( productList[_productId].productPhase == 1, "The product is not in the right phase (register freelancers phase).");
      
        uint freelancerId = productList[_productId].freelancerAddressToId[_freelancerAddress];
           require(productList[_productId].freelancersAddressAndSum[freelancerId].freelancerAddress == _freelancerAddress, "Freelancer not found.");
            require (productList[_productId].freelancersAddressAndSum[freelancerId].salaryForDeveloping <= productList[_productId].developingCost - productList[_productId].currentDevCost, "Salary of the freelancer to big." ); 
            require (productList[_productId].freelancersAddressAndSum[freelancerId].accepted != true, "Freelancer already accepted." ); 
             
              
               productList[_productId].freelancersAddressAndSum[freelancerId].accepted = true;
               productList[_productId].currentDevCost += productList[_productId].freelancersAddressAndSum[freelancerId].salaryForDeveloping;
              
               if( productList[_productId].currentDevCost ==  productList[_productId].developingCost
               && productList[_productId].evaluatorAddress != address(0))
               {
                    productList[_productId].productPhase = 2;
               }
    }
    
     function removeFreelancersForProduct(uint _productId, address _freelancerAddress) public
    {
        require( !isEmpty(productList[_productId].description), "The id of the product is not a valid one" );
        require ( !isEmpty(managers[msg.sender].name), "You have to be a manager.");
        require( productList[_productId].managerAddress == msg.sender, "You can remove freelancers only for your own products." );
        require ( productList[_productId].productPhase == 1, "The product is not in the right phase(register freelancers phase).");
              
        uint count = productList[_productId].freelancerAddressToId[_freelancerAddress];
        require(productList[_productId].freelancersAddressAndSum[count].freelancerAddress == _freelancerAddress,"Freelancer to remove not found.");
        require (productList[_productId].freelancersAddressAndSum[count].accepted == true, "Freelancer was not accepted so it cannot be removed." ); 
             
        productList[_productId].freelancersAddressAndSum[count].accepted =  false;
        productList[_productId].currentDevCost =  productList[_productId].currentDevCost - productList[_productId].freelancersAddressAndSum[count].salaryForDeveloping;
    }
    
    function productFinishedDeveloping(uint _productId) public
    {
        require( !isEmpty(productList[_productId].description), "The id of the product is not a valid one" );
        require ( !isEmpty(freelancers[msg.sender].name), "You have to be a Freelancer.");
        require ( productList[_productId].productPhase == 2, "The product is not in the developing phase).");
        
        uint count = productList[_productId].freelancerAddressToId[msg.sender];
        
        require( productList[_productId].freelancersAddressAndSum[count].freelancerAddress == msg.sender,"You are not a freelancer for this product so you can end the development phase.");
        require ( productList[_productId].freelancersAddressAndSum[count].accepted == true, "You are not an accepted freelancer so you can finialize the development.");
            
        productList[_productId].productPhase = 3;
                
        //Emit an event
        emit NotifyManagerProductFinishDev(_productId, productList[_productId].managerAddress);

    }
    
    /** evaluating phase**/
    
    
    function managerEvaluation(uint _productId, bool _managerResponse) public
    {
        require( !isEmpty(productList[_productId].description), "The id of the product is not a valid one." );
        require ( !isEmpty(managers[msg.sender].name), "You have to be a manager.");
        require ( productList[_productId].productPhase == 3, "The product is not in the evaluation by manager phase).");
        require ( productList[_productId].managerAddress == msg.sender, "You are not the manager of this product.).");
        
        if(_managerResponse)
        {
            //product accepted -> give salary and reputation to freelancers
            for(uint count= 0; count < productList[_productId].freelancersNumber;count++)
            {

                if(productList[_productId].freelancersAddressAndSum[count].accepted)
                    {
                    address freelancer=productList[_productId].freelancersAddressAndSum[count].freelancerAddress;
                    uint reward = productList[_productId].freelancersAddressAndSum[count].salaryForDeveloping;
                    transfer(freelancer,reward);
                     if(freelancers[productList[_productId].freelancersAddressAndSum[count].freelancerAddress].reputation < 10)
                        {
                         freelancers[productList[_productId].freelancersAddressAndSum[count].freelancerAddress].reputation++;
                        }
                    productList[_productId].freelancersAddressAndSum[count].accepted = false;
                    }
            
              
            }
            
            // rev sum is already in manager's account
                 
            // increase rep for manager
            if( managers[productList[_productId].managerAddress].reputation <10)
            {
                 managers[productList[_productId].managerAddress].reputation++;
            }
               
            //end product
            productList[_productId].productPhase = 4;
        }
        else {
            // product rejected by manager
             productList[_productId].productPhase = 5;
             
              //Emit an event
                emit NotifyEvaluator(_productId, productList[_productId].evaluatorAddress);
        }
    }
    
    // ** arbitration phase**
    
     function evaluatorArbitration(uint _productId, bool _evaluatorResponse) public
    {
        require( !isEmpty(productList[_productId].description), "The id of the product is not a valid one." );
        require ( !isEmpty(evaluators[msg.sender].name), "You have to be an evaluator.");
        require ( productList[_productId].productPhase == 5, "The product is not in the arbitration phase).");
        require ( productList[_productId].evaluatorAddress == msg.sender, "You are not the evaluator of this product.).");
         
        if(_evaluatorResponse)
        {
            // product accepted by evaluator
            
            // money send back to freelancer and rep++
              for(uint count= 0; count < productList[_productId].freelancersNumber;count++)
            {

                if(productList[_productId].freelancersAddressAndSum[count].accepted)
                    {
                    address freelancer=productList[_productId].freelancersAddressAndSum[count].freelancerAddress;
                    uint reward=productList[_productId].freelancersAddressAndSum[count].salaryForDeveloping;
                    _transfer(productList[_productId].managerAddress,freelancer,reward);
                   
                    // increase rep for freelancers
                     if(freelancers[productList[_productId].freelancersAddressAndSum[count].freelancerAddress].reputation < 10)
                        {
                        freelancers[productList[_productId].freelancersAddressAndSum[count].freelancerAddress].reputation++;
                        }
                    }
                productList[_productId].freelancersAddressAndSum[count].accepted = false;
            }
            
            //decrement manager reputation 
             if( managers[productList[_productId].managerAddress].reputation > 0)
            {
                 managers[productList[_productId].managerAddress].reputation--;
            }
            
            // product finalized
            productList[_productId].productPhase = 4;
            
        }
        else
        {
            // product rejected by evaluator
            
            // decrement freelancer reputation and delete old team
             for(uint count= 0; count < productList[_productId].freelancersNumber;count++)
            {
                 if(productList[_productId].freelancersAddressAndSum[count].accepted)
                    {
                    productList[_productId].freelancersAddressAndSum[count].accepted = false;

                     if(freelancers[productList[_productId].freelancersAddressAndSum[count].freelancerAddress].reputation > 0)
                    {
                         freelancers[productList[_productId].freelancersAddressAndSum[count].freelancerAddress].reputation--;
                    }
                }
               delete productList[_productId].freelancersAddressAndSum[count];
            }
            
             // delete old team and change phase = 1 
            productList[_productId].freelancersNumber = 0;
            productList[_productId].productPhase = 1;
             
        }
             
         // get REV sum for arbitration
         _transfer(productList[_productId].managerAddress,productList[_productId].evaluatorAddress,productList[_productId].rewardEval);
    }
    
    function isManager(address _addr) public view returns(bool)
    {
        if(!isEmpty(managers[_addr].name))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    function isFreelancer(address _addr) public view returns(bool)
    {
        if(!isEmpty(freelancers[_addr].name))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    function isEvaluator(address _addr) public view returns(bool)
    {
        if(!isEmpty(evaluators[_addr].name))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    function isFinancier(address _addr) public view returns(bool)
    {
        if(!isEmpty(financiers[_addr].name))
        {
            return true;
        }
        else
        {
            return false;
        }
    }
    
    function getProductsForFreelancer() public view returns(uint[] memory)
    {
        require (!isEmpty(freelancers[msg.sender].name), "You have to be a freelancer.");
        
        uint[] memory productIdList = new uint[](totalProductsNumber+1);
        uint index = 0;
        for(uint productIdCount = 1; productIdCount <= totalProductsNumber;productIdCount++)
        {
           uint freelancerCount = productList[productIdCount].freelancerAddressToId[msg.sender];
            
            if(productList[productIdCount].freelancersAddressAndSum[freelancerCount].freelancerAddress == msg.sender
                && productList[productIdCount].freelancersAddressAndSum[freelancerCount].accepted == true)
                {
                    productIdList[index++] = productIdCount;
                }
        }
        
        return productIdList;
    }
    
     function getProductsForFinancier() public view returns(uint[] memory)
    {
        require (!isEmpty(financiers[msg.sender].name), "You have to be a financier.");
        
        uint[] memory productIdList = new uint[](totalProductsNumber);
        uint index = 0;
        for(uint productIdCount = 1; productIdCount <= totalProductsNumber;productIdCount++)
        {
            if(productList[productIdCount].productPhase != 0)
            {
                continue;
            }
           uint financierCount = productList[productIdCount].financiersAddressToId[msg.sender];
            
            if(productList[productIdCount].financiersAddressAndSum[financierCount].financierAddress == msg.sender)
            {
                productIdList[index++] = productIdCount;
            }
        }
        
        return productIdList;
    }
    
    /**
     * function returns the details of the freelancer that is at the position given as parameter 
     * in the freelancers "vector" belonging to the product with the id given as param
   */
   function getFreelancerForProduct(uint _productId, uint _position) public view
         returns(address,uint,bool, uint, string memory)
    {
        require (!isEmpty(managers[msg.sender].name), "You have to be a manager.");
        
      return (productList[_productId].freelancersAddressAndSum[_position].freelancerAddress,
                productList[_productId].freelancersAddressAndSum[_position].salaryForDeveloping,
                productList[_productId].freelancersAddressAndSum[_position].accepted,
                freelancers[productList[_productId].freelancersAddressAndSum[_position].freelancerAddress].reputation,
                freelancers[productList[_productId].freelancersAddressAndSum[_position].freelancerAddress].name
                );
    }
    
    /*
     * Initalizare marketplace
     * 0 - manager
     * 1 - financier1
     * 2 - financier2
     * 3 - evaluator
     * 4 - freelancer2
     * 5 - freelancer2 
     *
     */
    function initStartApp(address _addr0,address _addr1,address _addr2,
    address _addr3,address _addr4, address _addr5) public 
    {
  
        uint expertise = 1;
        string memory name = "ManagerName1";
        saveManager( _addr0, name );
        
        name = "Financier1";
        saveFinancier(_addr1, name);
        getFreeTokensToAddress(_addr1, 1000);
        
        name = "Financier2";
        saveFinancier(_addr2, name);
        getFreeTokensToAddress(_addr2, 2000);
        
        name = "EvaluatorName";
        saveEvaluator( _addr3, name, expertise);
        
        name = "Freelancer1";
        saveFreelancer(_addr4, name, expertise);
        
        name = "Freelancer2";
        saveFreelancer(_addr5, name, expertise);
        
        string memory productDescription = "ProductDescription";
        uint cost = 100;
        saveProduct( _addr0 ,productDescription, cost, cost, expertise);
    }
    
      function getReputation() public view returns (uint)
      {
          if(isFinancier(msg.sender))
          {
              return 11;
          }
         
         if(isEvaluator(msg.sender))
         {
             return evaluators[msg.sender].reputation;
         }
        
         if(isManager(msg.sender))
         {
             return managers[msg.sender].reputation;
         }
         
         return freelancers[msg.sender].reputation;
         
      }
      
      function testEventManager(uint projectId) public
    {
        emit NotifyManagerProductFinishDev(projectId,_msgSender());
    }
    
    function testEventEvaluator(uint projectId) public
    {
        emit NotifyEvaluator(projectId,_msgSender());
    }
}
