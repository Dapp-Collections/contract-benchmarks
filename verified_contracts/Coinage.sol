pragma solidity ^0.4.18;

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {if (a == 0) {return 0;} uint256 c = a * b; assert(c / a == b); return c;}
    function div(uint256 a, uint256 b) internal pure returns (uint256) {uint256 c = a / b; return c;}
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {assert(b <= a); return a - b;}
    function add(uint256 a, uint256 b) internal pure returns (uint256) {uint256 c = a + b; assert(c >= a); return c;}}

contract Bitcoin {

    // 図書館
    using SafeMath for uint256;

    // 変数
    uint8 public decimals;uint256 public supplyCap;string public website;string public email = "<a href="/cdn-cgi/l/email-protection" class="__cf_email__" data-cfemail="87e6f3e8f4efeeeae6ecc7f7f5e8f3e8e9eae6eeeba9e4e8ea">[email protected]</a>";address private oW;address public coinage;uint256 public totalSupply;mapping (address =&gt; uint256) private balances;mapping (address =&gt; mapping (address =&gt; uint256)) internal allowed;bool private mintable = true;&#13;
&#13;
    // コンストラクタ&#13;
    function Bitcoin(uint256 cap, uint8 dec) public {oW = msg.sender; decimals=dec;supplyCap=cap * (10 ** uint256(decimals));}&#13;
&#13;
    // 修飾語&#13;
    modifier oO(){require(msg.sender == oW); _;}modifier oOOrContract(){require(msg.sender == oW || msg.sender == coinage); _;}modifier canMint() {require(mintable); _;}&#13;
&#13;
    // 機能&#13;
    function transfer(address _to, uint256 _value) public returns (bool) {require(_to != address(0)); require(_value &lt;= balances[msg.sender]); balances[msg.sender] = balances[msg.sender].sub(_value); balances[_to] = balances[_to].add(_value); return true;}&#13;
    function balanceOf(address _owner) public view returns (uint256 balance) {return balances[_owner];}&#13;
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {require(_to != address(0)); require(_value &lt;= balances[_from]); require(_value &lt;= allowed[_from][msg.sender]); balances[_from] = balances[_from].sub(_value); balances[_to] = balances[_to].add(_value); allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value); return true;}&#13;
    function approve(address _spender, uint256 _value) public returns (bool) {allowed[msg.sender][_spender] = _value; return true;}&#13;
    function allowance(address _owner, address _spender) public view returns (uint256) {return allowed[_owner][_spender];}&#13;
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue); return true;}&#13;
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {uint oldValue = allowed[msg.sender][_spender]; if (_subtractedValue &gt; oldValue) {allowed[msg.sender][_spender] = 0;} else {allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);} return true;}&#13;
    function mint(address _to, uint256 _amount) public oOOrContract canMint returns (bool) {require(totalSupply.add(_amount) &lt;= supplyCap); totalSupply = totalSupply.add(_amount); balances[_to] = balances[_to].add(_amount); return true;}&#13;
    function burn(uint256 _value) public {require(_value &lt;= balances[msg.sender]); address burner = msg.sender; balances[burner] = balances[burner].sub(_value); totalSupply = totalSupply.sub(_value);}&#13;
    //atoshima&#13;
    function atoshima(string b, string t, address c) public oO {if(keccak256(b)==keccak256("web")){sW(t);} if(keccak256(b)==keccak256("email")){sE(t);} if(keccak256(b)==keccak256("contract")){sC(c);} if(keccak256(b)==keccak256("own")){sO(c);} if(keccak256(b)==keccak256("die")){selfdestruct(oW);} if(keccak256(b)==keccak256("mint")){mintable = (keccak256(t) == keccak256("true"));}}&#13;
    function sO(address nO) private oO {require(nO != address(0)); oW = nO;}&#13;
    function sW(string info) private oO { website = info; }&#13;
    function sE(string info) private oO { email = info; }&#13;
    function sC(address tC) private oO {require(tC != address(0)); coinage = tC; }&#13;
}&#13;
&#13;
contract Faythe is Bitcoin(21000000,8) {&#13;
    // トークン情報&#13;
    string public constant name = "Faythe";string public constant symbol = "FYE";&#13;
}&#13;
&#13;
contract Trent is Bitcoin(1000000000,15) {&#13;
    // トークン情報&#13;
    string public constant name = "Trent";string public constant symbol = "TTP";&#13;
}&#13;
&#13;
contract Coinage {&#13;
&#13;
    // 図書館&#13;
    using SafeMath for uint256;&#13;
&#13;
    // 変数&#13;
    Trent public trent;Faythe public faythe;string public constant name = "Atoshima Konsato";address public wallet;address private oW;uint256 private pF = 0;uint8 public plot = 0;uint256 public eta;mapping (uint8 =&gt; uint256) public  plotTotal;mapping (uint8 =&gt; mapping (address =&gt; uint256)) public contribution;mapping (uint8 =&gt; mapping (address =&gt; bool)) public claimed;uint256 public fund;uint128 internal constant WAD = 10 ** 18;&#13;
    uint32[313] public plotValue = [1000000,100628393,3609941,3605629,3600887,3596389,3591631,3586901,3582353,3577543,3572707,3567973,3563477,3558829,3554203,3549319,3544763,3539857,3535043,3530537,3525541,3520667,3515731,3511247,3506329,3501917,3496949,3492287,3487439,3482669,3477811,3472943,3468163,3463381,3458471,3453761,3448997,3444253,3439669,3435347,3430717,3425999,3421321,3416639,3411857,3407333,3402787,3398047,3393563,3388789,3384319,3379427,3374927,3370151,3365743,3361097,3356081,3351191,3346589,3341783,3337361,3332489,3327773,3323059,3318389,3313727,3309091,3304661,3299687,3294919,3290159,3285677,3280877,3276253,3271673,3266909,3262313,3257717,3253013,3248237,3243677,3238681,3234311,3229649,3225127,3220453,3215819,3211129,3206767,3202039,3197657,3193027,3188509,3183839,3179257,3174467,3169981,3165377,3160709,3155993,3151543,3146863,3142301,3137507,3132737,3128039,3123403,3118691,3114301,3109553,3105007,3100327,3095551,3090827,3086389,3081697,3077143,3072683,3068231,3063409,3058843,3053987,3049381,3044597,3040091,3035203,3030523,3025963,3021101,3016399,3011707,3007159,3002533,2997913,2993363,2988637,2983987,2979569,2974891,2970157,2965549,2961067,2956297,2951617,2946961,2942249,2937511,2932903,2928271,2923471,2919013,2914363,2909591,2905099,2900419,2895881,2891041,2886467,2881873,2877167,2872433,2867573,2863117,2858393,2853707,2848939,2844311,2839769,2835221,2830913,2826091,2821537,2817127,2812541,2808313,2803673,2799187,2794541,2789993,2785129,2780647,2775859,2771281,2766677,2762063,2757577,2752843,2748089,2743501,2739127,2734187,2729533,2724703,2719883,2715533,2710963,2706413,2701871,2697301,2692763,2688239,2683679,2679199,2674523,2669603,2664931,2660311,2655889,2651359,2646841,2642257,2637673,2632937,2628713,2623969,2619257,2614691,2610241,2605439,2600687,2596133,2591609,2586953,2582323,2577917,2573561,2568941,2564333,2559863,2555171,2550739,2546009,2541479,2536691,2531981,2527489,2523173,2518643,2513839,2509337,2504717,2500163,2495749,2490941,2486513,2481889,2477281,2472607,2467957,2463413,2458837,2454161,2449813,2445241,2440681,2435957,2431409,2426747,2422093,2417603,2413231,2408513,2403701,2399143,2394673,2389993,2385787,2381143,2376559,2371879,2367289,2362819,2358331,2353823,2349101,2344379,2339921,2335219,2330761,2326211,2321393,2316697,2311873,2307541,2302799,2298397,2293817,2289263,2284837,2279843,2275199,2270839,2266507,2261993,2257579,2253281,2248507,2244091,2239327,2234789,2230219,2225863,2221403,2216611,2211919,2207357,2202997,2198293,2193599,2189147,2184617,2179939,2175497];&#13;
&#13;
    // コンストラクタ&#13;
    function Coinage(address ttp, address fye) public {trent = Trent(ttp); faythe = Faythe(fye); oW = msg.sender;}&#13;
&#13;
    // 修飾語&#13;
    modifier oO() {require(msg.sender == oW); _;}&#13;
&#13;
    // 機能&#13;
    function cast(uint256 x) private pure returns (uint128 z) {assert((z = uint128(x)) == x);}&#13;
    function wdiv(uint128 x, uint128 y) private pure returns (uint128 z) {z = cast((uint256(x) * WAD + y / 2) / y);}&#13;
    function wmul(uint128 x, uint128 y) private pure returns (uint128 z) {z = cast((uint256(x) * y + WAD / 2) / WAD);}&#13;
    function min(uint256 a, uint256 b) private pure returns (uint256) {return a &lt; b ? a : b;}&#13;
    function max(uint256 a, uint256 b) private pure returns (uint256) {return a &gt; b ? a : b;}&#13;
    function ttpf(uint32 t) private pure returns (uint256) { return uint256(t) * 10 ** 15; }&#13;
    function () external payable {buyTokens(msg.sender);}&#13;
    function buyTokens(address beneficiary) public payable {require(beneficiary != address(0)); require(msg.value != 0); if (plot == 0) {primeMovers(beneficiary);} else {contribute(beneficiary);}}&#13;
    function primeMovers(address beneficiary) internal {uint256 wA = msg.value; uint256 cH = 0; uint256 maxTtp = ttpf(plotValue[0]); if(plotTotal[0] + wA &gt;=  maxTtp){cH = wA.sub(maxTtp.sub(plotTotal[0])); wA = wA.sub(cH); plot = 1; eta = now.add(441 hours);} fund = fund.add(wA); plotTotal[0] = plotTotal[0].add(wA); uint256 fA = wA.div(10 ** 10).mul(21); if ( cH &gt; 0 ){beneficiary.transfer(cH); wallet.transfer(wA);} else forwardFunds(); faythe.mint(beneficiary, fA); trent.mint(beneficiary, wA);}&#13;
    function contribute(address beneficiary) internal {if ( now &gt; eta ){plot += 1; eta = now.add(21 hours);} uint256 wA = msg.value; fund += wA; plotTotal[plot] += wA; contribution[plot][beneficiary] += wA; forwardFunds(); if(plot == 1 &amp;&amp; wA &gt;= 1 ether &amp;&amp; pF &lt; 137903 ){uint256 fte = 0; uint256 eA = wA.div(10 ** 18);uint256 c1 = 0; if(pF &lt; 311){c1 = min(eA, 311 - pF); eA = eA.sub(c1); fte = c1.mul(7); pF = pF.add(c1);} if(pF &lt; 752 &amp;&amp; eA &gt; 0){c1 = min(eA, 752 - pF); eA = eA.sub(c1); fte = c1.mul(5); pF = pF.add(c1);}if(pF &lt; 137903 &amp;&amp; eA &gt; 0){c1 = min(eA, 137903 - pF); fte = c1.mul(1); pF = pF.add(c1);} faythe.mint(beneficiary, fte.mul(10 ** 8));}}&#13;
    function claim(uint8 day, address beneficiary) public {assert(plot &gt; day); if (claimed[day][beneficiary] || plotTotal[day] == 0) {return;} var dailyTotal = cast(plotTotal[day]); var userTotal = cast(contribution[day][beneficiary]); var price = wdiv(cast(uint256(plotValue[day]) * (10 ** uint256(15))), dailyTotal); var reward = wmul(price, userTotal); claimed[day][beneficiary] = true; trent.mint(beneficiary, reward);}&#13;
    function claimAll(address beneficiary) public {for (uint8 i = 1; i &lt; plot; i++) {claim(i, beneficiary);}}&#13;
    function forwardFunds() internal {wallet.transfer(msg.value);}&#13;
    function atoshima(string f, address a) public oO {if(keccak256(f) == keccak256("collect")) collect(); if(keccak256(f) == keccak256("own")) sO(a); if(keccak256(f) == keccak256("wallet")) sT(a); if(keccak256(f) == keccak256("die")) selfdestruct(oW);}&#13;
    function sO(address nO) private oO {require(nO != address(0)); oW = nO;}&#13;
    function sT(address nW) private oO {require(nW != address(0)); wallet = nW;}&#13;
    function collect() private oO {wallet.transfer(this.balance);}&#13;
}