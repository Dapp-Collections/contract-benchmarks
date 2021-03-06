/**
 * Copyright (c) 2018 blockimmo AG <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e28e8b81878c9187a2808e8d81898b8f8f8dcc818a">[email protected]</a>&#13;
 * Non-Profit Open Software License 3.0 (NPOSL-3.0)&#13;
 * https://opensource.org/licenses/NPOSL-3.0&#13;
 */&#13;
 &#13;
&#13;
pragma solidity 0.4.25;&#13;
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
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {&#13;
    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the&#13;
    // benefit is lost if 'b' is also tested.&#13;
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522&#13;
    if (_a == 0) {&#13;
      return 0;&#13;
    }&#13;
&#13;
    c = _a * _b;&#13;
    assert(c / _a == _b);&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Integer division of two numbers, truncating the quotient.&#13;
  */&#13;
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {&#13;
    // assert(_b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    // uint256 c = _a / _b;&#13;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold&#13;
    return _a / _b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).&#13;
  */&#13;
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {&#13;
    assert(_b &lt;= _a);&#13;
    return _a - _b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Adds two numbers, throws on overflow.&#13;
  */&#13;
  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {&#13;
    c = _a + _b;&#13;
    assert(c &gt;= _a);&#13;
    return c;&#13;
  }&#13;
}&#13;
&#13;
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
  event OwnershipRenounced(address indexed previousOwner);&#13;
  event OwnershipTransferred(&#13;
    address indexed previousOwner,&#13;
    address indexed newOwner&#13;
  );&#13;
&#13;
&#13;
  /**&#13;
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender&#13;
   * account.&#13;
   */&#13;
  constructor() public {&#13;
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
   * @dev Allows the current owner to relinquish control of the contract.&#13;
   * @notice Renouncing to ownership will leave the contract without an owner.&#13;
   * It will not be possible to call the functions with the `onlyOwner`&#13;
   * modifier anymore.&#13;
   */&#13;
  function renounceOwnership() public onlyOwner {&#13;
    emit OwnershipRenounced(owner);&#13;
    owner = address(0);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows the current owner to transfer control of the contract to a newOwner.&#13;
   * @param _newOwner The address to transfer ownership to.&#13;
   */&#13;
  function transferOwnership(address _newOwner) public onlyOwner {&#13;
    _transferOwnership(_newOwner);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Transfers control of the contract to a newOwner.&#13;
   * @param _newOwner The address to transfer ownership to.&#13;
   */&#13;
  function _transferOwnership(address _newOwner) internal {&#13;
    require(_newOwner != address(0));&#13;
    emit OwnershipTransferred(owner, _newOwner);&#13;
    owner = _newOwner;&#13;
  }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title Escrow&#13;
 * @dev Base escrow contract, holds funds destinated to a payee until they&#13;
 * withdraw them. The contract that uses the escrow as its payment method&#13;
 * should be its owner, and provide public methods redirecting to the escrow's&#13;
 * deposit and withdraw.&#13;
 */&#13;
contract Escrow is Ownable {&#13;
  using SafeMath for uint256;&#13;
&#13;
  event Deposited(address indexed payee, uint256 weiAmount);&#13;
  event Withdrawn(address indexed payee, uint256 weiAmount);&#13;
&#13;
  mapping(address =&gt; uint256) private deposits;&#13;
&#13;
  function depositsOf(address _payee) public view returns (uint256) {&#13;
    return deposits[_payee];&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Stores the sent amount as credit to be withdrawn.&#13;
  * @param _payee The destination address of the funds.&#13;
  */&#13;
  function deposit(address _payee) public onlyOwner payable {&#13;
    uint256 amount = msg.value;&#13;
    deposits[_payee] = deposits[_payee].add(amount);&#13;
&#13;
    emit Deposited(_payee, amount);&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Withdraw accumulated balance for a payee.&#13;
  * @param _payee The address whose funds will be withdrawn and transferred to.&#13;
  */&#13;
  function withdraw(address _payee) public onlyOwner {&#13;
    uint256 payment = deposits[_payee];&#13;
    assert(address(this).balance &gt;= payment);&#13;
&#13;
    deposits[_payee] = 0;&#13;
&#13;
    _payee.transfer(payment);&#13;
&#13;
    emit Withdrawn(_payee, payment);&#13;
  }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title ConditionalEscrow&#13;
 * @dev Base abstract escrow to only allow withdrawal if a condition is met.&#13;
 */&#13;
contract ConditionalEscrow is Escrow {&#13;
  /**&#13;
  * @dev Returns whether an address is allowed to withdraw their funds. To be&#13;
  * implemented by derived contracts.&#13;
  * @param _payee The destination address of the funds.&#13;
  */&#13;
  function withdrawalAllowed(address _payee) public view returns (bool);&#13;
&#13;
  function withdraw(address _payee) public {&#13;
    require(withdrawalAllowed(_payee));&#13;
    super.withdraw(_payee);&#13;
  }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * @title RefundEscrow&#13;
 * @dev Escrow that holds funds for a beneficiary, deposited from multiple parties.&#13;
 * The contract owner may close the deposit period, and allow for either withdrawal&#13;
 * by the beneficiary, or refunds to the depositors.&#13;
 */&#13;
contract RefundEscrow is Ownable, ConditionalEscrow {&#13;
  enum State { Active, Refunding, Closed }&#13;
&#13;
  event Closed();&#13;
  event RefundsEnabled();&#13;
&#13;
  State public state;&#13;
  address public beneficiary;&#13;
&#13;
  /**&#13;
   * @dev Constructor.&#13;
   * @param _beneficiary The beneficiary of the deposits.&#13;
   */&#13;
  constructor(address _beneficiary) public {&#13;
    require(_beneficiary != address(0));&#13;
    beneficiary = _beneficiary;&#13;
    state = State.Active;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Stores funds that may later be refunded.&#13;
   * @param _refundee The address funds will be sent to if a refund occurs.&#13;
   */&#13;
  function deposit(address _refundee) public payable {&#13;
    require(state == State.Active);&#13;
    super.deposit(_refundee);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows for the beneficiary to withdraw their funds, rejecting&#13;
   * further deposits.&#13;
   */&#13;
  function close() public onlyOwner {&#13;
    require(state == State.Active);&#13;
    state = State.Closed;&#13;
    emit Closed();&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows for refunds to take place, rejecting further deposits.&#13;
   */&#13;
  function enableRefunds() public onlyOwner {&#13;
    require(state == State.Active);&#13;
    state = State.Refunding;&#13;
    emit RefundsEnabled();&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Withdraws the beneficiary's funds.&#13;
   */&#13;
  function beneficiaryWithdraw() public {&#13;
    require(state == State.Closed);&#13;
    beneficiary.transfer(address(this).balance);&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Returns whether refundees can withdraw their deposits (be refunded).&#13;
   */&#13;
  function withdrawalAllowed(address _payee) public view returns (bool) {&#13;
    return state == State.Refunding;&#13;
  }&#13;
}