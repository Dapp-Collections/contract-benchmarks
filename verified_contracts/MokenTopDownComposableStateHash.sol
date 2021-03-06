pragma solidity 0.4.24;
/******************************************************************************\
* Author: Nick Mudge, <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="8ee0e7ede5cee3e1e5ebe0fda0e7e1">[email protected]</a>&#13;
* Mokens&#13;
* Copyright (c) 2018&#13;
*&#13;
* The getStateHash function returns a hash that represents the state of a moken. &#13;
* This can be used to verify that child non-fungible tokens have not&#13;
* been added/removed right before a transfer or sale.&#13;
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
///////////////////////////////////////////////////////////////////////////////////&#13;
//MokenERC998ERC721TopDown&#13;
//MokenERC998ERC721TopDownBatch&#13;
//MokenERC721&#13;
//MokenERC721Batch&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
contract Storage5 is Storage4 {&#13;
    // tokenId =&gt; (child address =&gt; array of child tokens)&#13;
    mapping(uint256 =&gt; mapping(address =&gt; uint256[])) internal childTokens;&#13;
    // tokenId =&gt; (child address =&gt; (child token =&gt; child index)&#13;
    mapping(uint256 =&gt; mapping(address =&gt; mapping(uint256 =&gt; uint256))) internal childTokenIndex;&#13;
    // tokenId =&gt; (child address =&gt; contract index)&#13;
    mapping(uint256 =&gt; mapping(address =&gt; uint256)) internal childContractIndex;&#13;
    // tokenId =&gt; child contract&#13;
    mapping(uint256 =&gt; address[]) internal childContracts;&#13;
}&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
//MokenERC998ERC20TopDown&#13;
//MokenStateChange&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
contract Storage6 is Storage5 {&#13;
    // tokenId =&gt; token contract&#13;
    mapping(uint256 =&gt; address[]) internal erc20Contracts;&#13;
    // tokenId =&gt; (token contract =&gt; token contract index)&#13;
    mapping(uint256 =&gt; mapping(address =&gt; uint256)) erc20ContractIndex;&#13;
    // tokenId =&gt; (token contract =&gt; balance)&#13;
    mapping(uint256 =&gt; mapping(address =&gt; uint256)) internal erc20Balances;&#13;
}&#13;
&#13;
contract MokenTopDownComposableStateHash is Storage6 {&#13;
    function topDownComposableStateHash(uint256 _tokenId) external view returns (bytes32 stateHash) {&#13;
        address[] memory childContracts_ = childContracts[_tokenId];&#13;
        uint256 length = childContracts_.length;&#13;
        uint256 i;&#13;
        if(length &gt; 0) {&#13;
            stateHash = keccak256(stateHash, childContracts_);&#13;
            for (i = 0; i &lt; length; i++) {&#13;
                stateHash = keccak256(stateHash, childTokens[_tokenId][childContracts_[i]]);&#13;
            }&#13;
        }&#13;
        address[] memory erc20Contracts_ = erc20Contracts[_tokenId];&#13;
        length = erc20Contracts_.length;&#13;
        if(length &gt; 0) {&#13;
            stateHash = keccak256(stateHash, erc20Contracts_);&#13;
            for (i = 0; i &lt; length; i++) {&#13;
                stateHash = keccak256(stateHash, erc20Balances[_tokenId][erc20Contracts_[i]]);&#13;
            }&#13;
        }&#13;
        return stateHash;&#13;
    }&#13;
}