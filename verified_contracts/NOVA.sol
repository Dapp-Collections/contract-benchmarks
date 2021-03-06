pragma solidity ^0.4.17;

contract NovaAccessControl {
  mapping (address => bool) managers;
  address public cfoAddress;

  function NovaAccessControl() public {
    managers[msg.sender] = true;
  }

  modifier onlyManager() {
    require(managers[msg.sender]);
    _;
  }

  function setManager(address _newManager) external onlyManager {
    require(_newManager != address(0));
    managers[_newManager] = true;
  }

  function removeManager(address mangerAddress) external onlyManager {
    require(mangerAddress != msg.sender);
    managers[mangerAddress] = false;
  }

  function updateCfo(address newCfoAddress) external onlyManager {
    require(newCfoAddress != address(0));
    cfoAddress = newCfoAddress;
  }
}

contract NovaCoin is NovaAccessControl {
  string public name;
  string public symbol;
  uint256 public totalSupply;
  address supplier;
  // 1:1 convert with currency, so to cent
  uint8 public decimals = 2;
  mapping (address => uint256) public balanceOf;
  address public novaContractAddress;

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Burn(address indexed from, uint256 value);
  event NovaCoinTransfer(address indexed to, uint256 value);

  function NovaCoin(uint256 initialSupply, string tokenName, string tokenSymbol) public {
    totalSupply = initialSupply * 10 ** uint256(decimals);
    supplier = msg.sender;
    balanceOf[supplier] = totalSupply;
    name = tokenName;
    symbol = tokenSymbol;
  }

  function _transfer(address _from, address _to, uint _value) internal {
    require(_to != 0x0);
    require(balanceOf[_from] >= _value);
    require(balanceOf[_to] + _value > balanceOf[_to]);
    balanceOf[_from] -= _value;
    balanceOf[_to] += _value;
  }

  // currently only permit NovaContract to consume
  function transfer(address _to, uint256 _value) external {
    _transfer(msg.sender, _to, _value);
    Transfer(msg.sender, _to, _value);
  }

  function novaTransfer(address _to, uint256 _value) external onlyManager {
    _transfer(supplier, _to, _value);
    NovaCoinTransfer(_to, _value);
  }

  function updateNovaContractAddress(address novaAddress) external onlyManager {
    novaContractAddress = novaAddress;
  }

  // This is function is used for sell Nova properpty only
  // coin can only be trasfered to invoker, and invoker must be Nova contract
  function consumeCoinForNova(address _from, uint _value) external {
    require(msg.sender == novaContractAddress);
    require(balanceOf[_from] >= _value);
    var _to = novaContractAddress;
    require(balanceOf[_to] + _value > balanceOf[_to]);
    uint previousBalances = balanceOf[_from] + balanceOf[_to];
    balanceOf[_from] -= _value;
    balanceOf[_to] += _value;
  }
}

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="87e3e2f3e2c7e6ffeee8eafde2e9a9e4e8">[email protected]</a>&gt; (https://github.com/dete)&#13;
contract ERC721 {&#13;
  // Required methods&#13;
  function totalSupply() public view returns (uint256 total);&#13;
  function balanceOf(address _owner) public view returns (uint256 balance);&#13;
  function ownerOf(uint256 _tokenId) external view returns (address owner);&#13;
  function approve(address _to, uint256 _tokenId) external;&#13;
  function transfer(address _to, uint256 _tokenId) external;&#13;
  function transferFrom(address _from, address _to, uint256 _tokenId) external;&#13;
&#13;
  // Events&#13;
  event Transfer(address from, address to, uint256 tokenId);&#13;
  event Approval(address owner, address approved, uint256 tokenId);&#13;
&#13;
  // Optional&#13;
  // function name() public view returns (string name);&#13;
  // function symbol() public view returns (string symbol);&#13;
  // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);&#13;
  // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);&#13;
&#13;
  // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)&#13;
  function supportsInterface(bytes4 _interfaceID) external view returns (bool);&#13;
}&#13;
&#13;
// just interface reference&#13;
contract NovaLabInterface {&#13;
  function bornStar() external returns(uint star) {}&#13;
  function bornMeteoriteNumber() external returns(uint mNumber) {}&#13;
  function bornMeteorite() external returns(uint mQ) {}&#13;
  function mergeMeteorite(uint totalQuality) external returns(bool isSuccess, uint finalMass) {}&#13;
}&#13;
&#13;
contract FamedStarInterface {&#13;
  function bornFamedStar(address userAddress, uint mass) external returns(uint id, bytes32 name) {}&#13;
  function updateFamedStarOwner(uint id, address newOwner) external {}&#13;
}&#13;
&#13;
contract Nova is NovaAccessControl,ERC721 {&#13;
  // ERC721 Required&#13;
  bytes4 constant InterfaceSignature_ERC165 = bytes4(keccak256('supportsInterface(bytes4)'));&#13;
&#13;
  bytes4 constant InterfaceSignature_ERC721 =&#13;
    bytes4(keccak256('name()')) ^&#13;
    bytes4(keccak256('symbol()')) ^&#13;
    bytes4(keccak256('totalSupply()')) ^&#13;
    bytes4(keccak256('balanceOf(address)')) ^&#13;
    bytes4(keccak256('ownerOf(uint256)')) ^&#13;
    bytes4(keccak256('approve(address,uint256)')) ^&#13;
    bytes4(keccak256('transfer(address,uint256)')) ^&#13;
    bytes4(keccak256('transferFrom(address,address,uint256)')) ^&#13;
    bytes4(keccak256('tokensOfOwner(address)')) ^&#13;
    bytes4(keccak256('tokenMetadata(uint256,string)'));&#13;
&#13;
  function supportsInterface(bytes4 _interfaceID) external view returns (bool) {&#13;
    return ((_interfaceID == InterfaceSignature_ERC165) || (_interfaceID == InterfaceSignature_ERC721));&#13;
  }&#13;
&#13;
  function name() public pure returns (string) {&#13;
    return "Nova";&#13;
  }&#13;
&#13;
  function symbol() public pure returns (string) {&#13;
    return "NOVA";&#13;
  }&#13;
&#13;
  function totalSupply() public view returns (uint256 total) {&#13;
    return validAstroCount;&#13;
  }&#13;
&#13;
  function balanceOf(address _owner) public constant returns (uint balance) {&#13;
    return astroOwnerToIDsLen[_owner];&#13;
  }&#13;
&#13;
  function ownerOf(uint256 _tokenId) external constant returns (address owner) {&#13;
    return astroIndexToOwners[_tokenId];&#13;
  }&#13;
&#13;
  mapping(address =&gt; mapping (address =&gt; uint256)) allowed;&#13;
  function approve(address _to, uint256 _tokenId) external {&#13;
    require(msg.sender == astroIndexToOwners[_tokenId]);&#13;
    require(msg.sender != _to);&#13;
&#13;
    allowed[msg.sender][_to] = _tokenId;&#13;
    Approval(msg.sender, _to, _tokenId);&#13;
  }&#13;
&#13;
  function transfer(address _to, uint256 _tokenId) external {&#13;
    _transfer(msg.sender, _to, _tokenId);&#13;
    Transfer(msg.sender, _to, _tokenId);&#13;
  }&#13;
&#13;
  function transferFrom(address _from, address _to, uint256 _tokenId) external {&#13;
    _transfer(_from, _to, _tokenId);&#13;
  }&#13;
&#13;
  function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds) {&#13;
    return astroOwnerToIDs[_owner];&#13;
  }&#13;
&#13;
  string metaBaseUrl = "http://supernova.duelofkings.com";&#13;
  function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl) {&#13;
    return metaBaseUrl;&#13;
  }&#13;
