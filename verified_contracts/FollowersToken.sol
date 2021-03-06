pragma solidity ^0.4.18; // solhint-disable-line



/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="f793928392b7968f9e989a8d9299d99498">[email protected]</a>&gt; (https://github.com/dete)&#13;
contract ERC721 {&#13;
  // Required methods&#13;
  function approve(address _to, uint256 _tokenId) public;&#13;
  function balanceOf(address _owner) public view returns (uint256 balance);&#13;
  function implementsERC721() public pure returns (bool);&#13;
  function ownerOf(uint256 _tokenId) public view returns (address addr);&#13;
  function takeOwnership(uint256 _tokenId) public;&#13;
  function totalSupply() public view returns (uint256 total);&#13;
  function transferFrom(address _from, address _to, uint256 _tokenId) public;&#13;
  function transfer(address _to, uint256 _tokenId) public;&#13;
&#13;
  event Transfer(address indexed from, address indexed to, uint256 tokenId);&#13;
  event Approval(address indexed owner, address indexed approved, uint256 tokenId);&#13;
&#13;
  // Optional&#13;
  // function name() public view returns (string name);&#13;
  // function symbol() public view returns (string symbol);&#13;
  // function tokenOfOwnerByIndex(address _owner, uint256 _index) external view returns (uint256 tokenId);&#13;
  // function tokenMetadata(uint256 _tokenId) public view returns (string infoUrl);&#13;
}&#13;
&#13;
&#13;
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
contract FollowersToken is ERC721 {&#13;
&#13;
	string public constant NAME 		= "FollowersToken";&#13;
	string public constant SYMBOL 		= "FWTK";&#13;
&#13;
	uint256 private startingPrice	= 0.05 ether;&#13;
	uint256 private firstStepLimit 	= 6.4 ether;&#13;
	uint256 private secondStepLimit = 120.9324 ether;&#13;
	uint256 private thirdStepLimit 	= 792.5423 ether;&#13;
&#13;
	bool 	private isPresale;&#13;
&#13;
	mapping (uint256 =&gt; address) public personIndexToOwner;&#13;
	mapping (address =&gt; uint256) private ownershipTokenCount;&#13;
	mapping (uint256 =&gt; address) public personIndexToApproved;&#13;
	mapping (uint256 =&gt; uint256) private personIndexToPrice;&#13;
	mapping (uint256 =&gt; uint256) private personIndexToPriceLevel;&#13;
&#13;
	address public ceoAddress;&#13;
	address public cooAddress;&#13;
&#13;
	struct Person {&#13;
		string name;&#13;
	}&#13;
&#13;
	Person[] private persons;&#13;
&#13;
	modifier onlyCEO() {&#13;
		require(msg.sender == ceoAddress);&#13;
		_;&#13;
	}&#13;
&#13;
	modifier onlyCOO() {&#13;
		require(msg.sender == cooAddress);&#13;
		_;&#13;
	}&#13;
&#13;
	modifier onlyCLevel() {&#13;
		require( msg.sender == ceoAddress || msg.sender == cooAddress );&#13;
		_;&#13;
	}&#13;
&#13;
	constructor() public {&#13;
		ceoAddress = msg.sender;&#13;
		cooAddress = msg.sender;&#13;
		isPresale  = true;&#13;
	}&#13;
&#13;
	function startPresale() public onlyCLevel {&#13;
		isPresale = true;&#13;
	}&#13;
&#13;
	function stopPresale() public onlyCLevel {&#13;
		isPresale = false;&#13;
	}&#13;
&#13;
	function presale() public view returns ( bool presaleStatus ) {&#13;
		return isPresale;&#13;
	}&#13;
&#13;
	function approve( address _to, uint256 _tokenId ) public {&#13;
		// Caller must own token.&#13;
		require( _owns( msg.sender , _tokenId ) );&#13;
		personIndexToApproved[_tokenId] = _to;&#13;
		emit Approval( msg.sender , _to , _tokenId );&#13;
	}&#13;
&#13;
	function balanceOf(address _owner) public view returns (uint256 balance) {&#13;
		return ownershipTokenCount[_owner];&#13;
	}&#13;
&#13;
	function createContractPerson( string _name , uint256 _price , address _owner ) public onlyCOO {&#13;
		if ( _price &lt;= 0 ) {&#13;
			_price = startingPrice;&#13;
		}&#13;
		_createPerson( _name , _owner , _price );&#13;
	}&#13;
&#13;
	function getPerson(uint256 _tokenId) public view returns ( string personName, uint256 sellingPrice, address owner , uint256 sellingPriceNext , uint256 priceLevel ) {&#13;
		Person storage person = persons[_tokenId];&#13;
		personName 			= person.name;&#13;
		sellingPrice 		= personIndexToPrice[_tokenId];&#13;
		owner 				= personIndexToOwner[_tokenId];&#13;
		priceLevel 			= personIndexToPriceLevel[ _tokenId ];&#13;
		sellingPriceNext 	= _calcNextPrice( _tokenId );&#13;
	}&#13;
&#13;
	function _calcNextPrice( uint256 _tokenId ) private view returns ( uint256 nextSellingPrice ) {&#13;
		uint256 sellingPrice 	= priceOf( _tokenId );&#13;
		if( isPresale == true ){&#13;
			nextSellingPrice =  uint256( SafeMath.div( SafeMath.mul( sellingPrice, 400 ) , 100 ) );&#13;
		}else{&#13;
			if ( sellingPrice &lt; firstStepLimit ) {&#13;
				nextSellingPrice =  uint256( SafeMath.div( SafeMath.mul( sellingPrice, 200 ) , 100 ) );&#13;
			} else if ( sellingPrice &lt; secondStepLimit ) {&#13;
				nextSellingPrice =  uint256( SafeMath.div( SafeMath.mul( sellingPrice, 180 ) , 100 ) );&#13;
			} else if ( sellingPrice &lt; thirdStepLimit ) {&#13;
				nextSellingPrice =  uint256( SafeMath.div( SafeMath.mul( sellingPrice, 160 ) , 100 ) );&#13;
			} else {&#13;
				nextSellingPrice  =  uint256( SafeMath.div( SafeMath.mul( sellingPrice, 140 ) , 100 ) );&#13;
			}&#13;
		}&#13;
		return nextSellingPrice;&#13;
	}&#13;
&#13;
	function implementsERC721() public pure returns (bool) {&#13;
		return true;&#13;
	}&#13;
&#13;
	function name() public pure returns (string) {&#13;
		return NAME;&#13;
	}&#13;
&#13;
	function ownerOf( uint256 _tokenId ) public view returns ( address owner ){&#13;
		owner = personIndexToOwner[_tokenId];&#13;
		require( owner != address(0) );&#13;
	}&#13;
&#13;
	function payout( address _to ) public onlyCLevel {&#13;
		_payout( _to );&#13;
	}&#13;
&#13;
	function purchase(uint256 _tokenId) public payable {&#13;
		address oldOwner 		= personIndexToOwner[_tokenId];&#13;
		address newOwner 		= msg.sender;&#13;
		uint256 sellingPrice 	= personIndexToPrice[_tokenId];&#13;
&#13;
		require( oldOwner != newOwner );&#13;
		require( _addressNotNull( newOwner ) );&#13;
		require( msg.value &gt;= sellingPrice );&#13;
&#13;
		uint256 payment 		= uint256( SafeMath.div( SafeMath.mul( sellingPrice , 94 ) , 100 ) );&#13;
		uint256 purchaseExcess 	= SafeMath.sub( msg.value , sellingPrice );&#13;
&#13;
		if( isPresale == true ){&#13;
			require( personIndexToPriceLevel[ _tokenId ] == 0 );&#13;
		}&#13;
		personIndexToPrice[ _tokenId ] 		= _calcNextPrice( _tokenId );&#13;
		personIndexToPriceLevel[ _tokenId ] = SafeMath.add( personIndexToPriceLevel[ _tokenId ] , 1 );&#13;
&#13;
		_transfer( oldOwner , newOwner , _tokenId );&#13;
&#13;
		if ( oldOwner != address(this) ) {&#13;
			oldOwner.transfer( payment );&#13;
		}&#13;
&#13;
		msg.sender.transfer( purchaseExcess );&#13;
	}&#13;
&#13;
	function priceOf(uint256 _tokenId) public view returns (uint256 price) {&#13;
		return personIndexToPrice[_tokenId];&#13;
	}&#13;
&#13;
	function setCEO(address _newCEO) public onlyCEO {&#13;
		require(_newCEO != address(0));&#13;
		ceoAddress = _newCEO;&#13;
	}&#13;
&#13;
	function setCOO(address _newCOO) public onlyCEO {&#13;
		require(_newCOO != address(0));&#13;
		cooAddress = _newCOO;&#13;
	}&#13;
&#13;
	function symbol() public pure returns (string) {&#13;
		return SYMBOL;&#13;
	}&#13;
&#13;
	function takeOwnership(uint256 _tokenId) public {&#13;
		address newOwner = msg.sender;&#13;
		address oldOwner = personIndexToOwner[_tokenId];&#13;
		require(_addressNotNull(newOwner));&#13;
		require(_approved(newOwner, _tokenId));&#13;
		_transfer(oldOwner, newOwner, _tokenId);&#13;
	}&#13;
&#13;
	function tokensOfOwner(address _owner) public view returns( uint256[] ownerTokens ) {&#13;
		uint256 tokenCount = balanceOf(_owner);&#13;
		if (tokenCount == 0) {&#13;
			return new uint256[](0);&#13;
		} else {&#13;
			uint256[] memory result = new uint256[](tokenCount);&#13;
			uint256 totalPersons = totalSupply();&#13;
			uint256 resultIndex = 0;&#13;
			uint256 personId;&#13;
			for (personId = 0; personId &lt;= totalPersons; personId++) {&#13;
				if (personIndexToOwner[personId] == _owner) {&#13;
					result[resultIndex] = personId;&#13;
					resultIndex++;&#13;
				}&#13;
			}&#13;
			return result;&#13;
		}&#13;
	}&#13;
&#13;
	function totalSupply() public view returns (uint256 total) {&#13;
		return persons.length;&#13;
	}&#13;
&#13;
	function transfer( address _to, uint256 _tokenId ) public {&#13;
		require( _owns(msg.sender, _tokenId ) );&#13;
		require( _addressNotNull( _to ) );&#13;
		_transfer( msg.sender, _to, _tokenId );&#13;
	}&#13;
&#13;
	function transferFrom( address _from, address _to, uint256 _tokenId ) public {&#13;
		require(_owns(_from, _tokenId));&#13;
		require(_approved(_to, _tokenId));&#13;
		require(_addressNotNull(_to));&#13;
		_transfer(_from, _to, _tokenId);&#13;
	}&#13;
&#13;
	function _addressNotNull(address _to) private pure returns (bool) {&#13;
		return _to != address(0);&#13;
	}&#13;
&#13;
	function _approved(address _to, uint256 _tokenId) private view returns (bool) {&#13;
		return personIndexToApproved[_tokenId] == _to;&#13;
	}&#13;
&#13;
	function _createPerson( string _name, address _owner, uint256 _price ) private {&#13;
		Person memory _person = Person({&#13;
			name: _name&#13;
		});&#13;
&#13;
		uint256 newPersonId = persons.push(_person) - 1;&#13;
		require(newPersonId == uint256(uint32(newPersonId)));&#13;
		personIndexToPrice[newPersonId] = _price;&#13;
		personIndexToPriceLevel[ newPersonId ] = 0;&#13;
		_transfer( address(0) , _owner, newPersonId);&#13;
	}&#13;
&#13;
	function _owns(address claimant, uint256 _tokenId) private view returns (bool) {&#13;
		return claimant == personIndexToOwner[_tokenId];&#13;
	}&#13;
&#13;
	function _payout(address _to) private {&#13;
		if (_to == address(0)) {&#13;
			ceoAddress.transfer( address( this ).balance );&#13;
		} else {&#13;
			_to.transfer( address( this ).balance );&#13;
		}&#13;
	}&#13;
&#13;
	function _transfer(address _from, address _to, uint256 _tokenId) private {&#13;
		ownershipTokenCount[_to] = SafeMath.add( ownershipTokenCount[_to] , 1 );&#13;
		personIndexToOwner[_tokenId] = _to;&#13;
		if (_from != address(0)) {&#13;
			ownershipTokenCount[_from] = SafeMath.sub( ownershipTokenCount[_from] , 1 );&#13;
			delete personIndexToApproved[_tokenId];&#13;
		}&#13;
		emit Transfer(_from, _to, _tokenId);&#13;
	}&#13;
&#13;
}