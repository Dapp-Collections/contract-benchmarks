pragma solidity ^0.4.25;

/** For more info visit www.MettaCreative.world
 * 
 * Need a custom token for your own event? Interested in using smart contracts?
 * Contact the developer! Email: <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5163343f28676361693a603037113e213028207f323e3c">[email protected]</a>&#13;
 */&#13;
&#13;
/** The MIT License (MIT)&#13;
 *&#13;
 * Copyright (c) 2018 Metta Creative&#13;
 *&#13;
 * Permission is hereby granted, free of charge, to any person obtaining&#13;
 * a copy of this software and associated documentation files (the&#13;
 * "Software"), to deal in the Software without restriction, including&#13;
 * without limitation the rights to use, copy, modify, merge, publish,&#13;
 * distribute, sublicense, and/or sell copies of the Software, and to&#13;
 * permit persons to whom the Software is furnished to do so, subject to&#13;
 * the following conditions:&#13;
 * &#13;
 * The above copyright notice and this permission notice shall be included&#13;
 * in all copies or substantial portions of the Software.&#13;
 *&#13;
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS&#13;
 * OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF&#13;
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.&#13;
 * IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY&#13;
 * CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,&#13;
 * TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE&#13;
 * SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.&#13;
 */&#13;
&#13;
/**&#13;
 * @title SafeMath&#13;
 * @dev Math operations with safety checks that revert on error&#13;
 */&#13;
library SafeMath {&#13;
&#13;
  /**&#13;
  * @dev Multiplies two numbers, reverts on overflow.&#13;
  */&#13;
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the&#13;
    // benefit is lost if 'b' is also tested.&#13;
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522&#13;
    if (a == 0) {&#13;
      return 0;&#13;
    }&#13;
&#13;
    uint256 c = a * b;&#13;
    require(c / a == b);&#13;
&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.&#13;
  */&#13;
  function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    require(b &gt; 0); // Solidity only automatically asserts when dividing by 0&#13;
    uint256 c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).&#13;
  */&#13;
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    require(b &lt;= a);&#13;
    uint256 c = a - b;&#13;
&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Adds two numbers, reverts on overflow.&#13;
  */&#13;
  function add(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    uint256 c = a + b;&#13;
    require(c &gt;= a);&#13;
&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),&#13;
  * reverts when dividing by zero.&#13;
  */&#13;
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    require(b != 0);&#13;
    return a % b;&#13;
  }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/20&#13;
 */&#13;
interface IERC20 {&#13;
  function totalSupply() external view returns (uint256);&#13;
&#13;
  function balanceOf(address who) external view returns (uint256);&#13;
&#13;
  function allowance(address owner, address spender)&#13;
    external view returns (uint256);&#13;
&#13;
  function transfer(address to, uint256 value) external returns (bool);&#13;
&#13;
  function approve(address spender, uint256 value)&#13;
    external returns (bool);&#13;
&#13;
  function transferFrom(address from, address to, uint256 value)&#13;
    external returns (bool);&#13;
&#13;
  event Transfer(&#13;
    address indexed from,&#13;
    address indexed to,&#13;
    uint256 value&#13;
  );&#13;
&#13;
  event Approval(&#13;
    address indexed owner,&#13;
    address indexed spender,&#13;
    uint256 value&#13;
  );&#13;
}&#13;
&#13;
/**&#13;
 * @title Standard ERC20 token&#13;
 *&#13;
 * @dev Implementation of the basic standard token.&#13;
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md&#13;
 * Originally based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol&#13;
 */&#13;
