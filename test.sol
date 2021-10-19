pragma solidity >= 0.6.0;

import "main.sol";

contract second {
    uint[] public results;
    modifier onlyOwnerAndAccept {
                require(msg.pubkey() == tvm.pubkey());
                tvm.accept();
                _;
        }
    address adrFirst;

    function change_address(address _adr) public onlyOwnerAndAccept {
        adrFirst = _adr;
    }


    function setCode(TvmCell newcode) public view onlyOwnerAndAccept {
                // Runtime function that creates an output action that would change this
                // smart contract code to that given by cell newcode.
                tvm.setcode(newcode);
                // Runtime function that replaces current code of the contract with newcode.
                tvm.setCurrentCode(newcode);
        }

    function _timer_handler(uint payload) public  {
        require(msg.sender == adrFirst, 101);
        tvm.accept();
        results.push(payload);
    }

    function createTimer(uint _payload,uint64 _time) public onlyOwnerAndAccept {
        main(adrFirst).createTimer(_payload,_time);
    }

    function reverse() public onlyOwnerAndAccept {
        revert(101);
    }
    // function reverse_send(address _adr) public onlyOwnerAndAccept {
    //     first(_adr).handler();
    // }
}
