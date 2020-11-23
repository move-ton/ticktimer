This repository for freeton [contest](https://devex.gov.freeton.org/proposal?proposalAddress=0:91ea1dcdfbaa2d9f869e07a04516addd8752eecd307157e8d4012e1a934094be) for running this contract you need: [solc](https://github.com/tonlabs/TON-Solidity-Compiler), [tvm_linker](https://github.com/tonlabs/TVM-linker), [tonos-cli](https://github.com/tonlabs/tonos-cli)

## Deploy

##### Compile contract:
```bash
solc main.sol
```

##### Compile in tvc:
```bash
tvm_linker compile --lib stdlib_sol.tvm --abi-json main.abi.json main.code
```

##### Generate address
```bash
tonos-cli genaddr <main>.tvc main.abi.json --genkey timer.keys.json
```

##### Send some crystal there or use giver

##### Use it! 
```bash
tonos-cli call <address> createTimer '{"_payload":"<payload in int64>","_time":<time in seconds>}' --abi main.abi.json --sign timer.keys.json
``` 

or 

```bash 
tonos-cli call <address> createHandler '{"_payload":"<payload in int64>","_time":<time in seconds>}' --abi main.abi.json --sign timer.keys.json
```

## Are there any differences between createTimer and createHandler?

Yes, createTimer create handler nowtime + your time. Its useful for users. And createHandler set only your time.

## How connect this library to my contract?

Its simple. You can watch the test.sol

##### First you need create contract interface
```solidity
contract timer {
    function createHandler(uint _payload,uint64 _time) public {}
    function createTimer(uint _payload,uint64 _time) public {}
}
```
##### More you need to save address of timer in contract

```solidity
address timerAddress;
``` 

##### and set this address through the function for example changeAddress

```solidity
function changeAddress(address _adr) public onlyOwnerAndAccept {
    timerAddress = _adr;
}
```

##### Then you need to create handler there will be sending from timer

```solidity
function _timer_handler(uint payload) public {
    require(timerAddress == msg.sender,100,'Unauthorized');
    <Your code>
}
```

##### And start timer

```solidity
timer(timerAddress).createTimer(100,60);
```

You can use payload to diffent things, for instance delay send.

By commaster1