&#13;
  function updateMetaBaseUrl(string newUrl) external onlyManager {&#13;
    metaBaseUrl = newUrl;&#13;
  }&#13;
&#13;
  // END of ERC-165 ERC-721&#13;
&#13;
  enum AstroType {Placeholder, Supernova, Meteorite, NormalStar, FamedStar, Dismissed}&#13;
  uint public superNovaSupply;&#13;
  uint public validAstroCount;&#13;
  address public novaCoinAddress;&#13;
  address public labAddress;&#13;
  address public famedStarAddress;&#13;
  uint public astroIDPool;&#13;
  uint public priceValidSeconds = 3600; //default 1 hour&#13;
&#13;
  uint novaTransferRate = 30; // 30/1000&#13;
&#13;
  struct Astro {&#13;
    uint id; //world unique, astroIDPool start from 1&#13;
    uint createTime;&#13;
    uint nextAttractTime;&#13;
    // [8][8][88][88] -&gt; L to H: astroType, cdIdx, famedID, mass&#13;
    uint48 code;&#13;
    bytes32 name;&#13;
  }&#13;
&#13;
  struct PurchasingRecord {&#13;
    uint id;&#13;
    uint priceWei;&#13;
    uint time;&#13;
  }&#13;
&#13;
  Astro[] public supernovas;&#13;
  Astro[] public normalStars;&#13;
  Astro[] public famedStars;&#13;
  Astro[] public meteorites;&#13;
