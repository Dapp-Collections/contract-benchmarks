/*
This file is part of the eHealth First Contract.

www.ehfirst.io

An IT-platform for Personalized Health and Longevity Management
based on Blockchain, Artificial Intelligence,
Machine Learning and Natural Language Processing

The eHealth First Contract is free software: you can redistribute it and/or
modify it under the terms of the GNU lesser General Public License as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

The eHealth First Contract is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with the eHealth First Contract. If not, see <http://www.gnu.org/licenses/>.

@author Ilya Svirin <<span class="__cf_email__" data-cfemail="e68fc895908f948f88a6969489908394c89493">[email protected]</span>&gt;&#13;
&#13;
IF YOU ARE ENJOYED IT DONATE TO 0x3Ad38D1060d1c350aF29685B2b8Ec3eDE527452B ! :)&#13;
*/&#13;
&#13;
&#13;
pragma solidity ^0.4.19;&#13;
&#13;
contract owned {&#13;
&#13;
    address public owner;&#13;
    address public candidate;&#13;
&#13;
  function owned() public payable {&#13;
         owner = msg.sender;&#13;
     }&#13;
    &#13;
    modifier onlyOwner {&#13;
        require(owner == msg.sender);&#13;
        _;&#13;
    }&#13;
&#13;
    function changeOwner(address _owner) onlyOwner public {&#13;
        require(_owner != 0);&#13;
        candidate = _owner;&#13;
    }&#13;
    &#13;
    function confirmOwner() public {&#13;
        require(candidate == msg.sender);&#13;
        owner = candidate;&#13;
        delete candidate;&#13;
    }&#13;
}&#13;
&#13;
/**&#13;
 * @title ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/20&#13;
 */&#13;
