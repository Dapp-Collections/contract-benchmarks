pragma solidity 0.4.24;
/**
* @title Networth Token Contract
* @dev ERC-20 Token Standar Compliant
* Contact: networthlabs.com
* Airdrop service provided by <span class="__cf_email__" data-cfemail="4c2a622d223823222523622d2729200c2b212d2520622f2321">[email protected]</span>&#13;
*/&#13;
&#13;
/**&#13;
 * @title SafeMath by OpenZeppelin (partially)&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
library SafeMath {&#13;
&#13;
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        assert(b &lt;= a);&#13;
        return a - b;&#13;
    }&#13;
&#13;
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {&#13;
        c = a + b;&#13;
        assert(c &gt;= a);&#13;
        return c;&#13;
    }&#13;
&#13;
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
        uint256 c = a * b;&#13;
        assert(a == 0 || c / a == b);&#13;
        return c;&#13;
    }&#13;
}&#13;
&#13;
/**&#13;
* @title ERC20 Token minimal interface for external tokens handle&#13;
*/&#13;
contract token {&#13;
    function balanceOf(address _owner) public constant returns (uint256 balance);&#13;
    function transfer(address _to, uint256 _value) public returns (bool success);&#13;
}&#13;
&#13;
/**&#13;
* @title Admin parameters&#13;
* @dev Define administration parameters for this contract&#13;
*/&#13;
contract admined { //This token contract is administered&#13;
    address public admin; //Admin address is public&#13;
    address public allowed; //Allowed address is public&#13;
    bool public transferLock; //global transfer lock&#13;
&#13;
    /**&#13;
    * @dev Contract constructor, define initial administrator&#13;
    */&#13;
    constructor() internal {&#13;
        admin = msg.sender; //Set initial admin to contract creator&#13;
        emit Admined(admin);&#13;
    }&#13;
&#13;
    modifier onlyAdmin() { //A modifier to define admin-only functions&#13;
        require(msg.sender == admin);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyAllowed() { //A modifier to define allowed only function during transfer locks&#13;
        require(msg.sender == admin || msg.sender == allowed || transferLock == false);&#13;
        _;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Function to set new admin address&#13;
    * @param _newAdmin The address to transfer administration to&#13;
    */&#13;
    function transferAdminship(address _newAdmin) onlyAdmin public { //Admin can be transfered&#13;
        require(_newAdmin != address(0));&#13;
        admin = _newAdmin;&#13;
        emit TransferAdminship(_newAdmin);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Function to set new allowed address&#13;
    * @param _newAllowed The address to allow&#13;
    */&#13;
    function SetAllow(address _newAllowed) onlyAdmin public {&#13;
        allowed = _newAllowed;&#13;
        emit SetAllowed(_newAllowed);&#13;
    }&#13;
&#13;
   /**&#13;
    * @dev Function to set transfer locks&#13;
    * @param _set boolean flag (true | false)&#13;
    */&#13;
    function setTransferLock(bool _set) onlyAdmin public { //Only the admin can set a lock on transfers&#13;
        transferLock = _set;&#13;
        emit SetTransferLock(_set);&#13;
    }&#13;
&#13;
    //All admin actions have a log for public review&#13;
    event SetTransferLock(bool _set);&#13;
    event SetAllowed(address _allowed);&#13;
    event TransferAdminship(address _newAdminister);&#13;
    event Admined(address _administer);&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title ERC20TokenInterface&#13;
 * @dev Token contract interface for external use&#13;
 */&#13;
contract ERC20TokenInterface {&#13;
    function balanceOf(address _owner) public view returns (uint256 balance);&#13;
    function transfer(address _to, uint256 _value) public returns (bool success);&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);&#13;
    function approve(address _spender, uint256 _value) public returns (bool success);&#13;
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);&#13;
}&#13;
&#13;
&#13;
/**&#13;
* @title ERC20Token&#13;
* @notice Token definition contract&#13;
*/&#13;
contract ERC20Token is admined,ERC20TokenInterface { //Standard definition of an ERC20Token&#13;
    using SafeMath for uint256;&#13;
    uint256 public totalSupply;&#13;
    mapping (address =&gt; uint256) balances; //A mapping of all balances per address&#13;
    mapping (address =&gt; mapping (address =&gt; uint256)) allowed; //A mapping of all allowances&#13;
    mapping (address =&gt; bool) frozen; //A mapping of all frozen status&#13;
&#13;
    /**&#13;
    * @dev Get the balance of an specified address.&#13;
    * @param _owner The address to be query.&#13;
    */&#13;
    function balanceOf(address _owner) public constant returns (uint256 value) {&#13;
        return balances[_owner];&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev transfer token to a specified address&#13;
    * @param _to The address to transfer to.&#13;
    * @param _value The amount to be transferred.&#13;
    */&#13;
    function transfer(address _to, uint256 _value) onlyAllowed public returns (bool success) {&#13;
        require(_to != address(0)); //If you dont want that people destroy token&#13;
        require(frozen[msg.sender]==false);&#13;
        balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
        balances[_to] = balances[_to].add(_value);&#13;
        emit Transfer(msg.sender, _to, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev transfer token from an address to another specified address using allowance&#13;
    * @param _from The address where token comes.&#13;
    * @param _to The address to transfer to.&#13;
    * @param _value The amount to be transferred.&#13;
    */&#13;
    function transferFrom(address _from, address _to, uint256 _value) onlyAllowed public returns (bool success) {&#13;
        require(_to != address(0)); //If you dont want that people destroy token&#13;
        require(frozen[_from]==false);&#13;
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
        balances[_from] = balances[_from].sub(_value);&#13;
        balances[_to] = balances[_to].add(_value);&#13;
        emit Transfer(_from, _to, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Assign allowance to an specified address to use the owner balance&#13;
    * @param _spender The address to be allowed to spend.&#13;
    * @param _value The amount to be allowed.&#13;
    */&#13;
    function approve(address _spender, uint256 _value) public returns (bool success) {&#13;
        require((_value == 0) || (allowed[msg.sender][_spender] == 0)); //exploit mitigation&#13;
        allowed[msg.sender][_spender] = _value;&#13;
        emit Approval(msg.sender, _spender, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Get the allowance of an specified address to use another address balance.&#13;
    * @param _owner The address of the owner of the tokens.&#13;
    * @param _spender The address of the allowed spender.&#13;
    */&#13;
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {&#13;
        return allowed[_owner][_spender];&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Frozen account.&#13;
    * @param _target The address to being frozen.&#13;
    * @param _flag The frozen status to set.&#13;
    */&#13;
    function setFrozen(address _target,bool _flag) onlyAdmin public {&#13;
        frozen[_target]=_flag;&#13;
        emit FrozenStatus(_target,_flag);&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Special only admin function for batch tokens assignments.&#13;
    * @param _target Array of target addresses.&#13;
    * @param _amount Targets value.&#13;
    */&#13;
    function batch(address[] _target,uint256 _amount) onlyAdmin public { //It takes an array of addresses and an amount&#13;
        uint256 size = _target.length;&#13;
        require( balances[msg.sender] &gt;= size.mul(_amount));&#13;
        balances[msg.sender] = balances[msg.sender].sub(size.mul(_amount));&#13;
&#13;
        for (uint i=0; i&lt;size; i++) { //It moves over the array&#13;
            balances[_target[i]] = balances[_target[i]].add(_amount);&#13;
            emit Transfer(msg.sender, _target[i], _amount);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
    * @dev Log Events&#13;
    */&#13;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);&#13;
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);&#13;
    event FrozenStatus(address _target,bool _flag);&#13;
&#13;
}&#13;
&#13;
/**&#13;
* @title Networth&#13;
* @notice Networth Token creation.&#13;
* @dev ERC20 Token compliant&#13;
*/&#13;
contract Networth is ERC20Token {&#13;
    string public name = 'Networth';&#13;
    uint8 public decimals = 18;&#13;
    string public symbol = 'Googol';&#13;
    string public version = '1';&#13;
&#13;
    /**&#13;
    * @notice token contructor.&#13;
    */&#13;
    constructor() public {&#13;
        totalSupply = 250000000 * 10 ** uint256(decimals); //250.000.000 tokens initial supply;&#13;
        balances[msg.sender] = totalSupply;&#13;
        emit Transfer(0, msg.sender, totalSupply);&#13;
    }&#13;
&#13;
    /**&#13;
    * @notice Function to claim any token stuck on contract&#13;
    */&#13;
    function externalTokensRecovery(token _address) onlyAdmin public {&#13;
        uint256 remainder = _address.balanceOf(this); //Check remainder tokens&#13;
        _address.transfer(msg.sender,remainder); //Transfer tokens to admin&#13;
    }&#13;
&#13;
&#13;
    /**&#13;
    * @notice this contract will revert on direct non-function calls, also it's not payable&#13;
    * @dev Function to handle callback calls to contract&#13;
    */&#13;
    function() public {&#13;
        revert();&#13;
    }&#13;
&#13;
}