pragma solidity ^0.4.24;

// ----------------------------------------------------------------------------
// 'SMARTZ' token contract
//
// Deployed to : 0xCB5FFc129Db563bBced9dF68b8256f1F229668a2
// Symbol      : STZ
// Name        : <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="e1b2aca1b3b5bb">[email protected]</a>&#13;
// Total supply: 100000000&#13;
// Decimals    : 2&#13;
//&#13;
// Enjoy.&#13;
//&#13;
// (c) by Moritz Neto with BokkyPooBah / Bok Consulting Pty Ltd Au 2017. The MIT Licence.&#13;
// ----------------------------------------------------------------------------&#13;
&#13;
&#13;
// ----------------------------------------------------------------------------&#13;
// Safe maths&#13;
// ----------------------------------------------------------------------------&#13;
contract SafeMath {&#13;
    function safeAdd(uint a, uint b) public pure returns (uint c) {&#13;
        c = a + b;&#13;
        require(c &gt;= a);&#13;
    }&#13;
    function safeSub(uint a, uint b) public pure returns (uint c) {&#13;
        require(b &lt;= a);&#13;
        c = a - b;&#13;
    }&#13;
    function safeMul(uint a, uint b) public pure returns (uint c) {&#13;
        c = a * b;&#13;
        require(a == 0 || c / a == b);&#13;
    }&#13;
    function safeDiv(uint a, uint b) public pure returns (uint c) {&#13;
        require(b &gt; 0);&#13;
        c = a / b;&#13;
    }&#13;
}&#13;
&#13;
&#13;
// ----------------------------------------------------------------------------&#13;
// ERC Token Standard #20 Interface&#13;
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md&#13;
// ----------------------------------------------------------------------------&#13;
contract ERC20Interface {&#13;
    function totalSupply() public constant returns (uint);&#13;
    function balanceOf(address tokenOwner) public constant returns (uint balance);&#13;
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);&#13;
    function transfer(address to, uint tokens) public returns (bool success);&#13;
    function approve(address spender, uint tokens) public returns (bool success);&#13;
    function transferFrom(address from, address to, uint tokens) public returns (bool success);&#13;
