pragma solidity 0.4.15;


/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) constant returns (uint256);
  function transfer(address to, uint256 value) returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}


/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) returns (bool) {
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of. 
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) constant returns (uint256 balance) {
    return balances[_owner];
  }

}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) returns (bool);
  function approve(address spender, uint256 value) returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amout of tokens to be transfered
   */
  function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
    var _allowance = allowed[_from][msg.sender];

    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met
    // require (_value <= _allowance);

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);
    allowed[_from][msg.sender] = _allowance.sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifing the amount of tokens still avaible for the spender.
   */
  function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

/// note: during any ownership changes all pending operations (waiting for more signatures) are cancelled
// TODO acceptOwnership
contract multiowned {

	// TYPES

    // struct for the status of a pending operation.
    struct MultiOwnedOperationPendingState {
        // count of confirmations needed
        uint yetNeeded;

        // bitmap of confirmations where owner #ownerIndex's decision corresponds to 2**ownerIndex bit
        uint ownersDone;

        // position of this operation key in m_multiOwnedPendingIndex
        uint index;
    }

	// EVENTS

    event Confirmation(address owner, bytes32 operation);
    event Revoke(address owner, bytes32 operation);
    event FinalConfirmation(address owner, bytes32 operation);

    // some others are in the case of an owner changing.
    event OwnerChanged(address oldOwner, address newOwner);
    event OwnerAdded(address newOwner);
    event OwnerRemoved(address oldOwner);

    // the last one is emitted if the required signatures change
    event RequirementChanged(uint newRequirement);

	// MODIFIERS

    // simple single-sig function modifier.
    modifier onlyowner {
        require(isOwner(msg.sender));
        _;
    }
    // multi-sig function modifier: the operation must have an intrinsic hash in order
    // that later attempts can be realised as the same underlying operation and
    // thus count as confirmations.
    modifier onlymanyowners(bytes32 _operation) {
        if (confirmAndCheck(_operation)) {
            _;
        }
        // Even if required number of confirmations has't been collected yet,
        // we can't throw here - because changes to the state have to be preserved.
        // But, confirmAndCheck itself will throw in case sender is not an owner.
    }

    modifier validNumOwners(uint _numOwners) {
        require(_numOwners > 0 && _numOwners <= c_maxOwners);
        _;
    }

    modifier multiOwnedValidRequirement(uint _required, uint _numOwners) {
        require(_required > 0 && _required <= _numOwners);
        _;
    }

    modifier ownerExists(address _address) {
        require(isOwner(_address));
        _;
    }

    modifier ownerDoesNotExist(address _address) {
        require(!isOwner(_address));
        _;
    }

    modifier multiOwnedOperationIsActive(bytes32 _operation) {
        require(isOperationActive(_operation));
        _;
    }

	// METHODS

    // constructor is given number of sigs required to do protected "onlymanyowners" transactions
    // as well as the selection of addresses capable of confirming them (msg.sender is not added to the owners!).
    function multiowned(address[] _owners, uint _required)
        validNumOwners(_owners.length)
        multiOwnedValidRequirement(_required, _owners.length)
    {
        assert(c_maxOwners <= 255);

        m_numOwners = _owners.length;
        m_multiOwnedRequired = _required;

        for (uint i = 0; i < _owners.length; ++i)
        {
            address owner = _owners[i];
            // invalid and duplicate addresses are not allowed
            require(0 != owner && !isOwner(owner) /* not isOwner yet! */);

            uint currentOwnerIndex = checkOwnerIndex(i + 1 /* first slot is unused */);
            m_owners[currentOwnerIndex] = owner;
            m_ownerIndex[owner] = currentOwnerIndex;
        }

        assertOwnersAreConsistent();
    }

    /// @notice replaces an owner `_from` with another `_to`.
    /// @param _from address of owner to replace
    /// @param _to address of new owner
    // All pending operations will be canceled!
    function changeOwner(address _from, address _to)
        external
        ownerExists(_from)
        ownerDoesNotExist(_to)
        onlymanyowners(sha3(msg.data))
    {
        assertOwnersAreConsistent();

        clearPending();
        uint ownerIndex = checkOwnerIndex(m_ownerIndex[_from]);
        m_owners[ownerIndex] = _to;
        m_ownerIndex[_from] = 0;
        m_ownerIndex[_to] = ownerIndex;

        assertOwnersAreConsistent();
        OwnerChanged(_from, _to);
    }

    /// @notice adds an owner
    /// @param _owner address of new owner
    // All pending operations will be canceled!
    function addOwner(address _owner)
        external
        ownerDoesNotExist(_owner)
        validNumOwners(m_numOwners + 1)
        onlymanyowners(sha3(msg.data))
    {
        assertOwnersAreConsistent();

        clearPending();
        m_numOwners++;
        m_owners[m_numOwners] = _owner;
        m_ownerIndex[_owner] = checkOwnerIndex(m_numOwners);

        assertOwnersAreConsistent();
        OwnerAdded(_owner);
    }

    /// @notice removes an owner
    /// @param _owner address of owner to remove
    // All pending operations will be canceled!
    function removeOwner(address _owner)
        external
        ownerExists(_owner)
        validNumOwners(m_numOwners - 1)
        multiOwnedValidRequirement(m_multiOwnedRequired, m_numOwners - 1)
        onlymanyowners(sha3(msg.data))
    {
        assertOwnersAreConsistent();

        clearPending();
        uint ownerIndex = checkOwnerIndex(m_ownerIndex[_owner]);
        m_owners[ownerIndex] = 0;
        m_ownerIndex[_owner] = 0;
        //make sure m_numOwners is equal to the number of owners and always points to the last owner
        reorganizeOwners();

        assertOwnersAreConsistent();
        OwnerRemoved(_owner);
    }

    /// @notice changes the required number of owner signatures
    /// @param _newRequired new number of signatures required
    // All pending operations will be canceled!
    function changeRequirement(uint _newRequired)
        external
        multiOwnedValidRequirement(_newRequired, m_numOwners)
        onlymanyowners(sha3(msg.data))
    {
        m_multiOwnedRequired = _newRequired;
        clearPending();
        RequirementChanged(_newRequired);
    }

    /// @notice Gets an owner by 0-indexed position
    /// @param ownerIndex 0-indexed owner position
    function getOwner(uint ownerIndex) public constant returns (address) {
        return m_owners[ownerIndex + 1];
    }

    /// @notice Gets owners
    /// @return memory array of owners
    function getOwners() public constant returns (address[]) {
        address[] memory result = new address[](m_numOwners);
        for (uint i = 0; i < m_numOwners; i++)
            result[i] = getOwner(i);

        return result;
    }

    /// @notice checks if provided address is an owner address
    /// @param _addr address to check
    /// @return true if it's an owner
    function isOwner(address _addr) public constant returns (bool) {
        return m_ownerIndex[_addr] > 0;
    }

    /// @notice Tests ownership of the current caller.
    /// @return true if it's an owner
    // It's advisable to call it by new owner to make sure that the same erroneous address is not copy-pasted to
    // addOwner/changeOwner and to isOwner.
    function amIOwner() external constant onlyowner returns (bool) {
        return true;
    }

    /// @notice Revokes a prior confirmation of the given operation
    /// @param _operation operation value, typically sha3(msg.data)
    function revoke(bytes32 _operation)
        external
        multiOwnedOperationIsActive(_operation)
        onlyowner
    {
        uint ownerIndexBit = makeOwnerBitmapBit(msg.sender);
        var pending = m_multiOwnedPending[_operation];
        require(pending.ownersDone & ownerIndexBit > 0);

        assertOperationIsConsistent(_operation);

        pending.yetNeeded++;
        pending.ownersDone -= ownerIndexBit;

        assertOperationIsConsistent(_operation);
        Revoke(msg.sender, _operation);
    }

    /// @notice Checks if owner confirmed given operation
    /// @param _operation operation value, typically sha3(msg.data)
    /// @param _owner an owner address
    function hasConfirmed(bytes32 _operation, address _owner)
        external
        constant
        multiOwnedOperationIsActive(_operation)
        ownerExists(_owner)
        returns (bool)
    {
        return !(m_multiOwnedPending[_operation].ownersDone & makeOwnerBitmapBit(_owner) == 0);
    }

    // INTERNAL METHODS

    function confirmAndCheck(bytes32 _operation)
        private
        onlyowner
        returns (bool)
    {
        if (512 == m_multiOwnedPendingIndex.length)
            // In case m_multiOwnedPendingIndex grows too much we have to shrink it: otherwise at some point
            // we won't be able to do it because of block gas limit.
            // Yes, pending confirmations will be lost. Dont see any security or stability implications.
            // TODO use more graceful approach like compact or removal of clearPending completely
            clearPending();

        var pending = m_multiOwnedPending[_operation];

        // if we're not yet working on this operation, switch over and reset the confirmation status.
        if (! isOperationActive(_operation)) {
            // reset count of confirmations needed.
            pending.yetNeeded = m_multiOwnedRequired;
            // reset which owners have confirmed (none) - set our bitmap to 0.
            pending.ownersDone = 0;
            pending.index = m_multiOwnedPendingIndex.length++;
            m_multiOwnedPendingIndex[pending.index] = _operation;
            assertOperationIsConsistent(_operation);
        }

        // determine the bit to set for this owner.
        uint ownerIndexBit = makeOwnerBitmapBit(msg.sender);
        // make sure we (the message sender) haven't confirmed this operation previously.
        if (pending.ownersDone & ownerIndexBit == 0) {
            // ok - check if count is enough to go ahead.
            assert(pending.yetNeeded > 0);
            if (pending.yetNeeded == 1) {
                // enough confirmations: reset and run interior.
                delete m_multiOwnedPendingIndex[m_multiOwnedPending[_operation].index];
                delete m_multiOwnedPending[_operation];
                FinalConfirmation(msg.sender, _operation);
                return true;
            }
            else
            {
                // not enough: record that this owner in particular confirmed.
                pending.yetNeeded--;
                pending.ownersDone |= ownerIndexBit;
                assertOperationIsConsistent(_operation);
                Confirmation(msg.sender, _operation);
            }
        }
    }

    // Reclaims free slots between valid owners in m_owners.
    // TODO given that its called after each removal, it could be simplified.
    function reorganizeOwners() private {
        uint free = 1;
        while (free < m_numOwners)
        {
            // iterating to the first free slot from the beginning
            while (free < m_numOwners && m_owners[free] != 0) free++;

            // iterating to the first occupied slot from the end
            while (m_numOwners > 1 && m_owners[m_numOwners] == 0) m_numOwners--;

            // swap, if possible, so free slot is located at the end after the swap
            if (free < m_numOwners && m_owners[m_numOwners] != 0 && m_owners[free] == 0)
            {
                // owners between swapped slots should't be renumbered - that saves a lot of gas
                m_owners[free] = m_owners[m_numOwners];
                m_ownerIndex[m_owners[free]] = free;
                m_owners[m_numOwners] = 0;
            }
        }
    }

    function clearPending() private onlyowner {
        uint length = m_multiOwnedPendingIndex.length;
        for (uint i = 0; i < length; ++i) {
            if (m_multiOwnedPendingIndex[i] != 0)
                delete m_multiOwnedPending[m_multiOwnedPendingIndex[i]];
        }
        delete m_multiOwnedPendingIndex;
    }

    function checkOwnerIndex(uint ownerIndex) private constant returns (uint) {
        assert(0 != ownerIndex && ownerIndex <= c_maxOwners);
        return ownerIndex;
    }

    function makeOwnerBitmapBit(address owner) private constant returns (uint) {
        uint ownerIndex = checkOwnerIndex(m_ownerIndex[owner]);
        return 2 ** ownerIndex;
    }

    function isOperationActive(bytes32 _operation) private constant returns (bool) {
        return 0 != m_multiOwnedPending[_operation].yetNeeded;
    }


    function assertOwnersAreConsistent() private constant {
        assert(m_numOwners > 0);
        assert(m_numOwners <= c_maxOwners);
        assert(m_owners[0] == 0);
        assert(0 != m_multiOwnedRequired && m_multiOwnedRequired <= m_numOwners);
    }

    function assertOperationIsConsistent(bytes32 _operation) private constant {
        var pending = m_multiOwnedPending[_operation];
        assert(0 != pending.yetNeeded);
        assert(m_multiOwnedPendingIndex[pending.index] == _operation);
        assert(pending.yetNeeded <= m_multiOwnedRequired);
    }


   	// FIELDS

    uint constant c_maxOwners = 250;

    // the number of owners that must confirm the same operation before it is run.
    uint public m_multiOwnedRequired;


    // pointer used to find a free slot in m_owners
    uint public m_numOwners;

    // list of owners (addresses),
    // slot 0 is unused so there are no owner which index is 0.
    // TODO could we save space at the end of the array for the common case of <10 owners? and should we?
    address[256] internal m_owners;

    // index on the list of owners to allow reverse lookup: owner address => index in m_owners
    mapping(address => uint) internal m_ownerIndex;


    // the ongoing operations.
    mapping(bytes32 => MultiOwnedOperationPendingState) internal m_multiOwnedPending;
    bytes32[] internal m_multiOwnedPendingIndex;
}