&#13;
  uint32[31] public cd = [&#13;
    0,&#13;
    uint32(360 minutes),&#13;
    uint32(400 minutes),&#13;
    uint32(444 minutes),&#13;
    uint32(494 minutes),&#13;
    uint32(550 minutes),&#13;
    uint32(610 minutes),&#13;
    uint32(677 minutes),&#13;
    uint32(752 minutes),&#13;
    uint32(834 minutes),&#13;
    uint32(925 minutes),&#13;
    uint32(1027 minutes),&#13;
    uint32(1140 minutes),&#13;
    uint32(1265 minutes),&#13;
    uint32(1404 minutes),&#13;
    uint32(1558 minutes),&#13;
    uint32(1729 minutes),&#13;
    uint32(1919 minutes),&#13;
    uint32(2130 minutes),&#13;
    uint32(2364 minutes),&#13;
    uint32(2624 minutes),&#13;
    uint32(2912 minutes),&#13;
    uint32(3232 minutes),&#13;
    uint32(3587 minutes),&#13;
    uint32(3982 minutes),&#13;
    uint32(4420 minutes),&#13;
    uint32(4906 minutes),&#13;
    uint32(5445 minutes),&#13;
    uint32(6044 minutes),&#13;
    uint32(6708 minutes),&#13;
    uint32(7200 minutes)&#13;
  ];&#13;
&#13;
  // a mapping from astro ID to the address that owns&#13;
  mapping (uint =&gt; address) public astroIndexToOwners;&#13;
  mapping (address =&gt; uint[]) public astroOwnerToIDs;&#13;
  mapping (address =&gt; uint) public astroOwnerToIDsLen;&#13;
&#13;
  mapping (address =&gt; mapping(uint =&gt; uint)) public astroOwnerToIDIndex;&#13;
&#13;
  mapping (uint =&gt; uint) public idToIndex;&#13;
&#13;
  // a mapping from astro name to ID&#13;
  mapping (bytes32 =&gt; uint256) astroNameToIDs;&#13;
&#13;
  // purchasing mapping&#13;
  mapping (address =&gt; PurchasingRecord) public purchasingBuyer;&#13;
&#13;
  event PurchasedSupernova(address userAddress, uint astroID);&#13;
  event ExplodedSupernova(address userAddress, uint[] newAstroIDs);&#13;
  event MergedAstros(address userAddress, uint newAstroID);&#13;
  event AttractedMeteorites(address userAddress, uint[] newAstroIDs);&#13;
  event UserPurchasedAstro(address buyerAddress, address sellerAddress, uint astroID, uint recordPriceWei, uint value);&#13;
  event NovaPurchasing(address buyAddress, uint astroID, uint priceWei);&#13;
&#13;
  // initial supply to managerAddress&#13;
  function Nova(uint32 initialSupply) public {&#13;
    superNovaSupply = initialSupply;&#13;
    validAstroCount = 0;&#13;
    astroIDPool = 0;&#13;
  }&#13;
&#13;
  function updateNovaTransferRate(uint rate) external onlyManager {&#13;
    novaTransferRate = rate;&#13;
  }&#13;
&#13;
  function updateNovaCoinAddress(address novaCoinAddr) external onlyManager {&#13;
    novaCoinAddress = novaCoinAddr;&#13;
  }&#13;
&#13;
  function updateLabContractAddress(address addr) external onlyManager {&#13;
    labAddress = addr;&#13;
  }&#13;
&#13;
  function updateFamedStarContractAddress(address addr) external onlyManager {&#13;
    famedStarAddress = addr;&#13;
  }&#13;
&#13;
  function updatePriceValidSeconds(uint newSeconds) external onlyManager {&#13;
    priceValidSeconds = newSeconds;&#13;
  }&#13;
&#13;
  function getAstrosLength() constant external returns(uint) {&#13;
      return astroIDPool;&#13;
  }&#13;
&#13;
  function getUserAstroIDs(address userAddress) constant external returns(uint[]) {&#13;
    return astroOwnerToIDs[userAddress];&#13;
  }&#13;
&#13;
  function getNovaOwnerAddress(uint novaID) constant external returns(address) {&#13;
      return astroIndexToOwners[novaID];&#13;
  }&#13;
&#13;
  function getAstroInfo(uint id) constant public returns(uint novaId, uint idx, AstroType astroType, string astroName, uint mass, uint createTime, uint famedID, uint nextAttractTime, uint cdTime) {&#13;
      if (id &gt; astroIDPool) {&#13;
          return;&#13;
      }&#13;
&#13;
      (idx, astroType) = _extractIndex(idToIndex[id]);&#13;
      if (astroType == AstroType.Placeholder || astroType == AstroType.Dismissed) {&#13;
          return;&#13;
      }&#13;
&#13;
      Astro memory astro;&#13;
      uint cdIdx;&#13;
&#13;
      var astroPool = _getAstroPoolByType(astroType);&#13;
      astro = astroPool[idx];&#13;
      (astroType, cdIdx, famedID, mass) = _extractCode(astro.code);&#13;
&#13;
      return (id, idx, astroType, _bytes32ToString(astro.name), mass, astro.createTime, famedID, astro.nextAttractTime, cd[cdIdx]);&#13;
  }&#13;