&#13;
    event Transfer(address indexed from, address indexed to, uint tokens);&#13;
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);&#13;
}&#13;
&#13;
&#13;
// ----------------------------------------------------------------------------&#13;
// Contract function to receive approval and execute function in one call&#13;
//&#13;
// Borrowed from MiniMeToken&#13;
// ----------------------------------------------------------------------------&#13;
contract ApproveAndCallFallBack {&#13;
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;&#13;
}&#13;
&#13;
&#13;
// ----------------------------------------------------------------------------&#13;
// Owned contract&#13;
// ----------------------------------------------------------------------------&#13;
contract Owned {&#13;
    address public owner;&#13;
    address public newOwner;&#13;
&#13;
    event OwnershipTransferred(address indexed _from, address indexed _to);&#13;
&#13;
    constructor() public {&#13;
        owner = msg.sender;&#13;
    }&#13;
&#13;
    modifier onlyOwner {&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
&#13;
    function transferOwnership(address _newOwner) public onlyOwner {&#13;
        newOwner = _newOwner;&#13;
    }&#13;
    function acceptOwnership() public {&#13;
        require(msg.sender == newOwner);&#13;
        emit OwnershipTransferred(owner, newOwner);&#13;
        owner = newOwner;&#13;
        newOwner = address(0);&#13;
    }&#13;
}&#13;
&#13;
&#13;
// ----------------------------------------------------------------------------&#13;
// ERC20 Token, with the addition of symbol, name and decimals and assisted&#13;
// token transfers&#13;
// ----------------------------------------------------------------------------&#13;
contract SMARTZ is ERC20Interface, Owned, SafeMath {&#13;
    string public symbol;&#13;
    string public  name;&#13;
    uint8 public decimals;&#13;
    uint public _totalSupply;&#13;
&#13;
    mapping(address =&gt; uint) balances;&#13;
    mapping(address =&gt; mapping(address =&gt; uint)) allowed;&#13;
&#13;
&#13;
    // ------------------------------------------------------------------------&#13;
    // Constructor&#13;
    // ------------------------------------------------------------------------&#13;
    constructor() public {&#13;
        symbol = "STZ";&#13;
        name = "<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="1546585547414f">[email protected]</a>";&#13;
        decimals = 2;&#13;
        _totalSupply = 2100000000000000;&#13;
        balances[0xCB5FFc129Db563bBced9dF68b8256f1F229668a2] = _totalSupply;&#13;
        emit Transfer(address(0), 0xCB5FFc129Db563bBced9dF68b8256f1F229668a2, _totalSupply);&#13;
    }&#13;
&#13;
&#13;
    // ------------------------------------------------------------------------&#13;
    // Total supply&#13;
    // ------------------------------------------------------------------------&#13;
    function totalSupply() public constant returns (uint) {&#13;
        return _totalSupply  - balances[address(0)];&#13;
    }&#13;
&#13;
&#13;
    // ------------------------------------------------------------------------&#13;
    // Get the token balance for account tokenOwner&#13;
    // ------------------------------------------------------------------------&#13;
    function balanceOf(address tokenOwner) public constant returns (uint balance) {&#13;
        return balances[tokenOwner];&#13;
    }&#13;
&#13;
&#13;
    // ------------------------------------------------------------------------&#13;
    // Transfer the balance from token owner's account to to account&#13;
    // - Owner's account must have sufficient balance to transfer&#13;
    // - 0 value transfers are allowed&#13;
    // ------------------------------------------------------------------------&#13;
    function transfer(address to, uint tokens) public returns (bool success) {&#13;
        balances[msg.sender] = safeSub(balances[msg.sender], tokens);&#13;
        balances[to] = safeAdd(balances[to], tokens);&#13;
        emit Transfer(msg.sender, to, tokens);&#13;
        return true;&#13;
    }&#13;
&#13;
&#13;
    // ------------------------------------------------------------------------&#13;
    // Token owner can approve for spender to transferFrom(...) tokens&#13;
    // from the token owner's account&#13;
    //&#13;
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md&#13;
    // recommends that there are no checks for the approval double-spend attack&#13;
    // as this should be implemented in user interfaces &#13;
    // ------------------------------------------------------------------------&#13;
    function approve(address spender, uint tokens) public returns (bool success) {&#13;
        allowed[msg.sender][spender] = tokens;&#13;
        emit Approval(msg.sender, spender, tokens);&#13;
        return true;&#13;
    }&#13;
&#13;
&#13;
    // ------------------------------------------------------------------------&#13;
    // Transfer tokens from the from account to the to account&#13;
    // &#13;
    // The calling account must already have sufficient tokens approve(...)-d&#13;
    // for spending from the from account and&#13;
    // - From account must have sufficient balance to transfer&#13;
    // - Spender must have sufficient allowance to transfer&#13;
    // - 0 value transfers are allowed&#13;
    // ------------------------------------------------------------------------&#13;
    function transferFrom(address from, address to, uint tokens) public returns (bool success) {&#13;
        balances[from] = safeSub(balances[from], tokens);&#13;
        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);&#13;
        balances[to] = safeAdd(balances[to], tokens);&#13;
        emit Transfer(from, to, tokens);&#13;
        return true;&#13;
    }&#13;
&#13;
&#13;
    // ------------------------------------------------------------------------&#13;
    // Returns the amount of tokens approved by the owner that can be&#13;
    // transferred to the spender's account&#13;
    // ------------------------------------------------------------------------&#13;
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {&#13;
        return allowed[tokenOwner][spender];&#13;
    }&#13;
&#13;
&#13;
    // ------------------------------------------------------------------------&#13;
    // Token owner can approve for spender to transferFrom(...) tokens&#13;
    // from the token owner's account. The spender contract function&#13;
    // receiveApproval(...) is then executed&#13;
    // ------------------------------------------------------------------------&#13;
    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {&#13;
        allowed[msg.sender][spender] = tokens;&#13;
        emit Approval(msg.sender, spender, tokens);&#13;
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);&#13;
        return true;&#13;
    }&#13;
&#13;
&#13;
    // ------------------------------------------------------------------------&#13;
    // Don't accept ETH&#13;
    // ------------------------------------------------------------------------&#13;
    function () public payable {&#13;
        revert();&#13;
    }&#13;
&#13;
&#13;
    // ------------------------------------------------------------------------&#13;
    // Owner can transfer out any accidentally sent ERC20 tokens&#13;
    // ------------------------------------------------------------------------&#13;
    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {&#13;
        return ERC20Interface(tokenAddress).transfer(owner, tokens);&#13;
    }&#13;
}