pragma solidity 0.4.18;
/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }
  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }
  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }
}
/*
  Copyright 2017 Loopring Project Ltd (Loopring Foundation).
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  http://www.apache.org/licenses/LICENSE-2.0
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
*/
/// @title LRC Foundation Airdrop Address Binding Contract
/// @author Kongliang Zhong - <<span class="__cf_email__" data-cfemail="fd9692939a91949c939abd9192928d8f94939ad3928f9a">[email protected]</span>&gt;,&#13;
contract LRxAirdropAddressBinding is Ownable {&#13;
    mapping(address =&gt; mapping(uint8 =&gt; string)) public bindings;&#13;
    mapping(uint8 =&gt; string) public projectNameMap;&#13;
    event AddressesBound(address sender, uint8 projectId, string targetAddr);&#13;
    event AddressesUnbound(address sender, uint8 projectId);&#13;
    // @projectId: 1=LRN, 2=LRQ&#13;
    function bind(uint8 projectId, string targetAddr)&#13;
        external&#13;
    {&#13;
        require(projectId &gt; 0);&#13;
        bindings[msg.sender][projectId] = targetAddr;&#13;
        AddressesBound(msg.sender, projectId, targetAddr);&#13;
    }&#13;
    function unbind(uint8 projectId)&#13;
        external&#13;
    {&#13;
        require(projectId &gt; 0);&#13;
        delete bindings[msg.sender][projectId];&#13;
        AddressesUnbound(msg.sender, projectId);&#13;
    }&#13;
    function getBindingAddress(address owner, uint8 projectId)&#13;
        external&#13;
        view&#13;
        returns (string)&#13;
    {&#13;
        require(projectId &gt; 0);&#13;
        return bindings[owner][projectId];&#13;
    }&#13;
    function setProjectName(uint8 id, string name) onlyOwner external {&#13;
        projectNameMap[id] = name;&#13;
    }&#13;
}