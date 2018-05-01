pragma solidity ^0.4.18;

import "./ERC20Interface.sol";
import "./Utils.sol";

contract SellContract is Utils {

    ERC20 internal token;
	uint  public baseSellRate;
	uint  public qtyToSell;
	address seller;

	function SellContract(ERC20 _token, uint _baseSellRate, uint _qtyToSell, address _seller ) public  {
		
		require(_baseSellRate > 0 );
		require(_qtyToSell > 0 );
		require(_seller!=address(0));
		require(token.approve(this,qtyToSell));
		
		token = _token;
		baseSellRate = _baseSellRate;
		qtyToSell = _qtyToSell;
		seller = _seller;
		
    }
    
    function getETHQty() internal view returns(uint) {
        uint srcDecimals = ETH_DECIMALS;
        uint dstDecimals = getDecimals(token);
        return calcSrcQty(qtyToSell, srcDecimals, dstDecimals, baseSellRate);
    }
    
    function finalizeTransaction(address _buyer) public returns( bool ){
        return ( token.transfer(_buyer,qtyToSell) );
    }
    

}
