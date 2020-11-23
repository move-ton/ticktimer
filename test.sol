pragma solidity >= 0.6.0;

import "main.sol";

contract second {
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

    function reverse() public onlyOwnerAndAccept {
        revert(101);
    }
        function reverse_send(address _adr) public onlyOwnerAndAccept {
        first(_adr).handler();
    }
}
