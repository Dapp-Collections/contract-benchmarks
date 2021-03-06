pragma solidity ^0.4.23;

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

  /**
   * @dev Allows the current owner to relinquish control of the contract.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }
}

// File: openzeppelin-solidity/contracts/ownership/HasNoEther.sol

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="8cfee9e1efe3ccbe">[email protected]</a>π.com&gt;&#13;
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up&#13;
 * in the contract, it will allow the owner to reclaim this ether.&#13;
 * @notice Ether can still be sent to this contract by:&#13;
 * calling functions labeled `payable`&#13;
 * `selfdestruct(contract_address)`&#13;
 * mining directly to the contract address&#13;
 */&#13;
contract HasNoEther is Ownable {&#13;
&#13;
  /**&#13;
  * @dev Constructor that rejects incoming Ether&#13;
  * @dev The `payable` flag is added so we can access `msg.value` without compiler warning. If we&#13;
  * leave out payable, then Solidity will allow inheriting contracts to implement a payable&#13;
  * constructor. By doing it this way we prevent a payable constructor from working. Alternatively&#13;
  * we could use assembly to access msg.value.&#13;
  */&#13;
  constructor() public payable {&#13;
    require(msg.value == 0);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Disallows direct send by settings a default function without the `payable` flag.&#13;
   */&#13;
  function() external {&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Transfer all Ether held by the contract to the owner.&#13;
   */&#13;
  function reclaimEther() external onlyOwner {&#13;
    owner.transfer(this.balance);&#13;
  }&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/math/SafeMath.sol&#13;
&#13;
/**&#13;
 * @title SafeMath&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
library SafeMath {&#13;
&#13;
  /**&#13;
  * @dev Multiplies two numbers, throws on overflow.&#13;
  */&#13;
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {&#13;
    if (a == 0) {&#13;
      return 0;&#13;
    }&#13;
    c = a * b;&#13;
    assert(c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Integer division of two numbers, truncating the quotient.&#13;
  */&#13;
  function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    // uint256 c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return a / b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).&#13;
  */&#13;
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Adds two numbers, throws on overflow.&#13;
  */&#13;
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {&#13;
    c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol&#13;
&#13;
/**&#13;
 * @title ERC20Basic&#13;
 * @dev Simpler version of ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/179&#13;
 */&#13;
contract ERC20Basic {&#13;
  function totalSupply() public view returns (uint256);&#13;
  function balanceOf(address who) public view returns (uint256);&#13;
  function transfer(address to, uint256 value) public returns (bool);&#13;
  event Transfer(address indexed from, address indexed to, uint256 value);&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/token/ERC20/BasicToken.sol&#13;
&#13;
/**&#13;
 * @title Basic token&#13;
 * @dev Basic version of StandardToken, with no allowances.&#13;
 */&#13;
contract BasicToken is ERC20Basic {&#13;
  using SafeMath for uint256;&#13;
&#13;
  mapping(address =&gt; uint256) balances;&#13;
&#13;
  uint256 totalSupply_;&#13;
&#13;
  /**&#13;
  * @dev total number of tokens in existence&#13;
  */&#13;
  function totalSupply() public view returns (uint256) {&#13;
    return totalSupply_;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev transfer token for a specified address&#13;
  * @param _to The address to transfer to.&#13;
  * @param _value The amount to be transferred.&#13;
  */&#13;
  function transfer(address _to, uint256 _value) public returns (bool) {&#13;
    require(_to != address(0));&#13;
    require(_value &lt;= balances[msg.sender]);&#13;
&#13;
    balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    emit Transfer(msg.sender, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Gets the balance of the specified address.&#13;
  * @param _owner The address to query the the balance of.&#13;
  * @return An uint256 representing the amount owned by the passed address.&#13;
  */&#13;
  function balanceOf(address _owner) public view returns (uint256) {&#13;
    return balances[_owner];&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/token/ERC20/BurnableToken.sol&#13;
&#13;
/**&#13;
 * @title Burnable Token&#13;
 * @dev Token that can be irreversibly burned (destroyed).&#13;
 */&#13;
contract BurnableToken is BasicToken {&#13;
&#13;
  event Burn(address indexed burner, uint256 value);&#13;
&#13;
  /**&#13;
   * @dev Burns a specific amount of tokens.&#13;
   * @param _value The amount of token to be burned.&#13;
   */&#13;
  function burn(uint256 _value) public {&#13;
    _burn(msg.sender, _value);&#13;
  }&#13;
&#13;
  function _burn(address _who, uint256 _value) internal {&#13;
    require(_value &lt;= balances[_who]);&#13;
    // no need to require value &lt;= totalSupply, since that would imply the&#13;
    // sender's balance is greater than the totalSupply, which *should* be an assertion failure&#13;
&#13;
    balances[_who] = balances[_who].sub(_value);&#13;
    totalSupply_ = totalSupply_.sub(_value);&#13;
    emit Burn(_who, _value);&#13;
    emit Transfer(_who, address(0), _value);&#13;
  }&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/token/ERC20/ERC20.sol&#13;
&#13;
/**&#13;
 * @title ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/20&#13;
 */&#13;
contract ERC20 is ERC20Basic {&#13;
  function allowance(address owner, address spender)&#13;
    public view returns (uint256);&#13;
&#13;
  function transferFrom(address from, address to, uint256 value)&#13;
    public returns (bool);&#13;
&#13;
  function approve(address spender, uint256 value) public returns (bool);&#13;
  event Approval(&#13;
    address indexed owner,&#13;
    address indexed spender,&#13;
    uint256 value&#13;
  );&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/token/ERC20/StandardToken.sol&#13;
&#13;
/**&#13;
 * @title Standard ERC20 token&#13;
 *&#13;
 * @dev Implementation of the basic standard token.&#13;
 * @dev https://github.com/ethereum/EIPs/issues/20&#13;
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol&#13;
 */&#13;
contract StandardToken is ERC20, BasicToken {&#13;
&#13;
  mapping (address =&gt; mapping (address =&gt; uint256)) internal allowed;&#13;
&#13;
&#13;
  /**&#13;
   * @dev Transfer tokens from one address to another&#13;
   * @param _from address The address which you want to send tokens from&#13;
   * @param _to address The address which you want to transfer to&#13;
   * @param _value uint256 the amount of tokens to be transferred&#13;
   */&#13;
  function transferFrom(&#13;
    address _from,&#13;
    address _to,&#13;
    uint256 _value&#13;
  )&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    require(_to != address(0));&#13;
    require(_value &lt;= balances[_from]);&#13;
    require(_value &lt;= allowed[_from][msg.sender]);&#13;
&#13;
    balances[_from] = balances[_from].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
    emit Transfer(_from, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.&#13;
   *&#13;
   * Beware that changing an allowance with this method brings the risk that someone may use both the old&#13;
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this&#13;
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:&#13;
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _value The amount of tokens to be spent.&#13;
   */&#13;
  function approve(address _spender, uint256 _value) public returns (bool) {&#13;
    allowed[msg.sender][_spender] = _value;&#13;
    emit Approval(msg.sender, _spender, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to check the amount of tokens that an owner allowed to a spender.&#13;
   * @param _owner address The address which owns the funds.&#13;
   * @param _spender address The address which will spend the funds.&#13;
   * @return A uint256 specifying the amount of tokens still available for the spender.&#13;
   */&#13;
  function allowance(&#13;
    address _owner,&#13;
    address _spender&#13;
   )&#13;
    public&#13;
    view&#13;
    returns (uint256)&#13;
  {&#13;
    return allowed[_owner][_spender];&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Increase the amount of tokens that an owner allowed to a spender.&#13;
   *&#13;
   * approve should be called when allowed[_spender] == 0. To increment&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _addedValue The amount of tokens to increase the allowance by.&#13;
   */&#13;
  function increaseApproval(&#13;
    address _spender,&#13;
    uint _addedValue&#13;
  )&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    allowed[msg.sender][_spender] = (&#13;
      allowed[msg.sender][_spender].add(_addedValue));&#13;
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Decrease the amount of tokens that an owner allowed to a spender.&#13;
   *&#13;
   * approve should be called when allowed[_spender] == 0. To decrement&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _subtractedValue The amount of tokens to decrease the allowance by.&#13;
   */&#13;
  function decreaseApproval(&#13;
    address _spender,&#13;
    uint _subtractedValue&#13;
  )&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    uint oldValue = allowed[msg.sender][_spender];&#13;
    if (_subtractedValue &gt; oldValue) {&#13;
      allowed[msg.sender][_spender] = 0;&#13;
    } else {&#13;
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);&#13;
    }&#13;
    emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);&#13;
    return true;&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: contracts/ChartToken.sol&#13;
&#13;
contract ChartToken is StandardToken, BurnableToken, Ownable, HasNoEther {&#13;
    string public constant name = "BetOnChart token";&#13;
    string public constant symbol = "CHART";&#13;
    uint8 public constant decimals = 18; // 1 ether&#13;
    bool public saleFinished;&#13;
    address public saleAgent;&#13;
    address private wallet;&#13;
&#13;
   /**&#13;
    * @dev Event should be emited when sale agent changed&#13;
    */&#13;
    event SaleAgent(address);&#13;
&#13;
   /**&#13;
    * @dev ChartToken constructor&#13;
    * All tokens supply will be assign to contract owner.&#13;
    * @param _wallet Wallet to handle initial token emission.&#13;
    */&#13;
    constructor(address _wallet) public {&#13;
        require(_wallet != address(0));&#13;
&#13;
        totalSupply_ = 50*1e6*(1 ether);&#13;
        saleFinished = false;&#13;
        balances[_wallet] = totalSupply_;&#13;
        wallet = _wallet;&#13;
        saleAgent = address(0);&#13;
    }&#13;
&#13;
   /**&#13;
    * @dev Modifier to make a function callable only by owner or sale agent.&#13;
    */&#13;
    modifier onlyOwnerOrSaleAgent() {&#13;
        require(msg.sender == owner || msg.sender == saleAgent);&#13;
        _;&#13;
    }&#13;
&#13;
   /**&#13;
    * @dev Modifier to make a function callable only when a sale is finished.&#13;
    */&#13;
    modifier whenSaleFinished() {&#13;
        require(saleFinished || msg.sender == saleAgent || msg.sender == wallet );&#13;
        _;&#13;
    }&#13;
&#13;
   /**&#13;
    * @dev Modifier to make a function callable only when a sale is not finished.&#13;
    */&#13;
    modifier whenSaleNotFinished() {&#13;
        require(!saleFinished);&#13;
        _;&#13;
    }&#13;
&#13;
   /**&#13;
    * @dev Set sale agent&#13;
    * @param _agent The agent address which you want to set.&#13;
    */&#13;
    function setSaleAgent(address _agent) public whenSaleNotFinished onlyOwner {&#13;
        saleAgent = _agent;&#13;
        emit SaleAgent(_agent);&#13;
    }&#13;
&#13;
   /**&#13;
    * @dev Handle ICO end&#13;
    */&#13;
    function finishSale() public onlyOwnerOrSaleAgent {&#13;
        saleAgent = address(0);&#13;
        emit SaleAgent(saleAgent);&#13;
        saleFinished = true;&#13;
    }&#13;
&#13;
   /**&#13;
    * @dev Overrides default ERC20&#13;
    */&#13;
    function transfer(address _to, uint256 _value) public whenSaleFinished returns (bool) {&#13;
        return super.transfer(_to, _value);&#13;
    }&#13;
&#13;
   /**&#13;
    * @dev Overrides default ERC20&#13;
    */&#13;
    function transferFrom(address _from, address _to, uint256 _value) public whenSaleFinished returns (bool) {&#13;
        return super.transferFrom(_from, _to, _value);&#13;
    }&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/crowdsale/Crowdsale.sol&#13;
&#13;
/**&#13;
 * @title Crowdsale&#13;
 * @dev Crowdsale is a base contract for managing a token crowdsale,&#13;
 * allowing investors to purchase tokens with ether. This contract implements&#13;
 * such functionality in its most fundamental form and can be extended to provide additional&#13;
 * functionality and/or custom behavior.&#13;
 * The external interface represents the basic interface for purchasing tokens, and conform&#13;
 * the base architecture for crowdsales. They are *not* intended to be modified / overriden.&#13;
 * The internal interface conforms the extensible and modifiable surface of crowdsales. Override&#13;
 * the methods to add functionality. Consider using 'super' where appropiate to concatenate&#13;
 * behavior.&#13;
 */&#13;
contract Crowdsale {&#13;
  using SafeMath for uint256;&#13;
&#13;
  // The token being sold&#13;
  ERC20 public token;&#13;
&#13;
  // Address where funds are collected&#13;
  address public wallet;&#13;
&#13;
  // How many token units a buyer gets per wei&#13;
  uint256 public rate;&#13;
&#13;
  // Amount of wei raised&#13;
  uint256 public weiRaised;&#13;
&#13;
  /**&#13;
   * Event for token purchase logging&#13;
   * @param purchaser who paid for the tokens&#13;
   * @param beneficiary who got the tokens&#13;
   * @param value weis paid for purchase&#13;
   * @param amount amount of tokens purchased&#13;
   */&#13;
  event TokenPurchase(&#13;
    address indexed purchaser,&#13;
    address indexed beneficiary,&#13;
    uint256 value,&#13;
    uint256 amount&#13;
  );&#13;
&#13;
  /**&#13;
   * @param _rate Number of token units a buyer gets per wei&#13;
   * @param _wallet Address where collected funds will be forwarded to&#13;
   * @param _token Address of the token being sold&#13;
   */&#13;
  constructor(uint256 _rate, address _wallet, ERC20 _token) public {&#13;
    require(_rate &gt; 0);&#13;
    require(_wallet != address(0));&#13;
    require(_token != address(0));&#13;
&#13;
    rate = _rate;&#13;
    wallet = _wallet;&#13;
    token = _token;&#13;
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
    emit TokenPurchase(&#13;
      msg.sender,&#13;
      _beneficiary,&#13;
      weiAmount,&#13;
      tokens&#13;
    );&#13;
&#13;
    _updatePurchasingState(_beneficiary, weiAmount);&#13;
&#13;
    _forwardFunds();&#13;
    _postValidatePurchase(_beneficiary, weiAmount);&#13;
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
  function _preValidatePurchase(&#13;
    address _beneficiary,&#13;
    uint256 _weiAmount&#13;
  )&#13;
    internal&#13;
  {&#13;
    require(_beneficiary != address(0));&#13;
    require(_weiAmount != 0);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Validation of an executed purchase. Observe state and use revert statements to undo rollback when valid conditions are not met.&#13;
   * @param _beneficiary Address performing the token purchase&#13;
   * @param _weiAmount Value in wei involved in the purchase&#13;
   */&#13;
  function _postValidatePurchase(&#13;
    address _beneficiary,&#13;
    uint256 _weiAmount&#13;
  )&#13;
    internal&#13;
  {&#13;
    // optional override&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Source of tokens. Override this method to modify the way in which the crowdsale ultimately gets and sends its tokens.&#13;
   * @param _beneficiary Address performing the token purchase&#13;
   * @param _tokenAmount Number of tokens to be emitted&#13;
   */&#13;
  function _deliverTokens(&#13;
    address _beneficiary,&#13;
    uint256 _tokenAmount&#13;
  )&#13;
    internal&#13;
  {&#13;
    token.transfer(_beneficiary, _tokenAmount);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Executed when a purchase has been validated and is ready to be executed. Not necessarily emits/sends tokens.&#13;
   * @param _beneficiary Address receiving the tokens&#13;
   * @param _tokenAmount Number of tokens to be purchased&#13;
   */&#13;
  function _processPurchase(&#13;
    address _beneficiary,&#13;
    uint256 _tokenAmount&#13;
  )&#13;
    internal&#13;
  {&#13;
    _deliverTokens(_beneficiary, _tokenAmount);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Override for extensions that require an internal state to check for validity (current user contributions, etc.)&#13;
   * @param _beneficiary Address receiving the tokens&#13;
   * @param _weiAmount Value in wei involved in the purchase&#13;
   */&#13;
  function _updatePurchasingState(&#13;
    address _beneficiary,&#13;
    uint256 _weiAmount&#13;
  )&#13;
    internal&#13;
  {&#13;
    // optional override&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Override to extend the way in which ether is converted to tokens.&#13;
   * @param _weiAmount Value in wei to be converted into tokens&#13;
   * @return Number of tokens that can be purchased with the specified _weiAmount&#13;
   */&#13;
  function _getTokenAmount(uint256 _weiAmount)&#13;
    internal view returns (uint256)&#13;
  {&#13;
    return _weiAmount.mul(rate);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Determines how ETH is stored/forwarded on purchases.&#13;
   */&#13;
  function _forwardFunds() internal {&#13;
    wallet.transfer(msg.value);&#13;
  }&#13;
}&#13;
&#13;
// File: contracts/lib/TimedCrowdsale.sol&#13;
&#13;
/**&#13;
 * @title TimedCrowdsale&#13;
 * @dev Crowdsale accepting contributions only within a time frame.&#13;
 */&#13;
contract TimedCrowdsale is Crowdsale {&#13;
    using SafeMath for uint256;&#13;
&#13;
    uint256 public openingTime;&#13;
    uint256 public closingTime;&#13;
&#13;
    /**&#13;
     * @dev Reverts if not in crowdsale time range.&#13;
     */&#13;
    modifier onlyWhileOpen {&#13;
        // solium-disable-next-line security/no-block-members&#13;
        require(block.timestamp &gt;= openingTime &amp;&amp; block.timestamp &lt;= closingTime);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Constructor, takes crowdsale opening and closing times.&#13;
     * @param _openingTime Crowdsale opening time&#13;
     * @param _closingTime Crowdsale closing time&#13;
     */&#13;
    constructor(uint256 _openingTime, uint256 _closingTime) public {&#13;
        require(_closingTime &gt;= _openingTime);&#13;
&#13;
        openingTime = _openingTime;&#13;
        closingTime = _closingTime;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Checks whether the period in which the crowdsale is open has already elapsed.&#13;
     * @return Whether crowdsale period has elapsed&#13;
     */&#13;
    function hasClosed() public view returns (bool) {&#13;
        // solium-disable-next-line security/no-block-members&#13;
        return block.timestamp &gt; closingTime;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Extend parent behavior requiring to be within contributing period&#13;
     * @param _beneficiary Token purchaser&#13;
     * @param _weiAmount Amount of wei contributed&#13;
     */&#13;
    function _preValidatePurchase(&#13;
        address _beneficiary,&#13;
        uint256 _weiAmount&#13;
    )&#13;
    internal&#13;
    onlyWhileOpen&#13;
    {&#13;
        super._preValidatePurchase(_beneficiary, _weiAmount);&#13;
    }&#13;
&#13;
}&#13;
&#13;
// File: contracts/lib/WhitelistedCrowdsale.sol&#13;
&#13;
/**&#13;
 * @title WhitelistedCrowdsale&#13;
 * @dev Crowdsale in which only whitelisted users can contribute.&#13;
 */&#13;
contract WhitelistedCrowdsale is Crowdsale, Ownable {&#13;
    using SafeMath for uint256;&#13;
&#13;
   /**&#13;
    * @dev Minimal contract to whitelisted addresses&#13;
    */&#13;
    struct Contract&#13;
    {&#13;
        uint256 rate;   // Token rate&#13;
        uint256 minInvestment; // Minimal investment&#13;
    }&#13;
&#13;
    mapping(address =&gt; bool) public whitelist;&#13;
    mapping(address =&gt; Contract) public contracts;&#13;
&#13;
    /**&#13;
     * @dev Reverts if beneficiary is not whitelisted.&#13;
     */&#13;
    modifier isWhitelisted(address _beneficiary) {&#13;
        require(whitelist[_beneficiary]);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Reverts if beneficiary is not invests minimal ether amount.&#13;
     */&#13;
    modifier isMinimalInvestment(address _beneficiary, uint256 _weiAmount) {&#13;
        require(_weiAmount &gt;= contracts[_beneficiary].minInvestment);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Adds single address to whitelist.&#13;
     * @param _beneficiary Address to be added to the whitelist&#13;
     * @param _bonus Token bonus from 0% to 300%&#13;
     * @param _minInvestment Minimal investment&#13;
     */&#13;
    function addToWhitelist(address _beneficiary, uint16 _bonus, uint256 _minInvestment) external onlyOwner {&#13;
        require(_bonus &lt;= 300);&#13;
&#13;
        whitelist[_beneficiary] = true;&#13;
        Contract storage beneficiaryContract = contracts[_beneficiary];&#13;
        beneficiaryContract.rate = rate.add(rate.mul(_bonus).div(100));&#13;
        beneficiaryContract.minInvestment = _minInvestment.mul(1 ether);&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Adds list of addresses to whitelist. Not overloaded due to limitations with truffle testing.&#13;
     * @param _beneficiaries Addresses to be added to the whitelist&#13;
     * @param _bonus Token bonus from 0% to 300%&#13;
     * @param _minInvestment Minimal investment&#13;
     */&#13;
    function addManyToWhitelist(address[] _beneficiaries, uint16 _bonus, uint256 _minInvestment) external onlyOwner {&#13;
        require(_bonus &lt;= 300);&#13;
&#13;
        for (uint256 i = 0; i &lt; _beneficiaries.length; i++) {&#13;
            whitelist[_beneficiaries[i]] = true;&#13;
            Contract storage beneficiaryContract = contracts[_beneficiaries[i]];&#13;
            beneficiaryContract.rate = rate.add(rate.mul(_bonus).div(100));&#13;
            beneficiaryContract.minInvestment = _minInvestment.mul(1 ether);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Removes single address from whitelist.&#13;
     * @param _beneficiary Address to be removed to the whitelist&#13;
     */&#13;
    function removeFromWhitelist(address _beneficiary) external onlyOwner {&#13;
        whitelist[_beneficiary] = false;&#13;
    }&#13;
&#13;
    /**&#13;
     * @dev Extend parent behavior requiring beneficiary to be in whitelist.&#13;
     * @param _beneficiary Token beneficiary&#13;
     * @param _weiAmount Amount of wei contributed&#13;
     */&#13;
    function _preValidatePurchase(&#13;
        address _beneficiary,&#13;
        uint256 _weiAmount&#13;
    )&#13;
    internal&#13;
    isWhitelisted(_beneficiary)&#13;
    isMinimalInvestment(_beneficiary, _weiAmount)&#13;
    {&#13;
        super._preValidatePurchase(_beneficiary, _weiAmount);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev The way in which ether is converted to tokens. Overrides default function.&#13;
    * @param _weiAmount Value in wei to be converted into tokens&#13;
    * @return Number of tokens that can be purchased with the specified _weiAmount&#13;
    */&#13;
    function _getTokenAmount(uint256 _weiAmount) internal view returns (uint256)&#13;
    {&#13;
        return _weiAmount.mul(contracts[msg.sender].rate);&#13;
    }&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/crowdsale/emission/AllowanceCrowdsale.sol&#13;
&#13;
/**&#13;
 * @title AllowanceCrowdsale&#13;
 * @dev Extension of Crowdsale where tokens are held by a wallet, which approves an allowance to the crowdsale.&#13;
 */&#13;
contract AllowanceCrowdsale is Crowdsale {&#13;
  using SafeMath for uint256;&#13;
&#13;
  address public tokenWallet;&#13;
&#13;
  /**&#13;
   * @dev Constructor, takes token wallet address.&#13;
   * @param _tokenWallet Address holding the tokens, which has approved allowance to the crowdsale&#13;
   */&#13;
  constructor(address _tokenWallet) public {&#13;
    require(_tokenWallet != address(0));&#13;
    tokenWallet = _tokenWallet;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Checks the amount of tokens left in the allowance.&#13;
   * @return Amount of tokens left in the allowance&#13;
   */&#13;
  function remainingTokens() public view returns (uint256) {&#13;
    return token.allowance(tokenWallet, this);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Overrides parent behavior by transferring tokens from wallet.&#13;
   * @param _beneficiary Token purchaser&#13;
   * @param _tokenAmount Amount of tokens purchased&#13;
   */&#13;
  function _deliverTokens(&#13;
    address _beneficiary,&#13;
    uint256 _tokenAmount&#13;
  )&#13;
    internal&#13;
  {&#13;
    token.transferFrom(tokenWallet, _beneficiary, _tokenAmount);&#13;
  }&#13;
}&#13;
&#13;
// File: openzeppelin-solidity/contracts/crowdsale/validation/CappedCrowdsale.sol&#13;
&#13;
/**&#13;
 * @title CappedCrowdsale&#13;
 * @dev Crowdsale with a limit for total contributions.&#13;
 */&#13;
contract CappedCrowdsale is Crowdsale {&#13;
  using SafeMath for uint256;&#13;
&#13;
  uint256 public cap;&#13;
&#13;
  /**&#13;
   * @dev Constructor, takes maximum amount of wei accepted in the crowdsale.&#13;
   * @param _cap Max amount of wei to be contributed&#13;
   */&#13;
  constructor(uint256 _cap) public {&#13;
    require(_cap &gt; 0);&#13;
    cap = _cap;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Checks whether the cap has been reached.&#13;
   * @return Whether the cap was reached&#13;
   */&#13;
  function capReached() public view returns (bool) {&#13;
    return weiRaised &gt;= cap;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Extend parent behavior requiring purchase to respect the funding cap.&#13;
   * @param _beneficiary Token purchaser&#13;
   * @param _weiAmount Amount of wei contributed&#13;
   */&#13;
  function _preValidatePurchase(&#13;
    address _beneficiary,&#13;
    uint256 _weiAmount&#13;
  )&#13;
    internal&#13;
  {&#13;
    super._preValidatePurchase(_beneficiary, _weiAmount);&#13;
    require(weiRaised.add(_weiAmount) &lt;= cap);&#13;
  }&#13;
&#13;
}&#13;
&#13;
// File: contracts/ChartPresale.sol&#13;
&#13;
contract ChartPresale is WhitelistedCrowdsale, AllowanceCrowdsale, TimedCrowdsale, CappedCrowdsale {&#13;
    using SafeMath for uint256;&#13;
&#13;
    string public constant name = "BetOnChart token presale";&#13;
&#13;
    constructor(uint256 _rate, address _tokenWallet, address _ethWallet, ChartToken _token, uint256 _cap, uint256 _openingTime, uint256 _closingTime) public&#13;
    Crowdsale(_rate, _ethWallet, _token)&#13;
    AllowanceCrowdsale(_tokenWallet)&#13;
    TimedCrowdsale(_openingTime, _closingTime)&#13;
    CappedCrowdsale(_cap) {}&#13;
}