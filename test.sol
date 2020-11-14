pragma solidity >= 0.6.0;
pragma AbiHeader expire;

contract ticktimer {
    function startCallback(uint payload,uint32 timeInt)  public {}
}

contract test {
    uint count = 0;
    address callback;
    modifier onlyOwnerAndAccept {
        require(msg.pubkey() == tvm.pubkey());
        tvm.accept();
        _;
    }
    modifier alwaysAccept {
		// Runtime function that allows contract to process inbound messages spending
		// its own resources (it's necessary if contract should process all inbound messages,
		// not only those that carry value with them).
		tvm.accept();
		_;
	}
    function _callbackTimer(uint number) public{
        count = count + number;
    }
    function get() public onlyOwnerAndAccept returns(uint) {
        return count;
    }

    function setCode(TvmCell newcode) public view onlyOwnerAndAccept {
		// Runtime function that creates an output action that would change this
		// smart contract code to that given by cell newcode.
		tvm.setcode(newcode);
		// Runtime function that replaces current code of the contract with newcode.
		tvm.setCurrentCode(newcode);
	}

    function runCallback(uint payload,uint32 timeInt,address timeraddress) public alwaysAccept{
        ticktimer handler;
        handler = ticktimer(timeraddress);
        callback = timeraddress;
        handler.startCallback(payload,timeInt);
    }
}