&#13;
  function getAstroInfoByIdx(uint index, AstroType aType) constant external returns(uint novaId, uint idx, AstroType astroType, string astroName, uint mass, uint createTime, uint famedID, uint nextAttractTime, uint cdTime) {&#13;
      if (aType == AstroType.Placeholder || aType == AstroType.Dismissed) {&#13;
          return;&#13;
      }&#13;
&#13;
      var astroPool = _getAstroPoolByType(aType);&#13;
      Astro memory astro = astroPool[index];&#13;
      uint cdIdx;&#13;
      (astroType, cdIdx, famedID, mass) = _extractCode(astro.code);&#13;
      return (astro.id, index, astroType, _bytes32ToString(astro.name), mass, astro.createTime, famedID, astro.nextAttractTime, cd[cdIdx]);&#13;
  }&#13;
&#13;
  function getSupernovaBalance() constant external returns(uint) {&#13;
      return superNovaSupply;&#13;
  }&#13;
&#13;
  function getAstroPoolLength(AstroType astroType) constant external returns(uint) {&#13;
      Astro[] storage pool = _getAstroPoolByType(astroType);&#13;
      return pool.length;&#13;
  }&#13;
&#13;
  // read from end position&#13;
  function getAstroIdxsByPage(uint lastIndex, uint count, AstroType expectedType) constant external returns(uint[] idx, uint idxLen) {&#13;
      if (expectedType == AstroType.Placeholder || expectedType == AstroType.Dismissed) {&#13;
          return;&#13;
      }&#13;
&#13;
      Astro[] storage astroPool = _getAstroPoolByType(expectedType);&#13;
&#13;
      if (lastIndex == 0 || astroPool.length == 0 || lastIndex &gt; astroPool.length) {&#13;
          return;&#13;
      }&#13;
&#13;
      uint[] memory result = new uint[](count);&#13;
      uint start = lastIndex - 1;&#13;
      uint i = 0;&#13;
      for (uint cursor = start; cursor &gt;= 0 &amp;&amp; i &lt; count; --cursor) {&#13;
          var astro = astroPool[cursor];&#13;
          if (_isValidAstro(_getAstroTypeByCode(astro.code))) {&#13;
            result[i++] = cursor;&#13;
          }&#13;
          if (cursor == 0) {&#13;
              break;&#13;
          }&#13;
      }&#13;
&#13;
      // ugly&#13;
      uint[] memory finalR = new uint[](i);&#13;
      for (uint cnt = 0; cnt &lt; i; cnt++) {&#13;
        finalR[cnt] = result[cnt];&#13;
      }&#13;
&#13;
      return (finalR, i);&#13;
  }&#13;
&#13;
  function isUserOwnNovas(address userAddress, uint[] novaIDs) constant external returns(bool isOwn) {&#13;
      for (uint i = 0; i &lt; novaIDs.length; i++) {&#13;
          if (astroIndexToOwners[novaIDs[i]] != userAddress) {&#13;
              return false;&#13;
          }&#13;
      }&#13;
&#13;
      return true;&#13;
  }&#13;
&#13;
  function getUserPurchasingTime(address buyerAddress) constant external returns(uint) {&#13;
    return purchasingBuyer[buyerAddress].time;&#13;
  }&#13;
&#13;
  function _extractIndex(uint codeIdx) pure public returns(uint index, AstroType astroType) {&#13;
      astroType = AstroType(codeIdx &amp; 0x0000000000ff);&#13;
      index = uint(codeIdx &gt;&gt; 8);&#13;
  }&#13;
&#13;
  function _combineIndex(uint index, AstroType astroType) pure public returns(uint codeIdx) {&#13;
      codeIdx = uint((index &lt;&lt; 8) | uint(astroType));&#13;
  }&#13;
&#13;
  function _updateAstroTypeForIndexCode(uint orgCodeIdx, AstroType astroType) pure public returns(uint) {&#13;
      return (orgCodeIdx &amp; 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff00) | (uint(astroType));&#13;
  }&#13;
&#13;
  function _updateIndexForIndexCode(uint orgCodeIdx, uint idx) pure public returns(uint) {&#13;
      return (orgCodeIdx &amp; 0xff) | (idx &lt;&lt; 8);&#13;
  }&#13;
&#13;
  function _extractCode(uint48 code) pure public returns(AstroType astroType, uint cdIdx, uint famedID, uint mass) {&#13;
     astroType = AstroType(code &amp; 0x0000000000ff);&#13;
     if (astroType == AstroType.NormalStar) {&#13;
        cdIdx = (code &amp; 0x00000000ff00) &gt;&gt; 8;&#13;
        famedID = 0;&#13;
        mass = (code &amp; 0xffff00000000) &gt;&gt; 32;&#13;
     } else if (astroType == AstroType.FamedStar) {&#13;
        cdIdx = (code &amp; 0x00000000ff00) &gt;&gt; 8;&#13;
        famedID = (code &amp; 0x0000ffff0000) &gt;&gt; 16;&#13;
        mass = (code &amp; 0xffff00000000) &gt;&gt; 32;&#13;
     } else if (astroType == AstroType.Supernova) {&#13;
        cdIdx = 0;&#13;
        famedID = 0;&#13;
        mass = 0;&#13;
     } else {&#13;
        cdIdx = 0;&#13;
        famedID = 0;&#13;
        mass = (code &amp; 0xffff00000000) &gt;&gt; 32;&#13;
     }&#13;
  }&#13;
