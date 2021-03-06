/*
 * Safe Math Smart Contract.  Copyright © 2016–2017 by ABDK Consulting.
 * Author: Mikhail Vladimirov <<span class="__cf_email__" data-cfemail="274a4e4c4f464e4b09514b46434e4a4e55485167404a464e4b0944484a">[email protected]</span>&gt;&#13;
 */&#13;
pragma solidity ^0.4.16;&#13;
&#13;
/**&#13;
 * ERC-20 standard token interface, as defined&#13;
 * &lt;a href="http://github.com/ethereum/EIPs/issues/20"&gt;here&lt;/a&gt;.&#13;
 */&#13;
contract Token {&#13;
    /**&#13;
     * Get total number of tokens in circulation.&#13;
     *&#13;
     * @return total number of tokens in circulation&#13;
     */&#13;
    function totalSupply () constant returns (uint256 supply);&#13;
&#13;
    /**&#13;
     * Get number of tokens currently belonging to given owner.&#13;
     *&#13;
     * @param _owner address to get number of tokens currently belonging to the&#13;
     *        owner of&#13;
     * @return number of tokens currently belonging to the owner of given address&#13;
     */&#13;
    function balanceOf (address _owner) constant returns (uint256 balance);&#13;
&#13;
    /**&#13;
     * Transfer given number of tokens from message sender to given recipient.&#13;
     *&#13;
     * @param _to address to transfer tokens to the owner of&#13;
     * @param _value number of tokens to transfer to the owner of given address&#13;
     * @return true if tokens were transferred successfully, false otherwise&#13;
     */&#13;
    function transfer (address _to, uint256 _value) returns (bool success);&#13;
&#13;
    /**&#13;
     * Transfer given number of tokens from given owner to given recipient.&#13;
     *&#13;
     * @param _from address to transfer tokens from the owner of&#13;
     * @param _to address to transfer tokens to the owner of&#13;
     * @param _value number of tokens to transfer from given owner to given&#13;
     *        recipient&#13;
     * @return true if tokens were transferred successfully, false otherwise&#13;
     */&#13;
    function transferFrom (address _from, address _to, uint256 _value)&#13;
    returns (bool success);&#13;
&#13;
    /**&#13;
     * Allow given spender to transfer given number of tokens from message sender.&#13;
     *&#13;
     * @param _spender address to allow the owner of to transfer tokens from&#13;
     *        message sender&#13;
     * @param _value number of tokens to allow to transfer&#13;
     * @return true if token transfer was successfully approved, false otherwise&#13;
     */&#13;
    function approve (address _spender, uint256 _value) returns (bool success);&#13;
&#13;
    /**&#13;
     * Tell how many tokens given spender is currently allowed to transfer from&#13;
     * given owner.&#13;
     *&#13;
     * @param _owner address to get number of tokens allowed to be transferred&#13;
     *        from the owner of&#13;
     * @param _spender address to get number of tokens allowed to be transferred&#13;
     *        by the owner of&#13;
     * @return number of tokens given spender is currently allowed to transfer&#13;
     *         from given owner&#13;
     */&#13;
    function allowance (address _owner, address _spender) constant&#13;
    returns (uint256 remaining);&#13;
&#13;
    /**&#13;
     * Logged when tokens were transferred from one owner to another.&#13;
     *&#13;
     * @param _from address of the owner, tokens were transferred from&#13;
     * @param _to address of the owner, tokens were transferred to&#13;
     * @param _value number of tokens transferred&#13;
     */&#13;
    event Transfer (address indexed _from, address indexed _to, uint256 _value);&#13;
&#13;
    /**&#13;
     * Logged when owner approved his tokens to be transferred by some spender.&#13;
     *&#13;
     * @param _owner owner who approved his tokens to be transferred&#13;
     * @param _spender spender who were allowed to transfer the tokens belonging&#13;
     *        to the owner&#13;
     * @param _value number of tokens belonging to the owner, approved to be&#13;
     *        transferred by the spender&#13;
     */&#13;
    event Approval (&#13;
        address indexed _owner, address indexed _spender, uint256 _value);&#13;
}&#13;
&#13;
/**&#13;
 * Provides methods to safely add, subtract and multiply uint256 numbers.&#13;
 */&#13;