/**
 * @title Contract which is owned by owners and operated by controller.
 *
 * @notice Provides a way to set up an entity (typically other contract) entitled to control actions of this contract.
 * Controller is set up by owners or during construction.
 *
 * @dev controller check is performed by onlyController modifier.
 */
contract MultiownedControlled is multiowned {

    event ControllerSet(address controller);
    event ControllerRetired(address was);


    modifier onlyController {
        require(msg.sender == m_controller);
        _;
    }


    // PUBLIC interface

    function MultiownedControlled(address[] _owners, uint _signaturesRequired, address _controller)
        multiowned(_owners, _signaturesRequired)
    {
        m_controller = _controller;
        ControllerSet(m_controller);
    }

    /// @dev sets the controller
    function setController(address _controller) external onlymanyowners(sha3(msg.data)) {
        m_controller = _controller;
        ControllerSet(m_controller);
    }

    /// @dev ability for controller to step down
    function detachController() external onlyController {
        address was = m_controller;
        m_controller = address(0);
        ControllerRetired(was);
    }


    // FIELDS

    /// @notice address of entity entitled to mint new tokens
    address public m_controller;
}


/// @title StandardToken which can be minted by another contract.
contract MintableMultiownedToken is MultiownedControlled, StandardToken {

    /// @dev parameters of an extra token emission
    struct EmissionInfo {
        // tokens created
        uint256 created;

        // totalSupply at the moment of emission (excluding created tokens)
        uint256 totalSupplyWas;
    }

    event Mint(address indexed to, uint256 amount);
    event Emission(uint256 tokensCreated, uint256 totalSupplyWas, uint256 time);
    event Dividend(address indexed to, uint256 amount);


    // PUBLIC interface

    function MintableMultiownedToken(address[] _owners, uint _signaturesRequired, address _minter)
        MultiownedControlled(_owners, _signaturesRequired, _minter)
    {
        dividendsPool = this;   // or any other special unforgeable value, actually

        // emission #0 is a dummy: because of default value 0 in m_lastAccountEmission
        m_emissions.push(EmissionInfo({created: 0, totalSupplyWas: 0}));
    }

    /// @notice Request dividends for current account.
    function requestDividends() external {
        payDividendsTo(msg.sender);
    }

    /// @notice hook on standard ERC20#transfer to pay dividends
    function transfer(address _to, uint256 _value) returns (bool) {
        payDividendsTo(msg.sender);
        payDividendsTo(_to);
        return super.transfer(_to, _value);
    }

    /// @notice hook on standard ERC20#transferFrom to pay dividends
    function transferFrom(address _from, address _to, uint256 _value) returns (bool) {
        payDividendsTo(_from);
        payDividendsTo(_to);
        return super.transferFrom(_from, _to, _value);
    }

    // Disabled: this could be undesirable because sum of (balanceOf() for each token owner) != totalSupply
    // (but: sum of (balances[owner] for each token owner) == totalSupply!).
    //
    // @notice hook on standard ERC20#balanceOf to take dividends into consideration
    // function balanceOf(address _owner) constant returns (uint256) {
    //     var (hasNewDividends, dividends) = calculateDividendsFor(_owner);
    //     return hasNewDividends ? super.balanceOf(_owner).add(dividends) : super.balanceOf(_owner);
    // }


    /// @dev mints new tokens
    function mint(address _to, uint256 _amount) external onlyController {
        require(m_externalMintingEnabled);
        payDividendsTo(_to);
        mintInternal(_to, _amount);
    }

    /// @dev disables mint(), irreversible!
    function disableMinting() external onlyController {
        require(m_externalMintingEnabled);
        m_externalMintingEnabled = false;
    }


    // INTERNAL functions

    /**
     * @notice Starts new token emission
     * @param _tokensCreated Amount of tokens to create
     * @dev Dividends are not distributed immediately as it could require billions of gas,
     * instead they are `pulled` by a holder from dividends pool account before any update to the holder account occurs.
     */
    function emissionInternal(uint256 _tokensCreated) internal {
        require(0 != _tokensCreated);
        require(_tokensCreated < totalSupply / 2);  // otherwise it looks like an error

        uint256 totalSupplyWas = totalSupply;

        m_emissions.push(EmissionInfo({created: _tokensCreated, totalSupplyWas: totalSupplyWas}));
        mintInternal(dividendsPool, _tokensCreated);

        Emission(_tokensCreated, totalSupplyWas, now);
    }

    function mintInternal(address _to, uint256 _amount) internal {
        totalSupply = totalSupply.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        Transfer(this, _to, _amount);
        Mint(_to, _amount);
    }

    /// @dev adds dividends to the account _to
    function payDividendsTo(address _to) internal {
        var (hasNewDividends, dividends) = calculateDividendsFor(_to);
        if (!hasNewDividends)
            return;

        if (0 != dividends) {
            balances[dividendsPool] = balances[dividendsPool].sub(dividends);
            balances[_to] = balances[_to].add(dividends);
            Transfer(dividendsPool, _to, dividends);
        }
        m_lastAccountEmission[_to] = getLastEmissionNum();
    }

    /// @dev calculates dividends for the account _for
    /// @return (true if state has to be updated, dividend amount (could be 0!))
    function calculateDividendsFor(address _for) constant internal returns (bool hasNewDividends, uint dividends) {
        assert(_for != dividendsPool);  // no dividends for the pool!

        uint256 lastEmissionNum = getLastEmissionNum();
        uint256 lastAccountEmissionNum = m_lastAccountEmission[_for];
        assert(lastAccountEmissionNum <= lastEmissionNum);
        if (lastAccountEmissionNum == lastEmissionNum)
            return (false, 0);

        uint256 initialBalance = balances[_for];    // beware of recursion!
        if (0 == initialBalance)
            return (true, 0);

        uint256 balance = initialBalance;
        for (uint256 emissionToProcess = lastAccountEmissionNum + 1; emissionToProcess <= lastEmissionNum; emissionToProcess++) {
            EmissionInfo storage emission = m_emissions[emissionToProcess];
            assert(0 != emission.created && 0 != emission.totalSupplyWas);

            uint256 dividend = balance.mul(emission.created).div(emission.totalSupplyWas);
            Dividend(_for, dividend);

            balance = balance.add(dividend);
        }

        return (true, balance.sub(initialBalance));
    }

    function getLastEmissionNum() private constant returns (uint256) {
        return m_emissions.length - 1;
    }


    // FIELDS

    /// @notice if this true then token is still externally mintable (but this flag does't affect emissions!)
    bool public m_externalMintingEnabled = true;

    /// @dev internal address of dividends in balances mapping.
    address dividendsPool;

    /// @notice record of issued dividend emissions
    EmissionInfo[] public m_emissions;

    /// @dev for each token holder: last emission (index in m_emissions) which was processed for this holder
    mapping(address => uint256) m_lastAccountEmission;
}

