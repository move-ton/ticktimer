pragma solidity >= 0.6.0;
pragma AbiHeader expire;

contract callbackContract {
    function _callbackTimer(uint number) public {}
}

contract ticktimer {
    address owner;

    modifier onlyOwnerAndAccept {
        require(msg.pubkey() == tvm.pubkey());
        tvm.accept();
        _;
    }
    constructor() public onlyOwnerAndAccept {owner = msg.sender; }


    function setCode(TvmCell newcode) public view onlyOwnerAndAccept {
		// Runtime function that creates an output action that would change this
		// smart contract code to that given by cell newcode.
		tvm.setcode(newcode);
		// Runtime function that replaces current code of the contract with newcode.
		tvm.setCurrentCode(newcode);
	}

    function add(uint a,uint b) public returns (uint) {
        return a + b;
    }
    address addressAnotherContract;

    function changeAddressContract(address _addressAnotherContract) public onlyOwnerAndAccept {
        addressAnotherContract = _addressAnotherContract;
    }

    function getAddressContract() public view returns (address){
        return addressAnotherContract;
    }

    function startCallback(uint payload,uint64 timeInt) public {
        require(msg.sender == owner);
        tvm.accept();
        ticktimer sender;
        sender = ticktimer(addressAnotherContract);
        sender._callback(payload,timeInt);
    }

    function _callback(uint payload,uint64 timeInt) public {
        require(msg.sender == addressAnotherContract);
        tvm.accept();
        if (timeInt <= now) {
            callbackContract handler;
            handler = callbackContract(owner);
            handler._callbackTimer(payload);
        } else {
            ticktimer sender;
            sender = ticktimer(addressAnotherContract);
            sender._callback(payload,timeInt);
        }
    }
    
    function _get_time() public onlyOwnerAndAccept returns (uint32 nowtime) {
        return now;
    }
}

