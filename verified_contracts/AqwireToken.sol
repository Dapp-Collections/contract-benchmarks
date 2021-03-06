pragma solidity ^0.4.23;

/**
 * Contributors
 * Andrey Shishkin <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5934362d302f3c773d36193e34383035773a3634">[email protected]</a>&#13;
 * Scott Yu <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4d3e2e2239390d2c3c3a243f28632422">[email protected]</a>&#13;
 */&#13;
&#13;
/**&#13;
 * @title Ownable&#13;
 * @dev The Ownable contract has an owner address, and provides basic authorization control&#13;
 * functions, this simplifies the implementation of "user permissions".&#13;
 */&#13;
contract Ownable {&#13;
  address public owner;&#13;
&#13;
&#13;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);&#13;
&#13;
&#13;
  /**&#13;
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender&#13;
   * account.&#13;
   */&#13;
  function Ownable() public {&#13;
    owner = msg.sender;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Throws if called by any account other than the owner.&#13;
   */&#13;
  modifier onlyOwner() {&#13;
    require(msg.sender == owner);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows the current owner to transfer control of the contract to a newOwner.&#13;
   * @param newOwner The address to transfer ownership to.&#13;
   */&#13;
  function transferOwnership(address newOwner) public onlyOwner {&#13;
    require(newOwner != address(0));&#13;
    emit OwnershipTransferred(owner, newOwner);&#13;
    owner = newOwner;&#13;
  }&#13;
&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title Whitelist&#13;
 * @dev The Whitelist contract has a whitelist of addresses, and provides basic authorization control functions.&#13;
 * @dev This simplifies the implementation of "user permissions".&#13;
 */&#13;
contract Whitelist is Ownable {&#13;
  mapping(address =&gt; bool) public whitelist;&#13;
&#13;
  event WhitelistedAddressAdded(address addr);&#13;
  event WhitelistedAddressRemoved(address addr);&#13;
&#13;
  /**&#13;
   * @dev Throws if called by any account that's not whitelisted.&#13;
   */&#13;
  modifier onlyWhitelisted() {&#13;
    require(whitelist[msg.sender]);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev add an address to the whitelist&#13;
   * @param addr address&#13;
   * @return true if the address was added to the whitelist, false if the address was already in the whitelist&#13;
   */&#13;
  function addAddressToWhitelist(address addr) onlyOwner public returns(bool success) {&#13;
    if (!whitelist[addr]) {&#13;
      whitelist[addr] = true;&#13;
      emit WhitelistedAddressAdded(addr);&#13;
      success = true;&#13;
    }&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev add addresses to the whitelist&#13;
   * @param addrs addresses&#13;
   * @return true if at least one address was added to the whitelist,&#13;
   * false if all addresses were already in the whitelist&#13;
   */&#13;
  function addAddressesToWhitelist(address[] addrs) onlyOwner public returns(bool success) {&#13;
    for (uint256 i = 0; i &lt; addrs.length; i++) {&#13;
      if (addAddressToWhitelist(addrs[i])) {&#13;
        success = true;&#13;
      }&#13;
    }&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev remove an address from the whitelist&#13;
   * @param addr address&#13;
   * @return true if the address was removed from the whitelist,&#13;
   * false if the address wasn't in the whitelist in the first place&#13;
   */&#13;
  function removeAddressFromWhitelist(address addr) onlyOwner public returns(bool success) {&#13;
    if (whitelist[addr]) {&#13;
      whitelist[addr] = false;&#13;
      emit WhitelistedAddressRemoved(addr);&#13;
      success = true;&#13;
    }&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev remove addresses from the whitelist&#13;
   * @param addrs addresses&#13;
   * @return true if at least one address was removed from the whitelist,&#13;
   * false if all addresses weren't in the whitelist in the first place&#13;
   */&#13;
  function removeAddressesFromWhitelist(address[] addrs) onlyOwner public returns(bool success) {&#13;
    for (uint256 i = 0; i &lt; addrs.length; i++) {&#13;
      if (removeAddressFromWhitelist(addrs[i])) {&#13;
        success = true;&#13;
      }&#13;
    }&#13;
  }&#13;
&#13;
}&#13;
&#13;
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
&#13;
/**&#13;
 * @title ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/20&#13;
 */&#13;
contract ERC20 is ERC20Basic {&#13;
  function allowance(address owner, address spender) public view returns (uint256);&#13;
  function transferFrom(address from, address to, uint256 value) public returns (bool);&#13;
  function approve(address spender, uint256 value) public returns (bool);&#13;
  event Approval(address indexed owner, address indexed spender, uint256 value);&#13;
}&#13;
&#13;
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
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {&#13;
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
  function allowance(address _owner, address _spender) public view returns (uint256) {&#13;
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
  function increaseApproval(address _spender, uint _addedValue) public returns (bool) {&#13;
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);&#13;
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
  function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {&#13;
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
&#13;
/**&#13;
 * @title Standard Burnable Token&#13;
 * @dev Adds burnFrom method to ERC20 implementations&#13;
 */&#13;
contract StandardBurnableToken is BurnableToken, StandardToken {&#13;
&#13;
  /**&#13;
   * @dev Burns a specific amount of tokens from the target address and decrements allowance&#13;
   * @param _from address The address which you want to send tokens from&#13;
   * @param _value uint256 The amount of token to be burned&#13;
   */&#13;
  function burnFrom(address _from, uint256 _value) public {&#13;
    require(_value &lt;= allowed[_from][msg.sender]);&#13;
    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,&#13;
    // this function needs to emit an event with the updated approval.&#13;
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
    _burn(_from, _value);&#13;
  }&#13;
}&#13;
&#13;
&#13;
contract AqwireToken is StandardBurnableToken, Whitelist {&#13;
    string public constant name = "Aqwire Token"; &#13;
    string public constant symbol = "QEY"; &#13;
    uint8 public constant decimals = 18; &#13;
&#13;
    uint256 public constant INITIAL_SUPPLY = 250000000 * (10 ** uint256(decimals));&#13;
    uint256 public unlockTime;&#13;
&#13;
    constructor() public{&#13;
        totalSupply_ = INITIAL_SUPPLY;&#13;
        balances[msg.sender] = INITIAL_SUPPLY;&#13;
        emit Transfer(0x0, msg.sender, INITIAL_SUPPLY);&#13;
&#13;
        // owner is automatically whitelisted&#13;
        addAddressToWhitelist(msg.sender);&#13;
&#13;
    }&#13;
&#13;
    function setUnlockTime(uint256 _unlockTime) public onlyOwner {&#13;
        unlockTime = _unlockTime;&#13;
    }&#13;
&#13;
    function transfer(address _to, uint256 _value) public returns (bool) {&#13;
        // lock transfers until after ICO completes unless whitelisted&#13;
        require(block.timestamp &gt;= unlockTime || whitelist[msg.sender], "Unable to transfer as unlock time not passed or address not whitelisted");&#13;
&#13;
        return super.transfer(_to, _value);&#13;
    }&#13;
&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {&#13;
        // lock transfers until after ICO completes unless whitelisted&#13;
        require(block.timestamp &gt;= unlockTime || whitelist[msg.sender], "Unable to transfer as unlock time not passed or address not whitelisted");&#13;
&#13;
        return super.transferFrom(_from, _to, _value);&#13;
    }&#13;
&#13;
}