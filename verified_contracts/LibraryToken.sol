pragma solidity ^0.4.19; // solhint-disable-line

/**
  * Interface for contracts conforming to ERC-721: Non-Fungible Tokens
  * @author Dieter Shirley <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="b6d2d3c2d3f6d7cedfd9dbccd3d898d5d9">[email protected]</a>&gt; (https://github.com/dete)&#13;
  */&#13;
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
library SafeMath {&#13;
&#13;
  /**&#13;
  * @dev Multiplies two numbers, throws on overflow.&#13;
  */&#13;
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    if (a == 0) {&#13;
      return 0;&#13;
    }&#13;
    uint256 c = a * b;&#13;
    assert(c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Integer division of two numbers, truncating the quotient.&#13;
  */&#13;
  function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    uint256 c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return c;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Substracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).&#13;
  */&#13;
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Adds two numbers, throws on overflow.&#13;
  */&#13;
  function add(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    uint256 c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
}&#13;
&#13;
contract LibraryToken is ERC721 {&#13;
  using SafeMath for uint256;&#13;
&#13;
  /*** EVENTS ***/&#13;
&#13;
  /**&#13;
    * @dev The Created event is fired whenever a new library comes into existence.&#13;
    */&#13;
  event Created(uint256 indexed _tokenId, string _language, string _name, address indexed _owner);&#13;
&#13;
  /**&#13;
    * @dev The Sold event is fired whenever a token is sold.&#13;
    */&#13;
  event Sold(uint256 indexed _tokenId, address indexed _owner, uint256 indexed _price);&#13;
&#13;
  /**&#13;
    * @dev The Bought event is fired whenever a token is bought.&#13;
    */&#13;
  event Bought(uint256 indexed _tokenId, address indexed _owner, uint256 indexed _price);&#13;
&#13;
  /**&#13;
    * @dev Transfer event as defined in current draft of ERC721.&#13;
    */&#13;
  event Transfer(address indexed _from, address indexed _to, uint256 indexed _tokenId);&#13;
&#13;
  /**&#13;
    * @dev Approval event as defined in current draft of ERC721.&#13;
    */&#13;
  event Approval(address indexed _owner, address indexed _approved, uint256 indexed _tokenId);&#13;
&#13;
  /**&#13;
    * @dev FounderSet event fired when founder is set.&#13;
    */&#13;
  event FounderSet(address indexed _founder, uint256 indexed _tokenId);&#13;
&#13;
&#13;
&#13;
&#13;
  /*** CONSTANTS ***/&#13;
&#13;
  /**&#13;
    * @notice Name and symbol of the non-fungible token, as defined in ERC721.&#13;
    */&#13;
  string public constant NAME = "CryptoLibraries"; // solhint-disable-line&#13;
  string public constant SYMBOL = "CL"; // solhint-disable-line&#13;
&#13;
  /**&#13;
    * @dev Increase tiers to deterine how much price have to be changed&#13;
    */&#13;
  uint256 private startingPrice = 0.002 ether;&#13;
  uint256 private developersCut = 0 ether;&#13;
  uint256 private TIER1 = 0.02 ether;&#13;
  uint256 private TIER2 = 0.5 ether;&#13;
  uint256 private TIER3 = 2.0 ether;&#13;
  uint256 private TIER4 = 5.0 ether;&#13;
&#13;
  /*** STORAGE ***/&#13;
&#13;
  /**&#13;
    * @dev A mapping from library IDs to the address that owns them.&#13;
    * All libraries have some valid owner address.&#13;
    */&#13;
  mapping (uint256 =&gt; address) public libraryIndexToOwner;&#13;
&#13;
  /**&#13;
    * @dev A mapping from library IDs to the address that founder of library.&#13;
    */&#13;
  mapping (uint256 =&gt; address) public libraryIndexToFounder;&#13;
&#13;
  /**&#13;
    * @dev A mapping from founder address to token count.&#13;
  */&#13;
  mapping (address =&gt; uint256) public libraryIndexToFounderCount;&#13;
&#13;
  /**&#13;
    * @dev A mapping from owner address to count of tokens that address owns.&#13;
    * Used internally inside balanceOf() to resolve ownership count.&#13;
    */&#13;
  mapping (address =&gt; uint256) private ownershipTokenCount;&#13;
&#13;
  /**&#13;
    * @dev A mapping from LibraryIDs to an address that has been approved to call&#13;
    * transferFrom(). Each Library can only have one approved address for transfer&#13;
    * at any time. A zero value means no approval is outstanding.&#13;
    */&#13;
  mapping (uint256 =&gt; address) public libraryIndexToApproved;&#13;
&#13;
  /**&#13;
    * @dev A mapping from LibraryIDs to the price of the token.&#13;
    */&#13;
  mapping (uint256 =&gt; uint256) private libraryIndexToPrice;&#13;
&#13;
  /**&#13;
    * @dev A mapping from LibraryIDs to the funds avaialble for founder.&#13;
    */&#13;
  mapping (uint256 =&gt; uint256) private libraryIndexToFunds;&#13;
&#13;
  /**&#13;
    * The addresses of the owner that can execute actions within each roles.&#13;
    */&#13;
  address public owner;&#13;
&#13;
&#13;
&#13;
  /*** DATATYPES ***/&#13;
  struct Library {&#13;
    string language;&#13;
    string name;&#13;
  }&#13;
&#13;
  Library[] private libraries;&#13;
&#13;
&#13;
&#13;
  /*** ACCESS MODIFIERS ***/&#13;
&#13;
  /**&#13;
    * @dev Access modifier for owner functionality.&#13;
    */&#13;
  modifier onlyOwner() {&#13;
    require(msg.sender == owner);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
    * @dev Access modifier for founder of library.&#13;
    */&#13;
  modifier onlyFounder(uint256 _tokenId) {&#13;
    require(msg.sender == founderOf(_tokenId));&#13;
    _;&#13;
  }&#13;
&#13;
&#13;
&#13;
  /*** CONSTRUCTOR ***/&#13;
&#13;
  function LibraryToken() public {&#13;
    owner = msg.sender;&#13;
  }&#13;
&#13;
&#13;
&#13;
  /*** PUBLIC FUNCTIONS ERC-721 COMPILANCE ***/&#13;
&#13;
  /**&#13;
    * @notice Grant another address the right to transfer token via takeOwnership() and transferFrom().&#13;
    * @param _to The address to be granted transfer approval. Pass address(0) to&#13;
    * clear all approvals.&#13;
    * @param _tokenId The ID of the Token that can be transferred if this call succeeds.&#13;
    */&#13;
  function approve(&#13;
    address _to,&#13;
    uint256 _tokenId&#13;
  )&#13;
    public&#13;
  {&#13;
    // Caller can't be approver of request&#13;
    require(msg.sender != _to);&#13;
&#13;
    // Caller must own token.&#13;
    require(_owns(msg.sender, _tokenId));&#13;
&#13;
    libraryIndexToApproved[_tokenId] = _to;&#13;
&#13;
    Approval(msg.sender, _to, _tokenId);&#13;
  }&#13;
&#13;
  /**&#13;
    * For querying balance of a particular account&#13;
    * @param _owner The address for balance query&#13;
    * @return balance The number of tokens owned by owner&#13;
    */&#13;
  function balanceOf(address _owner) public view returns (uint256 balance) {&#13;
    return ownershipTokenCount[_owner];&#13;
  }&#13;
&#13;
  /**&#13;
    * @dev Required for ERC-721 compliance.&#13;
    * @return bool&#13;
    */&#13;
  function implementsERC721() public pure returns (bool) {&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
    * For querying owner of token&#13;
    * @dev Required for ERC-721 compliance.&#13;
    * @param _tokenId The tokenID for owner inquiry&#13;
    * @return tokenOwner address of token owner&#13;
    */&#13;
  function ownerOf(uint256 _tokenId) public view returns (address tokenOwner) {&#13;
    tokenOwner = libraryIndexToOwner[_tokenId];&#13;
    require(tokenOwner != address(0));&#13;
  }&#13;
&#13;
  /**&#13;
    * @notice Allow pre-approved user to take ownership of a token&#13;
    * @dev Required for ERC-721 compliance.&#13;
    * @param _tokenId The ID of the Token that can be transferred if this call succeeds.&#13;
    */&#13;
  function takeOwnership(uint256 _tokenId) public {&#13;
    // Safety check to prevent against an unexpected 0x0 default.&#13;
    require(_addressNotNull(newOwner));&#13;
&#13;
    // Making sure transfer is approved&#13;
    require(_approved(newOwner, _tokenId));&#13;
&#13;
    address newOwner = msg.sender;&#13;
    address oldOwner = libraryIndexToOwner[_tokenId];&#13;
&#13;
    _transfer(oldOwner, newOwner, _tokenId);&#13;
  }&#13;
&#13;
  /**&#13;
    * totalSupply&#13;
    * For querying total numbers of tokens&#13;
    * @return total The total supply of tokens&#13;
    */&#13;
  function totalSupply() public view returns (uint256 total) {&#13;
    return libraries.length;&#13;
  }&#13;
&#13;
  /**&#13;
    * transferFro&#13;
    * Third-party initiates transfer of token from address _from to address _to&#13;
    * @param _from The address for the token to be transferred from.&#13;
    * @param _to The address for the token to be transferred to.&#13;
    * @param _tokenId The ID of the Token that can be transferred if this call succeeds.&#13;
    */&#13;
  function transferFrom(&#13;
    address _from,&#13;
    address _to,&#13;
    uint256 _tokenId&#13;
  )&#13;
    public&#13;
  {&#13;
    require(_owns(_from, _tokenId));&#13;
    require(_approved(_to, _tokenId));&#13;
    require(_addressNotNull(_to));&#13;
&#13;
    _transfer(_from, _to, _tokenId);&#13;
  }&#13;
&#13;
  /**&#13;
    * Owner initates the transfer of the token to another account&#13;
    * @param _to The address for the token to be transferred to.&#13;
    * @param _tokenId The ID of the Token that can be transferred if this call succeeds.&#13;
    */&#13;
  function transfer(&#13;
    address _to,&#13;
    uint256 _tokenId&#13;
  )&#13;
    public&#13;
  {&#13;
    require(_owns(msg.sender, _tokenId));&#13;
    require(_addressNotNull(_to));&#13;
&#13;
    _transfer(msg.sender, _to, _tokenId);&#13;
  }&#13;
&#13;
  /**&#13;
    * @dev Required for ERC-721 compliance.&#13;
    */&#13;
  function name() public pure returns (string) {&#13;
    return NAME;&#13;
  }&#13;
&#13;
  /**&#13;
    * @dev Required for ERC-721 compliance.&#13;
    */&#13;
  function symbol() public pure returns (string) {&#13;
    return SYMBOL;&#13;
  }&#13;
&#13;
&#13;
&#13;
  /*** PUBLIC FUNCTIONS ***/&#13;
&#13;
  /**&#13;
    * @dev Creates a new Library with the given language and name.&#13;
    * @param _language The library language&#13;
    * @param _name The name of library/framework&#13;
    */&#13;
  function createLibrary(string _language, string _name) public onlyOwner {&#13;
    _createLibrary(_language, _name, address(this), address(0), 0, startingPrice);&#13;
  }&#13;
&#13;
  /**&#13;
    * @dev Creates a new Library with the given language and name and founder address.&#13;
    * @param _language The library language&#13;
    * @param _name The name of library/framework&#13;
    * @param _founder The founder of library/framework&#13;
    */&#13;
  function createLibraryWithFounder(string _language, string _name, address _founder) public onlyOwner {&#13;
    require(_addressNotNull(_founder));&#13;
    _createLibrary(_language, _name, address(this), _founder, 0, startingPrice);&#13;
  }&#13;
&#13;
  /**&#13;
    * @dev Creates a new Library with the given language and name and owner address and starting price.&#13;
    * Itd be used for various bounties prize.&#13;
    * @param _language The library language&#13;
    * @param _name The name of library/framework&#13;
    * @param _owner The owner of library token&#13;
    * @param _startingPrice The starting price of library token&#13;
    */&#13;
  function createLibraryBounty(string _language, string _name, address _owner, uint256 _startingPrice) public onlyOwner {&#13;
    require(_addressNotNull(_owner));&#13;
    _createLibrary(_language, _name, _owner, address(0), 0, _startingPrice);&#13;
  }&#13;
&#13;
  /**&#13;
    * @notice Returns all the relevant information about a specific library.&#13;
    * @param _tokenId The tokenId of the library of interest.&#13;
    */&#13;
  function getLibrary(uint256 _tokenId) public view returns (&#13;
    string language,&#13;
    string libraryName,&#13;
    uint256 tokenPrice,&#13;
    uint256 funds,&#13;
    address tokenOwner,&#13;
    address founder&#13;
  ) {&#13;
    Library storage x = libraries[_tokenId];&#13;
    libraryName = x.name;&#13;
    language = x.language;&#13;
    founder = libraryIndexToFounder[_tokenId];&#13;
    funds = libraryIndexToFunds[_tokenId];&#13;
    tokenPrice = libraryIndexToPrice[_tokenId];&#13;
    tokenOwner = libraryIndexToOwner[_tokenId];&#13;
  }&#13;
&#13;
  /**&#13;
    * For querying price of token&#13;
    * @param _tokenId The tokenID for owner inquiry&#13;
    * @return _price The current price of token&#13;
    */&#13;
  function priceOf(uint256 _tokenId) public view returns (uint256 _price) {&#13;
    return libraryIndexToPrice[_tokenId];&#13;
  }&#13;
&#13;
  /**&#13;
    * For querying next price of token&#13;
    * @param _tokenId The tokenID for owner inquiry&#13;
    * @return _nextPrice The next price of token&#13;
    */&#13;
  function nextPriceOf(uint256 _tokenId) public view returns (uint256 _nextPrice) {&#13;
    return calculateNextPrice(priceOf(_tokenId));&#13;
  }&#13;
&#13;
  /**&#13;
    * For querying founder of library&#13;
    * @param _tokenId The tokenID for founder inquiry&#13;
    * @return _founder The address of library founder&#13;
    */&#13;
  function founderOf(uint256 _tokenId) public view returns (address _founder) {&#13;
    _founder = libraryIndexToFounder[_tokenId];&#13;
    require(_founder != address(0));&#13;
  }&#13;
&#13;
  /**&#13;
    * For querying founder funds of library&#13;
    * @param _tokenId The tokenID for founder inquiry&#13;
    * @return _funds The funds availale for a fo&#13;
    */&#13;
  function fundsOf(uint256 _tokenId) public view returns (uint256 _funds) {&#13;
    _funds = libraryIndexToFunds[_tokenId];&#13;
  }&#13;
&#13;
  /**&#13;
    * For querying next price of token&#13;
    * @param _price The token actual price&#13;
    * @return _nextPrice The next price&#13;
    */&#13;
  function calculateNextPrice (uint256 _price) public view returns (uint256 _nextPrice) {&#13;
    if (_price &lt; TIER1) {&#13;
      return _price.mul(200).div(95);&#13;
    } else if (_price &lt; TIER2) {&#13;
      return _price.mul(135).div(96);&#13;
    } else if (_price &lt; TIER3) {&#13;
      return _price.mul(125).div(97);&#13;
    } else if (_price &lt; TIER4) {&#13;
      return _price.mul(117).div(97);&#13;
    } else {&#13;
      return _price.mul(115).div(98);&#13;
    }&#13;
  }&#13;
&#13;
  /**&#13;
    * For querying developer's cut which is left in the contract by `purchase`&#13;
    * @param _price The token actual price&#13;
    * @return _devCut The developer's cut&#13;
    */&#13;
  function calculateDevCut (uint256 _price) public view returns (uint256 _devCut) {&#13;
    if (_price &lt; TIER1) {&#13;
      return _price.mul(5).div(100); // 5%&#13;
    } else if (_price &lt; TIER2) {&#13;
      return _price.mul(4).div(100); // 4%&#13;
    } else if (_price &lt; TIER3) {&#13;
      return _price.mul(3).div(100); // 3%&#13;
    } else if (_price &lt; TIER4) {&#13;
      return _price.mul(3).div(100); // 3%&#13;
    } else {&#13;
      return _price.mul(2).div(100); // 2%&#13;
    }&#13;
  }&#13;
&#13;
  /**&#13;
    * For querying founder cut which is left in the contract by `purchase`&#13;
    * @param _price The token actual price&#13;
    */&#13;
  function calculateFounderCut (uint256 _price) public pure returns (uint256 _founderCut) {&#13;
    return _price.mul(1).div(100);&#13;
  }&#13;
&#13;
  /**&#13;
    * @dev This function withdrawing all of developer's cut which is left in the contract by `purchase`.&#13;
    * User funds are immediately sent to the old owner in `purchase`, no user funds are left in the contract&#13;
    * expect funds that stay in the contract that are waiting to be sent to a founder of a library when we would assign him.&#13;
    */&#13;
  function withdrawAll () onlyOwner() public {&#13;
    owner.transfer(developersCut);&#13;
    // Set developersCut to 0 to reset counter of possible funds&#13;
    developersCut = 0;&#13;
  }&#13;
&#13;
  /**&#13;
    * @dev This function withdrawing selected amount of developer's cut which is left in the contract by `purchase`.&#13;
    * User funds are immediately sent to the old owner in `purchase`, no user funds are left in the contract&#13;
    * expect funds that stay in the contract that are waiting to be sent to a founder of a library when we would assign him.&#13;
    * @param _amount The amount to withdraw&#13;
    */&#13;
  function withdrawAmount (uint256 _amount) onlyOwner() public {&#13;
    require(_amount &gt;= developersCut);&#13;
&#13;
    owner.transfer(_amount);&#13;
    developersCut = developersCut.sub(_amount);&#13;
  }&#13;
&#13;
    /**&#13;
    * @dev This function withdrawing selected amount of developer's cut which is left in the contract by `purchase`.&#13;
    * User funds are immediately sent to the old owner in `purchase`, no user funds are left in the contract&#13;
    * expect funds that stay in the contract that are waiting to be sent to a founder of a library when we would assign him.&#13;
    */&#13;
  function withdrawFounderFunds (uint256 _tokenId) onlyFounder(_tokenId) public {&#13;
    address founder = founderOf(_tokenId);&#13;
    uint256 funds = fundsOf(_tokenId);&#13;
    founder.transfer(funds);&#13;
&#13;
    // Set funds to 0 after transfer since founder can only withdraw all funts&#13;
    libraryIndexToFunds[_tokenId] = 0;&#13;
  }&#13;
&#13;
  /*&#13;
     Purchase a library directly from the contract for the calculated price&#13;
     which ensures that the owner gets a profit.  All libraries that&#13;
     have been listed can be bought by this method. User funds are sent&#13;
     directly to the previous owner and are never stored in the contract.&#13;
  */&#13;
  function purchase(uint256 _tokenId) public payable {&#13;
    address oldOwner = libraryIndexToOwner[_tokenId];&#13;
    address newOwner = msg.sender;&#13;
    // Making sure token owner is not sending to self&#13;
    require(oldOwner != newOwner);&#13;
&#13;
    // Safety check to prevent against an unexpected 0x0 default.&#13;
    require(_addressNotNull(newOwner));&#13;
&#13;
    // Making sure sent amount is greater than or equal to the sellingPrice&#13;
    uint256 price = libraryIndexToPrice[_tokenId];&#13;
    require(msg.value &gt;= price);&#13;
&#13;
    uint256 excess = msg.value.sub(price);&#13;
&#13;
    _transfer(oldOwner, newOwner, _tokenId);&#13;
    libraryIndexToPrice[_tokenId] = nextPriceOf(_tokenId);&#13;
&#13;
    Bought(_tokenId, newOwner, price);&#13;
    Sold(_tokenId, oldOwner, price);&#13;
&#13;
    // Devevloper's cut which is left in contract and accesed by&#13;
    // `withdrawAll` and `withdrawAmount` methods.&#13;
    uint256 devCut = calculateDevCut(price);&#13;
    developersCut = developersCut.add(devCut);&#13;
&#13;
    // Founders cut which is left in contract and accesed by&#13;
    // `withdrawFounderFunds` methods.&#13;
    uint256 founderCut = calculateFounderCut(price);&#13;
    libraryIndexToFunds[_tokenId] = libraryIndexToFunds[_tokenId].add(founderCut);&#13;
&#13;
    // Pay previous tokenOwner if owner is not contract&#13;
    if (oldOwner != address(this)) {&#13;
      oldOwner.transfer(price.sub(devCut.add(founderCut)));&#13;
    }&#13;
&#13;
    if (excess &gt; 0) {&#13;
      newOwner.transfer(excess);&#13;
    }&#13;
  }&#13;
&#13;
  /**&#13;
    * @dev This method MUST NEVER be called by smart contract code. First, it's fairly&#13;
    * expensive (it walks the entire Cities array looking for cities belonging to owner),&#13;
    * but it also returns a dynamic array, which is only supported for web3 calls, and&#13;
    * not contract-to-contract calls.&#13;
    * @param _owner The owner whose library tokens we are interested in.&#13;
    * @return []ownerTokens The tokens of owner&#13;
    */&#13;
  function tokensOfOwner(address _owner) public view returns(uint256[] ownerTokens) {&#13;
    uint256 tokenCount = balanceOf(_owner);&#13;
    if (tokenCount == 0) {&#13;
        // Return an empty array&#13;
      return new uint256[](0);&#13;
    } else {&#13;
      uint256[] memory result = new uint256[](tokenCount);&#13;
      uint256 totalLibraries = totalSupply();&#13;
      uint256 resultIndex = 0;&#13;
&#13;
      uint256 libraryId;&#13;
      for (libraryId = 0; libraryId &lt;= totalLibraries; libraryId++) {&#13;
        if (libraryIndexToOwner[libraryId] == _owner) {&#13;
          result[resultIndex] = libraryId;&#13;
          resultIndex++;&#13;
        }&#13;
      }&#13;
      return result;&#13;
    }&#13;
  }&#13;
&#13;
    /**&#13;
    * @dev This method MUST NEVER be called by smart contract code. First, it's fairly&#13;
    * expensive (it walks the entire Cities array looking for cities belonging to owner),&#13;
    * but it also returns a dynamic array, which is only supported for web3 calls, and&#13;
    * not contract-to-contract calls.&#13;
    * @param _founder The owner whose library tokens we are interested in.&#13;
    * @return []founderTokens The tokens of owner&#13;
    */&#13;
  function tokensOfFounder(address _founder) public view returns(uint256[] founderTokens) {&#13;
    uint256 tokenCount = libraryIndexToFounderCount[_founder];&#13;
    if (tokenCount == 0) {&#13;
        // Return an empty array&#13;
      return new uint256[](0);&#13;
    } else {&#13;
      uint256[] memory result = new uint256[](tokenCount);&#13;
      uint256 totalLibraries = totalSupply();&#13;
      uint256 resultIndex = 0;&#13;
&#13;
      uint256 libraryId;&#13;
      for (libraryId = 0; libraryId &lt;= totalLibraries; libraryId++) {&#13;
        if (libraryIndexToFounder[libraryId] == _founder) {&#13;
          result[resultIndex] = libraryId;&#13;
          resultIndex++;&#13;
        }&#13;
      }&#13;
      return result;&#13;
    }&#13;
  }&#13;
&#13;
&#13;
    /**&#13;
    * @dev &#13;
    * @return []_libraries All tokens&#13;
    */&#13;
  function allTokens() public pure returns(Library[] _libraries) {&#13;
    return _libraries;&#13;
  }&#13;
&#13;
  /**&#13;
    * @dev Assigns a new address to act as the Owner. Only available to the current Owner.&#13;
    * @param _newOwner The address of the new owner&#13;
    */&#13;
  function setOwner(address _newOwner) public onlyOwner {&#13;
    require(_newOwner != address(0));&#13;
&#13;
    owner = _newOwner;&#13;
  }&#13;
&#13;
    /**&#13;
    * @dev Assigns a new address to act as the founder of library to let him withdraw collected funds of his library.&#13;
    * @param _tokenId The id of a Token&#13;
    * @param _newFounder The address of the new owner&#13;
    */&#13;
  function setFounder(uint256 _tokenId, address _newFounder) public onlyOwner {&#13;
    require(_newFounder != address(0));&#13;
&#13;
    address oldFounder = founderOf(_tokenId);&#13;
&#13;
    libraryIndexToFounder[_tokenId] = _newFounder;&#13;
    FounderSet(_newFounder, _tokenId);&#13;
&#13;
    libraryIndexToFounderCount[_newFounder] = libraryIndexToFounderCount[_newFounder].add(1);&#13;
    libraryIndexToFounderCount[oldFounder] = libraryIndexToFounderCount[oldFounder].sub(1);&#13;
  }&#13;
&#13;
&#13;
&#13;
  /*** PRIVATE FUNCTIONS ***/&#13;
&#13;
  /**&#13;
    * Safety check on _to address to prevent against an unexpected 0x0 default.&#13;
    * @param _to The address to validate if not null&#13;
    * @return bool The result of check&#13;
    */&#13;
  function _addressNotNull(address _to) private pure returns (bool) {&#13;
    return _to != address(0);&#13;
  }&#13;
&#13;
  /**&#13;
    * For checking approval of transfer for address _to&#13;
    * @param _to The address to validate if approved&#13;
    * @param _tokenId The token id to validate if approved&#13;
    * @return bool The result of validation&#13;
    */&#13;
  function _approved(address _to, uint256 _tokenId) private view returns (bool) {&#13;
    return libraryIndexToApproved[_tokenId] == _to;&#13;
  }&#13;
&#13;
  /**&#13;
    * Function to create a new Library&#13;
    * @param _language The language (etc. Python, JavaScript) of library&#13;
    * @param _name The name of library/framework (etc. Anguar, Redux, Flask)&#13;
    * @param _owner The current owner of Token&#13;
    * @param _founder The founder of library/framework&#13;
    * @param _funds The funds available to founder of library/framework&#13;
    * @param _price The current price of a Token&#13;
    */&#13;
  function _createLibrary(&#13;
    string _language,&#13;
    string _name,&#13;
    address _owner,&#13;
    address _founder,&#13;
    uint256 _funds,&#13;
    uint256 _price&#13;
  )&#13;
    private&#13;
  {&#13;
    Library memory _library = Library({&#13;
      name: _name,&#13;
      language: _language&#13;
    });&#13;
    uint256 newLibraryId = libraries.push(_library) - 1;&#13;
&#13;
    Created(newLibraryId, _language, _name, _owner);&#13;
&#13;
    libraryIndexToPrice[newLibraryId] = _price;&#13;
    libraryIndexToFounder[newLibraryId] = _founder;&#13;
    libraryIndexToFunds[newLibraryId] = _funds;&#13;
&#13;
    // This will assign ownership, and also emit the Transfer event as per ERC721 draft&#13;
    _transfer(address(0), _owner, newLibraryId);&#13;
  }&#13;
&#13;
  /**&#13;
    * Check for token ownership&#13;
    * @param claimant The claimant&#13;
    * @param _tokenId The token id to check claim&#13;
    * @return bool The result of validation&#13;
    */&#13;
  function _owns(address claimant, uint256 _tokenId) private view returns (bool) {&#13;
    return claimant == libraryIndexToOwner[_tokenId];&#13;
  }&#13;
&#13;
  /**&#13;
    * @dev Assigns ownership of a specific Library to an address.&#13;
    * @param _from The old owner of token&#13;
    * @param _to The new owner of token&#13;
    * @param _tokenId The id of token to change owner&#13;
    */&#13;
  function _transfer(address _from, address _to, uint256 _tokenId) private {&#13;
    // Since the number of library is capped to 2^32 we can't overflow this&#13;
    ownershipTokenCount[_to] = ownershipTokenCount[_to].add(1);&#13;
&#13;
    //transfer ownership&#13;
    libraryIndexToOwner[_tokenId] = _to;&#13;
&#13;
    // When creating new libraries _from is 0x0, but we can't account that address.&#13;
    if (_from != address(0)) {&#13;
      ownershipTokenCount[_from] = ownershipTokenCount[_from].sub(1);&#13;
&#13;
      // clear any previously approved ownership exchange&#13;
      delete libraryIndexToApproved[_tokenId];&#13;
    }&#13;
&#13;
    // Emit the transfer event.&#13;
    Transfer(_from, _to, _tokenId);&#13;
  }&#13;
}