/// @title utility methods and modifiers of arguments validation
contract ArgumentsChecker {

    /// @dev check which prevents short address attack
    modifier payloadSizeIs(uint size) {
       require(msg.data.length == size + 4 /* function selector */);
       _;
    }

    /// @dev check that address is valid
    modifier validAddress(address addr) {
        require(addr != address(0));
        _;
    }
}


/**
 * @title Interface for code which processes and stores investments.
 * @author Eenae
 */
contract IInvestmentsWalletConnector {
    /// @dev process and forward investment
    function storeInvestment(address investor, uint payment) internal;

    /// @dev total investments amount stored using storeInvestment()
    function getTotalInvestmentsStored() internal constant returns (uint);

    /// @dev called in case crowdsale succeeded
    function wcOnCrowdsaleSuccess() internal;

    /// @dev called in case crowdsale failed
    function wcOnCrowdsaleFailure() internal;
}

/**
 * @title Stores investments in specified external account.
 * @author Eenae
 */
contract ExternalAccountWalletConnector is ArgumentsChecker, IInvestmentsWalletConnector {

    function ExternalAccountWalletConnector(address accountAddress)
        validAddress(accountAddress)
    {
        m_walletAddress = accountAddress;
    }

    /// @dev process and forward investment
    function storeInvestment(address /*investor*/, uint payment) internal
    {
        m_wcStored += payment;
        m_walletAddress.transfer(payment);
    }

    /// @dev total investments amount stored using storeInvestment()
    function getTotalInvestmentsStored() internal constant returns (uint)
    {
        return m_wcStored;
    }

    /// @dev called in case crowdsale succeeded
    function wcOnCrowdsaleSuccess() internal {
    }

    /// @dev called in case crowdsale failed
    function wcOnCrowdsaleFailure() internal {
    }

    /// @notice address of wallet which stores funds
    address public m_walletAddress;

    /// @notice total investments stored to wallet
    uint public m_wcStored;
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/*
 * @title This is proxy for analytics. Target contract can be found at field m_analytics (see "read contract").
 * @author Eenae

 * FIXME after fix of truffle issue #560: refactor to a separate contract file which uses InvestmentAnalytics interface
 */
contract AnalyticProxy {

    function AnalyticProxy() {
        m_analytics = InvestmentAnalytics(msg.sender);
    }

    /// @notice forward payment to analytics-capable contract
    function() payable {
        m_analytics.iaInvestedBy.value(msg.value)(msg.sender);
    }

    InvestmentAnalytics public m_analytics;
}


/*
 * @title Mixin contract which supports different payment channels and provides analytical per-channel data.
 * @author Eenae
 */
contract InvestmentAnalytics {
    using SafeMath for uint256;

    function InvestmentAnalytics(){
    }

    /// @dev creates more payment channels, up to the limit but not exceeding gas stipend
    function createMorePaymentChannelsInternal(uint limit) internal returns (uint) {
        uint paymentChannelsCreated;
        for (uint i = 0; i < limit; i++) {
            uint startingGas = msg.gas;
            /*
             * ~170k of gas per paymentChannel,
             * using gas price = 4Gwei 2k paymentChannels will cost ~1.4 ETH.
             */

            address paymentChannel = new AnalyticProxy();
            m_validPaymentChannels[paymentChannel] = true;
            m_paymentChannels.push(paymentChannel);
            paymentChannelsCreated++;

            // cost of creating one channel
            uint gasPerChannel = startingGas.sub(msg.gas);
            if (gasPerChannel.add(50000) > msg.gas)
                break;  // enough proxies for this call
        }
        return paymentChannelsCreated;
    }


    /// @dev process payments - record analytics and pass control to iaOnInvested callback
    function iaInvestedBy(address investor) external payable {
        address paymentChannel = msg.sender;
        if (m_validPaymentChannels[paymentChannel]) {
            // payment received by one of our channels
            uint value = msg.value;
            m_investmentsByPaymentChannel[paymentChannel] = m_investmentsByPaymentChannel[paymentChannel].add(value);
            // We know for sure that investment came from specified investor (see AnalyticProxy).
            iaOnInvested(investor, value, true);
        } else {
            // Looks like some user has paid to this method, this payment is not included in the analytics,
            // but, of course, processed.
            iaOnInvested(msg.sender, msg.value, false);
        }
    }

    /// @dev callback
    function iaOnInvested(address /*investor*/, uint /*payment*/, bool /*usingPaymentChannel*/) internal {
    }


    function paymentChannelsCount() external constant returns (uint) {
        return m_paymentChannels.length;
    }

    function readAnalyticsMap() external constant returns (address[], uint[]) {
        address[] memory keys = new address[](m_paymentChannels.length);
        uint[] memory values = new uint[](m_paymentChannels.length);

        for (uint i = 0; i < m_paymentChannels.length; i++) {
            address key = m_paymentChannels[i];
            keys[i] = key;
            values[i] = m_investmentsByPaymentChannel[key];
        }

        return (keys, values);
    }

    function readPaymentChannels() external constant returns (address[]) {
        return m_paymentChannels;
    }


    mapping(address => uint256) public m_investmentsByPaymentChannel;
    mapping(address => bool) m_validPaymentChannels;

    address[] public m_paymentChannels;
}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
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
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}


