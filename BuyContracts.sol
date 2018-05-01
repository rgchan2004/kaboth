pragma solidity ^0.4.18;


import "./ERC20Interface.sol";
import "./Utils.sol";
import "./BuyContract.sol";
import "./Withdrawable.sol";

contract BuyContracts is Withdrawable , Utils {

    struct TokenData {
        bool listed;  // was added to reserve
        bool enabled; // whether trade is enabled
    }

	struct ListOfBuyContracts {
	    bool enabled; // whether trade is allowed
		BuyContract[] listOfBuyContracts;
	}

    ERC20[] internal listedTokens;
    mapping(address=>TokenData) internal tokenData;
	
	mapping(address=>ListOfBuyContracts) public tokenBuyContracts;


    function addToken(ERC20 token) public onlyAdmin {

        require(!tokenData[token].listed);
        tokenData[token].listed = true;
        listedTokens.push(token);
        setDecimals(token);
    }

    
    function enableTokenTrade(ERC20 token) public onlyAdmin {
        require(tokenData[token].listed);
        tokenData[token].enabled = true;
    }

    function disableTokenTrade(ERC20 token) public onlyAlerter {
        require(tokenData[token].listed);
        tokenData[token].enabled = false;
    }
    
    function addBuyContract(ERC20 token, BuyContract _buyContract) public {
        require(tokenData[token].listed);
        require(tokenData[token].enabled);
        tokenBuyContracts[token].listOfBuyContracts.push(_buyContract);
        
    }
    
    function getNumberOfContracts(ERC20 token) public onlyAdmin view returns (uint) 
    {
        return  uint(tokenBuyContracts[token].listOfBuyContracts.length - 1);
    }
    
    function getBuyContract(ERC20 token,uint index) public onlyAdmin view returns (BuyContract) 
    {
        return tokenBuyContracts[token].listOfBuyContracts[index];
    }
    
    function getLastContract(ERC20 token) public onlyAdmin view returns (BuyContract) 
    {
        return tokenBuyContracts[token].listOfBuyContracts[tokenBuyContracts[token].listOfBuyContracts.length - 1];
    }
    
    function remove(ERC20 token, BuyContract buyContract) public
    {
        //search index 
        uint i;
        
        for (i = 0; i<tokenBuyContracts[token].listOfBuyContracts.length; i++){
            if(tokenBuyContracts[token].listOfBuyContracts[i] == buyContract)
            {
                break;
            }
        }
        
        if(i < tokenBuyContracts[token].listOfBuyContracts.length ) {

            for (uint j = i; j<tokenBuyContracts[token].listOfBuyContracts.length-1; j++) {
                tokenBuyContracts[token].listOfBuyContracts[j] = tokenBuyContracts[token].listOfBuyContracts[j+1];
            }
            delete tokenBuyContracts[token].listOfBuyContracts[tokenBuyContracts[token].listOfBuyContracts.length - 1];
            tokenBuyContracts[token].listOfBuyContracts.length--;
        }
        
    }
}