&#13;
  function _getAstroTypeByCode(uint48 code) pure internal returns(AstroType astroType) {&#13;
     return AstroType(code &amp; 0x0000000000ff);&#13;
  }&#13;
&#13;
  function _getMassByCode(uint48 code) pure internal returns(uint mass) {&#13;
     return uint((code &amp; 0xffff00000000) &gt;&gt; 32);&#13;
  }&#13;
&#13;
  function _getCdIdxByCode(uint48 code) pure internal returns(uint cdIdx) {&#13;
     return uint((code &amp; 0x00000000ff00) &gt;&gt; 8);&#13;
  }&#13;
&#13;
  function _getFamedIDByCode(uint48 code) pure internal returns(uint famedID) {&#13;
    return uint((code &amp; 0x0000ffff0000) &gt;&gt; 16);&#13;
  }&#13;
&#13;
  function _combieCode(AstroType astroType, uint cdIdx, uint famedID, uint mass) pure public returns(uint48 code) {&#13;
     if (astroType == AstroType.NormalStar) {&#13;
        return uint48(astroType) | (uint48(cdIdx) &lt;&lt; 8) | (uint48(mass) &lt;&lt; 32);&#13;
     } else if (astroType == AstroType.FamedStar) {&#13;
        return uint48(astroType) | (uint48(cdIdx) &lt;&lt; 8) | (uint48(famedID) &lt;&lt; 16) | (uint48(mass) &lt;&lt; 32);&#13;
     } else if (astroType == AstroType.Supernova) {&#13;
        return uint48(astroType);&#13;
     } else {&#13;
        return uint48(astroType) | (uint48(mass) &lt;&lt; 32);&#13;
     }&#13;
  }&#13;
&#13;
  function _updateAstroTypeForCode(uint48 orgCode, AstroType newType) pure public returns(uint48 newCode) {&#13;
     return (orgCode &amp; 0xffffffffff00) | (uint48(newType));&#13;
  }&#13;
&#13;
  function _updateCdIdxForCode(uint48 orgCode, uint newIdx) pure public returns(uint48 newCode) {&#13;
     return (orgCode &amp; 0xffffffff00ff) | (uint48(newIdx) &lt;&lt; 8);&#13;
  }&#13;
&#13;
  function _getAstroPoolByType(AstroType expectedType) constant internal returns(Astro[] storage pool) {&#13;
      if (expectedType == AstroType.Supernova) {&#13;
          return supernovas;&#13;
      } else if (expectedType == AstroType.Meteorite) {&#13;
          return meteorites;&#13;
      } else if (expectedType == AstroType.NormalStar) {&#13;
          return normalStars;&#13;
      } else if (expectedType == AstroType.FamedStar) {&#13;
          return famedStars;&#13;
      }&#13;
  }&#13;
&#13;
  function _isValidAstro(AstroType astroType) pure internal returns(bool) {&#13;
      return astroType != AstroType.Placeholder &amp;&amp; astroType != AstroType.Dismissed;&#13;
  }&#13;
&#13;
  function _reduceValidAstroCount() internal {&#13;
    --validAstroCount;&#13;
  }&#13;
&#13;
  function _plusValidAstroCount() internal {&#13;
    ++validAstroCount;&#13;
  }&#13;
&#13;
  function _addAstro(AstroType astroType, bytes32 astroName, uint mass, uint createTime, uint famedID) internal returns(uint) {&#13;
    uint48 code = _combieCode(astroType, 0, famedID, mass);&#13;
&#13;
    var astroPool = _getAstroPoolByType(astroType);&#13;
    ++astroIDPool;&#13;
    uint idx = astroPool.push(Astro({&#13;
        id: astroIDPool,&#13;
        name: astroName,&#13;
        createTime: createTime,&#13;
        nextAttractTime: 0,&#13;
        code: code&#13;
    })) - 1;&#13;
&#13;
    idToIndex[astroIDPool] = _combineIndex(idx, astroType);&#13;
&#13;
    return astroIDPool;&#13;
  }&#13;