contract SafeMath {&#13;
    uint256 constant private MAX_UINT256 =&#13;
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;&#13;
&#13;
    /**&#13;
     * Add two uint256 values, throw in case of overflow.&#13;
     *&#13;
     * @param x first value to add&#13;
     * @param y second value to add&#13;
     * @return x + y&#13;
     */&#13;
    function safeAdd (uint256 x, uint256 y)&#13;
    constant internal&#13;
    returns (uint256 z) {&#13;
        assert (x &lt;= MAX_UINT256 - y);&#13;
        return x + y;&#13;
    }&#13;
&#13;
    /**&#13;
     * Subtract one uint256 value from another, throw in case of underflow.&#13;
     *&#13;
     * @param x value to subtract from&#13;
     * @param y value to subtract&#13;
     * @return x - y&#13;
     */&#13;
    function safeSub (uint256 x, uint256 y)&#13;
    constant internal&#13;
    returns (uint256 z) {&#13;
        assert (x &gt;= y);&#13;
        return x - y;&#13;
    }&#13;
&#13;
    /**&#13;
     * Multiply two uint256 values, throw in case of overflow.&#13;
     *&#13;
     * @param x first value to multiply&#13;
     * @param y second value to multiply&#13;
     * @return x * y&#13;
     */&#13;
    function safeMul (uint256 x, uint256 y)&#13;
    constant internal&#13;
    returns (uint256 z) {&#13;
        if (y == 0) return 0; // Prevent division by zero at the next line&#13;
        assert (x &lt;= MAX_UINT256 / y);&#13;
        return x * y;&#13;
    }&#13;
}&#13;
&#13;
/**&#13;
 * Math Utilities smart contract.&#13;
 */&#13;
