pragma solidity 0.4.24;
pragma experimental "v0.5.0";
/******************************************************************************\
* Author: Nick Mudge, <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5937303a32193436323c372a773036">[email protected]</a>&#13;
* Mokens&#13;
* Copyright (c) 2018&#13;
*&#13;
* Implements ERC721Enumerable.&#13;
/******************************************************************************/&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
//Storage contracts&#13;
////////////&#13;
//Some delegate contracts are listed with storage contracts they inherit.&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
//Mokens&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
contract Storage0 {&#13;
    // funcId =&gt; delegate contract&#13;
    mapping(bytes4 =&gt; address) internal delegates;&#13;
}&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
//MokenUpdates&#13;
//MokenOwner&#13;
//QueryMokenDelegates&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
contract Storage1 is Storage0 {&#13;
    address internal contractOwner;&#13;
    bytes[] internal funcSignatures;&#13;
    // signature =&gt; index+1&#13;
    mapping(bytes =&gt; uint256) internal funcSignatureToIndex;&#13;
}&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
//MokensSupportsInterfaces&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
contract Storage2 is Storage1 {&#13;
    mapping(bytes4 =&gt; bool) internal supportedInterfaces;&#13;
}&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
//MokenRootOwnerOf&#13;
//MokenERC721Metadata&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
contract Storage3 is Storage2 {&#13;
    struct Moken {&#13;
        string name;&#13;
        uint256 data;&#13;
        uint256 parentTokenId;&#13;
    }&#13;
    //tokenId =&gt; moken&#13;
    mapping(uint256 =&gt; Moken) internal mokens;&#13;
    uint256 internal mokensLength;&#13;
    // child address =&gt; child tokenId =&gt; tokenId+1&#13;
    mapping(address =&gt; mapping(uint256 =&gt; uint256)) internal childTokenOwner;&#13;
}&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
//MokenERC721Enumerable&#13;
//MokenLinkHash&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
contract Storage4 is Storage3 {&#13;
    // root token owner address =&gt; (tokenId =&gt; approved address)&#13;
    mapping(address =&gt; mapping(uint256 =&gt; address)) internal rootOwnerAndTokenIdToApprovedAddress;&#13;
    // token owner =&gt; (operator address =&gt; bool)&#13;
    mapping(address =&gt; mapping(address =&gt; bool)) internal tokenOwnerToOperators;&#13;
    // Mapping from owner to list of owned token IDs&#13;
    mapping(address =&gt; uint32[]) internal ownedTokens;&#13;
}&#13;
&#13;
contract MokenERC721Enumerable is Storage4 {&#13;
    function exists(uint256 _tokenId) external view returns (bool) {&#13;
        return _tokenId &lt; mokensLength;&#13;
    }&#13;
&#13;
    function tokenOfOwnerByIndex(address _tokenOwner, uint256 _index) external view returns (uint256 tokenId) {&#13;
        require(_index &lt; ownedTokens[_tokenOwner].length, "_tokenOwner does not own a moken at this index.");&#13;
        return ownedTokens[_tokenOwner][_index];&#13;
    }&#13;
&#13;
    function totalSupply() external view returns (uint256 totalMokens) {&#13;
        return mokensLength;&#13;
    }&#13;
&#13;
    function tokenByIndex(uint256 _index) external view returns (uint256 tokenId) {&#13;
        require(_index &lt; mokensLength, "A tokenId at index does not exist.");&#13;
        return _index;&#13;
    }&#13;
}