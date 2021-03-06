pragma solidity ^0.4.23;

/*******************************************************************************
 *
 * Copyright (c) 2018 Taboo University MDAO.
 * Released under the MIT License.
 *
 * Taboo Db - An eternal database, providing a sustainable storage solution
 *            for use throughout the upgrade lifecycle of managing contracts.
 *
 * Version 18.5.7
 *
 * Web    : https://taboou.com/
 * Email  : <a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="9feceaefeff0edebdfebfefdf0f0eab1fcf0f2">[email protected]</a>&#13;
 * Github : https://github.com/taboou/tabooads.bit/&#13;
 */&#13;
&#13;
&#13;
/*******************************************************************************&#13;
 * Owned contract&#13;
 */&#13;
contract Owned {&#13;
    address public owner;&#13;
    address public newOwner;&#13;
&#13;
    event OwnershipTransferred(address indexed _from, address indexed _to);&#13;
&#13;
    constructor() public {&#13;
        owner = msg.sender;&#13;
    }&#13;
&#13;
    modifier onlyOwner {&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
&#13;
    function transferOwnership(address _newOwner) public onlyOwner {&#13;
        newOwner = _newOwner;&#13;
    }&#13;
&#13;
    function acceptOwnership() public {&#13;
        require(msg.sender == newOwner);&#13;
&#13;
        emit OwnershipTransferred(owner, newOwner);&#13;
&#13;
        owner = newOwner;&#13;
&#13;
        newOwner = address(0);&#13;
    }&#13;
}&#13;
&#13;
&#13;
/*******************************************************************************&#13;
 * Taboo Db Contract&#13;
 */&#13;
contract TabooDb is Owned {&#13;
    /* Initialize all storage types. */&#13;
    mapping(bytes32 =&gt; address)    private addressStorage;&#13;
    mapping(bytes32 =&gt; bool)       private boolStorage;&#13;
    mapping(bytes32 =&gt; bytes)      private bytesStorage;&#13;
    mapping(bytes32 =&gt; int256)     private intStorage;&#13;
    mapping(bytes32 =&gt; string)     private stringStorage;&#13;
    mapping(bytes32 =&gt; uint256)    private uIntStorage;&#13;
&#13;
    /**&#13;
     * @dev Only allow access from the latest version of a contract&#13;
     *      in the Taboo U Networks (TUN) after deployment.&#13;
     */&#13;
    modifier onlyAuthByTUN() {&#13;
        /***********************************************************************&#13;
         * The owner is only allowed to set the authorized contracts upon&#13;
         * deployment, to register the initial contracts, afterwards their&#13;
         * direct access is permanently disabled.&#13;
         */&#13;
        if (msg.sender == owner) {&#13;
            /* Verify owner's write access has not already been disabled. */&#13;
            require(boolStorage[keccak256('owner.auth.disabled')] != true);&#13;
        } else {&#13;
            /* Verify write access is only permitted to authorized accounts. */&#13;
            require(boolStorage[keccak256(msg.sender, '.has.auth')] == true);&#13;
        }&#13;
&#13;
        _;      // function code is inserted here&#13;
    }&#13;
&#13;
    /***************************************************************************&#13;
     * Initialize all getter methods.&#13;
     */&#13;
&#13;
    /// @param _key The key for the record&#13;
    function getAddress(bytes32 _key) external view returns (address) {&#13;
        return addressStorage[_key];&#13;
    }&#13;
&#13;
    /// @param _key The key for the record&#13;
    function getBool(bytes32 _key) external view returns (bool) {&#13;
        return boolStorage[_key];&#13;
    }&#13;
&#13;
    /// @param _key The key for the record&#13;
    function getBytes(bytes32 _key) external view returns (bytes) {&#13;
        return bytesStorage[_key];&#13;
    }&#13;
&#13;
    /// @param _key The key for the record&#13;
    function getInt(bytes32 _key) external view returns (int) {&#13;
        return intStorage[_key];&#13;
    }&#13;
&#13;
    /// @param _key The key for the record&#13;
    function getString(bytes32 _key) external view returns (string) {&#13;
        return stringStorage[_key];&#13;
    }&#13;
&#13;
    /// @param _key The key for the record&#13;
    function getUint(bytes32 _key) external view returns (uint) {&#13;
        return uIntStorage[_key];&#13;
    }&#13;
&#13;
&#13;
    /***************************************************************************&#13;
     * Initialize all setter methods.&#13;
     */&#13;
&#13;
    /// @param _key The key for the record&#13;
    function setAddress(bytes32 _key, address _value) onlyAuthByTUN external {&#13;
        addressStorage[_key] = _value;&#13;
    }&#13;
&#13;
    /// @param _key The key for the record&#13;
    function setBool(bytes32 _key, bool _value) onlyAuthByTUN external {&#13;
        boolStorage[_key] = _value;&#13;
    }&#13;
&#13;
    /// @param _key The key for the record&#13;
    function setBytes(bytes32 _key, bytes _value) onlyAuthByTUN external {&#13;
        bytesStorage[_key] = _value;&#13;
    }&#13;
&#13;
    /// @param _key The key for the record&#13;
    function setInt(bytes32 _key, int _value) onlyAuthByTUN external {&#13;
        intStorage[_key] = _value;&#13;
    }&#13;
&#13;
    /// @param _key The key for the record&#13;
    function setString(bytes32 _key, string _value) onlyAuthByTUN external {&#13;
        stringStorage[_key] = _value;&#13;
    }&#13;
&#13;
    /// @param _key The key for the record&#13;
    function setUint(bytes32 _key, uint _value) onlyAuthByTUN external {&#13;
        uIntStorage[_key] = _value;&#13;
    }&#13;
&#13;
&#13;
    /***************************************************************************&#13;
     * Initialize all delete methods.&#13;
     */&#13;
&#13;
    /// @param _key The key for the record&#13;
    function deleteAddress(bytes32 _key) onlyAuthByTUN external {&#13;
        delete addressStorage[_key];&#13;
    }&#13;
&#13;
    /// @param _key The key for the record&#13;
    function deleteBool(bytes32 _key) onlyAuthByTUN external {&#13;
        delete boolStorage[_key];&#13;
    }&#13;
&#13;
    /// @param _key The key for the record&#13;
    function deleteBytes(bytes32 _key) onlyAuthByTUN external {&#13;
        delete bytesStorage[_key];&#13;
    }&#13;
&#13;
    /// @param _key The key for the record&#13;
    function deleteInt(bytes32 _key) onlyAuthByTUN external {&#13;
        delete intStorage[_key];&#13;
    }&#13;
&#13;
    /// @param _key The key for the record&#13;
    function deleteString(bytes32 _key) onlyAuthByTUN external {&#13;
        delete stringStorage[_key];&#13;
    }&#13;
&#13;
    /// @param _key The key for the record&#13;
    function deleteUint(bytes32 _key) onlyAuthByTUN external {&#13;
        delete uIntStorage[_key];&#13;
    }&#13;
}