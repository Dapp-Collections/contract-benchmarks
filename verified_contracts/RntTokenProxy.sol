pragma solidity ^0.4.15;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title Contracts that should not own Ether
 * @author Remco Bloemen <<span class="__cf_email__" data-cfemail="dcaeb9b1bfb39cee">[email protected]</span>π.com&gt;&#13;
 * @dev This tries to block incoming ether to prevent accidental loss of Ether. Should Ether end up&#13;
 * in the contract, it will allow the owner to reclaim this ether.&#13;
 * @notice Ether can still be send to this contract by:&#13;
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
  function HasNoEther() payable {&#13;
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
    assert(owner.send(this.balance));&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title Pausable&#13;
 * @dev Base contract which allows children to implement an emergency stop mechanism.&#13;
 */&#13;
contract Pausable is Ownable {&#13;
  event Pause();&#13;
  event Unpause();&#13;
&#13;
  bool public paused = false;&#13;
&#13;
&#13;
  /**&#13;
   * @dev Modifier to make a function callable only when the contract is not paused.&#13;
   */&#13;
  modifier whenNotPaused() {&#13;
    require(!paused);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Modifier to make a function callable only when the contract is paused.&#13;
   */&#13;
  modifier whenPaused() {&#13;
    require(paused);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev called by the owner to pause, triggers stopped state&#13;
   */&#13;
  function pause() onlyOwner whenNotPaused public {&#13;
    paused = true;&#13;
    Pause();&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev called by the owner to unpause, returns to normal state&#13;
   */&#13;
  function unpause() onlyOwner whenPaused public {&#13;
    paused = false;&#13;
    Unpause();&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title SafeMath&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
library SafeMath {&#13;
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {&#13;
    uint256 c = a * b;&#13;
    assert(a == 0 || c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
  function div(uint256 a, uint256 b) internal constant returns (uint256) {&#13;
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    uint256 c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return c;&#13;
  }&#13;
&#13;
  function sub(uint256 a, uint256 b) internal constant returns (uint256) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
  function add(uint256 a, uint256 b) internal constant returns (uint256) {&#13;
    uint256 c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
}&#13;
&#13;
contract IRntToken {&#13;
    uint256 public decimals = 18;&#13;
&#13;
    uint256 public totalSupply = 1000000000 * (10 ** 18);&#13;
&#13;
    string public name = "RNT Token";&#13;
&#13;
    string public code = "RNT";&#13;
&#13;
&#13;
    function balanceOf() public constant returns (uint256 balance);&#13;
&#13;
    function transfer(address _to, uint _value) public returns (bool success);&#13;
&#13;
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);&#13;
}&#13;
&#13;
contract RntTokenVault is HasNoEther, Pausable {&#13;
    using SafeMath for uint256;&#13;
&#13;
    IRntToken public rntToken;&#13;
&#13;
    uint256 public accountsCount = 0;&#13;
&#13;
    uint256 public tokens = 0;&#13;
&#13;
    mapping (bytes16 =&gt; bool) public accountsStatuses;&#13;
&#13;
    mapping (bytes16 =&gt; uint256) public balances;&#13;
&#13;
    mapping (address =&gt; bool) public allowedAddresses;&#13;
&#13;
    mapping (address =&gt; bytes16) public tokenTransfers;&#13;
&#13;
&#13;
    function RntTokenVault(address _rntTokenAddress){&#13;
        rntToken = IRntToken(_rntTokenAddress);&#13;
    }&#13;
&#13;
    /**&#13;
    @notice Modifier that prevent calling function from not allowed address.&#13;
    @dev Owner always allowed address.&#13;
    */&#13;
    modifier onlyAllowedAddresses {&#13;
        require(msg.sender == owner || allowedAddresses[msg.sender] == true);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
    @notice Modifier that prevent calling function if account not registered.&#13;
    */&#13;
    modifier onlyRegisteredAccount(bytes16 _uuid) {&#13;
        require(accountsStatuses[_uuid] == true);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
    @notice Get current amount of tokens on Vault address.&#13;
    @return { amount of tokens }&#13;
    */&#13;
    function getVaultBalance() onlyAllowedAddresses public constant returns (uint256) {&#13;
        return rntToken.balanceOf();&#13;
    }&#13;
&#13;
    /**&#13;
    @notice Get uuid of account taht transfer tokens to specified address.&#13;
    @param  _address Transfer address.&#13;
    @return { uuid that wsa transfer tokens }&#13;
    */&#13;
    function getTokenTransferUuid(address _address) onlyAllowedAddresses public constant returns (bytes16) {&#13;
        return tokenTransfers[_address];&#13;
    }&#13;
&#13;
    /**&#13;
    @notice Check that address is allowed to interact with functions.&#13;
    @return { true if allowed, false if not }&#13;
    */&#13;
    function isAllowedAddress(address _address) onlyAllowedAddresses public constant returns (bool) {&#13;
        return allowedAddresses[_address];&#13;
    }&#13;
&#13;
    /**&#13;
    @notice Check that address is registered.&#13;
    @return { true if registered, false if not }&#13;
    */&#13;
    function isRegisteredAccount(address _address) onlyAllowedAddresses public constant returns (bool) {&#13;
        return allowedAddresses[_address];&#13;
    }&#13;
&#13;
    /**&#13;
     @notice Register account.&#13;
     @dev It used for accounts counting.&#13;
     */&#13;
    function registerAccount(bytes16 _uuid) public {&#13;
        accountsStatuses[_uuid] = true;&#13;
        accountsCount = accountsCount.add(1);&#13;
    }&#13;
&#13;
    /**&#13;
     @notice Set allowance for address to interact with contract.&#13;
     @param _address Address to allow or disallow.&#13;
     @param _allow True to allow address to interact with function, false to disallow.&#13;
    */&#13;
    function allowAddress(address _address, bool _allow) onlyOwner {&#13;
        allowedAddresses[_address] = _allow;&#13;
    }&#13;
&#13;
    /**&#13;
    @notice Function for adding tokens to specified account.&#13;
    @dev Account will be registered if it wasn't. Tokens will not be added to Vault address.&#13;
    @param _uuid Uuid of account.&#13;
    @param _tokensCount Number of tokens for adding to account.&#13;
    @return { true if added, false if not }&#13;
    */&#13;
    function addTokensToAccount(bytes16 _uuid, uint256 _tokensCount) onlyAllowedAddresses whenNotPaused public returns (bool) {&#13;
        registerAccount(_uuid);&#13;
        balances[_uuid] = balances[_uuid].add(_tokensCount);&#13;
        tokens = tokens.add(_tokensCount);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    @notice Function for removing tokens from specified account.&#13;
    @dev Function throw exception if account wasn't registered. Tokens will not be returned to owner address.&#13;
    @param _uuid Uuid of account.&#13;
    @param _tokensCount Number of tokens for adding to account.&#13;
    @return { true if added, false if not }&#13;
    */&#13;
    function removeTokensFromAccount(bytes16 _uuid, uint256 _tokensCount) onlyAllowedAddresses&#13;
            onlyRegisteredAccount(_uuid) whenNotPaused internal returns (bool) {&#13;
        balances[_uuid] = balances[_uuid].sub(_tokensCount);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    @notice Function for transfering tokens from one account to another.&#13;
    @param _from Account from which tokens will be transfered.&#13;
    @param _to Account to which tokens will be transfered.&#13;
    @param _tokensCount Number of tokens that will be transfered.&#13;
    @return { true if transfered successful, false if not }&#13;
    */&#13;
    function transferTokensToAccount(bytes16 _from, bytes16 _to, uint256 _tokensCount) onlyAllowedAddresses&#13;
            onlyRegisteredAccount(_from) whenNotPaused public returns (bool) {&#13;
        registerAccount(_to);&#13;
        balances[_from] = balances[_from].sub(_tokensCount);&#13;
        balances[_to] = balances[_to].add(_tokensCount);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    @notice Function for withdrawal all tokens from Vault account to address.&#13;
    @dev Will transfer tokens from Vault address to specified address.&#13;
    @param _uuid Account from which tokens will be transfered.&#13;
    @param _address Address on which tokens will be transfered.&#13;
    @return { true if withdrawal successful, false if not }&#13;
    */&#13;
    function moveAllTokensToAddress(bytes16 _uuid, address _address) onlyAllowedAddresses&#13;
            onlyRegisteredAccount(_uuid) whenNotPaused public returns (bool) {&#13;
        uint256 accountBalance = balances[_uuid];&#13;
        removeTokensFromAccount(_uuid, accountBalance);&#13;
        rntToken.transfer(_address, accountBalance);&#13;
        tokens = tokens.sub(accountBalance);&#13;
        tokenTransfers[_address] = _uuid;&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    @notice Function for withdrawal tokens from Vault account to address.&#13;
    @dev Will transfer tokens from Vault address to specified address.&#13;
    @param _uuid Account from which tokens will be transfered.&#13;
    @param _address Address on which tokens will be transfered.&#13;
    @param _tokensCount Number of tokens that will be transfered.&#13;
    @return { true if transfered successful, false if not }&#13;
    */&#13;
    function moveTokensToAddress(bytes16 _uuid, address _address, uint256 _tokensCount) onlyAllowedAddresses&#13;
            onlyRegisteredAccount(_uuid) whenNotPaused public returns (bool) {&#13;
        removeTokensFromAccount(_uuid, _tokensCount);&#13;
        rntToken.transfer(_address, _tokensCount);&#13;
        tokens = tokens.sub(_tokensCount);&#13;
        tokenTransfers[_address] = _uuid;&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    @notice Function for withdrawal tokens from Vault to specified address.&#13;
    @dev Will transfer tokens from Vault address to specified address.&#13;
    @param _to Address on which tokens will be transfered.&#13;
    @param _tokensCount Number of tokens that will be transfered.&#13;
    @return { true if transfered successful, false if not }&#13;
    */&#13;
    function transferTokensFromVault(address _to, uint256 _tokensCount) onlyOwner public returns (bool) {&#13;
        rntToken.transfer(_to, _tokensCount);&#13;
        return true;&#13;
    }&#13;
}&#13;
&#13;
/**&#13;
 * @title Destructible&#13;
 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.&#13;
 */&#13;
contract Destructible is Ownable {&#13;
&#13;
  function Destructible() payable { }&#13;
&#13;
  /**&#13;
   * @dev Transfers the current balance to the owner and terminates the contract.&#13;
   */&#13;
  function destroy() onlyOwner public {&#13;
    selfdestruct(owner);&#13;
  }&#13;
&#13;
  function destroyAndSend(address _recipient) onlyOwner public {&#13;
    selfdestruct(_recipient);&#13;
  }&#13;
}&#13;
&#13;
contract ICrowdsale {&#13;
    function allocateTokens(address _receiver, bytes16 _customerUuid, uint256 _weiAmount) public;&#13;
}&#13;
&#13;
contract RntTokenProxy is Destructible, Pausable, HasNoEther {&#13;
    IRntToken public rntToken;&#13;
&#13;
    ICrowdsale public crowdsale;&#13;
&#13;
    RntTokenVault public rntTokenVault;&#13;
&#13;
    mapping (address =&gt; bool) public allowedAddresses;&#13;
&#13;
    function RntTokenProxy(address _tokenAddress, address _vaultAddress, address _defaultAllowed, address _crowdsaleAddress) {&#13;
        rntToken = IRntToken(_tokenAddress);&#13;
        rntTokenVault = RntTokenVault(_vaultAddress);&#13;
        crowdsale = ICrowdsale(_crowdsaleAddress);&#13;
        allowedAddresses[_defaultAllowed] = true;&#13;
    }&#13;
&#13;
    /**&#13;
      @notice Modifier that prevent calling function from not allowed address.&#13;
      @dev Owner always allowed address.&#13;
     */&#13;
    modifier onlyAllowedAddresses {&#13;
        require(msg.sender == owner || allowedAddresses[msg.sender] == true);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
      @notice Set allowance for address to interact with contract.&#13;
      @param _address Address to allow or disallow.&#13;
      @param _allow True to allow address to interact with function, false to disallow.&#13;
     */&#13;
    function allowAddress(address _address, bool _allow) onlyOwner external {&#13;
        allowedAddresses[_address] = _allow;&#13;
    }&#13;
&#13;
    /**&#13;
      @notice Function for adding tokens to account.&#13;
      @dev If account wasn't created, it will be created and tokens will be added. Also this function transfer tokens to address of Valut.&#13;
      @param _uuid Account uuid.&#13;
      @param _tokensCount Number of tokens that will be added to account.&#13;
     */&#13;
    function addTokens(bytes16 _uuid, uint256 _tokensCount) onlyAllowedAddresses whenNotPaused external {&#13;
        rntTokenVault.addTokensToAccount(_uuid, _tokensCount);&#13;
        rntToken.transferFrom(owner, address(rntTokenVault), _tokensCount);&#13;
    }&#13;
&#13;
    /**&#13;
      @notice Function for transfering tokens from account to specified address.&#13;
      @dev It will transfer tokens from Vault address to specified address.&#13;
      @param _to Address, on wich tokens will be added.&#13;
      @param _uuid Account, from wich token will be taken.&#13;
      @param _tokensCount Number of tokens for transfering.&#13;
     */&#13;
    function moveTokens(address _to, bytes16 _uuid, uint256 _tokensCount) onlyAllowedAddresses whenNotPaused external {&#13;
        rntTokenVault.moveTokensToAddress(_uuid, _to, _tokensCount);&#13;
    }&#13;
&#13;
    /**&#13;
      @notice Function for transfering all tokens from account to specified address.&#13;
      @dev It will transfer all account allowed tokens from Vault address to specified address.&#13;
      @param _to Address, on wich tokens will be added.&#13;
      @param _uuid Account, from wich token will be taken.&#13;
     */&#13;
    function moveAllTokens(address _to, bytes16 _uuid) onlyAllowedAddresses whenNotPaused external {&#13;
        rntTokenVault.moveAllTokensToAddress(_uuid, _to);&#13;
    }&#13;
&#13;
    /**&#13;
      @notice Add tokens to specified address, tokens amount depends of wei amount.&#13;
      @dev Tokens acount calculated using token price that specified in Prixing Strategy. This function should be used when tokens was buyed outside ethereum.&#13;
      @param _receiver Address, on wich tokens will be added.&#13;
      @param _customerUuid Uuid of account that was bought tokens.&#13;
      @param _weiAmount Wei that account was invest.&#13;
     */&#13;
    function allocate(address _receiver, bytes16 _customerUuid, uint256 _weiAmount) onlyAllowedAddresses whenNotPaused external {&#13;
        crowdsale.allocateTokens(_receiver, _customerUuid, _weiAmount);&#13;
    }&#13;
}