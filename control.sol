pragma solidity >= 0.6.0;
pragma AbiHeader expire;

import "ticktimer.sol";

//contract ticktimer {
//    function setCode(TvmCell newcode) public view {}
//    function startCallback(uint payload,uint32 timeInt) public {}
//}

//contract callbackContract {
//    function _callbackTimer(uint32 number) public {}
//}

contract control {
    struct metaData {
        address adr;
        uint32 payload;
    }
    bool isDeployd = false;
    address owner;
    address contract1;
    address contract2;
    metaData[] binders;
    uint32 count; // for test
    modifier checkOwnerAndAccept {
        // Check that inbound message was signed with owner's public key.
        // Runtime function that obtains sender's public key.
        require(msg.pubkey() == tvm.pubkey(), 100);

        // Runtime function that allows contract to process inbound messages spending
        // its own resources (it's necessary if contract should process all inbound messages,
        // not only those that carry value with them).
        tvm.accept();
        _;
    }


    function getAddresses() public checkContractDeployed view returns (address _contract1, address _contract2) {
        return (contract1,contract2);
    }

    function setAddresses(address _contract1, address _contract2) public checkOwnerAndAccept {
        contract1 = _contract1;
        contract2 = _contract2;
    }

    function getBinders() public checkOwnerAndAccept returns (metaData[] _binders){
        return binders;
    }

    function setCode(TvmCell newcode) public view checkOwnerAndAccept {
		// Runtime function that creates an output action that would change this
		// smart contract code to that given by cell newcode.
		tvm.setcode(newcode);
		// Runtime function that replaces current code of the contract with newcode.
		tvm.setCurrentCode(newcode);
	}
    function deployContract1(TvmCell code,TvmCell data,uint128 initialBalance) public checkOwnerAndAccept {
        TvmCell stateInit = tvm.buildStateInit(code, data);
        contract1 = new ticktimer{stateInit: stateInit, value: initialBalance}();
    }

    function deployContract2(TvmCell code,TvmCell data,uint128 initialBalance) public checkOwnerAndAccept {
        TvmCell stateInit1 = tvm.buildStateInit(code, data);
        contract2 = new ticktimer{stateInit: stateInit1, value: initialBalance}();
    }

    function updateTimersCode(TvmCell newcode) public checkOwnerAndAccept {
        ticktimer(contract1).setCode(newcode);
        ticktimer(contract2).setCode(newcode);
    }

    function createHandler(uint32 payload,uint64 timeint) public checkOwnerAndAccept {
        uint id = binders.length;
        binders.push(metaData(msg.sender,payload));
        ticktimer(contract1).startCallback(id,timeint);
    }

    function getCount() public view returns (uint32 _count) {
        return count;
    }

    function _callbackTimer(uint number) public {
        require(tvm.pubkey() != 0,100,"401 Unauthorized");
        require(msg.sender == contract1 || msg.sender == contract2,100,"403 Forbidden");
        tvm.accept();
        (address adr,uint payload) = binders[number].unpack();
        callbackContract(adr)._callbackTimer(payload);
        count++; // for test
    }
}
