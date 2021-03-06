pragma solidity ^0.4.24;

/**
 * SmartEth.co
 * ERC20 Token and ICO smart contracts development, smart contracts audit, ICO websites.
 * <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="8be8e4e5ffeae8ffcbf8e6eaf9ffeeffe3a5e8e4">[email protected]</a>&#13;
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
    owner = msg.sender;&#13;
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
 * @title ERC20Basic&#13;
 */&#13;
contract ERC20Basic {&#13;
  uint256 public totalSupply;&#13;
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
contract ZIC_Token is ERC20, Ownable {&#13;
    using SafeMath for uint256;&#13;
&#13;
    string public name = "Zinscoin";&#13;
    string public symbol = "ZIC";&#13;
    uint public decimals = 5;&#13;
&#13;
    uint public chainStartTime;&#13;
    uint public chainStartBlockNumber;&#13;
    uint public stakeStartTime;&#13;
    uint public stakeMinAge = 10 days; // minimum coin age: 10 Days&#13;
    uint public maxMintProofOfStake = 5 * 10 ** uint256(decimals-2); // Anual reward after 50 years: 5%&#13;
&#13;
    uint public totalSupply;&#13;
    uint public maxTotalSupply;&#13;
    uint public totalInitialSupply;&#13;
&#13;
    struct transferInStruct{&#13;
    uint128 amount;&#13;
    uint64 time;&#13;
    }&#13;
&#13;
    mapping(address =&gt; uint256) balances;&#13;
    mapping(address =&gt; mapping (address =&gt; uint256)) allowed;&#13;
    mapping(address =&gt; transferInStruct[]) transferIns;&#13;
    &#13;
    event Mint(address indexed _address, uint _reward);&#13;
    event Burn(address indexed burner, uint256 value);&#13;
&#13;
    /**&#13;
     * @dev Fix for the ERC20 short address attack.&#13;
     */&#13;
    modifier onlyPayloadSize(uint size) {&#13;
        require(msg.data.length &gt;= size + 4);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier canPoSMint() {&#13;
        require(totalSupply &lt; maxTotalSupply);&#13;
        _;&#13;
    }&#13;
&#13;
    constructor() public {&#13;
        maxTotalSupply = 2100000000 * 10 ** uint256(decimals); // Max supply: 2,100,000,000&#13;
        totalInitialSupply = 50000 * 10 ** uint256(decimals); // Initial supply: 50,000&#13;
&#13;
        chainStartTime = now;&#13;
        chainStartBlockNumber = block.number;&#13;
&#13;
        balances[owner] = totalInitialSupply;&#13;
        emit Transfer(0x0, owner, totalInitialSupply);&#13;
        totalSupply = totalInitialSupply;&#13;
    }&#13;
&#13;
    function transfer(address _to, uint256 _value) onlyPayloadSize(2 * 32) public returns (bool) {&#13;
        if(msg.sender == _to) return mint();&#13;
        balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
        balances[_to] = balances[_to].add(_value);&#13;
        emit Transfer(msg.sender, _to, _value);&#13;
        if(transferIns[msg.sender].length &gt; 0) delete transferIns[msg.sender];&#13;
        uint64 _now = uint64(now);&#13;
        transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),_now));&#13;
        transferIns[_to].push(transferInStruct(uint128(_value),_now));&#13;
        return true;&#13;
    }&#13;
&#13;
    function balanceOf(address _owner) public constant returns (uint256 balance) {&#13;
        return balances[_owner];&#13;
    }&#13;
&#13;
    function transferFrom(address _from, address _to, uint256 _value) onlyPayloadSize(3 * 32) public returns (bool) {&#13;
        require(_to != address(0));&#13;
        require(_value &lt;= balances[_from]);&#13;
        require(_value &lt;= allowed[_from][msg.sender]);&#13;
&#13;
        balances[_from] = balances[_from].sub(_value);&#13;
        balances[_to] = balances[_to].add(_value);&#13;
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);&#13;
        emit Transfer(_from, _to, _value);&#13;
        if(transferIns[_from].length &gt; 0) delete transferIns[_from];&#13;
        uint64 _now = uint64(now);&#13;
        transferIns[_from].push(transferInStruct(uint128(balances[_from]),_now));&#13;
        transferIns[_to].push(transferInStruct(uint128(_value),_now));&#13;
        return true;&#13;
    }&#13;
