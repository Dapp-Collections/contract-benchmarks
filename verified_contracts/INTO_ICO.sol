pragma solidity ^0.4.24;

/**
 * SmartEth.co
 * ERC20 Token and ICO smart contracts development, smart contracts audit, ICO websites.
 * <span class="__cf_email__" data-cfemail="0b6864657f6a687f4b78666a797f6e7f63256864">[email protected]</span>&#13;
 */&#13;
&#13;
/**&#13;
 * @title SafeMath&#13;
 */&#13;
library SafeMath {&#13;
&#13;
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    if (a == 0) {&#13;
      return 0;&#13;
    }&#13;
    uint256 c = a * b;&#13;
    assert(c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
  function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    uint256 c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return c;&#13;
  }&#13;
&#13;
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
  function add(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    uint256 c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title Ownable&#13;
 */&#13;
contract Ownable {&#13;
  address public owner;&#13;
&#13;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);&#13;
&#13;
  constructor() public {&#13;
    owner = 0x81FF7d5cA83707C23d663ADE4432bdc8eD6ccCE1;&#13;
  }&#13;
&#13;
  modifier onlyOwner() {&#13;
    require(msg.sender == owner);&#13;
    _;&#13;
  }&#13;
&#13;
  function transferOwnership(address newOwner) public onlyOwner {&#13;
    require(newOwner != address(0));&#13;
    emit OwnershipTransferred(owner, newOwner);&#13;
    owner = newOwner;&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Pausable&#13;
 */&#13;
contract Pausable is Ownable {&#13;
  event Pause();&#13;
  event Unpause();&#13;
&#13;
  bool public paused = false;&#13;
&#13;
  modifier whenNotPaused() {&#13;
    require(!paused);&#13;
    _;&#13;
  }&#13;
&#13;
  modifier whenPaused() {&#13;
    require(paused);&#13;
    _;&#13;
  }&#13;
&#13;
  function pause() onlyOwner whenNotPaused public {&#13;
    paused = true;&#13;
    emit Pause();&#13;
  }&#13;
&#13;
  function unpause() onlyOwner whenPaused public {&#13;
    paused = false;&#13;
    emit Unpause();&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title ERC20Basic&#13;
 */&#13;
contract ERC20Basic {&#13;
  function totalSupply() public view returns (uint256);&#13;
  function balanceOf(address who) public view returns (uint256);&#13;
  function transfer(address to, uint256 value) public returns (bool);&#13;
  event Transfer(address indexed from, address indexed to, uint256 value);&#13;
}&#13;
&#13;
/**&#13;
 * @title ERC20 interface&#13;
 */&#13;
contract ERC20 is ERC20Basic {&#13;
  function allowance(address owner, address spender) public view returns (uint256);&#13;
  function transferFrom(address from, address to, uint256 value) public returns (bool);&#13;
  function approve(address spender, uint256 value) public returns (bool);&#13;
  event Approval(address indexed owner, address indexed spender, uint256 value);&#13;
}&#13;
&#13;
contract INTO_ICO is Pausable {&#13;
  using SafeMath for uint256;&#13;
&#13;
  // The token being sold&#13;
  ERC20 public token;&#13;
&#13;
  // Address where funds are collected&#13;
  address public wallet;&#13;
&#13;
  // Max supply of tokens offered in the crowdsale&#13;
  uint256 public supply;&#13;
&#13;
  // How many token units a buyer gets per wei&#13;
  uint256 public rate;&#13;
&#13;
  // Amount of wei raised&#13;
  uint256 public weiRaised;&#13;
  &#13;
  // Crowdsale opening time&#13;
  uint256 public openingTime;&#13;
  &#13;
  // Crowdsale closing time&#13;
  uint256 public closingTime;&#13;
&#13;
  // Crowdsale duration in days&#13;
  uint256 public duration;&#13;
&#13;
  // Min amount of wei an investor can send&#13;
  uint256 public minInvest;&#13;
&#13;
  /**&#13;
   * Event for token purchase logging&#13;
   * @param purchaser who paid for the tokens&#13;
   * @param beneficiary who got the tokens&#13;
   * @param value weis paid for purchase&#13;
   * @param amount amount of tokens purchased&#13;
   */&#13;
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);&#13;
&#13;
  constructor() public {&#13;
    rate = 50000;&#13;
    wallet = owner;&#13;
    token = ERC20(0x7f738ffbdE7ECAC18D31ECba1e9B6eEF5b9214b7);&#13;
    minInvest = 0.05 * 1 ether;&#13;
    duration = 176 days;&#13;
    openingTime = 1530446400;  // Determined by start()&#13;
    closingTime = openingTime + duration;  // Determined by start()&#13;
  }&#13;
  &#13;
  /**&#13;
   * @dev called by the owner to start the crowdsale&#13;
   */&#13;
  function start() public onlyOwner {&#13;
    openingTime = now;&#13;
    closingTime =  now + duration;&#13;
  }&#13;
&#13;
  // -----------------------------------------&#13;
  // Crowdsale external interface&#13;
  // -----------------------------------------&#13;
&#13;
  /**&#13;
   * @dev fallback function ***DO NOT OVERRIDE***&#13;
   */&#13;
  function () external payable {&#13;
    buyTokens(msg.sender);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev low level token purchase ***DO NOT OVERRIDE***&#13;
   * @param _beneficiary Address performing the token purchase&#13;
   */&#13;
  function buyTokens(address _beneficiary) public payable {&#13;
&#13;
    uint256 weiAmount = msg.value;&#13;
    _preValidatePurchase(_beneficiary, weiAmount);&#13;
&#13;
    // calculate token amount to be created&#13;
    uint256 tokens = _getTokenAmount(weiAmount);&#13;
&#13;
    // update state&#13;
    weiRaised = weiRaised.add(weiAmount);&#13;
&#13;
    _processPurchase(_beneficiary, tokens);&#13;
    emit TokenPurchase(msg.sender, _beneficiary, weiAmount, tokens);&#13;
&#13;
    _forwardFunds();&#13;
  }&#13;
&#13;
  // -----------------------------------------&#13;
  // Internal interface (extensible)&#13;
  // -----------------------------------------&#13;
&#13;
  /**&#13;
   * @dev Validation of an incoming purchase. Use require statements to revert state when conditions are not met. Use super to concatenate validations.&#13;
   * @param _beneficiary Address performing the token purchase&#13;
   * @param _weiAmount Value in wei involved in the purchase&#13;
   */&#13;
  function _preValidatePurchase(address _beneficiary, uint256 _weiAmount) internal whenNotPaused {&#13;
    require(_beneficiary != address(0));&#13;
    require(_weiAmount &gt;= minInvest);&#13;
    require(now &gt;= openingTime &amp;&amp; now &lt;= closingTime);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.&#13;
   * @param _beneficiary Address performing the token purchase&#13;
   * @param _tokenAmount Number of tokens to be emitted&#13;
   */&#13;
  function _deliverTokens(address _beneficiary, uint256 _tokenAmount) internal {&#13;
    token.transfer(_beneficiary, _tokenAmount);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.&#13;
   * @param _beneficiary Address receiving the tokens&#13;
   * @param _tokenAmount Number of tokens to be purchased&#13;
   */&#13;
  function _processPurchase(address _beneficiary, uint256 _tokenAmount) internal {&#13;
    _deliverTokens(_beneficiary, _tokenAmount);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Override to extend the way in which ether is converted to tokens.&#13;
   * @param _weiAmount Value in wei to be converted into tokens&#13;
   * @return Number of tokens that can be purchased with the specified _weiAmount&#13;
   */&#13;
  function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256) {&#13;
    return _weiAmount.div(10 ** 18).mul(rate);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Determines how ETH is stored/forwarded on purchases.&#13;
   */&#13;
  function _forwardFunds() internal {&#13;
    wallet.transfer(msg.value);&#13;
  }&#13;
  &#13;
  /**&#13;
   * @dev Checks whether the period in which the crowdsale is open has already elapsed.&#13;
   * @return Whether crowdsale period has elapsed&#13;
   */&#13;
  function hasClosed() public view returns (bool) {&#13;
    return now &gt; closingTime;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev called by the owner to withdraw unsold tokens&#13;
   */&#13;
  function withdrawTokens() public onlyOwner {&#13;
    uint256 unsold = token.balanceOf(this);&#13;
    token.transfer(owner, unsold);&#13;
  }&#13;
&#13;
}