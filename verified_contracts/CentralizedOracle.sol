pragma solidity ^0.4.24;

// File: @gnosis.pm/util-contracts/contracts/Proxy.sol

/// @title Proxied - indicates that a contract will be proxied. Also defines storage requirements for Proxy.
/// @author Alan Lu - <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="cbaaa7aaa58baca5a4b8a2b8e5bba6">[email protected]</a>&gt;&#13;
contract Proxied {&#13;
    address public masterCopy;&#13;
}&#13;
&#13;
/// @title Proxy - Generic proxy contract allows to execute all transactions applying the code of a master contract.&#13;
/// @author Stefan George - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="4536312023242b05222b2a362c366b3528">[email protected]</a>&gt;&#13;
contract Proxy is Proxied {&#13;
    /// @dev Constructor function sets address of master copy contract.&#13;
    /// @param _masterCopy Master copy address.&#13;
    constructor(address _masterCopy)&#13;
        public&#13;
    {&#13;
        require(_masterCopy != 0);&#13;
        masterCopy = _masterCopy;&#13;
    }&#13;
&#13;
    /// @dev Fallback function forwards all transactions and returns all received return data.&#13;
    function ()&#13;
        external&#13;
        payable&#13;
    {&#13;
        address _masterCopy = masterCopy;&#13;
        assembly {&#13;
            calldatacopy(0, 0, calldatasize())&#13;
            let success := delegatecall(not(0), _masterCopy, 0, calldatasize(), 0, 0)&#13;
            returndatacopy(0, 0, returndatasize())&#13;
            switch success&#13;
            case 0 { revert(0, returndatasize()) }&#13;
            default { return(0, returndatasize()) }&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
// File: contracts/Oracles/Oracle.sol&#13;
&#13;
/// @title Abstract oracle contract - Functions to be implemented by oracles&#13;
contract Oracle {&#13;
&#13;
    function isOutcomeSet() public view returns (bool);&#13;
    function getOutcome() public view returns (int);&#13;
}&#13;
&#13;
// File: contracts/Oracles/CentralizedOracle.sol&#13;
&#13;
contract CentralizedOracleData {&#13;
&#13;
    /*&#13;
     *  Events&#13;
     */&#13;
    event OwnerReplacement(address indexed newOwner);&#13;
    event OutcomeAssignment(int outcome);&#13;
&#13;
    /*&#13;
     *  Storage&#13;
     */&#13;
    address public owner;&#13;
    bytes public ipfsHash;&#13;
    bool public isSet;&#13;
    int public outcome;&#13;
&#13;
    /*&#13;
     *  Modifiers&#13;
     */&#13;
    modifier isOwner () {&#13;
        // Only owner is allowed to proceed&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
}&#13;
&#13;
contract CentralizedOracleProxy is Proxy, CentralizedOracleData {&#13;
&#13;
    /// @dev Constructor sets owner address and IPFS hash&#13;
    /// @param _ipfsHash Hash identifying off chain event description&#13;
    constructor(address proxied, address _owner, bytes _ipfsHash)&#13;
        public&#13;
        Proxy(proxied)&#13;
    {&#13;
        // Description hash cannot be null&#13;
        require(_ipfsHash.length == 46);&#13;
        owner = _owner;&#13;
        ipfsHash = _ipfsHash;&#13;
    }&#13;
}&#13;
&#13;
/// @title Centralized oracle contract - Allows the contract owner to set an outcome&#13;
/// @author Stefan George - &lt;<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="3a494e5f5c5b547a5d5455495349144a57">[email protected]</a>&gt;&#13;
contract CentralizedOracle is Proxied, Oracle, CentralizedOracleData {&#13;
&#13;
    /*&#13;
     *  Public functions&#13;
     */&#13;
    /// @dev Replaces owner&#13;
    /// @param newOwner New owner&#13;
    function replaceOwner(address newOwner)&#13;
        public&#13;
        isOwner&#13;
    {&#13;
        // Result is not set yet&#13;
        require(!isSet);&#13;
        owner = newOwner;&#13;
        emit OwnerReplacement(newOwner);&#13;
    }&#13;
&#13;
    /// @dev Sets event outcome&#13;
    /// @param _outcome Event outcome&#13;
    function setOutcome(int _outcome)&#13;
        public&#13;
        isOwner&#13;
    {&#13;
        // Result is not set yet&#13;
        require(!isSet);&#13;
        isSet = true;&#13;
        outcome = _outcome;&#13;
        emit OutcomeAssignment(_outcome);&#13;
    }&#13;
&#13;
    /// @dev Returns if winning outcome is set&#13;
    /// @return Is outcome set?&#13;
    function isOutcomeSet()&#13;
        public&#13;
        view&#13;
        returns (bool)&#13;
    {&#13;
        return isSet;&#13;
    }&#13;
&#13;
    /// @dev Returns outcome&#13;
    /// @return Outcome&#13;
    function getOutcome()&#13;
        public&#13;
        view&#13;
        returns (int)&#13;
    {&#13;
        return outcome;&#13;
    }&#13;
}