&#13;
  function _removeAstroFromUser(address userAddress, uint novaID) internal {&#13;
    uint idsLen = astroOwnerToIDsLen[userAddress];&#13;
    uint index = astroOwnerToIDIndex[userAddress][novaID];&#13;
&#13;
    if (idsLen &gt; 1 &amp;&amp; index != idsLen - 1) {&#13;
        uint endNovaID = astroOwnerToIDs[userAddress][idsLen - 1];&#13;
        astroOwnerToIDs[userAddress][index] = endNovaID;&#13;
        astroOwnerToIDIndex[userAddress][endNovaID] = index;&#13;
    }&#13;
    astroOwnerToIDs[userAddress][idsLen - 1] = 0;&#13;
    astroOwnerToIDsLen[userAddress] = idsLen - 1;&#13;
  }&#13;
&#13;
  function _addAstroToUser(address userAddress, uint novaID) internal {&#13;
    uint idsLen = astroOwnerToIDsLen[userAddress];&#13;
    uint arrayLen = astroOwnerToIDs[userAddress].length;&#13;
    if (idsLen == arrayLen) {&#13;
      astroOwnerToIDsLen[userAddress] = astroOwnerToIDs[userAddress].push(novaID);&#13;
      astroOwnerToIDIndex[userAddress][novaID] = astroOwnerToIDsLen[userAddress] - 1;&#13;
    } else {&#13;
      // there is gap&#13;
      astroOwnerToIDs[userAddress][idsLen] = novaID;&#13;
      astroOwnerToIDsLen[userAddress] = idsLen + 1;&#13;
      astroOwnerToIDIndex[userAddress][novaID] = idsLen;&#13;
    }&#13;
  }&#13;
&#13;
  function _burnDownAstro(address userAddress, uint novaID) internal {&#13;
    delete astroIndexToOwners[novaID];&#13;
    _removeAstroFromUser(userAddress, novaID);&#13;
&#13;
    uint idx;&#13;
    AstroType astroType;&#13;
    uint orgIdxCode = idToIndex[novaID];&#13;
    (idx, astroType) = _extractIndex(orgIdxCode);&#13;
&#13;
    var pool = _getAstroPoolByType(astroType);&#13;
    pool[idx].code = _updateAstroTypeForCode(pool[idx].code, AstroType.Dismissed);&#13;
&#13;
    idToIndex[novaID] = _updateAstroTypeForIndexCode(orgIdxCode, AstroType.Dismissed);&#13;
&#13;
    _reduceValidAstroCount();&#13;
  }&#13;
&#13;
  function _insertNewAstro(address userAddress, AstroType t, uint mass, bytes32 novaName, uint famedID) internal returns(uint) {&#13;
    uint newNovaID = _addAstro(t, novaName, mass, block.timestamp, famedID);&#13;
    astroIndexToOwners[newNovaID] = userAddress;&#13;
    _addAstroToUser(userAddress, newNovaID);&#13;
&#13;
    _plusValidAstroCount();&#13;
    return newNovaID;&#13;
  }&#13;
&#13;
  function _bytes32ToString(bytes32 x) internal pure returns (string) {&#13;
    bytes memory bytesString = new bytes(32);&#13;
    uint charCount = 0;&#13;
    for (uint j = 0; j &lt; 32; j++) {&#13;
        byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));&#13;
        if (char != 0) {&#13;
            bytesString[charCount] = char;&#13;
            charCount++;&#13;
        }&#13;
    }&#13;
    bytes memory bytesStringTrimmed = new bytes(charCount);&#13;
    for (j = 0; j &lt; charCount; j++) {&#13;
        bytesStringTrimmed[j] = bytesString[j];&#13;
    }&#13;
    return string(bytesStringTrimmed);&#13;
  }&#13;
&#13;
  function _stringToBytes32(string source) internal pure returns (bytes32 result) {&#13;
    bytes memory tempEmptyStringTest = bytes(source);&#13;
    if (tempEmptyStringTest.length == 0) {&#13;
        return 0x0;&#13;
    }&#13;
&#13;
    assembly {&#13;
        result := mload(add(source, 32))&#13;
    }&#13;
  }&#13;
&#13;
  function _transfer(address _from, address _to, uint _tokenId) internal {&#13;
    require(_from == astroIndexToOwners[_tokenId]);&#13;
    require(_from != _to &amp;&amp; _to != address(0));&#13;
&#13;
    uint poolIdx;&#13;
    AstroType itemType;&#13;
    (poolIdx, itemType) = _extractIndex(idToIndex[_tokenId]);&#13;
    var pool = _getAstroPoolByType(itemType);&#13;
    var astro = pool[poolIdx];&#13;
    require(_getAstroTypeByCode(astro.code) != AstroType.Dismissed);&#13;
&#13;
    astroIndexToOwners[_tokenId] = _to;&#13;
&#13;
    _removeAstroFromUser(_from, _tokenId);&#13;
    _addAstroToUser(_to, _tokenId);&#13;
&#13;
    // Check if it's famous star&#13;
    uint famedID = _getFamedIDByCode(astro.code);&#13;
    if (famedID &gt; 0) {&#13;
      var famedstarContract = FamedStarInterface(famedStarAddress);&#13;
      famedstarContract.updateFamedStarOwner(famedID, _to);&#13;
    }&#13;
  }&#13;
