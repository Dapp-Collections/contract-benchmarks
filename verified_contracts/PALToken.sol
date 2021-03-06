pragma solidity ^0.4.18;

/**
 * @title Helps contracts guard agains rentrancy attacks.
 * @author Remco Bloemen <<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="5123343c323e1163">[email protected]</a>π.com&gt;&#13;
 * @notice If you mark a function `nonReentrant`, you should also&#13;
 * mark it `external`.&#13;
 */&#13;
contract ReentrancyGuard {&#13;
&#13;
  /**&#13;
   * @dev We use a single lock for the whole contract.37487895&#13;
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
/**&#13;
 * @title Ownable&#13;
 * @dev The Ownable contract has an owner address, and provides basic authorization control&#13;
 * functions, this simplifies the implementation of "user permissions".&#13;
 */&#13;
contract Ownable {&#13;
  address public owner;&#13;
&#13;
&#13;
  /**&#13;
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender&#13;
   * account.&#13;
   */&#13;
  function Ownable() public{&#13;
    owner = msg.sender;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Throws if called by any account other than the owner.&#13;
   */&#13;
  modifier onlyOwner() {&#13;
    require(msg.sender == owner);&#13;
    _;&#13;
  }&#13;
&#13;
&#13;
  /**&#13;
   * @dev Allows the current owner to transfer control of the contract to a newOwner.&#13;
   * @param newOwner The address to transfer ownership to.&#13;
   */&#13;
  function transferOwnership(address newOwner) onlyOwner public{&#13;
    require(newOwner != address(0));&#13;
    owner = newOwner;&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Claimable&#13;
 * @dev Extension for the Ownable contract, where the ownership needs to be claimed.&#13;
 * This allows the new owner to accept the transfer.&#13;
 */&#13;
contract Claimable is Ownable {&#13;
  address public pendingOwner;&#13;
&#13;
  /**&#13;
   * @dev Modifier throws if called by any account other than the pendingOwner.&#13;
   */&#13;
  modifier onlyPendingOwner() {&#13;
    require(msg.sender == pendingOwner);&#13;
    _;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows the current owner to set the pendingOwner address.&#13;
   * @param newOwner The address to transfer ownership to.&#13;
   */&#13;
  function transferOwnership(address newOwner) onlyOwner public {&#13;
    pendingOwner = newOwner;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Allows the pendingOwner address to finalize the transfer.&#13;
   */&#13;
  function claimOwnership() onlyPendingOwner public {&#13;
    owner = pendingOwner;&#13;
    pendingOwner = 0x0;&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title SafeMath&#13;
 * @dev Math operations with safety checks that throw on error&#13;
 */&#13;
library SafeMath {&#13;
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    uint256 c = a * b;&#13;
    assert(a == 0 || c / a == b);&#13;
    return c;&#13;
  }&#13;
&#13;
  function div(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    // assert(b &gt; 0); // Solidity automatically throws when dividing by 0&#13;
    uint256 c = a / b;&#13;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold&#13;
    return c;&#13;
  }&#13;
&#13;
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    assert(b &lt;= a);&#13;
    return a - b;&#13;
  }&#13;
&#13;
  function add(uint256 a, uint256 b) internal pure returns (uint256) {&#13;
    uint256 c = a + b;&#13;
    assert(c &gt;= a);&#13;
    return c;&#13;
  }&#13;
}&#13;
&#13;
/**&#13;
 * @title ERC20Basic&#13;
 * @dev Simpler version of ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/179&#13;
 */&#13;
contract ERC20Basic {&#13;
  uint256 public totalSupply;&#13;
  function balanceOf(address who) public constant returns (uint256);&#13;
  function transfer(address to, uint256 value) public returns (bool);&#13;
  event Transfer(address indexed from, address indexed to, uint256 value);&#13;
}&#13;
&#13;
/**&#13;
 * @title ERC20 interface&#13;
 * @dev see https://github.com/ethereum/EIPs/issues/20&#13;
 */&#13;
contract ERC20 is ERC20Basic {&#13;
  function allowance(address owner, address spender) public constant returns (uint256);&#13;
  function transferFrom(address from, address to, uint256 value) public returns (bool);&#13;
  function approve(address spender, uint256 value) public returns (bool);&#13;
  event Approval(address indexed owner, address indexed spender, uint256 value);&#13;
}&#13;
&#13;
/**&#13;
 * @title Basic token&#13;
 * @dev Basic version of StandardToken, with no allowances.&#13;
 */&#13;
contract BasicToken is ERC20Basic {&#13;
  using SafeMath for uint256;&#13;
&#13;
  mapping(address =&gt; uint256) balances;&#13;
&#13;
  /**&#13;
  * @dev transfer token for a specified address&#13;
  * @param _to The address to transfer to.&#13;
  * @param _value The amount to be transferred.&#13;
  */&#13;
  function transfer(address _to, uint256 _value) public returns (bool) {&#13;
    balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    Transfer(msg.sender, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
  * @dev Gets the balance of the specified address.&#13;
  * @param _owner The address to query the the balance of.&#13;
  * @return An uint256 representing the amount owned by the passed address.&#13;
  */&#13;
  function balanceOf(address _owner) public constant returns (uint256 balance) {&#13;
    return balances[_owner];&#13;
  }&#13;
&#13;
}&#13;
&#13;
/**&#13;
 * @title Standard ERC20 token&#13;
 *&#13;
 * @dev Implementation of the basic standard token.&#13;
 * @dev https://github.com/ethereum/EIPs/issues/20&#13;
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol&#13;
 */&#13;
contract StandardToken is ERC20, BasicToken {&#13;
&#13;
  mapping (address =&gt; mapping (address =&gt; uint256)) allowed;&#13;
&#13;
&#13;
  /**&#13;
   * @dev Transfer tokens from one address to another&#13;
   * @param _from address The address which you want to send tokens from&#13;
   * @param _to address The address which you want to transfer to&#13;
   * @param _value uint256 the amout of tokens to be transfered&#13;
   */&#13;
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {&#13;
    var _allowance = allowed[_from][msg.sender];&#13;
&#13;
    // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met&#13;
    // require (_value &lt;= _allowance);&#13;
&#13;
    balances[_to] = balances[_to].add(_value);&#13;
    balances[_from] = balances[_from].sub(_value);&#13;
    allowed[_from][msg.sender] = _allowance.sub(_value);&#13;
    Transfer(_from, _to, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Aprove the passed address to spend the specified amount of tokens on behalf of msg.sender.&#13;
   * @param _spender The address which will spend the funds.&#13;
   * @param _value The amount of tokens to be spent.&#13;
   */&#13;
  function approve(address _spender, uint256 _value) public returns (bool) {&#13;
&#13;
    // To change the approve amount you first have to reduce the addresses`&#13;
    //  allowance to zero by calling `approve(_spender, 0)` if it is not&#13;
    //  already 0 to mitigate the race condition described here:&#13;
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729&#13;
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));&#13;
&#13;
    allowed[msg.sender][_spender] = _value;&#13;
    Approval(msg.sender, _spender, _value);&#13;
    return true;&#13;
  }&#13;
&#13;
  /**&#13;
   * @dev Function to check the amount of tokens that an owner allowed to a spender.&#13;
   * @param _owner address The address which owns the funds.&#13;
   * @param _spender address The address which will spend the funds.&#13;
   * @return A uint256 specifing the amount of tokens still available for the spender.&#13;
   */&#13;
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {&#13;
    return allowed[_owner][_spender];&#13;
  }&#13;
&#13;
}&#13;
&#13;
contract Operational is Claimable {&#13;
    address public operator;&#13;
&#13;
    function Operational(address _operator) public {&#13;
      operator = _operator;&#13;
    }&#13;
&#13;
    modifier onlyOperator() {&#13;
      require(msg.sender == operator);&#13;
      _;&#13;
    }&#13;
&#13;
    function transferOperator(address newOperator) public onlyOwner {&#13;
      require(newOperator != address(0));&#13;
      operator = newOperator;&#13;
    }&#13;
&#13;
}&#13;
&#13;
library DateTime {&#13;
        /*&#13;
         *  Date and Time utilities for ethereum contracts&#13;
         *&#13;
         */&#13;
        struct MyDateTime {&#13;
                uint16 year;&#13;
                uint8 month;&#13;
                uint8 day;&#13;
                uint8 hour;&#13;
                uint8 minute;&#13;
                uint8 second;&#13;
                uint8 weekday;&#13;
        }&#13;
&#13;
        uint constant DAY_IN_SECONDS = 86400;&#13;
        uint constant YEAR_IN_SECONDS = 31536000;&#13;
        uint constant LEAP_YEAR_IN_SECONDS = 31622400;&#13;
&#13;
        uint constant HOUR_IN_SECONDS = 3600;&#13;
        uint constant MINUTE_IN_SECONDS = 60;&#13;
&#13;
        uint16 constant ORIGIN_YEAR = 1970;&#13;
&#13;
        function isLeapYear(uint16 year) public pure returns (bool) {&#13;
                if (year % 4 != 0) {&#13;
                        return false;&#13;
                }&#13;
                if (year % 100 != 0) {&#13;
                        return true;&#13;
                }&#13;
                if (year % 400 != 0) {&#13;
                        return false;&#13;
                }&#13;
                return true;&#13;
        }&#13;
&#13;
        function leapYearsBefore(uint year) public pure returns (uint) {&#13;
                year -= 1;&#13;
                return year / 4 - year / 100 + year / 400;&#13;
        }&#13;
&#13;
        function getDaysInMonth(uint8 month, uint16 year) public pure returns (uint8) {&#13;
                if (month == 1 || month == 3 || month == 5 || month == 7 || month == 8 || month == 10 || month == 12) {&#13;
                        return 31;&#13;
                }&#13;
                else if (month == 4 || month == 6 || month == 9 || month == 11) {&#13;
                        return 30;&#13;
                }&#13;
                else if (isLeapYear(year)) {&#13;
                        return 29;&#13;
                }&#13;
                else {&#13;
                        return 28;&#13;
                }&#13;
        }&#13;
&#13;
        function parseTimestamp(uint timestamp) internal pure returns (MyDateTime dt) {&#13;
                uint secondsAccountedFor = 0;&#13;
                uint buf;&#13;
                uint8 i;&#13;
&#13;
                // Year&#13;
                dt.year = getYear(timestamp);&#13;
                buf = leapYearsBefore(dt.year) - leapYearsBefore(ORIGIN_YEAR);&#13;
&#13;
                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * buf;&#13;
                secondsAccountedFor += YEAR_IN_SECONDS * (dt.year - ORIGIN_YEAR - buf);&#13;
&#13;
                // Month&#13;
                uint secondsInMonth;&#13;
                for (i = 1; i &lt;= 12; i++) {&#13;
                        secondsInMonth = DAY_IN_SECONDS * getDaysInMonth(i, dt.year);&#13;
                        if (secondsInMonth + secondsAccountedFor &gt; timestamp) {&#13;
                                dt.month = i;&#13;
                                break;&#13;
                        }&#13;
                        secondsAccountedFor += secondsInMonth;&#13;
                }&#13;
&#13;
                // Day&#13;
                for (i = 1; i &lt;= getDaysInMonth(dt.month, dt.year); i++) {&#13;
                        if (DAY_IN_SECONDS + secondsAccountedFor &gt; timestamp) {&#13;
                                dt.day = i;&#13;
                                break;&#13;
                        }&#13;
                        secondsAccountedFor += DAY_IN_SECONDS;&#13;
                }&#13;
&#13;
                // Hour&#13;
                dt.hour = 0;//getHour(timestamp);&#13;
&#13;
                // Minute&#13;
                dt.minute = 0;//getMinute(timestamp);&#13;
&#13;
                // Second&#13;
                dt.second = 0;//getSecond(timestamp);&#13;
&#13;
                // Day of week.&#13;
                dt.weekday = 0;//getWeekday(timestamp);&#13;
&#13;
        }&#13;
&#13;
        function getYear(uint timestamp) public pure returns (uint16) {&#13;
                uint secondsAccountedFor = 0;&#13;
                uint16 year;&#13;
                uint numLeapYears;&#13;
&#13;
                // Year&#13;
                year = uint16(ORIGIN_YEAR + timestamp / YEAR_IN_SECONDS);&#13;
                numLeapYears = leapYearsBefore(year) - leapYearsBefore(ORIGIN_YEAR);&#13;
&#13;
                secondsAccountedFor += LEAP_YEAR_IN_SECONDS * numLeapYears;&#13;
                secondsAccountedFor += YEAR_IN_SECONDS * (year - ORIGIN_YEAR - numLeapYears);&#13;
&#13;
                while (secondsAccountedFor &gt; timestamp) {&#13;
                        if (isLeapYear(uint16(year - 1))) {&#13;
                                secondsAccountedFor -= LEAP_YEAR_IN_SECONDS;&#13;
                        }&#13;
                        else {&#13;
                                secondsAccountedFor -= YEAR_IN_SECONDS;&#13;
                        }&#13;
                        year -= 1;&#13;
                }&#13;
                return year;&#13;
        }&#13;
&#13;
        function getMonth(uint timestamp) public pure returns (uint8) {&#13;
                return parseTimestamp(timestamp).month;&#13;
        }&#13;
&#13;
        function getDay(uint timestamp) public pure returns (uint8) {&#13;
                return parseTimestamp(timestamp).day;&#13;
        }&#13;
&#13;
        function getHour(uint timestamp) public pure returns (uint8) {&#13;
                return uint8((timestamp / 60 / 60) % 24);&#13;
        }&#13;
&#13;
        function getMinute(uint timestamp) public pure returns (uint8) {&#13;
                return uint8((timestamp / 60) % 60);&#13;
        }&#13;
&#13;
        function getSecond(uint timestamp) public pure returns (uint8) {&#13;
                return uint8(timestamp % 60);&#13;
        }&#13;
&#13;
        function toTimestamp(uint16 year, uint8 month, uint8 day) public pure returns (uint timestamp) {&#13;
                return toTimestamp(year, month, day, 0, 0, 0);&#13;
        }&#13;
&#13;
        function toTimestamp(uint16 year, uint8 month, uint8 day, uint8 hour, uint8 minute, uint8 second) public pure returns (uint timestamp) {&#13;
                uint16 i;&#13;
&#13;
                // Year&#13;
                for (i = ORIGIN_YEAR; i &lt; year; i++) {&#13;
                        if (isLeapYear(i)) {&#13;
                                timestamp += LEAP_YEAR_IN_SECONDS;&#13;
                        }&#13;
                        else {&#13;
                                timestamp += YEAR_IN_SECONDS;&#13;
                        }&#13;
                }&#13;
&#13;
                // Month&#13;
                uint8[12] memory monthDayCounts;&#13;
                monthDayCounts[0] = 31;&#13;
                if (isLeapYear(year)) {&#13;
                        monthDayCounts[1] = 29;&#13;
                }&#13;
                else {&#13;
                        monthDayCounts[1] = 28;&#13;
                }&#13;
                monthDayCounts[2] = 31;&#13;
                monthDayCounts[3] = 30;&#13;
                monthDayCounts[4] = 31;&#13;
                monthDayCounts[5] = 30;&#13;
                monthDayCounts[6] = 31;&#13;
                monthDayCounts[7] = 31;&#13;
                monthDayCounts[8] = 30;&#13;
                monthDayCounts[9] = 31;&#13;
                monthDayCounts[10] = 30;&#13;
                monthDayCounts[11] = 31;&#13;
&#13;
                for (i = 1; i &lt; month; i++) {&#13;
                        timestamp += DAY_IN_SECONDS * monthDayCounts[i - 1];&#13;
                }&#13;
&#13;
                // Day&#13;
                timestamp += DAY_IN_SECONDS * (day - 1);&#13;
&#13;
                // Hour&#13;
                timestamp += HOUR_IN_SECONDS * (hour);&#13;
&#13;
                // Minute&#13;
                timestamp += MINUTE_IN_SECONDS * (minute);&#13;
&#13;
                // Second&#13;
                timestamp += second;&#13;
&#13;
                return timestamp;&#13;
        }&#13;
}&#13;
&#13;
/**&#13;
 * @title Burnable Token&#13;
 * @dev Token that can be irreversibly burned (destroyed).&#13;
 */&#13;
contract BurnableToken is StandardToken {&#13;
    event Burn(address indexed burner, uint256 value);&#13;
    /**&#13;
     * @dev Burns a specific amount of tokens.&#13;
     * @param _value The amount of token to be burned.&#13;
     */&#13;
    function burn(uint256 _value) public returns (bool) {&#13;
        require(_value &gt; 0);&#13;
        require(_value &lt;= balances[msg.sender]);&#13;
        // no need to require value &lt;= totalSupply, since that would imply the&#13;
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure&#13;
        address burner = msg.sender;&#13;
        balances[burner] = balances[burner].sub(_value);&#13;
        totalSupply = totalSupply.sub(_value);&#13;
        Burn(burner, _value);&#13;
        return true;&#13;
    }&#13;
}&#13;
&#13;
contract LockableToken is Ownable, ReentrancyGuard, BurnableToken {&#13;
&#13;
    using DateTime for uint;&#13;
    using SafeMath for uint256;&#13;
&#13;
    mapping (uint256 =&gt; uint256) public lockedBalances;&#13;
    uint256[] public lockedKeys;&#13;
    // For store all user's transfer records, eg: (0x000...000 =&gt; (201806 =&gt; 100) )&#13;
    mapping (address =&gt; mapping (uint256 =&gt; uint256) ) public payRecords;&#13;
&#13;
    event TransferLocked(address indexed from,address indexed to,uint256 value, uint256 releaseTime);//new&#13;
    event ReleaseLockedBalance( uint256 value, uint256 releaseTime); //new&#13;
&#13;
    function transferLockedToken(uint256 _value) public payable nonReentrant returns (bool) {&#13;
&#13;
        require(_value &gt; 0 &amp;&amp; _value &lt;= balances[msg.sender]);&#13;
&#13;
        uint256 unlockTime = now.add(26 weeks);&#13;
        uint theYear = unlockTime.parseTimestamp().year;&#13;
        uint theMonth = unlockTime.parseTimestamp().month;&#13;
        uint256 theKey = (theYear.mul(100)).add(theMonth);&#13;
&#13;
        address _to = owner;&#13;
        balances[msg.sender] = balances[msg.sender].sub(_value);&#13;
        // Stored user's transfer per month&#13;
        var dt = now.parseTimestamp();&#13;
        var (curYear, curMonth) = (uint256(dt.year), uint256(dt.month) );&#13;
        uint256 yearMonth = (curYear.mul(100)).add(curMonth);&#13;
        payRecords[msg.sender][yearMonth] = payRecords[msg.sender][yearMonth].add(_value);&#13;
&#13;
        if(lockedBalances[theKey] == 0) {&#13;
            lockedBalances[theKey] = _value;&#13;
            push_or_update_key(theKey);&#13;
        }&#13;
        else {&#13;
            lockedBalances[theKey] = lockedBalances[theKey].add(_value);&#13;
        }&#13;
        TransferLocked(msg.sender, _to, _value, unlockTime);&#13;
        return true;&#13;
    }&#13;
&#13;
    function releaseLockedBalance() public returns (uint256 releaseAmount) {&#13;
        return releaseLockedBalance(now);&#13;
    }&#13;
&#13;
    function releaseLockedBalance(uint256 unlockTime) internal returns (uint256 releaseAmount) {&#13;
        uint theYear = unlockTime.parseTimestamp().year;&#13;
        uint theMonth = unlockTime.parseTimestamp().month;&#13;
        uint256 currentTime = (theYear.mul(100)).add(theMonth);&#13;
        for (uint i = 0; i &lt; lockedKeys.length; i++) {&#13;
            uint256 theTime = lockedKeys[i];&#13;
            if(theTime == 0 || lockedBalances[theTime] == 0)&#13;
                continue;&#13;
&#13;
            if(currentTime &gt;= theTime) {&#13;
                releaseAmount = releaseAmount.add(lockedBalances[theTime]);&#13;
                unlockBalanceByKey(theTime,i);&#13;
            }&#13;
        }&#13;
        ReleaseLockedBalance(releaseAmount,currentTime);&#13;
        return releaseAmount;&#13;
    }&#13;
&#13;
    function unlockBalanceByKey(uint256 theKey,uint keyIndex) internal {&#13;
        uint256 _value = lockedBalances[theKey];&#13;
        balances[owner] = balances[owner].add(_value);&#13;
        delete lockedBalances[theKey];&#13;
        delete lockedKeys[keyIndex];&#13;
    }&#13;
&#13;
    function lockedBalance() public constant returns (uint256 value) {&#13;
        for (uint i=0; i &lt; lockedKeys.length; i++) {&#13;
            value = value.add(lockedBalances[lockedKeys[i]]);&#13;
        }&#13;
        return value;&#13;
    }&#13;
&#13;
    function push_or_update_key(uint256 key) private {&#13;
        bool found_index = false;&#13;
        uint256 i=0;&#13;
        // Found a empty key.&#13;
        if(lockedKeys.length &gt;= 1) {&#13;
            for(; i&lt;lockedKeys.length; i++) {&#13;
                if(lockedKeys[i] == 0) {&#13;
                    found_index = true;&#13;
                    break;&#13;
                }&#13;
            }&#13;
        }&#13;
&#13;
        // If found a empty key(value == 0) in lockedKeys array, reused it.&#13;
        if( found_index ) {&#13;
            lockedKeys[i] = key;&#13;
        } else {&#13;
            lockedKeys.push(key);&#13;
        }&#13;
    }&#13;
}&#13;
&#13;
contract ReleaseableToken is Operational, LockableToken {&#13;
    using SafeMath for uint;&#13;
    using DateTime for uint256;&#13;
    bool secondYearUpdate = false; // Limit ,update to second year&#13;
    uint256 public createTime; // Contract creation time&#13;
    uint256 standardDecimals = 100000000; // 8 decimal places&#13;
&#13;
    uint256 public limitSupplyPerYear = standardDecimals.mul(10000000000); // Year limit, first year&#13;
    uint256 public dailyLimit = standardDecimals.mul(10000000000); // Day limit&#13;
&#13;
    uint256 public supplyLimit = standardDecimals.mul(10000000000); // PALT MAX&#13;
    uint256 public releaseTokenTime = 0;&#13;
&#13;
    event ReleaseSupply(address operator, uint256 value, uint256 releaseTime);&#13;
    event UnfreezeAmount(address receiver, uint256 amount, uint256 unfreezeTime);&#13;
&#13;
    function ReleaseableToken(&#13;
                    uint256 initTotalSupply,&#13;
                    address operator&#13;
                ) public Operational(operator) {&#13;
        totalSupply = standardDecimals.mul(initTotalSupply);&#13;
        createTime = now;&#13;
        balances[msg.sender] = totalSupply;&#13;
    }&#13;
&#13;
    // Release the amount on the time&#13;
    function releaseSupply(uint256 releaseAmount) public onlyOperator returns(uint256 _actualRelease) {&#13;
&#13;
        require(now &gt;= (releaseTokenTime.add(1 days)) );&#13;
        require(releaseAmount &lt;= dailyLimit);&#13;
        updateLimit();&#13;
        require(limitSupplyPerYear &gt; 0);&#13;
        if (releaseAmount &gt; limitSupplyPerYear) {&#13;
            if (totalSupply.add(limitSupplyPerYear) &gt; supplyLimit) {&#13;
                releaseAmount = supplyLimit.sub(totalSupply);&#13;
                totalSupply = supplyLimit;&#13;
            } else {&#13;
                totalSupply = totalSupply.add(limitSupplyPerYear);&#13;
                releaseAmount = limitSupplyPerYear;&#13;
            }&#13;
            limitSupplyPerYear = 0;&#13;
        } else {&#13;
            if (totalSupply.add(releaseAmount) &gt; supplyLimit) {&#13;
                releaseAmount = supplyLimit.sub(totalSupply);&#13;
                totalSupply = supplyLimit;&#13;
            } else {&#13;
                totalSupply = totalSupply.add(releaseAmount);&#13;
            }&#13;
            limitSupplyPerYear = limitSupplyPerYear.sub(releaseAmount);&#13;
        }&#13;
&#13;
        releaseTokenTime = now;&#13;
        balances[owner] = balances[owner].add(releaseAmount);&#13;
        ReleaseSupply(msg.sender, releaseAmount, releaseTokenTime);&#13;
        return releaseAmount;&#13;
    }&#13;
&#13;
    // Update year limit&#13;
    function updateLimit() internal {&#13;
        if (createTime.add(1 years) &lt; now &amp;&amp; !secondYearUpdate) {&#13;
            limitSupplyPerYear = standardDecimals.mul(10000000000);&#13;
            secondYearUpdate = true;&#13;
        }&#13;
        if (createTime.add(2 * 1 years) &lt; now) {&#13;
            if (totalSupply &lt; supplyLimit) {&#13;
                limitSupplyPerYear = supplyLimit.sub(totalSupply);&#13;
            }&#13;
        }&#13;
    }&#13;
&#13;
    // Set day limit&#13;
    function setDailyLimit(uint256 _dailyLimit) public onlyOwner {&#13;
        dailyLimit = _dailyLimit;&#13;
    }&#13;
}&#13;
&#13;
contract PALToken is ReleaseableToken {&#13;
    string public standard = '2018071701';&#13;
    string public name = 'PALToken';&#13;
    string public symbol = 'PALT';&#13;
    uint8 public decimals = 8;&#13;
&#13;
    function PALToken(&#13;
                     uint256 initTotalSupply,&#13;
                     address operator&#13;
                     ) public ReleaseableToken(initTotalSupply, operator) {}&#13;
}