/**
 * @title Basic crowdsale stat
 * @author Eenae
 */
contract ICrowdsaleStat {

    /// @notice amount of funds collected in wei
    function getWeiCollected() public constant returns (uint);

    /// @notice amount of tokens minted (NOT equal to totalSupply() in case token is reused!)
    function getTokenMinted() public constant returns (uint);
}






/**
 * @title Helps contracts guard agains rentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="097b6c646a66493b">[email protected]</a>π.com&gt;&#13;
 * @notice If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
&#13;
  /**&#13;
   * @dev We use a single lock for the whole contract.&#13;
   */&#13;
  bool private rentrancy_lock = false;&#13;
&#13;
  /**&#13;
   * @dev Prevents a contract from calling itself, directly or indirectly.&#13;
   * @notice If you mark a function `nonReentrant`, you should also&#13;
   * mark it `external`. Calling one nonReentrant function from&#13;
   * another is not supported. Instead, you can implement a&#13;
   * `private` function doing the actual work, and a `external`&#13;
   * wrapper marked as `nonReentrant`.&#13;
   */&#13;
  modifier nonReentrant() {&#13;
    require(!rentrancy_lock);&#13;
    rentrancy_lock = true;&#13;
    _;&#13;
    rentrancy_lock = false;&#13;
  }&#13;