contract ERC20 {&#13;
    uint public totalSupply;&#13;
    function balanceOf(address who) public constant returns (uint);&#13;
    function transfer(address to, uint value) public;&#13;
    function allowance(address owner, address spender) public constant returns (uint);&#13;
    function transferFrom(address from, address to, uint value) public;&#13;
    function approve(address spender, uint value) public;&#13;
    event Approval(address indexed owner, address indexed spender, uint value);&#13;
    event Transfer(address indexed from, address indexed to, uint value);&#13;
}&#13;
&#13;
contract Token is owned, ERC20 {&#13;
&#13;
    string  public standard    = 'Token 0.1';&#13;
    string  public name        = 'eHealth First';&#13;
    string  public symbol      = "EHF";&#13;
    uint8   public decimals    = 8;&#13;
&#13;
    uint    public freezedMoment;&#13;
&#13;
    struct TokenHolder {&#13;
        uint balance;&#13;
        uint balanceBeforeUpdate;&#13;
        uint balanceUpdateTime;&#13;
    }&#13;
    mapping (address =&gt; TokenHolder) public holders;&#13;
    mapping (address =&gt; uint) public vesting;&#13;
    mapping (address =&gt; mapping (address =&gt; uint256)) public allowed;&#13;
&#13;
    address public vestingManager;&#13;
&#13;
    function setVestingManager(address _vestingManager) public onlyOwner {&#13;
        vestingManager = _vestingManager;&#13;
    }&#13;
&#13;
    function beforeBalanceChanges(address _who) internal {&#13;
        if (holders[_who].balanceUpdateTime &lt;= freezedMoment) {&#13;
            holders[_who].balanceUpdateTime = now;&#13;
            holders[_who].balanceBeforeUpdate = holders[_who].balance;&#13;
        }&#13;
    }&#13;
&#13;
    event Burned(address indexed owner, uint256 value);&#13;
&#13;
    function Token() public owned() {}&#13;
&#13;
    function balanceOf(address _who) constant public returns (uint) {&#13;
        return holders[_who].balance;&#13;
    }&#13;
&#13;
    function transfer(address _to, uint256 _value) public {&#13;
        require(now &gt; vesting[msg.sender] || msg.sender == vestingManager);&#13;
        require(holders[_to].balance + _value &gt;= holders[_to].balance); // overflow&#13;
        beforeBalanceChanges(msg.sender);&#13;
        beforeBalanceChanges(_to);&#13;
        holders[msg.sender].balance -= _value;&#13;
        holders[_to].balance += _value;&#13;
        if (vesting[_to] &lt; vesting[msg.sender]) {&#13;
            vesting[_to] = vesting[msg.sender];&#13;
        }&#13;
        emit Transfer(msg.sender, _to, _value);&#13;
    }&#13;
    &#13;
    function transferFrom(address _from, address _to, uint256 _value) public {&#13;
        require(now &gt; vesting[_from]);&#13;
        require(holders[_to].balance + _value &gt;= holders[_to].balance); // overflow&#13;
        require(allowed[_from][msg.sender] &gt;= _value);&#13;
        beforeBalanceChanges(_from);&#13;
        beforeBalanceChanges(_to);&#13;
        holders[_from].balance -= _value;&#13;
        holders[_to].balance += _value;&#13;
        allowed[_from][msg.sender] -= _value;&#13;
        emit Transfer(_from, _to, _value);&#13;
    }&#13;
&#13;
    function approve(address _spender, uint256 _value) public {&#13;
        allowed[msg.sender][_spender] = _value;&#13;
        emit Approval(msg.sender, _spender, _value);&#13;
    }&#13;
&#13;
    function allowance(address _owner, address _spender) public constant&#13;
        returns (uint256 remaining) {&#13;
        return allowed[_owner][_spender];&#13;
    }&#13;
    &#13;
    function burn(uint256 _value) public {&#13;
        require(holders[msg.sender].balance &gt;= _value);&#13;
        beforeBalanceChanges(msg.sender);&#13;
        holders[msg.sender].balance -= _value;&#13;
        totalSupply -= _value;&#13;
        emit Burned(msg.sender, _value);&#13;
    }&#13;
}&#13;
&#13;
contract Crowdsale is Token {&#13;
&#13;
    address public backend;&#13;
&#13;
    uint public stage;&#13;
    bool public started;&#13;
    uint public startTokenPriceWei;&#13;
    uint public tokensForSale;&#13;
    uint public startTime;&#13;
    uint public lastTokenPriceWei;&#13;
    uint public milliPercent; // "25" means 0.25%&#13;
    uint public paymentsCount; // restart on each stage&#13;
    bool public sealed;&#13;
    modifier notSealed {&#13;
        require(sealed == false);&#13;
        _;&#13;
    }&#13;
&#13;
    event Mint(address indexed _who, uint _tokens, uint _coinType, bytes32 _txHash);&#13;
    event Stage(uint _stage, bool startNotFinish);&#13;
&#13;
    function Crowdsale() public Token() {&#13;
        totalSupply = 100000000*100000000;&#13;
        holders[this].balance = totalSupply;&#13;
    }&#13;
&#13;
    function startStage(uint _startTokenPriceWei, uint _tokensForSale, uint _milliPercent) public onlyOwner notSealed {&#13;
        require(!started);&#13;
        require(_startTokenPriceWei &gt;= lastTokenPriceWei);&#13;
        startTokenPriceWei = _startTokenPriceWei;&#13;
        tokensForSale = _tokensForSale * 100000000;&#13;
        if(tokensForSale &gt; holders[this].balance) {&#13;
            tokensForSale = holders[this].balance;&#13;
        }&#13;
        milliPercent = _milliPercent;&#13;
        startTime = now;&#13;
        started = true;&#13;
        paymentsCount = 0;&#13;
        emit Stage(stage, started);&#13;
    }&#13;
    &#13;
    function currentTokenPrice() public constant returns(uint) {&#13;
        uint price;&#13;
        if(!sealed &amp;&amp; started) {&#13;
            uint d = (now - startTime) / 1 days;&#13;
            price = startTokenPriceWei;&#13;
            price += startTokenPriceWei * d * milliPercent / 100;&#13;
        }&#13;
        return price;&#13;
    }&#13;
    &#13;
    function stopStage() public onlyOwner notSealed {&#13;
        require(started);&#13;
        started = false;&#13;
        lastTokenPriceWei = currentTokenPrice();&#13;
        emit Stage(stage, started);&#13;
        ++stage;&#13;
    }&#13;
    &#13;
    function () payable public notSealed {&#13;
        require(started);&#13;
        uint price = currentTokenPrice();&#13;
        if(paymentsCount &lt; 100) {&#13;
            price = price * 90 / 100;&#13;
        }&#13;
        ++paymentsCount;&#13;
        uint tokens = 100000000 * msg.value / price;&#13;
        if(tokens &gt; tokensForSale) {&#13;
            tokens = tokensForSale;&#13;
            uint sumWei = tokens * lastTokenPriceWei / 100000000;&#13;
            require(msg.sender.call.gas(3000000).value(msg.value - sumWei)());&#13;
        }&#13;
        require(tokens &gt; 0);&#13;
        require(holders[msg.sender].balance + tokens &gt; holders[msg.sender].balance); // overflow&#13;
        tokensForSale -= tokens;&#13;
        beforeBalanceChanges(msg.sender);&#13;
        beforeBalanceChanges(this);&#13;
        holders[msg.sender].balance += tokens;&#13;
        holders[this].balance -= tokens;&#13;
        emit Transfer(this, msg.sender, tokens);&#13;
    }&#13;
&#13;
    function mintTokens1(address _who, uint _tokens, uint _coinType, bytes32 _txHash) public notSealed {&#13;
        require(msg.sender == owner || msg.sender == backend);&#13;
        require(started);&#13;
        _tokens *= 100000000;&#13;
        if(_tokens &gt; tokensForSale) {&#13;
            _tokens = tokensForSale;&#13;
        }&#13;
        require(_tokens &gt; 0);&#13;
        require(holders[_who].balance + _tokens &gt; holders[_who].balance); // overflow&#13;
        tokensForSale -= _tokens;&#13;
        beforeBalanceChanges(_who);&#13;
        beforeBalanceChanges(this);&#13;
        holders[_who].balance += _tokens;&#13;
        holders[this].balance -= _tokens;&#13;
        emit Mint(_who, _tokens, _coinType, _txHash);&#13;
        emit Transfer(this, _who, _tokens);&#13;
    }&#13;
    &#13;
    // must be called by owners only out of stage&#13;
    function mintTokens2(address _who, uint _tokens, uint _vesting) public notSealed {&#13;
        require(msg.sender == owner || msg.sender == backend);&#13;
        require(!started);&#13;
        require(_tokens &gt; 0);&#13;
        _tokens *= 100000000;&#13;
        require(_tokens &lt;= holders[this].balance);&#13;
        require(holders[_who].balance + _tokens &gt; holders[_who].balance); // overflow&#13;
        if(_vesting != 0) {&#13;
            vesting[_who] = _vesting;&#13;
        }&#13;
        beforeBalanceChanges(_who);&#13;
        beforeBalanceChanges(this);&#13;
        holders[_who].balance += _tokens;&#13;
        holders[this].balance -= _tokens;&#13;
        emit Mint(_who, _tokens, 0, 0);&#13;
        emit Transfer(this, _who, _tokens);&#13;
    }&#13;
&#13;
    // need to seal Crowdsale when it is finished completely&#13;
    function seal() public onlyOwner {&#13;
        sealed = true;&#13;
    }&#13;
}&#13;
&#13;
contract Ehfirst is Crowdsale {&#13;
&#13;
   function Ehfirst() payable public Crowdsale() {}&#13;
&#13;
    function setBackend(address _backend) public onlyOwner {&#13;
        backend = _backend;&#13;
    }&#13;
    &#13;
    function withdraw() public onlyOwner {&#13;
        require(owner.call.gas(3000000).value(address(this).balance)());&#13;
    }&#13;
    &#13;
    function freezeTheMoment() public onlyOwner {&#13;
        freezedMoment = now;&#13;
    }&#13;
&#13;
    /** Get balance of _who for freezed moment&#13;
     *  freezeTheMoment()&#13;
     */&#13;
    function freezedBalanceOf(address _who) constant public returns(uint) {&#13;
        if (holders[_who].balanceUpdateTime &lt;= freezedMoment) {&#13;
            return holders[_who].balance;&#13;
        } else {&#13;
            return holders[_who].balanceBeforeUpdate;&#13;
        }&#13;
    }&#13;
}