pragma solidity ^0.4.25;

/******************************************/
/*       Netkiller Mini TOKEN             */
/******************************************/
/* Author netkiller <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="1b757e6f707277777e695b76687535787476">[email protected]</a>&gt;   */&#13;
/* Home http://www.netkiller.cn           */&#13;
/* Version 2018-09-26 Test Token          */&#13;
/******************************************/&#13;
&#13;
contract NetkillerTestToken {&#13;
    address public owner;&#13;
&#13;
    string public name;&#13;
    string public symbol;&#13;
    uint public decimals;&#13;
    uint256 public totalSupply;&#13;
&#13;
    mapping (address =&gt; uint256) public balanceOf;&#13;
    mapping (address =&gt; mapping (address =&gt; uint256)) public allowance;&#13;
&#13;
    event Transfer(address indexed from, address indexed to, uint256 value);&#13;
    event Approval(address indexed owner, address indexed spender, uint256 value);&#13;
&#13;
&#13;
    constructor(&#13;
        uint256 initialSupply,&#13;
        string tokenName,&#13;
        string tokenSymbol,&#13;
        uint decimalUnits&#13;
    ) public {&#13;
        owner = msg.sender;&#13;
        name = tokenName; &#13;
        symbol = tokenSymbol; &#13;
        decimals = decimalUnits;&#13;
        totalSupply = initialSupply * 10 ** uint256(decimals); &#13;
        balanceOf[msg.sender] = totalSupply;&#13;
    }&#13;
&#13;
    modifier onlyOwner {&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
    function setSupply(uint256 _initialSupply) onlyOwner public{&#13;
        totalSupply = _initialSupply * 10 ** uint256(decimals);&#13;
    }&#13;
    function setName(string _name) onlyOwner public{&#13;
        name = _name;&#13;
    }&#13;
    function setSymbol(string _symbol) onlyOwner public{&#13;
        symbol = _symbol;&#13;
    }&#13;
    function setDecimals(uint _decimals) onlyOwner public{&#13;
        decimals = _decimals;&#13;
    }&#13;
&#13;
    function transferOwnership(address newOwner) onlyOwner public {&#13;
        if (newOwner != address(0)) {&#13;
            owner = newOwner;&#13;
        }&#13;
    }&#13;
 &#13;
    function _transfer(address _from, address _to, uint _value) internal {&#13;
        require (_to != address(0));                        // Prevent transfer to 0x0 address. Use burn() instead&#13;
        require (balanceOf[_from] &gt;= _value);               // Check if the sender has enough&#13;
        require (balanceOf[_to] + _value &gt; balanceOf[_to]); // Check for overflows&#13;
        balanceOf[_from] -= _value;                         // Subtract from the sender&#13;
        balanceOf[_to] += _value;                           // Add the same to the recipient&#13;
        emit Transfer(_from, _to, _value);&#13;
    }&#13;
&#13;
    function transfer(address _to, uint256 _value) public returns (bool success){&#13;
        _transfer(msg.sender, _to, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {&#13;
        require(_value &lt;= allowance[_from][msg.sender]);     // Check allowance&#13;
        allowance[_from][msg.sender] -= _value;&#13;
        _transfer(_from, _to, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    function approve(address _spender, uint256 _value) public returns (bool success) {&#13;
        allowance[msg.sender][_spender] = _value;&#13;
        emit Approval(msg.sender, _spender, _value);&#13;
        return true;&#13;
    }&#13;
}