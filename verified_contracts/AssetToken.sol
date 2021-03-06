pragma solidity ^0.4.11;
/*
Original Code from Toshendra Sharma Course at UDEMY
Personalization and modifications by Fares Akel - <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="c8aee6a9a6bca7a6a1a7e6a9a3ada488afa5a9a1a4e6aba7a5">[email protected]</a>&#13;
*/&#13;
contract admined {&#13;
	address public admin;&#13;
&#13;
	function admined(){&#13;
		admin = msg.sender;&#13;
	}&#13;
&#13;
	modifier onlyAdmin(){&#13;
		if(msg.sender != admin) revert();&#13;
		_;&#13;
	}&#13;
&#13;
	function transferAdminship(address newAdmin) onlyAdmin {&#13;
		admin = newAdmin;&#13;
	}&#13;
&#13;
}&#13;
&#13;
contract Token {&#13;
&#13;
	mapping (address =&gt; uint256) public balanceOf;&#13;
	// balanceOf[address] = 5;&#13;
	string public name;&#13;
	string public symbol;&#13;
	uint8 public decimal; &#13;
	uint256 public totalSupply;&#13;
	event Transfer(address indexed from, address indexed to, uint256 value);&#13;
&#13;
&#13;
	function Token(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits){&#13;
		balanceOf[msg.sender] = initialSupply;&#13;
		totalSupply = initialSupply;&#13;
		decimal = decimalUnits;&#13;
		symbol = tokenSymbol;&#13;
		name = tokenName;&#13;
	}&#13;
&#13;
	function transfer(address _to, uint256 _value){&#13;
		if(balanceOf[msg.sender] &lt; _value) revert();&#13;
		if(balanceOf[_to] + _value &lt; balanceOf[_to]) revert();&#13;
		//if(admin)&#13;
&#13;
		balanceOf[msg.sender] -= _value;&#13;
		balanceOf[_to] += _value;&#13;
		Transfer(msg.sender, _to, _value);&#13;
	}&#13;
&#13;
}&#13;
&#13;
contract AssetToken is admined, Token{&#13;
&#13;
&#13;
	function AssetToken(uint256 initialSupply, string tokenName, string tokenSymbol, uint8 decimalUnits, address centralAdmin) Token (0, tokenName, tokenSymbol, decimalUnits ){&#13;
		totalSupply = initialSupply;&#13;
		if(centralAdmin != 0)&#13;
			admin = centralAdmin;&#13;
		else&#13;
			admin = msg.sender;&#13;
		balanceOf[admin] = initialSupply;&#13;
		totalSupply = initialSupply;	&#13;
	}&#13;
&#13;
	function mintToken(address target, uint256 mintedAmount) onlyAdmin{&#13;
		balanceOf[target] += mintedAmount;&#13;
		totalSupply += mintedAmount;&#13;
		Transfer(0, this, mintedAmount);&#13;
		Transfer(this, target, mintedAmount);&#13;
	}&#13;
&#13;
	function transfer(address _to, uint256 _value){&#13;
		if(balanceOf[msg.sender] &lt;= 0) revert();&#13;
		if(balanceOf[msg.sender] &lt; _value) revert();&#13;
		if(balanceOf[_to] + _value &lt; balanceOf[_to]) revert();&#13;
		//if(admin)&#13;
		balanceOf[msg.sender] -= _value;&#13;
		balanceOf[_to] += _value;&#13;
		Transfer(msg.sender, _to, _value);&#13;
	}&#13;
&#13;
}