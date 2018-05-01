pragma solidity ^0.4.18;


import "./ERC20Interface.sol";
import "./Utils.sol";
import "./SellContract.sol";
import "./Withdrawable.sol";

contract SellContracts is Withdrawable , Utils {

    struct TokenData {
        bool listed;  // was added to reserve
        bool enabled; // whether trade is enabled
    }

	struct ListOfSellContracts {
	    bool enabled; // whether trade is allowed
		SellContract[] listOfSellContracts;
	}

    ERC20[] internal listedTokens;
    mapping(address=>TokenData) internal tokenData;
	
	mapping(address=>ListOfSellContracts) public tokenSellContracts;


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
    
    function addSellContract(ERC20 token, SellContract _sellContract) public {
        require(tokenData[token].listed);
        require(tokenData[token].enabled);
        tokenSellContracts[token].listOfSellContracts.push(_sellContract);
    }
    
    function getLastContract(ERC20 token) public view returns (SellContract) 
    {
        uint lastContractNo = tokenSellContracts[token].listOfSellContracts.length - 1;
        return  tokenSellContracts[token].listOfSellContracts[ lastContractNo ];
    }
    
    function getSellContract(ERC20 token,uint index) public onlyAdmin view returns (SellContract) 
    {
        return  tokenSellContracts[token].listOfSellContracts[ index ];
    }
    
    function getNumberOfContracts(ERC20 token) public onlyAdmin view returns (uint) 
    {
        return  uint(tokenSellContracts[token].listOfSellContracts.length - 1);
    }
    
    function remove(ERC20 token, SellContract sellContract) public
    {
        //search index 
        uint i;
        
        for (i = 0; i<tokenSellContracts[token].listOfSellContracts.length; i++){
            if(tokenSellContracts[token].listOfSellContracts[i] == sellContract)
            {
                break;
            }
        }
        
        if(i < tokenSellContracts[token].listOfSellContracts.length ) {

            for (uint j = i; j<tokenSellContracts[token].listOfSellContracts.length-1; j++) {
                tokenSellContracts[token].listOfSellContracts[j] = tokenSellContracts[token].listOfSellContracts[j+1];
            }
            delete tokenSellContracts[token].listOfSellContracts[tokenSellContracts[token].listOfSellContracts.length - 1];
            tokenSellContracts[token].listOfSellContracts.length--;
        }
        
    }

}

