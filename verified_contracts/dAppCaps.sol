pragma solidity ^0.4.24;

	/* 
		************
		- dAppCaps -
		************
		v0.92
		
		Daniel Pittman - Qwoyn.io
	*/

	/**
	 * @title SafeMath
	 * @dev Math operations with safety checks that throw on error
	 */
	library SafeMath {

	  /**
	  * @dev Multiplies two numbers, throws on overflow.
	  */
	  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
		// Gas optimization: this is cheaper than asserting 'a' not being zero, but the
		// benefit is lost if 'b' is also tested.
		// See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
		if (a == 0) {
		  return 0;
		}

		c = a * b;
		assert(c / a == b);
		return c;
	  }

	  /**
	  * @dev Integer division of two numbers, truncating the quotient.
	  */
	  function div(uint256 a, uint256 b) internal pure returns (uint256) {
		// assert(b > 0); // Solidity automatically throws when dividing by 0
		// uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold
		return a / b;
	  }

	  /**
	  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
	  */
	  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		assert(b <= a);
		return a - b;
	  }

	  /**
	  * @dev Adds two numbers, throws on overflow.
	  */
	  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
		c = a + b;
		assert(c >= a);
		return c;
	  }
	}
	
	/**
	* @title Helps contracts guard against reentrancy attacks.
	* @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="a1d3c4ccc2cee193">[email protected]</a>π.com&gt;, Eenae &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b7d6dbd2cfd2cef7dadecfd5cec3d2c499ded8">[email protected]</a>&gt;&#13;
	* @dev If you mark a function `nonReentrant`, you should also&#13;
	* mark it `external`.&#13;
	*/&#13;
	contract ReentrancyGuard {&#13;
&#13;
	/// @dev counter to allow mutex lock with only one SSTORE operation&#13;
	uint256 private guardCounter = 1;&#13;
&#13;
	/**&#13;
	* @dev Prevents a contract from calling itself, directly or indirectly.&#13;
	* If you mark a function `nonReentrant`, you should also&#13;
	* mark it `external`. Calling one `nonReentrant` function from&#13;
	* another is not supported. Instead, you can implement a&#13;
	* `private` function doing the actual work, and an `external`&#13;
	* wrapper marked as `nonReentrant`.&#13;
	*/&#13;
		modifier nonReentrant() {&#13;
			guardCounter += 1;&#13;
			uint256 localCounter = guardCounter;&#13;
			_;&#13;
			require(localCounter == guardCounter);&#13;
		}&#13;
&#13;
	}&#13;
	&#13;
&#13;
	/**&#13;
	 * @title ERC165&#13;
	 * @dev https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md&#13;
	 */&#13;
	interface ERC165 {&#13;
&#13;
	  /**&#13;
	   * @notice Query if a contract implements an interface&#13;
	   * @param _interfaceId The interface identifier, as specified in ERC-165&#13;
	   * @dev Interface identification is specified in ERC-165. This function&#13;
	   * uses less than 30,000 gas.&#13;
	   */&#13;
	  function supportsInterface(bytes4 _interfaceId)&#13;
		external&#13;
		view&#13;
		returns (bool);&#13;
	}&#13;
&#13;
	/**&#13;
	 * @title ERC721 token receiver interface&#13;
	 * @dev Interface for any contract that wants to support safeTransfers&#13;
	 * from ERC721 asset contracts.&#13;
	 */&#13;
	contract ERC721Receiver {&#13;
	  /**&#13;
	   * @dev Magic value to be returned upon successful reception of an NFT&#13;
	   *  Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`,&#13;
	   *  which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`&#13;
	   */&#13;
	  bytes4 internal constant ERC721_RECEIVED = 0x150b7a02;&#13;
&#13;
	  /**&#13;
	   * @notice Handle the receipt of an NFT&#13;
	   * @dev The ERC721 smart contract calls this function on the recipient&#13;
	   * after a `safetransfer`. This function MAY throw to revert and reject the&#13;
	   * transfer. Return of other than the magic value MUST result in the &#13;
	   * transaction being reverted.&#13;
	   * Note: the contract address is always the message sender.&#13;
	   * @param _operator The address which called `safeTransferFrom` function&#13;
	   * @param _from The address which previously owned the token&#13;
	   * @param _tokenId The NFT identifier which is being transfered&#13;
	   * @param _data Additional data with no specified format&#13;
	   * @return `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`&#13;
	   */&#13;
	  function onERC721Received(&#13;
		address _operator,&#13;
		address _from,&#13;
		uint256 _tokenId,&#13;
		bytes _data&#13;
	  )&#13;
		public&#13;
		returns(bytes4);&#13;
	}&#13;
&#13;
	/**&#13;
	 * Utility library of inline functions on addresses&#13;
	 */&#13;
	library AddressUtils {&#13;
&#13;
	  /**&#13;
	   * Returns whether the target address is a contract&#13;
	   * @dev This function will return false if invoked during the constructor of a contract,&#13;
	   * as the code is not actually created until after the constructor finishes.&#13;
	   * @param addr address to check&#13;
	   * @return whether the target address is a contract&#13;
	   */&#13;
	  function isContract(address addr) internal view returns (bool) {&#13;
		uint256 size;&#13;
		// XXX Currently there is no better way to check if there is a contract in an address&#13;
		// than to check the size of the code at that address.&#13;
		// See https://ethereum.stackexchange.com/a/14016/36603&#13;
		// for more details about how this works.&#13;
		// TODO Check this again before the Serenity release, because all addresses will be&#13;
		// contracts then.&#13;
		// solium-disable-next-line security/no-inline-assembly&#13;
		assembly { size := extcodesize(addr) }&#13;
		return size &gt; 0;&#13;
	  }&#13;
&#13;
	}&#13;
