pragma solidity ^0.4.16;

// copyright <span class="__cf_email__" data-cfemail="16757978627775625653627e7364737b79783875797b">[email protected]</span>&#13;
&#13;
contract SafeMath {&#13;
&#13;
    /* function assert(bool assertion) internal { */&#13;
    /*   if (!assertion) { */&#13;
    /*     throw; */&#13;
    /*   } */&#13;
    /* }      // assert no longer needed once solidity is on 0.4.10 */&#13;
&#13;
    function safeAdd(uint256 x, uint256 y) pure internal returns(uint256) {&#13;
      uint256 z = x + y;&#13;
      assert((z &gt;= x) &amp;&amp; (z &gt;= y));&#13;
      return z;&#13;
    }&#13;
&#13;
    function safeSubtract(uint256 x, uint256 y) pure internal returns(uint256) {&#13;
      assert(x &gt;= y);&#13;
      uint256 z = x - y;&#13;
      return z;&#13;
    }&#13;
&#13;
    function safeMult(uint256 x, uint256 y) pure internal returns(uint256) {&#13;
      uint256 z = x * y;&#13;
      assert((x == 0)||(z/x == y));&#13;
      return z;&#13;
    }&#13;
&#13;
}&#13;
&#13;
contract BasicAccessControl {&#13;
    address public owner;&#13;
    // address[] public moderators;&#13;
    uint16 public totalModerators = 0;&#13;
    mapping (address =&gt; bool) public moderators;&#13;
    bool public isMaintaining = true;&#13;
&#13;
    function BasicAccessControl() public {&#13;
        owner = msg.sender;&#13;
    }&#13;
&#13;
    modifier onlyOwner {&#13;
        require(msg.sender == owner);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier onlyModerators() {&#13;
        require(moderators[msg.sender] == true);&#13;
        _;&#13;
    }&#13;
&#13;
    modifier isActive {&#13;
        require(!isMaintaining);&#13;
        _;&#13;
    }&#13;
&#13;
    function ChangeOwner(address _newOwner) onlyOwner public {&#13;
        if (_newOwner != address(0)) {&#13;
            owner = _newOwner;&#13;
        }&#13;
    }&#13;
&#13;
&#13;
    function AddModerator(address _newModerator) onlyOwner public {&#13;
        if (moderators[_newModerator] == false) {&#13;
            moderators[_newModerator] = true;&#13;
            totalModerators += 1;&#13;
        }&#13;
    }&#13;
    &#13;
    function RemoveModerator(address _oldModerator) onlyOwner public {&#13;
        if (moderators[_oldModerator] == true) {&#13;
            moderators[_oldModerator] = false;&#13;
            totalModerators -= 1;&#13;
        }&#13;
    }&#13;
&#13;
    function UpdateMaintaining(bool _isMaintaining) onlyOwner public {&#13;
        isMaintaining = _isMaintaining;&#13;
    }&#13;
}&#13;
&#13;
contract EtheremonEnum {&#13;
&#13;
    enum ResultCode {&#13;
        SUCCESS,&#13;
        ERROR_CLASS_NOT_FOUND,&#13;
        ERROR_LOW_BALANCE,&#13;
        ERROR_SEND_FAIL,&#13;
        ERROR_NOT_TRAINER,&#13;
        ERROR_NOT_ENOUGH_MONEY,&#13;
        ERROR_INVALID_AMOUNT,&#13;
        ERROR_OBJ_NOT_FOUND,&#13;
        ERROR_OBJ_INVALID_OWNERSHIP&#13;
    }&#13;
    &#13;
    enum ArrayType {&#13;
        CLASS_TYPE,&#13;
        STAT_STEP,&#13;
        STAT_START,&#13;
        STAT_BASE,&#13;
        OBJ_SKILL&#13;
    }&#13;
&#13;
    enum PropertyType {&#13;
        ANCESTOR,&#13;
        XFACTOR&#13;
    }&#13;
}&#13;
&#13;
contract EtheremonDataBase is EtheremonEnum, BasicAccessControl, SafeMath {&#13;
    &#13;
    uint64 public totalMonster;&#13;
    uint32 public totalClass;&#13;
    &#13;
    // read&#13;
    function getSizeArrayType(ArrayType _type, uint64 _id) constant public returns(uint);&#13;
    function getElementInArrayType(ArrayType _type, uint64 _id, uint _index) constant public returns(uint8);&#13;
    function getMonsterClass(uint32 _classId) constant public returns(uint32 classId, uint256 price, uint256 returnPrice, uint32 total, bool catchable);&#13;
    function getMonsterObj(uint64 _objId) constant public returns(uint64 objId, uint32 classId, address trainer, uint32 exp, uint32 createIndex, uint32 lastClaimIndex, uint createTime);&#13;
    function getMonsterName(uint64 _objId) constant public returns(string name);&#13;
    function getExtraBalance(address _trainer) constant public returns(uint256);&#13;
    function getMonsterDexSize(address _trainer) constant public returns(uint);&#13;
    function getMonsterObjId(address _trainer, uint index) constant public returns(uint64);&#13;
    function getExpectedBalance(address _trainer) constant public returns(uint256);&#13;
    function getMonsterReturn(uint64 _objId) constant public returns(uint256 current, uint256 total);&#13;
}&#13;
&#13;
contract EtheremonBattle is EtheremonEnum, BasicAccessControl, SafeMath {&#13;
    uint8 constant public NO_MONSTER = 3;&#13;
    uint8 constant public STAT_COUNT = 6;&#13;
    uint8 constant public GEN0_NO = 24;&#13;
&#13;
    struct MonsterClassAcc {&#13;
        uint32 classId;&#13;
        uint256 price;&#13;
        uint256 returnPrice;&#13;
        uint32 total;&#13;
        bool catchable;&#13;
    }&#13;
&#13;
    struct MonsterObjAcc {&#13;
        uint64 monsterId;&#13;
        uint32 classId;&#13;
        address trainer;&#13;
        string name;&#13;
        uint32 exp;&#13;
        uint32 createIndex;&#13;
        uint32 lastClaimIndex;&#13;
        uint createTime;&#13;
    } &#13;
    &#13;
    uint8 public maxLevel = 100;&#13;
    &#13;
    // linked smart contract&#13;
    address public dataContract;&#13;
    &#13;
    // modifier&#13;
    modifier requireDataContract {&#13;
        require(dataContract != address(0));&#13;
        _;&#13;
    }&#13;
&#13;
    function EtheremonBattle(address _dataContract) public {&#13;
        dataContract = _dataContract;&#13;
    }&#13;
     &#13;
    &#13;
    function setContract(address _dataContract) onlyModerators external {&#13;
        dataContract = _dataContract;&#13;
    }&#13;
    &#13;
    // public &#13;
    &#13;
    function getLevel(uint32 exp) view public returns (uint8) {&#13;
        uint8 level = 1;&#13;
        uint32 requirement = maxLevel;&#13;
        while(level &lt; maxLevel &amp;&amp; exp &gt; requirement) {&#13;
            exp -= requirement;&#13;
            level += 1;&#13;
            requirement = requirement * 11 / 10 + 5;&#13;
        }&#13;
        return level;&#13;
    }&#13;
&#13;
    &#13;
    function getMonsterLevel(uint64 _objId) constant external returns(uint32, uint8) {&#13;
        EtheremonDataBase data = EtheremonDataBase(dataContract);&#13;
        MonsterObjAcc memory obj;&#13;
        uint32 _ = 0;&#13;
        (obj.monsterId, obj.classId, obj.trainer, obj.exp, _, _, obj.createTime) = data.getMonsterObj(_objId);&#13;
     &#13;
        return (obj.exp, getLevel(obj.exp));&#13;
    }&#13;
    &#13;
    function getMonsterCP(uint64 _objId) constant external returns(uint64) {&#13;
        uint16[6] memory stats;&#13;
        uint32 classId = 0;&#13;
        uint32 exp = 0;&#13;
        (classId, exp, stats) = getCurrentStats(_objId);&#13;
        &#13;
        uint256 total;&#13;
        for(uint i=0; i &lt; STAT_COUNT; i+=1) {&#13;
            total += stats[i];&#13;
        }&#13;
        return uint64(total/STAT_COUNT);&#13;
    }&#13;
&#13;
    function getObjExp(uint64 _objId) constant public returns(uint32, uint32) {&#13;
        EtheremonDataBase data = EtheremonDataBase(dataContract);&#13;
        MonsterObjAcc memory obj;&#13;
        uint32 _ = 0;&#13;
        (_objId, obj.classId, obj.trainer, obj.exp, _, _, obj.createTime) = data.getMonsterObj(_objId);&#13;
        return (obj.classId, obj.exp);&#13;
    }    &#13;
    &#13;
    function getCurrentStats(uint64 _objId) constant public returns(uint32, uint32, uint16[6]){&#13;
        EtheremonDataBase data = EtheremonDataBase(dataContract);&#13;
        uint16[6] memory stats;&#13;
        uint32 classId;&#13;
        uint32 exp;&#13;
        (classId, exp) = getObjExp(_objId);&#13;
        if (classId == 0)&#13;
            return (classId, exp, stats);&#13;
        &#13;
        uint i = 0;&#13;
        uint8 level = getLevel(exp);&#13;
        uint baseSize = data.getSizeArrayType(ArrayType.STAT_BASE, _objId);&#13;
        if (baseSize != STAT_COUNT) {&#13;
            for(i=0; i &lt; STAT_COUNT; i+=1) {&#13;
                stats[i] += data.getElementInArrayType(ArrayType.STAT_START, uint64(classId), i);&#13;
                stats[i] += uint16(safeMult(data.getElementInArrayType(ArrayType.STAT_STEP, uint64(classId), i), level));&#13;
            }&#13;
        } else {&#13;
            for(i=0; i &lt; STAT_COUNT; i+=1) {&#13;
                stats[i] += data.getElementInArrayType(ArrayType.STAT_BASE, _objId, i);&#13;
                stats[i] += uint16(safeMult(data.getElementInArrayType(ArrayType.STAT_STEP, uint64(classId), i), level));&#13;
            }&#13;
        }&#13;
        return (classId, exp, stats);&#13;
    }&#13;
 &#13;
}