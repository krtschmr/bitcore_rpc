# BitcoreRPC

##### PULL REQUESTS WELCOME!

Connect to the Bitcoin RPC or any of its kind (every BTC fork is supported)

## Installation

use latest master

    gem "bitcore_rpc", github: "krtschmr/bitcore_rpc"

Always develop in testnet! Please! (default is `:testnet`)

## General Usage

If you want, you can create custom classes

    class BitcoinRPC < BitcoreRPC; end
    class BitcoinCashRPC < BitcoreRPC; end
    class DashRPC < BitcoreRPC; end
    class LitecoinRPC < BitcoreRPC; end

### Usage is super easy!

    $bitcoin_rpc = BitcoireRPC.new(user: "test", password: "myPazzwortz")
    $litecoin_rpc = LitecoinRPC.new(user: "test", password: "swag", host: "myhost", debug: true)

### call any method you want

    $bitcoin_rpc.getnewaddress "myaddress", "bech32"

### Error handling
if a method isn't know it throws an error

    BitcoreRPC::ResponseError: Method not found (-32601)

    # if RPC throws error, error will be printed with error code
    # if RPC can't be reached, it throws ConnectionError, if wrong auth it gets Unauthenticated


### useful stuff
    # get_transactions ist alias method for listtransactions and accepts regular parameters

    $bitcoin_rpc.get_transactions.each do |tx|
      tx_id = tx["txid"]
      address = tx["address"]
      amount = tx["amount"]
      confirmations = tx["confirmations"]  
      # do something
    end

Please fork and contribute



MIT License