&#13;
  // Purchase action only permit manager to use&#13;
  function purchaseSupernova(address targetAddress, uint price) external onlyManager {&#13;
    require(superNovaSupply &gt;= 1);&#13;
    NovaCoin novaCoinContract = NovaCoin(novaCoinAddress);&#13;
    require(novaCoinContract.balanceOf(targetAddress) &gt;= price);&#13;
    novaCoinContract.consumeCoinForNova(targetAddress, price);&#13;
&#13;
    superNovaSupply -= 1;&#13;
    var newNovaID = _insertNewAstro(targetAddress, AstroType.Supernova, 0, 0, 0);&#13;
    PurchasedSupernova(targetAddress, newNovaID);&#13;
  }&#13;
&#13;
  // explode one supernova from user's supernova balance, write explode result into user account&#13;
  function explodeSupernova(address userAddress, uint novaID) external onlyManager {&#13;
    // verifu if user own's this supernova&#13;
    require(astroIndexToOwners[novaID] == userAddress);&#13;
    uint poolIdx;&#13;
    AstroType itemType;&#13;
    (poolIdx, itemType) = _extractIndex(idToIndex[novaID]);&#13;
    require(itemType == AstroType.Supernova);&#13;
    // burn down user's supernova&#13;
    _burnDownAstro(userAddress, novaID);&#13;
&#13;
    uint[] memory newAstroIDs;&#13;
&#13;
    var labContract = NovaLabInterface(labAddress);&#13;
    uint star = labContract.bornStar();&#13;
    if (star &gt; 0) {&#13;
        // Got star, check if it's famed star&#13;
        newAstroIDs = new uint[](1);&#13;
        var famedstarContract = FamedStarInterface(famedStarAddress);&#13;
        uint famedID;&#13;
        bytes32 novaName;&#13;
        (famedID, novaName) = famedstarContract.bornFamedStar(userAddress, star);&#13;
        if (famedID &gt; 0) {&#13;
            newAstroIDs[0] = _insertNewAstro(userAddress, AstroType.FamedStar, star, novaName, famedID);&#13;
        } else {&#13;
            newAstroIDs[0] = _insertNewAstro(userAddress, AstroType.NormalStar, star, 0, 0);&#13;
        }&#13;
    } else {&#13;
        uint mNum = labContract.bornMeteoriteNumber();&#13;
        newAstroIDs = new uint[](mNum);&#13;
        uint m;&#13;
        for (uint i = 0; i &lt; mNum; i++) {&#13;
            m = labContract.bornMeteorite();&#13;
            newAstroIDs[i] = _insertNewAstro(userAddress, AstroType.Meteorite, m, 0, 0);&#13;
        }&#13;
    }&#13;
    ExplodedSupernova(userAddress, newAstroIDs);&#13;
  }&#13;
&#13;
  function _merge(address userAddress, uint mergeMass) internal returns (uint famedID, bytes32 novaName, AstroType newType, uint finalMass) {&#13;
    var labContract = NovaLabInterface(labAddress);&#13;
    bool mergeResult;&#13;
    (mergeResult, finalMass) = labContract.mergeMeteorite(mergeMass);&#13;
    if (mergeResult) {&#13;
        //got star, check if we can get famed star&#13;
        var famedstarContract = FamedStarInterface(famedStarAddress);&#13;
        (famedID, novaName) = famedstarContract.bornFamedStar(userAddress, mergeMass);&#13;
        if (famedID &gt; 0) {&#13;
            newType = AstroType.FamedStar;&#13;
        } else {&#13;
            newType = AstroType.NormalStar;&#13;
        }&#13;
    } else {&#13;
        newType = AstroType.Meteorite;&#13;
    }&#13;
    return;&#13;
  }&#13;
&#13;
  function _combine(address userAddress, uint[] astroIDs) internal returns(uint mergeMass) {&#13;
    uint astroID;&#13;
    mergeMass = 0;&#13;
    uint poolIdx;&#13;
    AstroType itemType;&#13;
    for (uint i = 0; i &lt; astroIDs.length; i++) {&#13;
        astroID = astroIDs[i];&#13;
        (poolIdx, itemType) = _extractIndex(idToIndex[astroID]);&#13;
        require(astroIndexToOwners[astroID] == userAddress);&#13;
        require(itemType == AstroType.Meteorite);&#13;
        // start merge&#13;
        //mergeMass += meteorites[idToIndex[astroID].index].mass;&#13;
        mergeMass += _getMassByCode(meteorites[poolIdx].code);&#13;
        // Burn down&#13;
        _burnDownAstro(userAddress, astroID);&#13;
    }&#13;
  }&#13;
