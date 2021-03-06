pragma solidity 0.4.24;
pragma experimental "v0.5.0";
/******************************************************************************\
* Author: Nick Mudge, <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="2947404a42694446424c475a074046">[email protected]</a>&#13;
* Mokens&#13;
* Copyright (c) 2018&#13;
*&#13;
* Authenticates and controls contracts that mint mokens.&#13;
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
///////////////////////////////////////////////////////////////////////////////////&#13;
//MokenERC998ERC721BottomUp&#13;
//MokenERC998ERC721BottomUpBatch&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
contract Storage7 is Storage6 {&#13;
    // parent address =&gt; (parent tokenId =&gt; array of child tokenIds)&#13;
    mapping(address =&gt; mapping(uint256 =&gt; uint32[])) internal parentToChildTokenIds;&#13;
    // tokenId =&gt; position in childTokens array&#13;
    mapping(uint256 =&gt; uint256) internal tokenIdToChildTokenIdsIndex;&#13;
}&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
//MokenMinting&#13;
//MokenMintContractManagement&#13;
//MokenEras&#13;
//QueryMokenData&#13;
///////////////////////////////////////////////////////////////////////////////////&#13;
contract Storage8 is Storage7 {&#13;
    // index =&gt; era&#13;
    mapping(uint256 =&gt; bytes32) internal eras;&#13;
    uint256 internal eraLength;&#13;
    // era =&gt; index+1&#13;
    mapping(bytes32 =&gt; uint256) internal eraIndex;&#13;
    uint256 internal mintPriceOffset; // = 0 szabo;&#13;
    uint256 internal mintStepPrice; // = 500 szabo;&#13;
    uint256 internal mintPriceBuffer; // = 5000 szabo;&#13;
    address[] internal mintContracts;&#13;
    mapping(address =&gt; uint256) internal mintContractIndex;&#13;
    //moken name =&gt; tokenId+1&#13;
    mapping(string =&gt; uint256) internal tokenByName_;&#13;
}&#13;
&#13;
contract MokenMintContractManagement is Storage8 {&#13;
&#13;
    function isMintContract(address _contract) public view returns (bool) {&#13;
        return mintContractIndex[_contract] != 0;&#13;
    }&#13;
&#13;
    function totalMintContracts() external view returns (uint256 totalMintContracts_) {&#13;
        return mintContracts.length;&#13;
    }&#13;
&#13;
    function mintContractByIndex(uint256 index) external view returns (address contract_) {&#13;
        require(index &lt; mintContracts.length, "Contract index does not exist.");&#13;
        return mintContracts[index];&#13;
    }&#13;
&#13;
    function isContract(address addr) internal view returns (bool) {&#13;
        uint256 size;&#13;
        assembly {size := extcodesize(addr)}&#13;
        return size &gt; 0;&#13;
    }&#13;
    // add contract to list of contracts that can mint mokens&#13;
    function addMintContract(address _contract) external {&#13;
        require(msg.sender == contractOwner, "Must own Mokens contract.");&#13;
        require(isContract(_contract), "Address is not a contract.");&#13;
        require(mintContractIndex[_contract] == 0, "Contract already added.");&#13;
        mintContracts.push(_contract);&#13;
        mintContractIndex[_contract] = mintContracts.length;&#13;
    }&#13;
&#13;
    function removeMintContract(address _contract) external {&#13;
        require(msg.sender == contractOwner, "Must own Mokens contract.");&#13;
        uint256 index = mintContractIndex[_contract];&#13;
        require(index != 0, "Mint contract was not added.");&#13;
        uint256 lastIndex = mintContracts.length - 1;&#13;
        address lastMintContract = mintContracts[lastIndex];&#13;
        mintContracts[index - 1] = lastMintContract;&#13;
        mintContractIndex[lastMintContract] = index;&#13;
        delete mintContractIndex[_contract];&#13;
        mintContracts.length--;&#13;
    }&#13;
}