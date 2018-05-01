pragma solidity ^0.4.18;

import "./ERC20Interface.sol";
import "./Utils.sol";
import "./Withdrawable.sol";
import "./SellContracts.sol";
import "./SellContract.sol";
import "./BuyContracts.sol";
import "./BuyContract.sol";
import "./Ownable.sol";
import "./RefundVault.sol";
import "./Withdrawable.sol";

contract TradeEngine is Ownable, Withdrawable, Utils {
    
    using SafeMath for uint256;

    //ERC20 internal token;
    ERC20[] internal tokenList;
    SellContracts internal sellContracts;
    BuyContracts  internal buyContracts;
    address internal wallet;
    
    function addBuyContract   (ERC20 _token, uint _baseBuyRate, uint _qtyToBuy, address _buyer) onlyOwner public {
        
        buyContracts.addBuyContract(_token, new BuyContract(_token,  _baseBuyRate,  _qtyToBuy,  _buyer));
        
    }
    
    function addSellContract   (ERC20 _token, uint _baseSellRate, uint _qtyToSell, address _seller) onlyOwner public {
        
        sellContracts.addSellContract(_token, new SellContract(_token,  _baseSellRate,  _qtyToSell,  _seller));
        
    }
    
    constructor (address _wallet) public Ownable() {
        
        require(_wallet != address(0));
        wallet = _wallet;
       
  }

    function DemandSupplyMatchingTriggeredBySell (ERC20 _token) public view returns(bool,BuyContract,SellContract) {
        
        
        SellContract lastSellContract = sellContracts.getLastContract(_token);
        BuyContract  dummyBuyContract;
        
        for (uint i = 0; i <= buyContracts.getNumberOfContracts(_token) ; i++) {
             
                BuyContract buyContract = buyContracts.getBuyContract(_token,i);
                if (lastSellContract.qtyToSell() == buyContract.qtyToBuy() ) {
                    return (true,buyContract,lastSellContract);
                    break;
                }
            }
        return (false,dummyBuyContract,lastSellContract);
        
    }
    
    function DemandSupplyMatchingTriggeredByBuy (ERC20 _token) public view returns(bool,BuyContract,SellContract) {
        
        
        BuyContract lastBuyContract = buyContracts.getLastContract(_token);
        SellContract  dummySellContract;
        
        for (uint i = 0; i <= sellContracts.getNumberOfContracts(_token) ; i++) {
             
                SellContract sellContract = sellContracts.getSellContract(_token,i);
                if (lastBuyContract.qtyToBuy() == sellContract.qtyToSell() ) {
                    return (true,lastBuyContract,sellContract);
                    break;
                }
            }
        return (false,lastBuyContract, dummySellContract);
        
    }
    
    function TryTradeSell(ERC20 token) internal  {
        
        bool matched;
        BuyContract buyContract;
        SellContract sellContract;
        ( matched, buyContract,sellContract ) = DemandSupplyMatchingTriggeredBySell(token);
        
        if(matched)
        {
            FinalizeTrade(buyContract,sellContract,token);
        }
        
    }
    
    function TryTradeBuy(ERC20 token) internal  {
        
        bool matched;
        BuyContract buyContract;
        SellContract sellContract;
        ( matched, buyContract,sellContract ) = DemandSupplyMatchingTriggeredByBuy(token);
        
        if(matched)
        {
            FinalizeTrade(buyContract,sellContract,token);
        }
        
    }
    
    function FinalizeTrade(BuyContract buyContract,SellContract sellContract,ERC20 token) internal {
        
        buyContract.finalizeTrade(true);
        sellContract.finalizeTransaction( buyContract.getBuyer());
        
        //now remove buy & sell contract
        sellContracts.remove(token, sellContract);
        buyContracts.remove(token, buyContract );
    }
    
    function AddBuyContract(ERC20 token, BuyContract buyContract) public {
        
        buyContracts.addBuyContract(token, buyContract);
        TryTradeBuy(token);
        
    }
    
    function addSellContractContract(ERC20 token, SellContract sellContract) public {
        
        sellContracts.addSellContract(token, sellContract);
        TryTradeSell(token);
        
    }

}