&#13;
  function mergeAstros(address userAddress, uint novaCoinCentCost, uint[] astroIDs) external onlyManager {&#13;
    // check nova coin balance&#13;
    NovaCoin novaCoinContract = NovaCoin(novaCoinAddress);&#13;
    require(novaCoinContract.balanceOf(userAddress) &gt;= novaCoinCentCost);&#13;
    // check astros&#13;
    require(astroIDs.length &gt; 1 &amp;&amp; astroIDs.length &lt;= 10);&#13;
&#13;
    uint mergeMass = _combine(userAddress, astroIDs);&#13;
    // Consume novaCoin&#13;
    novaCoinContract.consumeCoinForNova(userAddress, novaCoinCentCost);&#13;
    // start merge&#13;
    uint famedID;&#13;
    bytes32 novaName;&#13;
    AstroType newType;&#13;
    uint finalMass;&#13;
    (famedID, novaName, newType, finalMass) = _merge(userAddress, mergeMass);&#13;
    // Create new Astro&#13;
    MergedAstros(userAddress, _insertNewAstro(userAddress, newType, finalMass, novaName, famedID));&#13;
  }&#13;
&#13;
  function _attractBalanceCheck(address userAddress, uint novaCoinCentCost) internal {&#13;
    // check balance&#13;
    NovaCoin novaCoinContract = NovaCoin(novaCoinAddress);&#13;
    require(novaCoinContract.balanceOf(userAddress) &gt;= novaCoinCentCost);&#13;
&#13;
    // consume coin&#13;
    novaCoinContract.consumeCoinForNova(userAddress, novaCoinCentCost);&#13;
  }&#13;
&#13;
  function attractMeteorites(address userAddress, uint novaCoinCentCost, uint starID) external onlyManager {&#13;
    require(astroIndexToOwners[starID] == userAddress);&#13;
    uint poolIdx;&#13;
    AstroType itemType;&#13;
    (poolIdx, itemType) = _extractIndex(idToIndex[starID]);&#13;
&#13;
    require(itemType == AstroType.NormalStar || itemType == AstroType.FamedStar);&#13;
&#13;
    var astroPool = _getAstroPoolByType(itemType);&#13;
    Astro storage astro = astroPool[poolIdx];&#13;
    require(astro.nextAttractTime &lt;= block.timestamp);&#13;
&#13;
    _attractBalanceCheck(userAddress, novaCoinCentCost);&#13;
&#13;
    var labContract = NovaLabInterface(labAddress);&#13;
    uint[] memory newAstroIDs = new uint[](1);&#13;
    uint m = labContract.bornMeteorite();&#13;
    newAstroIDs[0] = _insertNewAstro(userAddress, AstroType.Meteorite, m, 0, 0);&#13;
    // update cd&#13;
    uint cdIdx = _getCdIdxByCode(astro.code);&#13;
    if (cdIdx &gt;= cd.length - 1) {&#13;
        astro.nextAttractTime = block.timestamp + cd[cd.length - 1];&#13;
    } else {&#13;
        astro.code = _updateCdIdxForCode(astro.code, ++cdIdx);&#13;
        astro.nextAttractTime = block.timestamp + cd[cdIdx];&#13;
    }&#13;
&#13;
    AttractedMeteorites(userAddress, newAstroIDs);&#13;
  }&#13;
&#13;
  function setPurchasing(address buyerAddress, address ownerAddress, uint astroID, uint priceWei) external onlyManager {&#13;
    require(astroIndexToOwners[astroID] == ownerAddress);&#13;
    purchasingBuyer[buyerAddress] = PurchasingRecord({&#13;
         id: astroID,&#13;
         priceWei: priceWei,&#13;
         time: block.timestamp&#13;
    });&#13;
    NovaPurchasing(buyerAddress, astroID, priceWei);&#13;
  }&#13;
&#13;
  function userPurchaseAstro(address ownerAddress, uint astroID) payable external {&#13;
    // check valid purchasing tim&#13;
    require(msg.sender.balance &gt;= msg.value);&#13;
    var record = purchasingBuyer[msg.sender];&#13;
    require(block.timestamp &lt; record.time + priceValidSeconds);&#13;
    require(record.id == astroID);&#13;
    require(record.priceWei &lt;= msg.value);&#13;
&#13;
    uint royalties = uint(msg.value * novaTransferRate / 1000);&#13;
    ownerAddress.transfer(msg.value - royalties);&#13;
    cfoAddress.transfer(royalties);&#13;
&#13;
    _transfer(ownerAddress, msg.sender, astroID);&#13;
&#13;
    UserPurchasedAstro(msg.sender, ownerAddress, astroID, record.priceWei, msg.value);&#13;
    // clear purchasing state&#13;
    delete purchasingBuyer[msg.sender];&#13;
  }&#13;
}