contract Math is SafeMath {&#13;
    /**&#13;
     * 2^127.&#13;
     */&#13;
    uint128 internal constant TWO127 = 0x80000000000000000000000000000000;&#13;
&#13;
    /**&#13;
     * 2^128 - 1.&#13;
     */&#13;
    uint128 internal constant TWO128_1 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;&#13;
&#13;
    /**&#13;
     * 2^128.&#13;
     */&#13;
    uint256 internal constant TWO128 = 0x100000000000000000000000000000000;&#13;
&#13;
    /**&#13;
     * 2^256 - 1.&#13;
     */&#13;
    uint256 internal constant TWO256_1 =&#13;
    0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;&#13;
&#13;
    /**&#13;
     * 2^255.&#13;
     */&#13;
    uint256 internal constant TWO255 =&#13;
    0x8000000000000000000000000000000000000000000000000000000000000000;&#13;
&#13;
    /**&#13;
     * -2^255.&#13;
     */&#13;
    int256 internal constant MINUS_TWO255 =&#13;
    -0x8000000000000000000000000000000000000000000000000000000000000000;&#13;
&#13;
    /**&#13;
     * 2^255 - 1.&#13;
     */&#13;
    int256 internal constant TWO255_1 =&#13;
    0x7FFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;&#13;
&#13;
    /**&#13;
     * ln(2) * 2^128.&#13;
     */&#13;
    uint128 internal constant LN2 = 0xb17217f7d1cf79abc9e3b39803f2f6af;&#13;
&#13;
    /**&#13;
     * Return index of most significant non-zero bit in given non-zero 256-bit&#13;
     * unsigned integer value.&#13;
     *&#13;
     * @param x value to get index of most significant non-zero bit in&#13;
     * @return index of most significant non-zero bit in given number&#13;
     */&#13;
    function mostSignificantBit (uint256 x) pure internal returns (uint8) {&#13;
        require (x &gt; 0);&#13;
&#13;
        uint8 l = 0;&#13;
        uint8 h = 255;&#13;
&#13;
        while (h &gt; l) {&#13;
            uint8 m = uint8 ((uint16 (l) + uint16 (h)) &gt;&gt; 1);&#13;
            uint256 t = x &gt;&gt; m;&#13;
            if (t == 0) h = m - 1;&#13;
            else if (t &gt; 1) l = m + 1;&#13;
            else return m;&#13;
        }&#13;
&#13;
        return h;&#13;
    }&#13;
&#13;
    /**&#13;
     * Calculate log_2 (x / 2^128) * 2^128.&#13;
     *&#13;
     * @param x parameter value&#13;
     * @return log_2 (x / 2^128) * 2^128&#13;
     */&#13;
    function log_2 (uint256 x) pure internal returns (int256) {&#13;
        require (x &gt; 0);&#13;
&#13;
        uint8 msb = mostSignificantBit (x);&#13;
&#13;
        if (msb &gt; 128) x &gt;&gt;= msb - 128;&#13;
        else if (msb &lt; 128) x &lt;&lt;= 128 - msb;&#13;
&#13;
        x &amp;= TWO128_1;&#13;
&#13;
        int256 result = (int256 (msb) - 128) &lt;&lt; 128; // Integer part of log_2&#13;
&#13;
        int256 bit = TWO127;&#13;
        for (uint8 i = 0; i &lt; 128 &amp;&amp; x &gt; 0; i++) {&#13;
            x = (x &lt;&lt; 1) + ((x * x + TWO127) &gt;&gt; 128);&#13;
            if (x &gt; TWO128_1) {&#13;
                result |= bit;&#13;
                x = (x &gt;&gt; 1) - TWO127;&#13;
            }&#13;
            bit &gt;&gt;= 1;&#13;
        }&#13;
&#13;
        return result;&#13;
    }&#13;
&#13;
    /**&#13;
     * Calculate ln (x / 2^128) * 2^128.&#13;
     *&#13;
     * @param x parameter value&#13;
     * @return ln (x / 2^128) * 2^128&#13;
     */&#13;
    function ln (uint256 x) pure internal returns (int256) {&#13;
        require (x &gt; 0);&#13;
&#13;
        int256 l2 = log_2 (x);&#13;
        if (l2 == 0) return 0;&#13;
        else {&#13;
            uint256 al2 = uint256 (l2 &gt; 0 ? l2 : -l2);&#13;
            uint8 msb = mostSignificantBit (al2);&#13;
            if (msb &gt; 127) al2 &gt;&gt;= msb - 127;&#13;
            al2 = (al2 * LN2 + TWO127) &gt;&gt; 128;&#13;
            if (msb &gt; 127) al2 &lt;&lt;= msb - 127;&#13;
&#13;
            return int256 (l2 &gt;= 0 ? al2 : -al2);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * Calculate x * y / 2^128.&#13;
     *&#13;
     * @param x parameter x&#13;
     * @param y parameter y&#13;
     * @return x * y / 2^128&#13;
     */&#13;
    function fpMul (uint256 x, uint256 y) pure internal returns (uint256) {&#13;
        uint256 xh = x &gt;&gt; 128;&#13;
        uint256 xl = x &amp; TWO128_1;&#13;
        uint256 yh = y &gt;&gt; 128;&#13;
        uint256 yl = y &amp; TWO128_1;&#13;
&#13;
        uint256 result = xh * yh;&#13;
        require (result &lt;= TWO128_1);&#13;
        result &lt;&lt;= 128;&#13;
&#13;
        result = safeAdd (result, xh * yl);&#13;
        result = safeAdd (result, xl * yh);&#13;
        result = safeAdd (result, (xl * yl) &gt;&gt; 128);&#13;
&#13;
        return result;&#13;
    }&#13;
&#13;
    /**&#13;
     * Calculate x * y.&#13;
     *&#13;
     * @param x parameter x&#13;
     * @param y parameter y&#13;
     * @return high and low words of x * y&#13;
     */&#13;
    function longMul (uint256 x, uint256 y)&#13;
    pure internal returns (uint256 h, uint256 l) {&#13;
        uint256 xh = x &gt;&gt; 128;&#13;
        uint256 xl = x &amp; TWO128_1;&#13;
        uint256 yh = y &gt;&gt; 128;&#13;
        uint256 yl = y &amp; TWO128_1;&#13;
&#13;
        h = xh * yh;&#13;
        l = xl * yl;&#13;
&#13;
        uint256 m1 = xh * yl;&#13;
        uint256 m2 = xl * yh;&#13;
&#13;
        h += m1 &gt;&gt; 128;&#13;
        h += m2 &gt;&gt; 128;&#13;
&#13;
        m1 &lt;&lt;= 128;&#13;
        m2 &lt;&lt;= 128;&#13;
&#13;
        if (l &gt; TWO256_1 - m1) h += 1;&#13;
        l += m1;&#13;
&#13;
        if (l &gt; TWO256_1 - m2) h += 1;&#13;
        l += m2;&#13;
    }&#13;
&#13;
    /**&#13;
     * Calculate x * y / 2^128.&#13;
     *&#13;
     * @param x parameter x&#13;
     * @param y parameter y&#13;
     * @return x * y / 2^128&#13;
     */&#13;
    function fpMulI (int256 x, int256 y) pure internal returns (int256) {&#13;
        bool negative = (x ^ y) &lt; 0; // Whether result is negative&#13;
&#13;
        uint256 result = fpMul (&#13;
            x &lt; 0 ? uint256 (-1 - x) + 1 : uint256 (x),&#13;
            y &lt; 0 ? uint256 (-1 - y) + 1 : uint256 (y));&#13;
&#13;
        if (negative) {&#13;
            require (result &lt;= TWO255);&#13;
            return result == 0 ? 0 : -1 - int256 (result - 1);&#13;
        } else {&#13;
            require (result &lt; TWO255);&#13;
            return int256 (result);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * Calculate x + y, throw in case of over-/underflow.&#13;
     *&#13;
     * @param x parameter x&#13;
     * @param y parameter y&#13;
     * @return x + y&#13;
     */&#13;
    function safeAddI (int256 x, int256 y) pure internal returns (int256) {&#13;
        if (x &lt; 0 &amp;&amp; y &lt; 0)&#13;
            assert (x &gt;= MINUS_TWO255 - y);&#13;
&#13;
        if (x &gt; 0 &amp;&amp; y &gt; 0)&#13;
            assert (x &lt;= TWO255_1 - y);&#13;
&#13;
        return x + y;&#13;
    }&#13;
&#13;
    /**&#13;
     * Calculate x / y * 2^128.&#13;
     *&#13;
     * @param x parameter x&#13;
     * @param y parameter y&#13;
     * @return  x / y * 2^128&#13;
     */&#13;
    function fpDiv (uint256 x, uint256 y) pure internal returns (uint256) {&#13;
        require (y &gt; 0); // Division by zero is forbidden&#13;
&#13;
        uint8 maxShiftY = mostSignificantBit (y);&#13;
        if (maxShiftY &gt;= 128) maxShiftY -= 127;&#13;
        else maxShiftY = 0;&#13;
&#13;
        uint256 result = 0;&#13;
&#13;
        while (true) {&#13;
            uint256 rh = x &gt;&gt; 128;&#13;
            uint256 rl = x &lt;&lt; 128;&#13;
&#13;
            uint256 ph;&#13;
            uint256 pl;&#13;
&#13;
            (ph, pl) = longMul (result, y);&#13;
            if (rl &lt; pl) {&#13;
                ph = safeAdd (ph, 1);&#13;
            }&#13;
&#13;
            rl -= pl;&#13;
            rh -= ph;&#13;
&#13;
            if (rh == 0) {&#13;
                result = safeAdd (result, rl / y);&#13;
                break;&#13;
            } else {&#13;
                uint256 reminder = (rh &lt;&lt; 128) + (rl &gt;&gt; 128);&#13;
&#13;
                // How many bits to shift reminder left&#13;
                uint8 shiftReminder = 255 - mostSignificantBit (reminder);&#13;
                if (shiftReminder &gt; 128) shiftReminder = 128;&#13;
&#13;
                // How many bits to shift result left&#13;
                uint8 shiftResult = 128 - shiftReminder;&#13;
&#13;
                // How many bits to shift Y right&#13;
                uint8 shiftY = maxShiftY;&#13;
                if (shiftY &gt; shiftResult) shiftY = shiftResult;&#13;
&#13;
                shiftResult -= shiftY;&#13;
&#13;
                uint256 r = (reminder &lt;&lt; shiftReminder) / (((y - 1) &gt;&gt; shiftY) + 1);&#13;
&#13;
                uint8 msbR = mostSignificantBit (r);&#13;
                require (msbR &lt;= 255 - shiftResult);&#13;
&#13;
                result = safeAdd (result, r &lt;&lt; shiftResult);&#13;
            }&#13;
        }&#13;
&#13;
        return result;&#13;
    }&#13;
}&#13;
&#13;
&#13;
/**&#13;
 * Continuous Sale Action for selling PAT tokens.&#13;
 */&#13;
contract PATTokenSale is Math {&#13;
    /**&#13;
     * Time period when 15% bonus is in force.&#13;
     */&#13;
    uint256 private constant TRIPLE_BONUS = 1 hours;&#13;
&#13;
    /**&#13;
     * Time period when 10% bonus is in force.&#13;
     */&#13;
    uint256 private constant DOUBLE_BONUS = 1 days;&#13;
&#13;
    /**&#13;
     * Time period when 5% bonus is in force.&#13;
     */&#13;
    uint256 private constant SINGLE_BONUS = 1 weeks;&#13;
&#13;
    /**&#13;
     * Create PAT Token Sale smart contract with given sale start time, token&#13;
     * contract and central bank address.&#13;
     *&#13;
     * @param _saleStartTime sale start time&#13;
     * @param _saleDuration sale duration&#13;
     * @param _token ERC20 smart contract managing tokens to be sold&#13;
     * @param _centralBank central bank address to transfer tokens from&#13;
     * @param _saleCap maximum amount of ether to collect (in Wei)&#13;
     * @param _minimumInvestment minimum investment amount (in Wei)&#13;
     * @param _a parameter a of price formula&#13;
     * @param _b parameter b of price formula&#13;
     * @param _c parameter c of price formula&#13;
     */&#13;
    function PATTokenSale (&#13;
        uint256 _saleStartTime, uint256 _saleDuration,&#13;
        Token _token, address _centralBank,&#13;
        uint256 _saleCap, uint256 _minimumInvestment,&#13;
        int256 _a, int256 _b, int256 _c) {&#13;
        saleStartTime = _saleStartTime;&#13;
        saleDuration = _saleDuration;&#13;
        token = _token;&#13;
        centralBank = _centralBank;&#13;
        saleCap = _saleCap;&#13;
        minimumInvestment = _minimumInvestment;&#13;
        a = _a;&#13;
        b = _b;&#13;
        c = _c;&#13;
    }&#13;
&#13;
    /**&#13;
     * Equivalent to buy().&#13;
     */&#13;
    function () payable public {&#13;
        require (msg.data.length == 0);&#13;
&#13;
        buy ();&#13;
    }&#13;
&#13;
    /**&#13;
     * Buy tokens.&#13;
     */&#13;
    function buy () payable public {&#13;
        require (!finished);&#13;
        require (now &gt;= saleStartTime);&#13;
        require (now &lt; safeAdd (saleStartTime, saleDuration));&#13;
&#13;
        require (msg.value &gt;= minimumInvestment);&#13;
&#13;
        if (msg.value &gt; 0) {&#13;
            uint256 remainingCap = safeSub (saleCap, totalInvested);&#13;
            uint256 toInvest;&#13;
            uint256 toRefund;&#13;
&#13;
            if (msg.value &lt;= remainingCap) {&#13;
                toInvest = msg.value;&#13;
                toRefund = 0;&#13;
            } else {&#13;
                toInvest = remainingCap;&#13;
                toRefund = safeSub (msg.value, toInvest);&#13;
            }&#13;
&#13;
            Investor storage investor = investors [msg.sender];&#13;
            investor.amount = safeAdd (investor.amount, toInvest);&#13;
            if (now &lt; safeAdd (saleStartTime, TRIPLE_BONUS))&#13;
                investor.bonusAmount = safeAdd (&#13;
                    investor.bonusAmount, safeMul (toInvest, 6));&#13;
            else if (now &lt; safeAdd (saleStartTime, DOUBLE_BONUS))&#13;
                investor.bonusAmount = safeAdd (&#13;
                    investor.bonusAmount, safeMul (toInvest, 4));&#13;
            else if (now &lt; safeAdd (saleStartTime, SINGLE_BONUS))&#13;
                investor.bonusAmount = safeAdd (&#13;
                    investor.bonusAmount, safeMul (toInvest, 2));&#13;
&#13;
            Investment (msg.sender, toInvest);&#13;
&#13;
            totalInvested = safeAdd (totalInvested, toInvest);&#13;
            if (toInvest == remainingCap) {&#13;
                finished = true;&#13;
                finalPrice = price (now);&#13;
&#13;
                Finished (finalPrice);&#13;
            }&#13;
&#13;
            if (toRefund &gt; 0)&#13;
                msg.sender.transfer (toRefund);&#13;
        }&#13;
    }&#13;
&#13;
    /**&#13;
     * Buy tokens providing referral code.&#13;
     *&#13;
     * @param _referralCode referral code, actually address of referee&#13;
     */&#13;
    function buyReferral (address _referralCode) payable public {&#13;
        require (msg.sender != _referralCode);&#13;
&#13;
        Investor storage referee = investors [_referralCode];&#13;
&#13;
        // Make sure referee actually did invest something&#13;
        require (referee.amount &gt; 0);&#13;
&#13;
        Investor storage referrer = investors [msg.sender];&#13;
        uint256 oldAmount = referrer.amount;&#13;
&#13;
        buy ();&#13;
&#13;
        uint256 invested = safeSub (referrer.amount, oldAmount);&#13;
&#13;
        // Make sure referrer actually did invest something&#13;
        require (invested &gt; 0);&#13;
&#13;
        referee.investedByReferrers = safeAdd (&#13;
            referee.investedByReferrers, invested);&#13;
&#13;
        referrer.bonusAmount = safeAdd (&#13;
            referrer.bonusAmount,&#13;
            min (referee.amount, invested));&#13;
    }&#13;
&#13;
    /**&#13;
     * Get number of tokens to be delivered to given investor.&#13;
     *&#13;
     * @param _investor address of the investor to get number of tokens to be&#13;
     *        delivered to&#13;
     * @return number of tokens to be delivered to given investor&#13;
     */&#13;
    function outstandingTokens (address _investor)&#13;
    constant public returns (uint256) {&#13;
        require (finished);&#13;
        assert (finalPrice &gt; 0);&#13;
&#13;
        Investor storage investor = investors [_investor];&#13;
        uint256 bonusAmount = investor.bonusAmount;&#13;
        bonusAmount = safeAdd (&#13;
            bonusAmount, min (investor.amount, investor.investedByReferrers));&#13;
&#13;
        uint256 effectiveAmount = safeAdd (&#13;
            investor.amount,&#13;
            bonusAmount / 40);&#13;
&#13;
        return fpDiv (effectiveAmount, finalPrice);&#13;
    }&#13;
&#13;
    /**&#13;
     * Deliver purchased tokens to given investor.&#13;
     *&#13;
     * @param _investor investor to deliver purchased tokens to&#13;
     */&#13;
    function deliver (address _investor) public returns (bool) {&#13;
        require (finished);&#13;
&#13;
        Investor storage investor = investors [_investor];&#13;
        require (investor.amount &gt; 0);&#13;
&#13;
        uint256 value = outstandingTokens (_investor);&#13;
        if (value &gt; 0) {&#13;
            if (!token.transferFrom (centralBank, _investor, value)) return false;&#13;
        }&#13;
&#13;
        totalInvested = safeSub (totalInvested, investor.amount);&#13;
        investor.amount = 0;&#13;
        investor.bonusAmount = 0;&#13;
        investor.investedByReferrers = 0;&#13;
        return true;&#13;
    }&#13;
&#13;
    /**&#13;
     * Collect sale revenue.&#13;
     */&#13;
    function collectRevenue () public {&#13;
        require (msg.sender == centralBank);&#13;
&#13;
        centralBank.transfer (this.balance);&#13;
    }&#13;
&#13;
    /**&#13;
     * Return token price at given time in Wei per token natural unit.&#13;
     *&#13;
     * @param _time time to return price at&#13;
     * @return price at given time as 128.128 fixed point number&#13;
     */&#13;
    function price (uint256 _time) constant public returns (uint256) {&#13;
        require (_time &gt;= saleStartTime);&#13;
        require (_time &lt;= safeAdd (saleStartTime, saleDuration));&#13;
&#13;
        require (_time &lt;= TWO128_1);&#13;
        uint256 t = _time &lt;&lt; 128;&#13;
&#13;
        uint256 cPlusT = (c &gt;= 0) ?&#13;
        safeAdd (t, uint256 (c)) :&#13;
        safeSub (t, uint256 (-1 - c) + 1);&#13;
        int256 lnCPlusT = ln (cPlusT);&#13;
        int256 bLnCPlusT = fpMulI (b, lnCPlusT);&#13;
        int256 aPlusBLnCPlusT = safeAddI (a, bLnCPlusT);&#13;
&#13;
        require (aPlusBLnCPlusT &gt;= 0);&#13;
        return uint256 (aPlusBLnCPlusT);&#13;
    }&#13;
&#13;
    /**&#13;
     * Finish sale after sale period ended.&#13;
     */&#13;
    function finishSale () public {&#13;
        require (msg.sender == centralBank);&#13;
        require (!finished);&#13;
        uint256 saleEndTime = safeAdd (saleStartTime, saleDuration);&#13;
        require (now &gt;= saleEndTime);&#13;
&#13;
        finished = true;&#13;
        finalPrice = price (saleEndTime);&#13;
&#13;
        Finished (finalPrice);&#13;
    }&#13;
&#13;
    /**&#13;
     * Destroy smart contract.&#13;
     */&#13;
    function destroy () public {&#13;
        require (msg.sender == centralBank);&#13;
        require (finished);&#13;
        require (now &gt;= safeAdd (saleStartTime, saleDuration));&#13;
        require (totalInvested == 0);&#13;
        require (this.balance == 0);&#13;
&#13;
        selfdestruct (centralBank);&#13;
    }&#13;
&#13;
    /**&#13;
     * Return minimum of two values.&#13;
     *&#13;
     * @param x first value&#13;
     * @param y second value&#13;
     * @return minimum of two values&#13;
     */&#13;
    function min (uint256 x, uint256 y) internal pure returns (uint256) {&#13;
        return x &lt; y ? x : y;&#13;
    }&#13;
&#13;
    /**&#13;
     * Sale start time.&#13;
     */&#13;
    uint256 internal saleStartTime;&#13;
&#13;
    /**&#13;
     * Sale duration.&#13;
     */&#13;
    uint256 internal saleDuration;&#13;
&#13;
    /**&#13;
     * ERC20 token smart contract managing tokens to be sold.&#13;
     */&#13;
    Token internal token;&#13;
&#13;
    /**&#13;
     * Address of central bank to transfer tokens from.&#13;
     */&#13;
    address internal centralBank;&#13;
&#13;
    /**&#13;
     * Maximum number of Wei to collect.&#13;
     */&#13;
    uint256 internal saleCap;&#13;
&#13;
    /**&#13;
     * Minimum investment amount in Wei.&#13;
     */&#13;
    uint256 internal minimumInvestment;&#13;
&#13;
    /**&#13;
     * Price formula parameters.  Price at given time t is calculated as&#13;
     * a / 2^128 + b * ln ((c + t) / 2^128) / 2^128.&#13;
     */&#13;
    int256 internal a;&#13;
    int256 internal b;&#13;
    int256 internal c;&#13;
&#13;
    /**&#13;
     * True is sale was finished successfully, false otherwise.&#13;
     */&#13;
    bool internal finished = false;&#13;
&#13;
    /**&#13;
     * Final price for finished sale.&#13;
     */&#13;
    uint256 internal finalPrice;&#13;
&#13;
    /**&#13;
     * Maps investor's address to corresponding Investor structure.&#13;
     */&#13;
    mapping (address =&gt; Investor) internal investors;&#13;
&#13;
    /**&#13;
     * Total amount invested in Wei.&#13;
     */&#13;
    uint256 internal totalInvested = 0;&#13;
&#13;
    /**&#13;
     * Encapsulates information about investor.&#13;
     */&#13;
    struct Investor {&#13;
        /**&#13;
         * Total amount invested in Wei.&#13;
         */&#13;
        uint256 amount;&#13;
&#13;
        /**&#13;
         * Bonus amount in Wei multiplied by 40.&#13;
         */&#13;
        uint256 bonusAmount;&#13;
&#13;
        /**&#13;
         * Total amount of ether invested by others while referring this address.&#13;
         */&#13;
        uint256 investedByReferrers;&#13;
    }&#13;
&#13;
    /**&#13;
     * Logged when an investment was made.&#13;
     *&#13;
     * @param investor address of the investor who made the investment&#13;
     * @param amount investment amount&#13;
     */&#13;
    event Investment (address indexed investor, uint256 amount);&#13;
&#13;
    /**&#13;
     * Logged when sale finished successfully.&#13;
     *&#13;
     * @param finalPrice final price of the sale in Wei per token natural unit as&#13;
     *                   128.128 bit fixed point number.&#13;
     */&#13;
    event Finished (uint256 finalPrice);&#13;
}