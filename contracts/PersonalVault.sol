//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.17;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import "https://github.com/thales-markets/contracts/blob/main/contracts/interfaces/IPositionalMarket.sol";
import "https://github.com/thales-markets/contracts/blob/main/contracts/interfaces/IThalesAMM.sol";



import "hardhat/console.sol";

interface IERC20 {
	function totalSupply() external view returns (uint);
	function balanceOf(address account) external view returns (uint);
	function transfer(address recipient, uint amount) external returns (bool);
	function allowance(address owner, address spender) external view returns (uint);
	function approve(address spender, uint amount) external returns (bool);
	function transferFrom(address sender, address recipient, uint amount) external returns (bool);
	event Transfer(address indexed from, address indexed to, uint value);
	event Approval(address indexed owner, address indexed spender, uint value);
}

contract PersonalVault is Ownable {
// An address type variable is used to store ethereum accounts.
    
    /* ========== LIBRARIES ========== */
    using SafeERC20Upgradeable for IERC20Upgradeable;


    /* ========== CONSTANTS ========== */
    uint private constant HUNDRED = 1e20;
    uint private constant ONE = 1e18;

    /* ========== STATE VARIABLES ========== */
    IThalesAMM public thalesAMM;
    IERC20Upgradeable public sUSD;

    /* ========== CONSTRUCTOR ========== */


    /* ========== EXTERNAL FUNCTIONS ========== */
    /// @notice Buy market options from Thales AMM
    /// @param market address of a market
    /// @param amount number of options to be bought
    /// @param position to buy options for
    function trade(
        address market,
        uint amount,
        IThalesAMM.Position position
    ) external nonReentrant whenNotPaused {
        require(amount >= minTradeAmount, "Amount less than minimum");

        IPositionalMarket marketContract = IPositionalMarket(market);
        (uint maturity, ) = marketContract.times();
        require(maturity < (roundStartTime[round] + roundLength), "Market time not valid");

        uint pricePosition = thalesAMM.price(address(market), position);
        require(pricePosition > 0, "Price not more than 0");

        int pricePositionImpact = thalesAMM.buyPriceImpact(address(market), position, amount);

        require(pricePosition >= priceLowerLimit && pricePosition <= priceUpperLimit, "Market price not valid");
        require(pricePositionImpact < skewImpactLimit, "Skew impact too high");
        _buyFromAmm(market, position, amount);

        if (!isTradingMarketInARound[round][market]) {
            tradingMarketsPerRound[round].push(market);
            isTradingMarketInARound[round][market] = true;
        }
    }


    function getBalance (address _tokenContractAddress) external view  returns (uint256) {
		uint balance = IERC20(_tokenContractAddress).balanceOf(address(this));
		return balance;
	}
	
	function recoverEth() external onlyOwner {
		payable(msg.sender).transfer(address(this).balance);
	}

	function recoverTokens(address tokenAddress) external onlyOwner {
		IERC20 token = IERC20(tokenAddress);
		token.transfer(msg.sender, token.balanceOf(address(this)));
	}
	
	receive() external payable {}



    /* ========== INTERNAL FUNCTIONS ========== */
    /// @notice Buy options from IthalesAMM
    /// @param market address of a market
    /// @param position position to be bought
    /// @param amount amount of positions to be bought
    function _buyFromAmm(
        address market,
        IThalesAMM.Position position,
        uint amount
    ) internal {
        uint quote = thalesAMM.buyFromAmmQuote(market, position, amount);
        require(quote < (tradingAllocation() - allocationSpentInARound[round]), "Amount exceeds available allocation");

        uint allocationAsset = (tradingAllocation() * allocationLimitsPerMarketPerRound) / HUNDRED;
        require(
            (quote + allocationSpentPerRound[round][market]) < allocationAsset,
            "Amount exceeds available allocation for asset"
        );

        uint balanceBeforeTrade = sUSD.balanceOf(address(this));

        thalesAMM.buyFromAMM(market, position, amount, quote, 0);

        uint balanceAfterTrade = sUSD.balanceOf(address(this));

        allocationSpentInARound[round] += quote;
        allocationSpentPerRound[round][market] += quote;
        tradingMarketPositionPerRound[round][market] = position;

        emit TradeExecuted(market, position, amount, quote);
    }

    /* ========== VIEWS ========== */
    /* ========== MODIFIERS ========== */
    /* ========== EVENTS ========== */


}