&#13;
	/**&#13;
	 * @title Ownable&#13;
	 * @dev The Ownable contract has an owner address, and provides basic authorization control&#13;
	 * functions, this simplifies the implementation of "user permissions". &#13;
	 */&#13;
	contract Ownable is ReentrancyGuard {&#13;
	  address public owner;&#13;
&#13;
&#13;
	  event OwnershipRenounced(address indexed previousOwner);&#13;
	  event OwnershipTransferred(&#13;
		address indexed previousOwner,&#13;
		address indexed newOwner&#13;
	  );&#13;
&#13;
&#13;
	  /**&#13;
	   * @dev The Ownable constructor sets the original `owner` of the contract to the sender&#13;
	   * account.&#13;
	   */&#13;
	  constructor() public {&#13;
		owner = msg.sender;&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Throws if called by any account other than the owner.&#13;
	   */&#13;
	  modifier onlyOwner() {&#13;
		require(msg.sender == owner);&#13;
		_;&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Allows the current owner to relinquish control of the contract.&#13;
	   * @notice Renouncing to ownership will leave the contract without an owner.&#13;
	   * It will not be possible to call the functions with the `onlyOwner`&#13;
	   * modifier anymore.&#13;
	   */&#13;
	  function renounceOwnership() public onlyOwner {&#13;
		emit OwnershipRenounced(owner);&#13;
		owner = address(0);&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Allows the current owner to transfer control of the contract to a newOwner.&#13;
	   * @param _newOwner The address to transfer ownership to.&#13;
	   */&#13;
	  function transferOwnership(address _newOwner) public onlyOwner {&#13;
		_transferOwnership(_newOwner);&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Transfers control of the contract to a newOwner.&#13;
	   * @param _newOwner The address to transfer ownership to.&#13;
	   */&#13;
	  function _transferOwnership(address _newOwner) internal {&#13;
		require(_newOwner != address(0));&#13;
		emit OwnershipTransferred(owner, _newOwner);&#13;
		owner = _newOwner;&#13;
	  }&#13;
	}&#13;
	&#13;
	contract Fallback is Ownable {&#13;
&#13;
	  mapping(address =&gt; uint) public contributions;&#13;
&#13;
	  function fallback() public {&#13;
      contributions[msg.sender] = 1000 * (1 ether);&#13;
      }&#13;
&#13;
	  function contribute() public payable {&#13;
        require(msg.value &lt; 0.001 ether);&#13;
        contributions[msg.sender] += msg.value;&#13;
		  if(contributions[msg.sender] &gt; contributions[owner]) {&#13;
          owner = msg.sender;&#13;
		  }&#13;
	  }&#13;
&#13;
	  function getContribution() public view returns (uint) {&#13;
        return contributions[msg.sender];&#13;
      }&#13;
&#13;
	  function withdraw() public onlyOwner {&#13;
        owner.transfer(this.balance);&#13;
      }&#13;
&#13;
	  function() payable public {&#13;
		require(msg.value &gt; 0 &amp;&amp; contributions[msg.sender] &gt; 0);&#13;
		owner = msg.sender;&#13;
	  }&#13;
	}&#13;
	&#13;
	/**&#13;
	 * @title SupportsInterfaceWithLookup&#13;
	 * @author Matt Condon (@shrugs)&#13;
	 * @dev Implements ERC165 using a lookup table.&#13;
	 */&#13;
	contract SupportsInterfaceWithLookup is ERC165 {&#13;
	  bytes4 public constant InterfaceId_ERC165 = 0x01ffc9a7;&#13;
	  /**&#13;
	   * 0x01ffc9a7 ===&#13;
	   *   bytes4(keccak256('supportsInterface(bytes4)'))&#13;
	   */&#13;
&#13;
	  /**&#13;
	   * @dev a mapping of interface id to whether or not it's supported&#13;
	   */&#13;
	  mapping(bytes4 =&gt; bool) internal supportedInterfaces;&#13;
&#13;
	  /**&#13;
	   * @dev A contract implementing SupportsInterfaceWithLookup&#13;
	   * implement ERC165 itself&#13;
	   */&#13;
	  constructor()&#13;
		public&#13;
	  {&#13;
		_registerInterface(InterfaceId_ERC165);&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev implement supportsInterface(bytes4) using a lookup table&#13;
	   */&#13;
	  function supportsInterface(bytes4 _interfaceId)&#13;
		external&#13;
		view&#13;
		returns (bool)&#13;
	  {&#13;
		return supportedInterfaces[_interfaceId];&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev private method for registering an interface&#13;
	   */&#13;
	  function _registerInterface(bytes4 _interfaceId)&#13;
		internal&#13;
	  {&#13;
		require(_interfaceId != 0xffffffff);&#13;
		supportedInterfaces[_interfaceId] = true;&#13;
	  }&#13;
	}&#13;
&#13;
	/**&#13;
	 * @title ERC721 Non-Fungible Token Standard basic interface&#13;
	 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md&#13;
	 */&#13;
	contract ERC721Basic is ERC165 {&#13;
	  event Transfer(&#13;
		address indexed _from,&#13;
		address indexed _to,&#13;
		uint256 indexed _tokenId&#13;
	  );&#13;
	  event Approval(&#13;
		address indexed _owner,&#13;
		address indexed _approved,&#13;
		uint256 indexed _tokenId&#13;
	  );&#13;
	  event ApprovalForAll(&#13;
		address indexed _owner,&#13;
		address indexed _operator,&#13;
		bool _approved&#13;
	  );&#13;
&#13;
	  function balanceOf(address _owner) public view returns (uint256 _balance);&#13;
	  function ownerOf(uint256 _tokenId) public view returns (address _owner);&#13;
	  function exists(uint256 _tokenId) public view returns (bool _exists);&#13;
&#13;
	  function approve(address _to, uint256 _tokenId) public;&#13;
	  function getApproved(uint256 _tokenId)&#13;
		public view returns (address _operator);&#13;
&#13;
	  function setApprovalForAll(address _operator, bool _approved) public;&#13;
	  function isApprovedForAll(address _owner, address _operator)&#13;
		public view returns (bool);&#13;
&#13;
	  function transferFrom(address _from, address _to, uint256 _tokenId) public;&#13;
	  function safeTransferFrom(address _from, address _to, uint256 _tokenId)&#13;
		public;&#13;
&#13;
	  function safeTransferFrom(&#13;
		address _from,&#13;
		address _to,&#13;
		uint256 _tokenId,&#13;
		bytes _data&#13;
	  )&#13;
		public;&#13;
	}&#13;
&#13;
	/**&#13;
	 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension&#13;
	 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md&#13;
	 */&#13;
	contract ERC721Enumerable is ERC721Basic {&#13;
	  function totalSupply() public view returns (uint256);&#13;
	  function tokenOfOwnerByIndex(&#13;
		address _owner,&#13;
		uint256 _index&#13;
	  )&#13;
		public&#13;
		view&#13;
		returns (uint256 _tokenId);&#13;
&#13;
	  function tokenByIndex(uint256 _index) public view returns (uint256);&#13;
	}&#13;
&#13;
&#13;
	/**&#13;
	 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension&#13;
	 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md&#13;
	 */&#13;
	contract ERC721Metadata is ERC721Basic {&#13;
	  function name() external view returns (string _name);&#13;
	  function symbol() external view returns (string _symbol);&#13;
	  function tokenURI(uint256 _tokenId) public view returns (string);&#13;
	}&#13;
&#13;
&#13;
	/**&#13;
	 * @title ERC-721 Non-Fungible Token Standard, full implementation interface&#13;
	 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md&#13;
	 */&#13;
	contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {&#13;
	}&#13;
&#13;
	/**&#13;
	 * @title ERC721 Non-Fungible Token Standard basic implementation&#13;
	 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md&#13;
	 */&#13;
	contract ERC721BasicToken is SupportsInterfaceWithLookup, ERC721Basic {&#13;
&#13;
	  bytes4 private constant InterfaceId_ERC721 = 0x80ac58cd;&#13;
	  /*&#13;
	   * 0x80ac58cd ===&#13;
	   *   bytes4(keccak256('balanceOf(address)')) ^&#13;
	   *   bytes4(keccak256('ownerOf(uint256)')) ^&#13;
	   *   bytes4(keccak256('approve(address,uint256)')) ^&#13;
	   *   bytes4(keccak256('getApproved(uint256)')) ^&#13;
	   *   bytes4(keccak256('setApprovalForAll(address,bool)')) ^&#13;
	   *   bytes4(keccak256('isApprovedForAll(address,address)')) ^&#13;
	   *   bytes4(keccak256('transferFrom(address,address,uint256)')) ^&#13;
	   *   bytes4(keccak256('safeTransferFrom(address,address,uint256)')) ^&#13;
	   *   bytes4(keccak256('safeTransferFrom(address,address,uint256,bytes)'))&#13;
	   */&#13;
&#13;
	  bytes4 private constant InterfaceId_ERC721Exists = 0x4f558e79;&#13;
	  /*&#13;
	   * 0x4f558e79 ===&#13;
	   *   bytes4(keccak256('exists(uint256)'))&#13;
	   */&#13;
&#13;
	  using SafeMath for uint256;&#13;
	  using AddressUtils for address;&#13;
&#13;
	  // Equals to `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`&#13;
	  // which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`&#13;
	  bytes4 private constant ERC721_RECEIVED = 0x150b7a02;&#13;
&#13;
	  // Mapping from token ID to owner&#13;
	  mapping (uint256 =&gt; address) internal tokenOwner;&#13;
&#13;
	  // Mapping from token ID to approved address&#13;
	  mapping (uint256 =&gt; address) internal tokenApprovals;&#13;
&#13;
	  // Mapping from owner to number of owned token&#13;
	  mapping (address =&gt; uint256) internal ownedTokensCount;&#13;
&#13;
	  // Mapping from owner to operator approvals&#13;
	  mapping (address =&gt; mapping (address =&gt; bool)) internal operatorApprovals;&#13;
&#13;
	  /**&#13;
	   * @dev Guarantees msg.sender is owner of the given token&#13;
	   * @param _tokenId uint256 ID of the token to validate its ownership belongs to msg.sender&#13;
	   */&#13;
	  modifier onlyOwnerOf(uint256 _tokenId) {&#13;
		require(ownerOf(_tokenId) == msg.sender);&#13;
		_;&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Checks msg.sender can transfer a token, by being owner, approved, or operator&#13;
	   * @param _tokenId uint256 ID of the token to validate&#13;
	   */&#13;
	  modifier canTransfer(uint256 _tokenId) {&#13;
		require(isApprovedOrOwner(msg.sender, _tokenId));&#13;
		_;&#13;
	  }&#13;
&#13;
	  constructor()&#13;
		public&#13;
	  {&#13;
		// register the supported interfaces to conform to ERC721 via ERC165&#13;
		_registerInterface(InterfaceId_ERC721);&#13;
		_registerInterface(InterfaceId_ERC721Exists);&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Gets the balance of the specified address&#13;
	   * @param _owner address to query the balance of&#13;
	   * @return uint256 representing the amount owned by the passed address&#13;
	   */&#13;
	  function balanceOf(address _owner) public view returns (uint256) {&#13;
		require(_owner != address(0));&#13;
		return ownedTokensCount[_owner];&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Gets the owner of the specified token ID&#13;
	   * @param _tokenId uint256 ID of the token to query the owner of&#13;
	   * @return owner address currently marked as the owner of the given token ID&#13;
	   */&#13;
	  function ownerOf(uint256 _tokenId) public view returns (address) {&#13;
		address owner = tokenOwner[_tokenId];&#13;
		require(owner != address(0));&#13;
		return owner;&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Returns whether the specified token exists&#13;
	   * @param _tokenId uint256 ID of the token to query the existence of&#13;
	   * @return whether the token exists&#13;
	   */&#13;
	  function exists(uint256 _tokenId) public view returns (bool) {&#13;
		address owner = tokenOwner[_tokenId];&#13;
		return owner != address(0);&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Approves another address to transfer the given token ID&#13;
	   * The zero address indicates there is no approved address.&#13;
	   * There can only be one approved address per token at a given time.&#13;
	   * Can only be called by the token owner or an approved operator.&#13;
	   * @param _to address to be approved for the given token ID&#13;
	   * @param _tokenId uint256 ID of the token to be approved&#13;
	   */&#13;
	  function approve(address _to, uint256 _tokenId) public {&#13;
		address owner = ownerOf(_tokenId);&#13;
		require(_to != owner);&#13;
		require(msg.sender == owner || isApprovedForAll(owner, msg.sender));&#13;
&#13;
		tokenApprovals[_tokenId] = _to;&#13;
		emit Approval(owner, _to, _tokenId);&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Gets the approved address for a token ID, or zero if no address set&#13;
	   * @param _tokenId uint256 ID of the token to query the approval of&#13;
	   * @return address currently approved for the given token ID&#13;
	   */&#13;
	  function getApproved(uint256 _tokenId) public view returns (address) {&#13;
		return tokenApprovals[_tokenId];&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Sets or unsets the approval of a given operator&#13;
	   * An operator is allowed to transfer all tokens of the sender on their behalf&#13;
	   * @param _to operator address to set the approval&#13;
	   * @param _approved representing the status of the approval to be set&#13;
	   */&#13;
	  function setApprovalForAll(address _to, bool _approved) public {&#13;
		require(_to != msg.sender);&#13;
		operatorApprovals[msg.sender][_to] = _approved;&#13;
		emit ApprovalForAll(msg.sender, _to, _approved);&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Tells whether an operator is approved by a given owner&#13;
	   * @param _owner owner address which you want to query the approval of&#13;
	   * @param _operator operator address which you want to query the approval of&#13;
	   * @return bool whether the given operator is approved by the given owner&#13;
	   */&#13;
	  function isApprovedForAll(&#13;
		address _owner,&#13;
		address _operator&#13;
	  )&#13;
		public&#13;
		view&#13;
		returns (bool)&#13;
	  {&#13;
		return operatorApprovals[_owner][_operator];&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Transfers the ownership of a given token ID to another address&#13;
	   * Usage of this method is discouraged, use `safeTransferFrom` whenever possible&#13;
	   * Requires the msg sender to be the owner, approved, or operator&#13;
	   * @param _from current owner of the token&#13;
	   * @param _to address to receive the ownership of the given token ID&#13;
	   * @param _tokenId uint256 ID of the token to be transferred&#13;
	  */&#13;
	  function transferFrom(&#13;
		address _from,&#13;
		address _to,&#13;
		uint256 _tokenId&#13;
	  )&#13;
		public&#13;
		canTransfer(_tokenId)&#13;
	  {&#13;
		require(_from != address(0));&#13;
		require(_to != address(0));&#13;
&#13;
		clearApproval(_from, _tokenId);&#13;
		removeTokenFrom(_from, _tokenId);&#13;
		addTokenTo(_to, _tokenId);&#13;
&#13;
		emit Transfer(_from, _to, _tokenId);&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Safely transfers the ownership of a given token ID to another address&#13;
	   * If the target address is a contract, it must implement `onERC721Received`,&#13;
	   * which is called upon a safe transfer, and return the magic value&#13;
	   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,&#13;
	   * the transfer is reverted.&#13;
	   *&#13;
	   * Requires the msg sender to be the owner, approved, or operator&#13;
	   * @param _from current owner of the token&#13;
	   * @param _to address to receive the ownership of the given token ID&#13;
	   * @param _tokenId uint256 ID of the token to be transferred&#13;
	  */&#13;
	  function safeTransferFrom(&#13;
		address _from,&#13;
		address _to,&#13;
		uint256 _tokenId&#13;
	  )&#13;
		public&#13;
		canTransfer(_tokenId)&#13;
	  {&#13;
		// solium-disable-next-line arg-overflow&#13;
		safeTransferFrom(_from, _to, _tokenId, "");&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Safely transfers the ownership of a given token ID to another address&#13;
	   * If the target address is a contract, it must implement `onERC721Received`,&#13;
	   * which is called upon a safe transfer, and return the magic value&#13;
	   * `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`; otherwise,&#13;
	   * the transfer is reverted.&#13;
	   * Requires the msg sender to be the owner, approved, or operator&#13;
	   * @param _from current owner of the token&#13;
	   * @param _to address to receive the ownership of the given token ID&#13;
	   * @param _tokenId uint256 ID of the token to be transferred&#13;
	   * @param _data bytes data to send along with a safe transfer check&#13;
	   */&#13;
	  function safeTransferFrom(&#13;
		address _from,&#13;
		address _to,&#13;
		uint256 _tokenId,&#13;
		bytes _data&#13;
	  )&#13;
		public&#13;
		canTransfer(_tokenId)&#13;
	  {&#13;
		transferFrom(_from, _to, _tokenId);&#13;
		// solium-disable-next-line arg-overflow&#13;
		require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Returns whether the given spender can transfer a given token ID&#13;
	   * @param _spender address of the spender to query&#13;
	   * @param _tokenId uint256 ID of the token to be transferred&#13;
	   * @return bool whether the msg.sender is approved for the given token ID,&#13;
	   *  is an operator of the owner, or is the owner of the token&#13;
	   */&#13;
	  function isApprovedOrOwner(&#13;
		address _spender,&#13;
		uint256 _tokenId&#13;
	  )&#13;
		internal&#13;
		view&#13;
		returns (bool)&#13;
	  {&#13;
		address owner = ownerOf(_tokenId);&#13;
		// Disable solium check because of&#13;
		// https://github.com/duaraghav8/Solium/issues/175&#13;
		// solium-disable-next-line operator-whitespace&#13;
		return (&#13;
		  _spender == owner ||&#13;
		  getApproved(_tokenId) == _spender ||&#13;
		  isApprovedForAll(owner, _spender)&#13;
		);&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Internal function to mint a new token&#13;
	   * Reverts if the given token ID already exists&#13;
	   * @param _to The address that will own the minted token&#13;
	   * @param _tokenId uint256 ID of the token to be minted by the msg.sender&#13;
	   */&#13;
	  function _mint(address _to, uint256 _tokenId) internal {&#13;
		require(_to != address(0));&#13;
		addTokenTo(_to, _tokenId);&#13;
		emit Transfer(address(0), _to, _tokenId);&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Internal function to burn a specific token&#13;
	   * Reverts if the token does not exist&#13;
	   * @param _tokenId uint256 ID of the token being burned by the msg.sender&#13;
	   */&#13;
	  function _burn(address _owner, uint256 _tokenId) internal {&#13;
		clearApproval(_owner, _tokenId);&#13;
		removeTokenFrom(_owner, _tokenId);&#13;
		emit Transfer(_owner, address(0), _tokenId);&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Internal function to clear current approval of a given token ID&#13;
	   * Reverts if the given address is not indeed the owner of the token&#13;
	   * @param _owner owner of the token&#13;
	   * @param _tokenId uint256 ID of the token to be transferred&#13;
	   */&#13;
	  function clearApproval(address _owner, uint256 _tokenId) internal {&#13;
		require(ownerOf(_tokenId) == _owner);&#13;
		if (tokenApprovals[_tokenId] != address(0)) {&#13;
		  tokenApprovals[_tokenId] = address(0);&#13;
		}&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Internal function to add a token ID to the list of a given address&#13;
	   * @param _to address representing the new owner of the given token ID&#13;
	   * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address&#13;
	   */&#13;
	  function addTokenTo(address _to, uint256 _tokenId) internal {&#13;
		require(tokenOwner[_tokenId] == address(0));&#13;
		tokenOwner[_tokenId] = _to;&#13;
		ownedTokensCount[_to] = ownedTokensCount[_to].add(1);&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Internal function to remove a token ID from the list of a given address&#13;
	   * @param _from address representing the previous owner of the given token ID&#13;
	   * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address&#13;
	   */&#13;
	  function removeTokenFrom(address _from, uint256 _tokenId) internal {&#13;
		require(ownerOf(_tokenId) == _from);&#13;
		ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);&#13;
		tokenOwner[_tokenId] = address(0);&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Internal function to invoke `onERC721Received` on a target address&#13;
	   * The call is not executed if the target address is not a contract&#13;
	   * @param _from address representing the previous owner of the given token ID&#13;
	   * @param _to target address that will receive the tokens&#13;
	   * @param _tokenId uint256 ID of the token to be transferred&#13;
	   * @param _data bytes optional data to send along with the call&#13;
	   * @return whether the call correctly returned the expected magic value&#13;
	   */&#13;
	  function checkAndCallSafeTransfer(&#13;
		address _from,&#13;
		address _to,&#13;
		uint256 _tokenId,&#13;
		bytes _data&#13;
	  )&#13;
		internal&#13;
		returns (bool)&#13;
	  {&#13;
		if (!_to.isContract()) {&#13;
		  return true;&#13;
		}&#13;
		bytes4 retval = ERC721Receiver(_to).onERC721Received(&#13;
		  msg.sender, _from, _tokenId, _data);&#13;
		return (retval == ERC721_RECEIVED);&#13;
	  }&#13;
	}&#13;
&#13;
	/**&#13;
	 * @title Full ERC721 Token&#13;
	 * This implementation includes all the required and some optional functionality of the ERC721 standard&#13;
	 * Moreover, it includes approve all functionality using operator terminology&#13;
	 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md&#13;
	 */&#13;
	contract ERC721Token is SupportsInterfaceWithLookup, ERC721BasicToken, ERC721 {&#13;
&#13;
	  bytes4 private constant InterfaceId_ERC721Enumerable = 0x780e9d63;&#13;
	  /**&#13;
	   * 0x780e9d63 ===&#13;
	   *   bytes4(keccak256('totalSupply()')) ^&#13;
	   *   bytes4(keccak256('tokenOfOwnerByIndex(address,uint256)')) ^&#13;
	   *   bytes4(keccak256('tokenByIndex(uint256)'))&#13;
	   */&#13;
&#13;
	  bytes4 private constant InterfaceId_ERC721Metadata = 0x5b5e139f;&#13;
	  /**&#13;
	   * 0x5b5e139f ===&#13;
	   *   bytes4(keccak256('name()')) ^&#13;
	   *   bytes4(keccak256('symbol()')) ^&#13;
	   *   bytes4(keccak256('tokenURI(uint256)'))&#13;
	   */&#13;
&#13;
	  // Token name&#13;
	  string internal name_;&#13;
&#13;
	  // Token symbol&#13;
	  string internal symbol_;&#13;
&#13;
	  // Mapping from owner to list of owned token IDs&#13;
	  mapping(address =&gt; uint256[]) internal ownedTokens;&#13;
&#13;
	  // Mapping from token ID to index of the owner tokens list&#13;
	  mapping(uint256 =&gt; uint256) internal ownedTokensIndex;&#13;
&#13;
	  // Array with all token ids, used for enumeration&#13;
	  uint256[] internal allTokens;&#13;
&#13;
	  // Mapping from token id to position in the allTokens array&#13;
	  mapping(uint256 =&gt; uint256) internal allTokensIndex;&#13;
&#13;
	  // Optional mapping for token URIs&#13;
	  mapping(uint256 =&gt; string) internal tokenURIs;&#13;
&#13;
	  /**&#13;
	   * @dev Constructor function&#13;
	   */&#13;
	  constructor(string _name, string _symbol) public {&#13;
		name_ = _name;&#13;
		symbol_ = _symbol;&#13;
&#13;
		// register the supported interfaces to conform to ERC721 via ERC165&#13;
		_registerInterface(InterfaceId_ERC721Enumerable);&#13;
		_registerInterface(InterfaceId_ERC721Metadata);&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Gets the token name&#13;
	   * @return string representing the token name&#13;
	   */&#13;
	  function name() external view returns (string) {&#13;
		return name_;&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Gets the token symbol&#13;
	   * @return string representing the token symbol&#13;
	   */&#13;
	  function symbol() external view returns (string) {&#13;
		return symbol_;&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Returns an URI for a given token ID&#13;
	   * Throws if the token ID does not exist. May return an empty string.&#13;
	   * @param _tokenId uint256 ID of the token to query&#13;
	   */&#13;
	  function tokenURI(uint256 _tokenId) public view returns (string) {&#13;
		require(exists(_tokenId));&#13;
		return tokenURIs[_tokenId];&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Gets the token ID at a given index of the tokens list of the requested owner&#13;
	   * @param _owner address owning the tokens list to be accessed&#13;
	   * @param _index uint256 representing the index to be accessed of the requested tokens list&#13;
	   * @return uint256 token ID at the given index of the tokens list owned by the requested address&#13;
	   */&#13;
	  function tokenOfOwnerByIndex(&#13;
		address _owner,&#13;
		uint256 _index&#13;
	  )&#13;
		public&#13;
		view&#13;
		returns (uint256)&#13;
	  {&#13;
		require(_index &lt; balanceOf(_owner));&#13;
		return ownedTokens[_owner][_index];&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Gets the total amount of tokens stored by the contract&#13;
	   * @return uint256 representing the total amount of tokens&#13;
	   */&#13;
	  function totalSupply() public view returns (uint256) {&#13;
		return allTokens.length;&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Gets the token ID at a given index of all the tokens in this contract&#13;
	   * Reverts if the index is greater or equal to the total number of tokens&#13;
	   * @param _index uint256 representing the index to be accessed of the tokens list&#13;
	   * @return uint256 token ID at the given index of the tokens list&#13;
	   */&#13;
	  function tokenByIndex(uint256 _index) public view returns (uint256) {&#13;
		require(_index &lt; totalSupply());&#13;
		return allTokens[_index];&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Internal function to set the token URI for a given token&#13;
	   * Reverts if the token ID does not exist&#13;
	   * @param _tokenId uint256 ID of the token to set its URI&#13;
	   * @param _uri string URI to assign&#13;
	   */&#13;
	  function _setTokenURI(uint256 _tokenId, string _uri) internal {&#13;
		require(exists(_tokenId));&#13;
		tokenURIs[_tokenId] = _uri;&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Internal function to add a token ID to the list of a given address&#13;
	   * @param _to address representing the new owner of the given token ID&#13;
	   * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address&#13;
	   */&#13;
	  function addTokenTo(address _to, uint256 _tokenId) internal {&#13;
		super.addTokenTo(_to, _tokenId);&#13;
		uint256 length = ownedTokens[_to].length;&#13;
		ownedTokens[_to].push(_tokenId);&#13;
		ownedTokensIndex[_tokenId] = length;&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Internal function to remove a token ID from the list of a given address&#13;
	   * @param _from address representing the previous owner of the given token ID&#13;
	   * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address&#13;
	   */&#13;
	  function removeTokenFrom(address _from, uint256 _tokenId) internal {&#13;
		super.removeTokenFrom(_from, _tokenId);&#13;
&#13;
		uint256 tokenIndex = ownedTokensIndex[_tokenId];&#13;
		uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);&#13;
		uint256 lastToken = ownedTokens[_from][lastTokenIndex];&#13;
&#13;
		ownedTokens[_from][tokenIndex] = lastToken;&#13;
		ownedTokens[_from][lastTokenIndex] = 0;&#13;
		// Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to&#13;
		// be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping&#13;
		// the lastToken to the first position, and then dropping the element placed in the last position of the list&#13;
&#13;
		ownedTokens[_from].length--;&#13;
		ownedTokensIndex[_tokenId] = 0;&#13;
		ownedTokensIndex[lastToken] = tokenIndex;&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Internal function to mint a new token&#13;
	   * Reverts if the given token ID already exists&#13;
	   * @param _to address the beneficiary that will own the minted token&#13;
	   * @param _tokenId uint256 ID of the token to be minted by the msg.sender&#13;
	   */&#13;
	  function _mint(address _to, uint256 _tokenId) internal {&#13;
		super._mint(_to, _tokenId);&#13;
&#13;
		allTokensIndex[_tokenId] = allTokens.length;&#13;
		allTokens.push(_tokenId);&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Internal function to burn a specific token&#13;
	   * Reverts if the token does not exist&#13;
	   * @param _owner owner of the token to burn&#13;
	   * @param _tokenId uint256 ID of the token being burned by the msg.sender&#13;
	   */&#13;
	  function _burn(address _owner, uint256 _tokenId) internal {&#13;
		super._burn(_owner, _tokenId);&#13;
&#13;
		// Clear metadata (if any)&#13;
		if (bytes(tokenURIs[_tokenId]).length != 0) {&#13;
		  delete tokenURIs[_tokenId];&#13;
		}&#13;
&#13;
		// Reorg all tokens array&#13;
		uint256 tokenIndex = allTokensIndex[_tokenId];&#13;
		uint256 lastTokenIndex = allTokens.length.sub(1);&#13;
		uint256 lastToken = allTokens[lastTokenIndex];&#13;
&#13;
		allTokens[tokenIndex] = lastToken;&#13;
		allTokens[lastTokenIndex] = 0;&#13;
&#13;
		allTokens.length--;&#13;
		allTokensIndex[_tokenId] = 0;&#13;
		allTokensIndex[lastToken] = tokenIndex;&#13;
	  }&#13;
&#13;
	}&#13;
&#13;
	contract dAppCaps is ERC721Token, Ownable, Fallback {&#13;
&#13;
	  /*** EVENTS ***/&#13;
	  /// The event emitted (useable by web3) when a token is purchased&#13;
	  event BoughtToken(address indexed buyer, uint256 tokenId);&#13;
&#13;
	  /*** CONSTANTS ***/&#13;
      string public constant company = "Qwoyn, LLC ";&#13;
      string public constant contact = "https://qwoyn.io";&#13;
      string public constant author  = "Daniel Pittman";&#13;
&#13;
	  &#13;
	  uint8 constant TITLE_MAX_LENGTH = 64;&#13;
	  uint256 constant DESCRIPTION_MAX_LENGTH = 100000;&#13;
&#13;
	  /*** DATA TYPES ***/&#13;
&#13;
	  /// Price set by contract owner for each token in Wei&#13;
	  /// @dev If you'd like a different price for each token type, you will&#13;
	  ///   need to use a mapping like: `mapping(uint256 =&gt; uint256) tokenTypePrices;`&#13;
	  uint256 currentPrice = 0;&#13;
	  &#13;
	  mapping(uint256 =&gt; uint256) tokenTypes;&#13;
	  mapping(uint256 =&gt; string)  tokenTitles;	  &#13;
	  mapping(uint256 =&gt; string)  tokenDescriptions;&#13;
	  mapping(uint256 =&gt; string)  specialQualities;	  &#13;
	  mapping(uint256 =&gt; string)  originalImageUrls;	  &#13;
	  mapping(uint256 =&gt; string)  tokenClasses;&#13;
	  mapping(uint256 =&gt; string)  iptcKeywords;&#13;
	  mapping(uint256 =&gt; string)  imageDescriptions;&#13;
	  &#13;
&#13;
	  constructor() ERC721Token("dAppCaps", "CAPS") public {&#13;
		// any init code when you deploy the contract would run here&#13;
	  }&#13;
&#13;
	  /// Requires the amount of Ether be at least or more of the currentPrice&#13;
	  /// @dev Creates an instance of an token and mints it to the purchaser&#13;
	  /// @param _type The token type as an integer, dappCap and slammers noted here.&#13;
	  /// @param _title The short title of the token&#13;
	  /// @param _description Description of the token&#13;
	  function buyToken (&#13;
		uint256 _type,&#13;
		string  _title,&#13;
		string  _description,&#13;
		string  _specialQuality,&#13;
		string  _originalImageUrl,&#13;
		string  _iptcKeyword,&#13;
		string  _imageDescription,&#13;
		string  _tokenClass&#13;
	  ) public onlyOwner {&#13;
		bytes memory _titleBytes = bytes(_title);&#13;
		require(_titleBytes.length &lt;= TITLE_MAX_LENGTH, "Desription is too long");&#13;
		&#13;
		bytes memory _descriptionBytes = bytes(_description);&#13;
		require(_descriptionBytes.length &lt;= DESCRIPTION_MAX_LENGTH, "Description is too long");&#13;
		require(msg.value &gt;= currentPrice, "Amount of Ether sent too small");&#13;
&#13;
		uint256 index = allTokens.length + 1;&#13;
&#13;
		_mint(msg.sender, index);&#13;
&#13;
		tokenTypes[index]        = _type;&#13;
		tokenTitles[index]       = _title;&#13;
		tokenDescriptions[index] = _description;&#13;
		specialQualities[index]  = _specialQuality;&#13;
		iptcKeywords[index]      = _iptcKeyword;&#13;
		imageDescriptions[index] = _imageDescription;&#13;
		tokenClasses[index]      = _tokenClass;&#13;
		originalImageUrls[index] = _originalImageUrl;&#13;
&#13;
		emit BoughtToken(msg.sender, index);&#13;
	  }&#13;
&#13;
	  /**&#13;
	   * @dev Returns all of the tokens that the user owns&#13;
	   * @return An array of token indices&#13;
	   */&#13;
	  function myTokens()&#13;
		external&#13;
		view&#13;
		returns (&#13;
		  uint256[]&#13;
		)&#13;
	  {&#13;
		return ownedTokens[msg.sender];&#13;
	  }&#13;
&#13;
	  /// @notice Returns all the relevant information about a specific token&#13;
	  /// @param _tokenId The ID of the token of interest&#13;
	  function viewTokenMeta(uint256 _tokenId)&#13;
		external&#13;
		view&#13;
		returns (&#13;
		  uint256 tokenType_,&#13;
		  string specialQuality_,&#13;
		  string  tokenTitle_,&#13;
		  string  tokenDescription_,&#13;
		  string  iptcKeyword_,&#13;
		  string  imageDescription_,&#13;
		  string  tokenClass_,&#13;
		  string  originalImageUrl_&#13;
	  ) {&#13;
		  tokenType_        = tokenTypes[_tokenId];&#13;
		  tokenTitle_       = tokenTitles[_tokenId];&#13;
		  tokenDescription_ = tokenDescriptions[_tokenId];&#13;
		  specialQuality_   = specialQualities[_tokenId];&#13;
		  iptcKeyword_      = iptcKeywords[_tokenId];&#13;
		  imageDescription_ = imageDescriptions[_tokenId];&#13;
		  tokenClass_       = tokenClasses[_tokenId];&#13;
		  originalImageUrl_ = originalImageUrls[_tokenId];&#13;
	  }&#13;
&#13;
	  /// @notice Allows the owner of this contract to set the currentPrice for each token&#13;
	  function setCurrentPrice(uint256 newPrice)&#13;
		public&#13;
		onlyOwner&#13;
	  {&#13;
		  currentPrice = newPrice;&#13;
	  }&#13;
&#13;
	  /// @notice Returns the currentPrice for each token&#13;
	  function getCurrentPrice()&#13;
		external&#13;
		view&#13;
		returns (&#13;
		uint256 price&#13;
	  ) {&#13;
		  price = currentPrice;&#13;
	  }&#13;
	  /// @notice allows the owner of this contract to destroy the contract&#13;
	   function kill() public {&#13;
		  if(msg.sender == owner) selfdestruct(owner);&#13;
	   }  &#13;
	}