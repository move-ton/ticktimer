pragma solidity >= 0.6.0;

contract secondC {
    function reverse() public {}
}


contract client {
    function _timer_handler(uint payload) public {}
}


contract first {
    struct MetaData { // Struct with necessary data to do callback
        uint payload;
        uint64 timeInt;
        address addr;
    }
    address secondAddress; // Address there is contract will be send message and raise error
    bool isRunning = false;
    uint lastBlockTimestamp = 0;
    MetaData[] binders; // Main array how contain data to callback

    function delMeta(uint index) internal {
        for (uint i = index; i + 1 < binders.length; ++i){
            binders[i] = binders[i + 1]; // Method from ArrayHelper example. Delete element by number
        }
        binders.pop();
    }

    modifier onlyOwnerAndAccept {
                require(msg.pubkey() == tvm.pubkey()); // Check owner
                tvm.accept();
                _;
        }

    function setCode(TvmCell newcode) public view onlyOwnerAndAccept {
                tvm.setcode(newcode);
                tvm.setCurrentCode(newcode);
        }

    function change_address(address _adr) public onlyOwnerAndAccept {
        // Test function
        secondAddress = _adr;
    }

    function createHandler(uint _payload,uint64 _time) public onlyOwnerAndAccept {
        // TODO check null sender
        //require(msg.sender != 0,100);
        MetaData obj;
        obj.addr = msg.sender;
        obj.payload = _payload;
        obj.timeInt = _time;
        binders.push(obj);
        if (isRunning == false) {
            secondC(secondAddress).reverse{value: 1 ton}();
        }
    }

    function createTimer(uint _payload,uint64 _time) public onlyOwnerAndAccept {
        // TODO check null sender
        //require(msg.sender != 0,100);
        MetaData obj;
        obj.addr = msg.sender;
        obj.payload = _payload;
        obj.timeInt = _time + now;
        binders.push(obj);
        if (isRunning == false) {
            secondC(secondAddress).reverse{value: 1 ton}();
        }
    }


    function changeIsRunning(bool _bool) public onlyOwnerAndAccept {
        // Test function
        isRunning = _bool;
    }

    function info() public returns (bool _isRunning, MetaData[] _metadata,uint _binders_count,bool isrunning) {
        // Get info about status
        return (isRunning,binders,binders.length,binders.length > 0);
    }


    function handler() public {
        // protection of gas leaking
        require(now > lastBlockTimestamp,101,"Double calling");
        lastBlockTimestamp = now;

        // Check owner
        if (msg.sender == secondAddress || msg.pubkey() == tvm.pubkey()) {
            tvm.accept();
        }

        // For loop to check all handlers
        for (uint i = 0; i < binders.length; i++) {

            if (binders[i].timeInt <= lastBlockTimestamp) {
                MetaData obj = binders[i]; // Save obj
                delMeta(i); // Delete element from handlers
                client(obj.addr)._timer_handler{value: 0,bounce: false}(obj.payload); // Send without bounce to protect gas leaking
            }
        }

        isRunning = binders.length > 0; // Check needing to work
        if (isRunning) {
            secondC(secondAddress).reverse{value: 1 ton}(); // Run another contract to run OnBounce throug one block (about 5 seconds in 0 workchain and about 0.2 in -1)
        }
    }


    onBounce(TvmSlice slice) external {
        handler(); // Handler to chceck timer
        // TODO Do check of function id
    }
}

