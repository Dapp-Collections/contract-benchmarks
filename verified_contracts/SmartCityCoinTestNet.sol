/*
This is the contract for Smart City Coin Test Net(SCCTN) 

Smart City Coin Test Net(SCCTN) is utility token designed to be used as prepayment and payment in Smart City Shop.

Smart City Coin Test Net(SCCTN) is utility token designed also to be proof of membership in Smart City Club.

Token implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20

Smart City Coin Test Net is as the name implies Test Network - it was deployed in order to test functionalities, options, user interface, liquidity, price fluctuation, type of users, 
market research and get first-hand feedback from all involved. We ask all users to be aware of test nature of the token - have patience and preferably 
report all errors, opinions, shortcomings to our email address <span class="__cf_email__" data-cfemail="fe97909891be8d939f8c8a9d978a879d919790d09d9193d0">[email protected]</span> Ask for bounty program for reporting shortcomings and improvement of functionalities. &#13;
&#13;
Smart City Coin Test Network is life real-world test with the goal to gather inputs for the Smart City Coin project.&#13;
&#13;
Smart City Coin Test Network is intended to be used by a skilled professional that understand and accept technology risk involved. &#13;
&#13;
Smart City Coin Test Net and Smart City Shop are operated by Smart City AG.&#13;
&#13;
Smart City AG does not assume any liability for damages or losses occurred due to the usage of SCCTN, since as name implied this is test Network design to test technology and its behavior in the real world. &#13;
&#13;
You can find all about the project on http://www.smartcitycointest.net&#13;
You can use your coins in https://www.smartcityshop.net/  &#13;
You can contact us at <span class="__cf_email__" data-cfemail="99f0f7fff6d9eaf4f8ebedfaf0ede0faf6f0f7b7faf6f4">[email protected]</span> &#13;
*/&#13;
&#13;
pragma solidity ^0.4.24;&#13;
contract Token {&#13;
&#13;
    /// return total amount of tokens&#13;
    function totalSupply() public pure returns (uint256) {}&#13;
&#13;
    /// param _owner The address from which the balance will be retrieved&#13;
    /// return The balance&#13;
    function balanceOf(address) public payable returns (uint256) {}&#13;
&#13;
    /// notice send `_value` token to `_to` from `msg.sender`&#13;
    /// param _to The address of the recipient&#13;
    /// param _value The amount of token to be transferred&#13;
    /// return Whether the transfer was successful or not&#13;
    function transfer(address , uint256 ) public payable returns (bool) {}&#13;
&#13;
    /// notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`&#13;
    /// param _from The address of the sender&#13;
    /// param _to The address of the recipient&#13;
    /// param _value The amount of token to be transferred&#13;
    /// return Whether the transfer was successful or not&#13;
    function transferFrom(address , address , uint256 ) public payable returns (bool ) {}&#13;
&#13;
    /// notice `msg.sender` approves `_addr` to spend `_value` tokens&#13;
    /// param _spender The address of the account able to transfer the tokens&#13;
    /// param _value The amount of wei to be approved for transfer&#13;
    /// return Whether the approval was successful or not&#13;
    function approve(address , uint256 ) public payable returns (bool ) {}&#13;
&#13;
    /// param _owner The address of the account owning tokens&#13;
    /// param _spender The address of the account able to transfer the tokens&#13;
    /// return Amount of remaining tokens allowed to spent&#13;
    function allowance(address , address ) public payable returns (uint256 ) {}&#13;
&#13;
    event Transfer(address indexed _from, address indexed _to, uint256 _value);&#13;
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);&#13;
}&#13;
&#13;
&#13;
/*&#13;
This implements implements ERC 20 Token standard: https://github.com/ethereum/EIPs/issues/20&#13;
.*/&#13;
&#13;
contract StandardToken is Token {&#13;
&#13;
    function transfer(address _to, uint256 _value) public payable returns (bool ) {&#13;
        if (balances[msg.sender] &gt;= _value &amp;&amp; _value &gt; 0) {&#13;
            balances[msg.sender] -= _value;&#13;
            balances[_to] += _value;&#13;
            emit Transfer(msg.sender, _to, _value);&#13;
            return true;&#13;
        } else { return false; }&#13;
    }&#13;
&#13;
    function transferFrom(address _from, address _to, uint256 _value) public payable returns (bool ) {&#13;
        if (balances[_from] &gt;= _value &amp;&amp; allowed[_from][msg.sender] &gt;= _value &amp;&amp; _value &gt; 0) {&#13;
            balances[_to] += _value;&#13;
            balances[_from] -= _value;&#13;
            allowed[_from][msg.sender] -= _value;&#13;
            emit Transfer(_from, _to, _value);&#13;
            return true;&#13;
        } else { return false; }&#13;
    }&#13;
&#13;
    function balanceOf(address _owner) public payable  returns (uint256 ) {&#13;
        return balances[_owner];&#13;
    }&#13;
&#13;
    function approve(address _spender, uint256 _value) public payable returns (bool ) {&#13;
        allowed[msg.sender][_spender] = _value;&#13;
        emit Approval(msg.sender, _spender, _value);&#13;
        return true;&#13;
    }&#13;
&#13;
    function allowance(address _owner, address _spender) public payable returns (uint256 a ) {&#13;
      return allowed[_owner][_spender];&#13;
    }&#13;
&#13;
    mapping (address =&gt; uint256) balances;&#13;
    mapping (address =&gt; mapping (address =&gt; uint256)) allowed;&#13;
    uint256 public totalSupply;&#13;
}&#13;
&#13;
/*&#13;
This Token Contract implements the standard token functionality (https://github.com/ethereum/EIPs/issues/20) as well as the following OPTIONAL extras intended for use by humans.&#13;
&#13;
This Token will be deployed, and then used by humans - members of Smart City Community - as an utility token as a prepayment for services and Smart House Hardware in SmartCityShop - www.smartcityshop.net .&#13;
&#13;
This token specify&#13;
1) Initial Finite Supply (upon creation one specifies how much is minted).&#13;
2) In the absence of a token registry: Optional Decimal, Symbol &amp; Name.&#13;
3) Optional approveAndCall() functionality to notify a contract if an approval() has occurred.&#13;
&#13;
.*/&#13;
&#13;
contract SmartCityCoinTestNet is StandardToken {&#13;
&#13;
    function () public {&#13;
        //if ether is sent to this address, send it back.&#13;
        revert();&#13;
    }&#13;
&#13;
    /* Public variables of the token */&#13;
&#13;
    /*&#13;
    NOTE:&#13;
    We've inlcuded the following variables as OPTIONAL vanities. &#13;
    They in no way influences the core functionality.&#13;
    Some wallets/interfaces might not even bother to look at this information.&#13;
    */&#13;
    string public name;                   //fancy name: eg Simon Bucks&#13;
    uint8 public decimals;                //How many decimals to show. ie. There could 1000 base units with 3 decimals. Meaning 0.980 SBX = 980 base units. It's like comparing 1 wei to 1 ether.&#13;
    string public symbol;                 //An identifier: eg SBX&#13;
    string public version = 'H0.1';       //human 0.1 standard. Just an arbitrary versioning scheme.&#13;
&#13;
    constructor (&#13;
        uint256 _initialAmount,&#13;
        string _tokenName,&#13;
        uint8 _decimalUnits,&#13;
        string _tokenSymbol&#13;
        ) public {&#13;
        balances[msg.sender] = _initialAmount;               // Give the creator all initial tokens&#13;
        totalSupply = _initialAmount;                        // Update total supply&#13;
        name = _tokenName;                                   // Set the name for display purposes&#13;
        decimals = _decimalUnits;                            // Amount of decimals for display purposes&#13;
        symbol = _tokenSymbol;                               // Set the symbol for display purposes&#13;
    }&#13;
&#13;
    /* Approves and then calls the receiving contract */&#13;
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) public payable returns (bool )  {&#13;
        allowed[msg.sender][_spender] = _value;&#13;
        emit Approval(msg.sender, _spender, _value);&#13;
&#13;
        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.&#13;
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)&#13;
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.&#13;
        if(!_spender.call(bytes4(bytes32(keccak256("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { revert(); }&#13;
        return true;&#13;
    }&#13;
}