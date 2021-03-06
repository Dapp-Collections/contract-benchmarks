pragma solidity 0.4.24;

/*
* @author Ivan Borisov (<span class="__cf_email__" data-cfemail="300206020206010070575d51595c1e535f5d">[email protected]</span>) (Github.com/pillardevelopment)&#13;
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
		uint256 c = a / b;&#13;
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
interface ERC20 {&#13;
	function transfer (address _beneficiary, uint256 _tokenAmount) external returns (bool);&#13;
	function transferFromICO(address _to, uint256 _value) external returns(bool);&#13;
	function balanceOf(address who) external view returns (uint256);&#13;
}&#13;
&#13;
contract Ownable {&#13;
	address public owner;&#13;
	&#13;
	constructor() public {&#13;
		owner = msg.sender;&#13;
	}&#13;
	&#13;
	modifier onlyOwner() {&#13;
		require(msg.sender == owner);&#13;
		_;&#13;
	}&#13;
}&#13;
&#13;
/*********************************************************************************************************************&#13;
* @dev see https://github.com/ethereum/EIPs/issues/20 */&#13;
/*************************************************************************************************************/&#13;
contract WhalesburgCrowdsale is Ownable {&#13;
	using SafeMath for uint256;&#13;
	&#13;
	ERC20 public token;&#13;
	&#13;
	address public constant multisig = 0x5ac618ca87b61c1434325b6d60141c90f32590df;&#13;
	address constant bounty = 0x5ac618ca87b61c1434325b6d60141c90f32590df;&#13;
	address constant privateInvestors = 0x5ac618ca87b61c1434325b6d60141c90f32590df;&#13;
	address developers = 0xd7dadf6149FF75f76f36423CAD1E24c81847E85d;&#13;
	address constant founders = 0xd7dadf6149FF75f76f36423CAD1E24c81847E85d;&#13;
	&#13;
	uint256 public startICO = 1527989629; // Sunday, 03-Jun-18 16:00:00 UTC&#13;
	uint256 public endICO = 1530633600;  // Tuesday, 03-Jul-18 16:00:00 UTC&#13;
&#13;
	uint256 constant privateSaleTokens = 46988857;&#13;
	uint256 constant foundersReserve = 10000000;&#13;
	uint256 constant developmentReserve = 20500000;&#13;
	uint256 constant bountyReserve = 3500000;&#13;
&#13;
	uint256 public individualRoundCap = 1250000000000000000;&#13;
&#13;
	uint256 public constant hardCap = 1365000067400000000000; // 1365.0000674 ether&#13;
	&#13;
	uint256 public investors;&#13;
	&#13;
	uint256 public membersWhiteList;&#13;
	&#13;
	uint256 public constant buyPrice = 71800000000000; // 0.0000718 Ether&#13;
	&#13;
	bool public isFinalized = false;&#13;
	bool public distribute = false;&#13;
	&#13;
	uint256 public weisRaised;&#13;
	&#13;
	mapping (address =&gt; bool) public onChain;&#13;
	mapping (address =&gt; bool) whitelist;&#13;
	mapping (address =&gt; uint256) public moneySpent;&#13;
	&#13;
	address[] tokenHolders;&#13;
	&#13;
	event Finalized();&#13;
	event Authorized(address wlCandidate, uint256 timestamp);&#13;
	event Revoked(address wlCandidate, uint256 timestamp);&#13;
	&#13;
	constructor(ERC20 _token) public {&#13;
		require(_token != address(0));&#13;
		token = _token;&#13;
	}&#13;
	&#13;
	function setVestingAddress(address _newDevPool) public onlyOwner {&#13;
		developers = _newDevPool;&#13;
	}&#13;
	&#13;
	function distributionTokens() public onlyOwner {&#13;
		require(!distribute);&#13;
		token.transferFromICO(bounty, bountyReserve*1e18);&#13;
		token.transferFromICO(privateInvestors, privateSaleTokens*1e18);&#13;
		token.transferFromICO(developers, developmentReserve*1e18);&#13;
		token.transferFromICO(founders, foundersReserve*1e18);&#13;
		distribute = true;&#13;
	}&#13;
	&#13;
	/******************-- WhiteList --***************************/&#13;
	function authorize(address _beneficiary) public onlyOwner  {&#13;
		require(_beneficiary != address(0x0));&#13;
		require(!isWhitelisted(_beneficiary));&#13;
		whitelist[_beneficiary] = true;&#13;
		membersWhiteList++;&#13;
		emit Authorized(_beneficiary, now);&#13;
	}&#13;
	&#13;
	function addManyAuthorizeToWhitelist(address[] _beneficiaries) public onlyOwner {&#13;
		for (uint256 i = 0; i &lt; _beneficiaries.length; i++) {&#13;
			authorize(_beneficiaries[i]);&#13;
		}&#13;
	}&#13;
	&#13;
	function revoke(address _beneficiary) public  onlyOwner {&#13;
		whitelist[_beneficiary] = false;&#13;
		emit Revoked(_beneficiary, now);&#13;
	}&#13;
	&#13;
	function isWhitelisted(address who) public view returns(bool) {&#13;
		return whitelist[who];&#13;
	}&#13;
	&#13;
	function finalize() onlyOwner public {&#13;
		require(!isFinalized);&#13;
		require(now &gt;= endICO || weisRaised &gt;= hardCap);&#13;
		emit Finalized();&#13;
		isFinalized = true;&#13;
		token.transferFromICO(owner, token.balanceOf(this));&#13;
	}&#13;
	&#13;
	/***************************--Payable --*********************************************/&#13;
	&#13;
	function () public payable {&#13;
		if(isWhitelisted(msg.sender)) {&#13;
			require(now &gt;= startICO &amp;&amp; now &lt; endICO);&#13;
			currentSaleLimit();&#13;
			moneySpent[msg.sender] = moneySpent[msg.sender].add(msg.value);&#13;
			require(moneySpent[msg.sender] &lt;= individualRoundCap);&#13;
			sell(msg.sender, msg.value);&#13;
			weisRaised = weisRaised.add(msg.value);&#13;
			require(weisRaised &lt;= hardCap);&#13;
			multisig.transfer(msg.value);&#13;
		} else {&#13;
			revert();&#13;
		}&#13;
	}&#13;
	&#13;
	function currentSaleLimit() private {&#13;
		if(now &gt;= startICO &amp;&amp; now &lt; startICO+7200) {&#13;
			&#13;
			individualRoundCap = 1250000000000000000; // 1.25 ETH&#13;
		}&#13;
		else if(now &gt;= startICO+7200 &amp;&amp; now &lt; startICO+14400) {&#13;
			&#13;
			individualRoundCap = 3750000000000000000; // 3.75 ETH&#13;
		}&#13;
		else if(now &gt;= startICO+14400 &amp;&amp; now &lt; endICO) {&#13;
			&#13;
			individualRoundCap = hardCap; // 1365 ether&#13;
		}&#13;
		else {&#13;
			revert();&#13;
		}&#13;
	}&#13;
	&#13;
	function sell(address _investor, uint256 amount) private {&#13;
		uint256 _amount = amount.mul(1e18).div(buyPrice);&#13;
		token.transferFromICO(_investor, _amount);&#13;
		if (!onChain[msg.sender]) {&#13;
			tokenHolders.push(msg.sender);&#13;
			onChain[msg.sender] = true;&#13;
		}&#13;
		investors = tokenHolders.length;&#13;
	}&#13;
}