&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
&#13;
/// @title Base contract for simple crowdsales&#13;
contract SimpleCrowdsaleBase is ArgumentsChecker, ReentrancyGuard, IInvestmentsWalletConnector, ICrowdsaleStat {&#13;
    using SafeMath for uint256;&#13;
&#13;
    event FundTransfer(address backer, uint amount, bool isContribution);&#13;
&#13;
    function SimpleCrowdsaleBase(address token)&#13;
        validAddress(token)&#13;
    {&#13;
        m_token = MintableMultiownedToken(token);&#13;
    }&#13;
&#13;
&#13;
    // PUBLIC interface: payments&#13;
&#13;
    // fallback function as a shortcut&#13;
    function() payable {&#13;
        require(0 == msg.data.length);&#13;
        buy();  // only internal call here!&#13;
    }&#13;
&#13;
    /// @notice crowdsale participation&#13;
    function buy() public payable {     // dont mark as external!&#13;
        buyInternal(msg.sender, msg.value, 0);&#13;
    }&#13;
&#13;
&#13;
    // INTERNAL&#13;
&#13;
    /// @dev payment processing&#13;
    function buyInternal(address investor, uint payment, uint extraBonuses)&#13;
        internal&#13;
        nonReentrant&#13;
    {&#13;
        require(payment &gt;= getMinInvestment());&#13;
        require(getCurrentTime() &gt;= getStartTime() || ! mustApplyTimeCheck(investor, payment) /* for final check */);&#13;
        if (getCurrentTime() &gt;= getEndTime())&#13;
            finish();&#13;
&#13;
        if (m_finished) {&#13;
            // saving provided gas&#13;
            investor.transfer(payment);&#13;
            return;&#13;
        }&#13;
&#13;
        uint startingWeiCollected = getWeiCollected();&#13;
        uint startingInvariant = this.balance.add(startingWeiCollected);&#13;
&#13;
        // return or update payment if needed&#13;
        uint paymentAllowed = getMaximumFunds().sub(getWeiCollected());&#13;
        assert(0 != paymentAllowed);&#13;
&#13;
        uint change;&#13;
        if (paymentAllowed &lt; payment) {&#13;
            change = payment.sub(paymentAllowed);&#13;
            payment = paymentAllowed;&#13;
        }&#13;
&#13;
        // issue tokens&#13;
        uint tokens = calculateTokens(investor, payment, extraBonuses);&#13;
        m_token.mint(investor, tokens);&#13;
        m_tokensMinted += tokens;&#13;
&#13;
        // record payment&#13;
        storeInvestment(investor, payment);&#13;
        assert(getWeiCollected() &lt;= getMaximumFunds() &amp;&amp; getWeiCollected() &gt; startingWeiCollected);&#13;
        FundTransfer(investor, payment, true);&#13;
&#13;
        if (getWeiCollected() == getMaximumFunds())&#13;
            finish();&#13;
&#13;
        if (change &gt; 0)&#13;
            investor.transfer(change);&#13;
&#13;
        assert(startingInvariant == this.balance.add(getWeiCollected()).add(change));&#13;
    }&#13;
&#13;
    function finish() internal {&#13;
        if (m_finished)&#13;
            return;&#13;
&#13;
        if (getWeiCollected() &gt;= getMinimumFunds())&#13;
            wcOnCrowdsaleSuccess();&#13;
        else&#13;
            wcOnCrowdsaleFailure();&#13;
&#13;
        m_finished = true;&#13;
    }&#13;
&#13;
&#13;
    // Other pluggables&#13;
&#13;
    /// @dev says if crowdsale time bounds must be checked&#13;
    function mustApplyTimeCheck(address /*investor*/, uint /*payment*/) constant internal returns (bool) {&#13;
        return true;&#13;
    }&#13;
&#13;
    /// @dev to be overridden in tests&#13;
    function getCurrentTime() internal constant returns (uint) {&#13;
        return now;&#13;
    }&#13;
&#13;
    /// @notice maximum investments to be accepted during pre-ICO&#13;
    function getMaximumFunds() internal constant returns (uint);&#13;
&#13;
    /// @notice minimum amount of funding to consider crowdsale as successful&#13;
    function getMinimumFunds() internal constant returns (uint);&#13;
&#13;
    /// @notice start time of the pre-ICO&#13;
    function getStartTime() internal constant returns (uint);&#13;
&#13;
    /// @notice end time of the pre-ICO&#13;
    function getEndTime() internal constant returns (uint);&#13;
&#13;
    /// @notice minimal amount of investment&#13;
    function getMinInvestment() public constant returns (uint) {&#13;
        return 10 finney;&#13;
    }&#13;
&#13;
    /// @dev calculates token amount for given investment&#13;
    function calculateTokens(address investor, uint payment, uint extraBonuses) internal constant returns (uint);&#13;
&#13;
&#13;
    // ICrowdsaleStat&#13;
&#13;
    function getWeiCollected() public constant returns (uint) {&#13;
        return getTotalInvestmentsStored();&#13;
    }&#13;
&#13;
    /// @notice amount of tokens minted (NOT equal to totalSupply() in case token is reused!)&#13;
    function getTokenMinted() public constant returns (uint) {&#13;
        return m_tokensMinted;&#13;
    }&#13;
&#13;
&#13;
    // FIELDS&#13;
&#13;
    /// @dev contract responsible for token accounting&#13;
    MintableMultiownedToken public m_token;&#13;
&#13;
    uint m_tokensMinted;&#13;
&#13;
    bool m_finished = false;&#13;
}&#13;
&#13;
&#13;
&#13;
/// @title Base contract for Storiqa pre-ICO&#13;
contract STQPreICOBase is SimpleCrowdsaleBase, Ownable, InvestmentAnalytics {&#13;
&#13;
    function STQPreICOBase(address token)&#13;
        SimpleCrowdsaleBase(token)&#13;
    {&#13;
    }&#13;
&#13;
&#13;
    // PUBLIC interface: maintenance&#13;
&#13;
    function createMorePaymentChannels(uint limit) external onlyOwner returns (uint) {&#13;
        return createMorePaymentChannelsInternal(limit);&#13;
    }&#13;
&#13;
    /// @notice Tests ownership of the current caller.&#13;
    /// @return true if it's an owner&#13;
    // It's advisable to call it by new owner to make sure that the same erroneous address is not copy-pasted to&#13;
    // addOwner/changeOwner and to isOwner.&#13;
    function amIOwner() external constant onlyOwner returns (bool) {&#13;
        return true;&#13;
    }&#13;
&#13;
&#13;
    // INTERNAL&#13;
&#13;
    /// @dev payment callback&#13;
    function iaOnInvested(address investor, uint payment, bool usingPaymentChannel) internal {&#13;
        buyInternal(investor, payment, usingPaymentChannel ? c_paymentChannelBonusPercent : 0);&#13;
    }&#13;
&#13;
    function calculateTokens(address /*investor*/, uint payment, uint extraBonuses) internal constant returns (uint) {&#13;
        uint bonusPercent = getPreICOBonus().add(getLargePaymentBonus(payment)).add(extraBonuses);&#13;
        uint rate = c_STQperETH.mul(bonusPercent.add(100)).div(100);&#13;
&#13;
        return payment.mul(rate);&#13;
    }&#13;
&#13;
    function getLargePaymentBonus(uint payment) private constant returns (uint) {&#13;
        if (payment &gt;= 5000 ether) return 20;&#13;
        if (payment &gt;= 3000 ether) return 15;&#13;
        if (payment &gt;= 1000 ether) return 10;&#13;
        if (payment &gt;= 800 ether) return 8;&#13;
        if (payment &gt;= 500 ether) return 5;&#13;
        if (payment &gt;= 200 ether) return 2;&#13;
        return 0;&#13;
    }&#13;
&#13;
    function mustApplyTimeCheck(address investor, uint /*payment*/) constant internal returns (bool) {&#13;
        return investor != owner;&#13;
    }&#13;
&#13;
    /// @notice pre-ICO bonus&#13;
    function getPreICOBonus() internal constant returns (uint);&#13;
&#13;
&#13;
    // FIELDS&#13;
&#13;
    /// @notice starting exchange rate of STQ&#13;
    uint public constant c_STQperETH = 100000;&#13;
&#13;
    /// @notice authorised payment bonus&#13;
    uint public constant c_paymentChannelBonusPercent = 2;&#13;
}&#13;
&#13;
&#13;
&#13;
&#13;
/// @title Storiqa pre-ICO contract&#13;
contract STQPreICO3 is STQPreICOBase, ExternalAccountWalletConnector {&#13;
&#13;
    function STQPreICO3(address token, address wallet)&#13;
        STQPreICOBase(token)&#13;
        ExternalAccountWalletConnector(wallet)&#13;
    {&#13;
&#13;
    }&#13;
&#13;
&#13;
    // INTERNAL&#13;
&#13;
    function getWeiCollected() public constant returns (uint) {&#13;
        return getTotalInvestmentsStored();&#13;
    }&#13;
&#13;
    /// @notice minimum amount of funding to consider crowdsale as successful&#13;
    function getMinimumFunds() internal constant returns (uint) {&#13;
        return 0;&#13;
    }&#13;
&#13;
    /// @notice maximum investments to be accepted during pre-ICO&#13;
    function getMaximumFunds() internal constant returns (uint) {&#13;
        return 100000000 ether;&#13;
    }&#13;
&#13;
    /// @notice start time of the pre-ICO&#13;
    function getStartTime() internal constant returns (uint) {&#13;
        return 1508958000; // 2017-10-25 19:00:00&#13;
    }&#13;
&#13;
    /// @notice end time of the pre-ICO&#13;
    function getEndTime() internal constant returns (uint) {&#13;
        return 1511568000; //2017-11-25 00:00:00&#13;
    }&#13;
&#13;
    /// @notice pre-ICO bonus&#13;
    function getPreICOBonus() internal constant returns (uint) {&#13;
        return 33;&#13;
    }&#13;
}