&#13;
    function approve(address _spender, uint256 _value) public returns (bool) {&#13;
        require((_value == 0) || (allowed[msg.sender][_spender] == 0));&#13;
&#13;
        allowed[msg.sender][_spender] = _value;&#13;
        emit Approval(msg.sender, _spender, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {&#13;
        return allowed[_owner][_spender];&#13;
    }&#13;
&#13;
    function mint() canPoSMint public returns (bool) {&#13;
        if(balances[msg.sender] &lt;= 0) return false;&#13;
        if(transferIns[msg.sender].length &lt;= 0) return false;&#13;
&#13;
        uint reward = getProofOfStakeReward(msg.sender);&#13;
        if(reward &lt;= 0) return false;&#13;
&#13;
        totalSupply = totalSupply.add(reward);&#13;
        balances[msg.sender] = balances[msg.sender].add(reward);&#13;
        delete transferIns[msg.sender];&#13;
        transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),uint64(now)));&#13;
&#13;
        emit Mint(msg.sender, reward);&#13;
        return true;&#13;
    }&#13;
&#13;
    function getBlockNumber() public view returns (uint blockNumber) {&#13;
        blockNumber = block.number.sub(chainStartBlockNumber);&#13;
    }&#13;
&#13;
    function coinAge() public constant returns (uint myCoinAge) {&#13;
        myCoinAge = getCoinAge(msg.sender,now);&#13;
    }&#13;
&#13;
    function annualInterest() public constant returns(uint interest) {&#13;
        uint _now = now;&#13;
        interest = maxMintProofOfStake;&#13;
        if((_now.sub(stakeStartTime)) &lt;= 30 years) {&#13;
            interest = 4 * maxMintProofOfStake; // Anual reward years (0, 30]: 20%&#13;
        } else if((_now.sub(stakeStartTime)) &gt; 30 years &amp;&amp; (_now.sub(stakeStartTime)) &lt;= 50 years){&#13;
            interest = 2 * maxMintProofOfStake; // Anual reward years (30, 50]: 20%&#13;
        }&#13;
    }&#13;
&#13;
    function getProofOfStakeReward(address _address) internal returns (uint) {&#13;
        require( (now &gt;= stakeStartTime) &amp;&amp; (stakeStartTime &gt; 0) );&#13;
&#13;
        uint _now = now;&#13;
        uint _coinAge = getCoinAge(_address, _now);&#13;
        if(_coinAge &lt;= 0) return 0;&#13;
        &#13;
        uint interest = maxMintProofOfStake;&#13;
        if((_now.sub(stakeStartTime)) &lt;= 30 years) {&#13;
            interest = 4 * maxMintProofOfStake; // Anual reward years (0, 30]: 20%&#13;
        } else if((_now.sub(stakeStartTime)) &gt; 30 years &amp;&amp; (_now.sub(stakeStartTime)) &lt;= 50 years){&#13;
            interest = 2 * maxMintProofOfStake; // Anual reward years (30, 50]: 20%&#13;
        }&#13;
&#13;
        return (_coinAge * interest).div(365 * 10 ** uint256(decimals));&#13;
    }&#13;
&#13;
    function getCoinAge(address _address, uint _now) internal returns (uint _coinAge) {&#13;
        if(transferIns[_address].length &lt;= 0) return 0;&#13;
&#13;
        for (uint i = 0; i &lt; transferIns[_address].length; i++){&#13;
            if( _now &lt; uint(transferIns[_address][i].time).add(stakeMinAge) ) continue;&#13;
&#13;
            uint nCoinSeconds = _now.sub(uint(transferIns[_address][i].time));&#13;
&#13;
            _coinAge = _coinAge.add(uint(transferIns[_address][i].amount) * nCoinSeconds.div(1 days));&#13;
        }&#13;
    }&#13;
&#13;
    function ownerSetStakeStartTime(uint timestamp) public onlyOwner {&#13;
        require((stakeStartTime &lt;= 0) &amp;&amp; (timestamp &gt;= chainStartTime));&#13;
        stakeStartTime = timestamp;&#13;
    }&#13;
&#13;
    function ownerBurnToken(uint _value) public onlyOwner {&#13;
        require(_value &gt; 0);&#13;
&#13;
        balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
        delete transferIns[msg.sender];&#13;
        transferIns[msg.sender].push(transferInStruct(uint128(balances[msg.sender]),uint64(now)));&#13;
&#13;
        totalSupply = totalSupply.sub(_value);&#13;
        totalInitialSupply = totalInitialSupply.sub(_value);&#13;
        maxTotalSupply = maxTotalSupply.sub(_value*10);&#13;
&#13;
        emit Burn(msg.sender, _value);&#13;
    }&#13;
}