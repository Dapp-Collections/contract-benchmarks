//sol Wallet
// Multi-sig, daily-limited account proxy/wallet.
// @authors:
// Gav Wood <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="6d0a2d08190509081b430e0200">[email protected]</a>&gt;&#13;
// inheritable "property" contract that enables methods to be protected by requiring the acquiescence of either a&#13;
// single, or, crucially, each of a number of, designated owners.&#13;
// usage:&#13;
// use modifiers onlyowner (just own owned) or onlymanyowners(hash), whereby the same hash must be provided by&#13;
// some number (specified in constructor) of the set of owners (specified in the constructor, modifiable) before the&#13;
// interior is executed.&#13;
contract multiowned {&#13;
&#13;
    // TYPES&#13;
&#13;
    // struct for the status of a pending operation.&#13;
    struct PendingState {&#13;
        uint yetNeeded;&#13;
        uint ownersDone;&#13;
        uint index;&#13;
    }&#13;
&#13;
    // EVENTS&#13;
&#13;
    // this contract only has five types of events: it can accept a confirmation, in which case&#13;
    // we record owner and operation (hash) alongside it.&#13;
    event Confirmation(address owner, bytes32 operation);&#13;
    event Revoke(address owner, bytes32 operation);&#13;
    // some others are in the case of an owner changing.&#13;
    event OwnerChanged(address oldOwner, address newOwner);&#13;
    event OwnerAdded(address newOwner);&#13;
    event OwnerRemoved(address oldOwner);&#13;
    // the last one is emitted if the required signatures change&#13;
    event RequirementChanged(uint newRequirement);&#13;
&#13;
    // MODIFIERS&#13;
&#13;
    // simple single-sig function modifier.&#13;
    modifier onlyowner {&#13;
        if (isOwner(msg.sender))&#13;
            _;&#13;
    }&#13;
    // multi-sig function modifier: the operation must have an intrinsic hash in order&#13;
    // that later attempts can be realised as the same underlying operation and&#13;
    // thus count as confirmations.&#13;
    modifier onlymanyowners(bytes32 _operation) {&#13;
        if (confirmAndCheck(_operation))&#13;
            _;&#13;
    }&#13;
&#13;
    // METHODS&#13;
&#13;
    // constructor is given number of sigs required to do protected "onlymanyowners" transactions&#13;
    // as well as the selection of addresses capable of confirming them.&#13;
    function multiowned(address[] _owners, uint _required) {&#13;
        m_numOwners = _owners.length + 1;&#13;
        m_owners[1] = uint(msg.sender);&#13;
        m_ownerIndex[uint(msg.sender)] = 1;&#13;
        for (uint i = 0; i &lt; _owners.length; ++i)&#13;
        {&#13;
            m_owners[2 + i] = uint(_owners[i]);&#13;
            m_ownerIndex[uint(_owners[i])] = 2 + i;&#13;
        }&#13;
        m_required = _required;&#13;
    }&#13;
    &#13;
    // Revokes a prior confirmation of the given operation&#13;
    function revoke(bytes32 _operation) external {&#13;
        uint ownerIndex = m_ownerIndex[uint(msg.sender)];&#13;
        // make sure they're an owner&#13;
        if (ownerIndex == 0) return;&#13;
        uint ownerIndexBit = 2**ownerIndex;&#13;
        var pending = m_pending[_operation];&#13;
        if (pending.ownersDone &amp; ownerIndexBit &gt; 0) {&#13;
            pending.yetNeeded++;&#13;
            pending.ownersDone -= ownerIndexBit;&#13;
            Revoke(msg.sender, _operation);&#13;
        }&#13;
    }&#13;
    &#13;
    // Replaces an owner `_from` with another `_to`.&#13;
    function changeOwner(address _from, address _to) onlymanyowners(sha3(msg.data, block.number)) external {&#13;
        if (isOwner(_to)) return;&#13;
        uint ownerIndex = m_ownerIndex[uint(_from)];&#13;
        if (ownerIndex == 0) return;&#13;
&#13;
        clearPending();&#13;
        m_owners[ownerIndex] = uint(_to);&#13;
        m_ownerIndex[uint(_from)] = 0;&#13;
        m_ownerIndex[uint(_to)] = ownerIndex;&#13;
        OwnerChanged(_from, _to);&#13;
    }&#13;
    &#13;
    function addOwner(address _owner) onlymanyowners(sha3(msg.data, block.number)) external {&#13;
        if (isOwner(_owner)) return;&#13;
&#13;
        clearPending();&#13;
        if (m_numOwners &gt;= c_maxOwners)&#13;
            reorganizeOwners();&#13;
        if (m_numOwners &gt;= c_maxOwners)&#13;
            return;&#13;
        m_numOwners++;&#13;
        m_owners[m_numOwners] = uint(_owner);&#13;
        m_ownerIndex[uint(_owner)] = m_numOwners;&#13;
        OwnerAdded(_owner);&#13;
    }&#13;
    &#13;
    function removeOwner(address _owner) onlymanyowners(sha3(msg.data, block.number)) external {&#13;
        uint ownerIndex = m_ownerIndex[uint(_owner)];&#13;
        if (ownerIndex == 0) return;&#13;
        if (m_required &gt; m_numOwners - 1) return;&#13;
&#13;
        m_owners[ownerIndex] = 0;&#13;
        m_ownerIndex[uint(_owner)] = 0;&#13;
        clearPending();&#13;
        reorganizeOwners(); //make sure m_numOwner is equal to the number of owners and always points to the optimal free slot&#13;
        OwnerRemoved(_owner);&#13;
    }&#13;
    &#13;
    function changeRequirement(uint _newRequired) onlymanyowners(sha3(msg.data, block.number)) external {&#13;
        if (_newRequired &gt; m_numOwners) return;&#13;
        m_required = _newRequired;&#13;
        clearPending();&#13;
        RequirementChanged(_newRequired);&#13;
    }&#13;
    &#13;
    function isOwner(address _addr) returns (bool) {&#13;
        return m_ownerIndex[uint(_addr)] &gt; 0;&#13;
    }&#13;
    &#13;
    function hasConfirmed(bytes32 _operation, address _owner) constant returns (bool) {&#13;
        var pending = m_pending[_operation];&#13;
        uint ownerIndex = m_ownerIndex[uint(_owner)];&#13;
&#13;
        // make sure they're an owner&#13;
        if (ownerIndex == 0) return false;&#13;
&#13;
        // determine the bit to set for this owner.&#13;
        uint ownerIndexBit = 2**ownerIndex;&#13;
        if (pending.ownersDone &amp; ownerIndexBit == 0) {&#13;
            return false;&#13;
        } else {&#13;
            return true;&#13;
        }&#13;
    }&#13;
    &#13;
    // INTERNAL METHODS&#13;
&#13;
    function confirmAndCheck(bytes32 _operation) internal returns (bool) {&#13;
        // determine what index the present sender is:&#13;
        uint ownerIndex = m_ownerIndex[uint(msg.sender)];&#13;
        // make sure they're an owner&#13;
        if (ownerIndex == 0) return;&#13;
&#13;
        var pending = m_pending[_operation];&#13;
        // if we're not yet working on this operation, switch over and reset the confirmation status.&#13;
        if (pending.yetNeeded == 0) {&#13;
            // reset count of confirmations needed.&#13;
            pending.yetNeeded = m_required;&#13;
            // reset which owners have confirmed (none) - set our bitmap to 0.&#13;
            pending.ownersDone = 0;&#13;
            pending.index = m_pendingIndex.length++;&#13;
            m_pendingIndex[pending.index] = _operation;&#13;
        }&#13;
        // determine the bit to set for this owner.&#13;
        uint ownerIndexBit = 2**ownerIndex;&#13;
        // make sure we (the message sender) haven't confirmed this operation previously.&#13;
        if (pending.ownersDone &amp; ownerIndexBit == 0) {&#13;
            Confirmation(msg.sender, _operation);&#13;
            // ok - check if count is enough to go ahead.&#13;
            if (pending.yetNeeded &lt;= 1) {&#13;
                // enough confirmations: reset and run interior.&#13;
                delete m_pendingIndex[m_pending[_operation].index];&#13;
                delete m_pending[_operation];&#13;
                return true;&#13;
            }&#13;
            else&#13;
            {&#13;
                // not enough: record that this owner in particular confirmed.&#13;
                pending.yetNeeded--;&#13;
                pending.ownersDone |= ownerIndexBit;&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    function reorganizeOwners() private returns (bool) {&#13;
        uint free = 1;&#13;
        while (free &lt; m_numOwners)&#13;
        {&#13;
            while (free &lt; m_numOwners &amp;&amp; m_owners[free] != 0) free++;&#13;
            while (m_numOwners &gt; 1 &amp;&amp; m_owners[m_numOwners] == 0) m_numOwners--;&#13;
            if (free &lt; m_numOwners &amp;&amp; m_owners[m_numOwners] != 0 &amp;&amp; m_owners[free] == 0)&#13;
            {&#13;
                m_owners[free] = m_owners[m_numOwners];&#13;
                m_ownerIndex[m_owners[free]] = free;&#13;
                m_owners[m_numOwners] = 0;&#13;
            }&#13;
        }&#13;
    }&#13;
    &#13;
    function clearPending() internal {&#13;
        uint length = m_pendingIndex.length;&#13;
        for (uint i = 0; i &lt; length; ++i)&#13;
            if (m_pendingIndex[i] != 0)&#13;
                delete m_pending[m_pendingIndex[i]];&#13;
        delete m_pendingIndex;&#13;
    }&#13;
        &#13;
    // FIELDS&#13;
&#13;
    // the number of owners that must confirm the same operation before it is run.&#13;
    uint public m_required;&#13;
    // pointer used to find a free slot in m_owners&#13;
    uint public m_numOwners;&#13;
    &#13;
    // list of owners&#13;
    uint[256] m_owners;&#13;
    uint constant c_maxOwners = 250;&#13;
    // index on the list of owners to allow reverse lookup&#13;
    mapping(uint =&gt; uint) m_ownerIndex;&#13;
    // the ongoing operations.&#13;
    mapping(bytes32 =&gt; PendingState) m_pending;&#13;
    bytes32[] m_pendingIndex;&#13;
}&#13;
&#13;
// inheritable "property" contract that enables methods to be protected by placing a linear limit (specifiable)&#13;
// on a particular resource per calendar day. is multiowned to allow the limit to be altered. resource that method&#13;
// uses is specified in the modifier.&#13;
contract daylimit is multiowned {&#13;
&#13;
    // MODIFIERS&#13;
&#13;
    // simple modifier for daily limit.&#13;
    modifier limitedDaily(uint _value) {&#13;
        if (underLimit(_value))&#13;
            _;&#13;
    }&#13;
&#13;
    // METHODS&#13;
&#13;
    // constructor - stores initial daily limit and records the present day's index.&#13;
    function daylimit(uint _limit) {&#13;
        m_dailyLimit = _limit;&#13;
        m_lastDay = today();&#13;
    }&#13;
    // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.&#13;
    function setDailyLimit(uint _newLimit) onlymanyowners(sha3(msg.data, block.number)) external {&#13;
        m_dailyLimit = _newLimit;&#13;
    }&#13;
    // (re)sets the daily limit. needs many of the owners to confirm. doesn't alter the amount already spent today.&#13;
    function resetSpentToday() onlymanyowners(sha3(msg.data, block.number)) external {&#13;
        m_spentToday = 0;&#13;
    }&#13;
    &#13;
    // INTERNAL METHODS&#13;
    &#13;
    // checks to see if there is at least `_value` left from the daily limit today. if there is, subtracts it and&#13;
    // returns true. otherwise just returns false.&#13;
    function underLimit(uint _value) internal onlyowner returns (bool) {&#13;
        // reset the spend limit if we're on a different day to last time.&#13;
        if (today() &gt; m_lastDay) {&#13;
            m_spentToday = 0;&#13;
            m_lastDay = today();&#13;
        }&#13;
        // check to see if there's enough left - if so, subtract and return true.&#13;
        if (m_spentToday + _value &gt;= m_spentToday &amp;&amp; m_spentToday + _value &lt;= m_dailyLimit) {&#13;
            m_spentToday += _value;&#13;
            return true;&#13;
        }&#13;
        return false;&#13;
    }&#13;
    // determines today's index.&#13;
    function today() private constant returns (uint) { return now / 1 days; }&#13;
&#13;
    // FIELDS&#13;
&#13;
    uint public m_dailyLimit;&#13;
    uint public m_spentToday;&#13;
    uint public m_lastDay;&#13;
}&#13;
&#13;
// interface contract for multisig proxy contracts; see below for docs.&#13;
contract multisig {&#13;
&#13;
    // EVENTS&#13;
&#13;
    // logged events:&#13;
    // Funds has arrived into the wallet (record how much).&#13;
    event Deposit(address from, uint value);&#13;
    // Single transaction going out of the wallet (record who signed for it, how much, and to whom it's going).&#13;
    event SingleTransact(address owner, uint value, address to, bytes data);&#13;
    // Multi-sig transaction going out of the wallet (record who signed for it last, the operation hash, how much, and to whom it's going).&#13;
    event MultiTransact(address owner, bytes32 operation, uint value, address to, bytes data);&#13;
    // Confirmation still needed for a transaction.&#13;
    event ConfirmationNeeded(bytes32 operation, address initiator, uint value, address to, bytes data);&#13;
    &#13;
    // FUNCTIONS&#13;
    &#13;
    // TODO: document&#13;
    function changeOwner(address _from, address _to) external;&#13;
    function execute(address _to, uint _value, bytes _data) external returns (bytes32);&#13;
    function confirm(bytes32 _h) returns (bool);&#13;
}&#13;
&#13;
// usage:&#13;
// bytes32 h = Wallet(w).from(oneOwner).transact(to, value, data);&#13;
// Wallet(w).from(anotherOwner).confirm(h);&#13;
contract Wallet is multisig, multiowned, daylimit {&#13;
&#13;
    uint public version = 2;&#13;
&#13;
    // TYPES&#13;
&#13;
    // Transaction structure to remember details of transaction lest it need be saved for a later call.&#13;
    struct Transaction {&#13;
        address to;&#13;
        uint value;&#13;
        bytes data;&#13;
    }&#13;
&#13;
    // METHODS&#13;
&#13;
    // constructor - just pass on the owner array to the multiowned and&#13;
    // the limit to daylimit&#13;
    function Wallet(address[] _owners, uint _required, uint _daylimit)&#13;
            multiowned(_owners, _required) daylimit(_daylimit) {&#13;
    }&#13;
    &#13;
    // kills the contract sending everything to `_to`.&#13;
    function kill(address _to) onlymanyowners(sha3(msg.data, block.number)) external {&#13;
        suicide(_to);&#13;
    }&#13;
    &#13;
    // gets called when no other function matches&#13;
    function() {&#13;
        // just being sent some cash?&#13;
        if (msg.value &gt; 0)&#13;
            Deposit(msg.sender, msg.value);&#13;
    }&#13;
    &#13;
    // Outside-visible transact entry point. Executes transacion immediately if below daily spend limit.&#13;
    // If not, goes into multisig process. We provide a hash on return to allow the sender to provide&#13;
    // shortcuts for the other confirmations (allowing them to avoid replicating the _to, _value&#13;
    // and _data arguments). They still get the option of using them if they want, anyways.&#13;
    function execute(address _to, uint _value, bytes _data) external onlyowner returns (bytes32 _r) {&#13;
        // first, take the opportunity to check that we're under the daily limit.&#13;
        if (underLimit(_value)) {&#13;
            SingleTransact(msg.sender, _value, _to, _data);&#13;
            // yes - just execute the call.&#13;
            _to.call.value(_value)(_data);&#13;
            return 0;&#13;
        }&#13;
        // determine our operation hash.&#13;
        _r = sha3(msg.data, block.number);&#13;
        if (!confirm(_r) &amp;&amp; m_txs[_r].to == 0) {&#13;
            m_txs[_r].to = _to;&#13;
            m_txs[_r].value = _value;&#13;
            m_txs[_r].data = _data;&#13;
            ConfirmationNeeded(_r, msg.sender, _value, _to, _data);&#13;
        }&#13;
    }&#13;
    &#13;
    // confirm a transaction through just the hash. we use the previous transactions map, m_txs, in order&#13;
    // to determine the body of the transaction from the hash provided.&#13;
    function confirm(bytes32 _h) onlymanyowners(_h) returns (bool) {&#13;
        if (m_txs[_h].to != 0) {&#13;
            m_txs[_h].to.call.value(m_txs[_h].value)(m_txs[_h].data);&#13;
            MultiTransact(msg.sender, _h, m_txs[_h].value, m_txs[_h].to, m_txs[_h].data);&#13;
            delete m_txs[_h];&#13;
            return true;&#13;
        }&#13;
    }&#13;
    &#13;
    // INTERNAL METHODS&#13;
    &#13;
    function clearPending() internal {&#13;
        uint length = m_pendingIndex.length;&#13;
        for (uint i = 0; i &lt; length; ++i)&#13;
            delete m_txs[m_pendingIndex[i]];&#13;
        super.clearPending();&#13;
    }&#13;
&#13;
    // FIELDS&#13;
&#13;
    // pending transactions we have at present.&#13;
    mapping (bytes32 =&gt; Transaction) m_txs;&#13;
}