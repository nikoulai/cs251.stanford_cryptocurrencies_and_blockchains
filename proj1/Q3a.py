from sys import exit
from bitcoin.core.script import *
from bitcoin.wallet import CBitcoinSecret

from lib.utils import *
from lib.config import (my_private_key, my_public_key, my_address,
                    faucet_address, network_type)
from Q1 import send_from_P2PKH_transaction


cust1_private_key = CBitcoinSecret(
    'cR7hEw1f3bb5KVqXbMDWuz1iao9Anarr4pPsHPwaZUnDKFcjcvTL')
cust1_public_key = cust1_private_key.pub
cust2_private_key = CBitcoinSecret(
    'cTAE8uDF44u4BGMXB5bDj2YtL9yhaWyrFAHhKM2pwAx7ryTwQJBr')
cust2_public_key = cust2_private_key.pub
cust3_private_key = CBitcoinSecret(
    'cNad68vVN6ENwacVgwE9jQbgiRDkGkja68D6Kr6PSaH196WFhmpS')
cust3_public_key = cust3_private_key.pub


######################################################################
# TODO: Complete the scriptPubKey implementation for Exercise 3

# You can assume the role of the bank for the purposes of this problem
# and use my_public_key and my_private_key in lieu of bank_public_key and
# bank_private_key.

Q3a_txout_scriptPubKey = [
        # fill this in!
        my_public_key,
        OP_CHECKSIGVERIFY,
        1,
        cust1_public_key,
        cust2_public_key,
        cust3_public_key,
        3,
        OP_CHECKMULTISIG
]
######################################################################

if __name__ == '__main__':
    ######################################################################
    # TODO: set these parameters correctly
    amount_to_send = 0.000004 # amount of BTC in the output you're sending minus fee
    txid_to_spend = (
        '32d34fa4535cc39ce2edb6fe271205a2a59c78b9006fda92b0b376ceb831c5fb')
    utxo_index = 5 # index of the output you are spending, indices start at 0
    ######################################################################

    response = send_from_P2PKH_transaction(amount_to_send, txid_to_spend,
        utxo_index, Q3a_txout_scriptPubKey, my_private_key, network_type)
    print(response.status_code, response.reason)
    print(response.text)
