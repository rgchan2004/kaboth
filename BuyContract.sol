pragma solidity ^0.4.18;

import "./ERC20Interface.sol";
import "./Utils.sol";
import "./SafeMath.sol";
import "./Withdrawable.sol";
import "./RefundVault.sol";

contract BuyContract is Utils, Withdrawable {
    
    using SafeMath for uint256;
    
    
    // address where funds are collected
    address public wallet;

    ERC20 public token;
	uint  public baseBuyRate;
	uint  public qtyToBuy;
	uint  weiRaised;
	address buyer;
	
	// refund vault used to hold funds while crowdsale is running
    RefundVault public vault;

	constructor(ERC20 _token, uint _baseBuyRate, uint _qtyToBuy, address _buyer ) public {
		token = _token;
		baseBuyRate = _baseBuyRate;
		qtyToBuy = _qtyToBuy;
		buyer = _buyer;
		weiRaised = 0; //initial value
		
		
		//refund vault
		vault = new RefundVault(wallet);

    }

	function getTokenQty(uint ethQty) internal view returns(uint) {
        uint dstDecimals = getDecimals(token);
        uint srcDecimals = ETH_DECIMALS;
        return calcDstQty(ethQty, srcDecimals, dstDecimals, baseBuyRate);
    }
    
    event DepositToken(ERC20 _token, uint _amount, BuyContract _contract);

    
    /**
   * @dev fallback function ***DO NOT OVERRIDE***
   */
    function () external payable {
        emit DepositToken(ETH_TOKEN_ADDRESS, msg.value,this);
        buyTokens(msg.sender);
    }
    
    
    /**
   * @dev low level token purchase ***DO NOT OVERRIDE***
   * @param _beneficiary Address performing the token purchase
   */
    function buyTokens(address _beneficiary) public payable {

    uint256 weiAmount = msg.value;
    // _preValidatePurchase(_beneficiary, weiAmount);

    // calculate token amount to be created
    uint256 tokens = getTokenQty(weiAmount);

    // update state
    weiRaised = weiRaised.add(weiAmount);

    // _processPurchase(_beneficiary, tokens);
    buyer = _beneficiary;
    
    
    // TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);

    // _updatePurchasingState(_beneficiary, weiAmount);

     _forwardFunds();
    // _postValidatePurchase(_beneficiary, weiAmount);
  }
  
  /**
   * @dev Overrides Crowdsale fund forwarding, sending funds to vault.
   */
  function _forwardFunds() internal {
    vault.deposit.value(msg.value)(msg.sender);
  }
  
  function getBuyer() public view returns(address)  {
      return buyer;
  }
  
  function finalizeTrade(bool tradeDone) external  {
      if (tradeDone)
      {
          vault.close();   
      }
      else
      {
          vault.enableRefunds();
      }
    
  }

}
