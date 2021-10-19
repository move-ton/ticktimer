import tonos_ts4.ts4 as ts4
import unittest
import time

EXCHANGER_COMMISSION = 3

class key:
    secret: str
    public: str
class TestPair(unittest.TestCase):
    secret = "bc891ad1f7dc0705db795a81761cf7ea0b74c9c2a93cbf9ac1bad8bd30c9b3b75a4889716084010dd2d013e48b366424c8ba9d391c867e46adce51b18718eb67"
    public = "0x5a4889716084010dd2d013e48b366424c8ba9d391c867e46adce51b18718eb67"
    def test_exchanger(self):
        ts4.reset_all() # reset all data
        ts4.init('./', verbose = True)
        key1 = ts4.make_keypair()
        self.public1 = key1[1]
        self.secret1 = key1[0]
        now = int(time.time())
        ts4.core.set_now(now)
        test = ts4.BaseContract('test',dict(),pubkey=self.public,private_key=self.secret,balance=150_000_000_000,nickname="test")
        now += 5
        ts4.core.set_now(now)
        main = ts4.BaseContract('main',dict(),pubkey=self.public,private_key=self.secret,balance=150_000_000_000,nickname="main")
        now += 5
        ts4.core.set_now(now)
        test.call_method("change_address",dict(_adr=main.addr),private_key=self.secret)
        now += 5
        ts4.core.set_now(now)
        test.call_method("createTimer",dict(_payload=1,_time=20),private_key=self.secret)
        
        while len(ts4.globals.QUEUE) > 0:
            now += 5
            ts4.core.set_now(now)
            ts4.dispatch_one_message()
        print(test.call_getter("results"))

if __name__ == '__main__':
    unittest.main()