contract ERC20 is IERC20 {&#13;
  using SafeMath for uint256;&#13;
&#13;
  mapping (address =&gt; uint256) private _balances;&#13;
&#13;
  mapping (address =&gt; mapping (address =&gt; uint256)) private _allowed;&#13;
&#13;
  uint256 private _totalSupply;&#13;
&#13;
  /**&#13;
  * @dev Total number of tokens in existence&#13;
  */&#13;
  function totalSupply() public view returns (uint256) {&#13;
    return _totalSupply;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Gets the balance of the specified address.&#13;
  * @param owner The address to query the balance of.&#13;
  * @return An uint256 representing the amount owned by the passed address.&#13;
  */&#13;
  function balanceOf(address owner) public view returns (uint256) {&#13;
    return _balances[owner];&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to check the amount of tokens that an owner allowed to a spender.&#13;
   * @param owner address The address which owns the funds.&#13;
   * @param spender address The address which will spend the funds.&#13;
   * @return A uint256 specifying the amount of tokens still available for the spender.&#13;
   */&#13;
  function allowance(&#13;
    address owner,&#13;
    address spender&#13;
   )&#13;
    public&#13;
    view&#13;
    returns (uint256)&#13;
  {&#13;
    return _allowed[owner][spender];&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Transfer token for a specified address&#13;
  * @param to The address to transfer to.&#13;
  * @param value The amount to be transferred.&#13;
  */&#13;
  function transfer(address to, uint256 value) public returns (bool) {&#13;
    _transfer(msg.sender, to, value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.&#13;
   * Beware that changing an allowance with this method brings the risk that someone may use both the old&#13;
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this&#13;
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:&#13;
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729&#13;
   * @param spender The address which will spend the funds.&#13;
   * @param value The amount of tokens to be spent.&#13;
   */&#13;
  function approve(address spender, uint256 value) public returns (bool) {&#13;
    require(spender != address(0));&#13;
&#13;
    _allowed[msg.sender][spender] = value;&#13;
    emit Approval(msg.sender, spender, value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Transfer tokens from one address to another&#13;
   * @param from address The address which you want to send tokens from&#13;
   * @param to address The address which you want to transfer to&#13;
   * @param value uint256 the amount of tokens to be transferred&#13;
   */&#13;
  function transferFrom(&#13;
    address from,&#13;
    address to,&#13;
    uint256 value&#13;
  )&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    require(value &lt;= _allowed[from][msg.sender]);&#13;
&#13;
    _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);&#13;
    _transfer(from, to, value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Increase the amount of tokens that an owner allowed to a spender.&#13;
   * approve should be called when allowed_[_spender] == 0. To increment&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   * @param spender The address which will spend the funds.&#13;
   * @param addedValue The amount of tokens to increase the allowance by.&#13;
   */&#13;
  function increaseAllowance(&#13;
    address spender,&#13;
    uint256 addedValue&#13;
  )&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    require(spender != address(0));&#13;
&#13;
    _allowed[msg.sender][spender] = (&#13;
      _allowed[msg.sender][spender].add(addedValue));&#13;
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Decrease the amount of tokens that an owner allowed to a spender.&#13;
   * approve should be called when allowed_[_spender] == 0. To decrement&#13;
   * allowed value is better to use this function to avoid 2 calls (and wait until&#13;
   * the first transaction is mined)&#13;
   * From MonolithDAO Token.sol&#13;
   * @param spender The address which will spend the funds.&#13;
   * @param subtractedValue The amount of tokens to decrease the allowance by.&#13;
   */&#13;
  function decreaseAllowance(&#13;
    address spender,&#13;
    uint256 subtractedValue&#13;
  )&#13;
    public&#13;
    returns (bool)&#13;
  {&#13;
    require(spender != address(0));&#13;
&#13;
    _allowed[msg.sender][spender] = (&#13;
      _allowed[msg.sender][spender].sub(subtractedValue));&#13;
    emit Approval(msg.sender, spender, _allowed[msg.sender][spender]);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Transfer token for a specified addresses&#13;
  * @param from The address to transfer from.&#13;
  * @param to The address to transfer to.&#13;
  * @param value The amount to be transferred.&#13;
  */&#13;
  function _transfer(address from, address to, uint256 value) internal {&#13;
    require(value &lt;= _balances[from]);&#13;
    require(to != address(0));&#13;
&#13;
    _balances[from] = _balances[from].sub(value);&#13;
    _balances[to] = _balances[to].add(value);&#13;
    emit Transfer(from, to, value);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Internal function that mints an amount of the token and assigns it to&#13;
   * an account. This encapsulates the modification of balances such that the&#13;
   * proper events are emitted.&#13;
   * @param account The account that will receive the created tokens.&#13;
   * @param value The amount that will be created.&#13;
   */&#13;
  function _mint(address account, uint256 value) internal {&#13;
    require(account != 0);&#13;
    _totalSupply = _totalSupply.add(value);&#13;
    _balances[account] = _balances[account].add(value);&#13;
    emit Transfer(address(0), account, value);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Internal function that burns an amount of the token of a given&#13;
   * account.&#13;
   * @param account The account whose tokens will be burnt.&#13;
   * @param value The amount that will be burnt.&#13;
   */&#13;
  function _burn(address account, uint256 value) internal {&#13;
    require(account != 0);&#13;
    require(value &lt;= _balances[account]);&#13;
&#13;
    _totalSupply = _totalSupply.sub(value);&#13;
    _balances[account] = _balances[account].sub(value);&#13;
    emit Transfer(account, address(0), value);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Internal function that burns an amount of the token of a given&#13;
   * account, deducting from the sender's allowance for said account. Uses the&#13;
   * internal burn function.&#13;
   * @param account The account whose tokens will be burnt.&#13;
   * @param value The amount that will be burnt.&#13;
   */&#13;
  function _burnFrom(address account, uint256 value) internal {&#13;
    require(value &lt;= _allowed[account][msg.sender]);&#13;
&#13;
    // Should https://github.com/OpenZeppelin/zeppelin-solidity/issues/707 be accepted,&#13;
    // this function needs to emit an event with the updated approval.&#13;
    _allowed[account][msg.sender] = _allowed[account][msg.sender].sub(&#13;
      value);&#13;
    _burn(account, value);&#13;
  }&#13;
}&#13;
&#13;
&#13;
contract MettaToken is ERC20 {&#13;
  string public name = "Metta Token";&#13;
  string public symbol = "MTTA";&#13;
  uint8 public decimals = 2;&#13;
  uint public INITIAL_SUPPLY = 5000000000;&#13;
  constructor() public {&#13;
 &#13;
    _mint(msg.sender, INITIAL_SUPPLY);&#13;
   }&#13;
&#13;
}