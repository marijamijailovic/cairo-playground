use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait};

use hello_sys_call::IENSSafeDispatcher;
use hello_sys_call::IENSSafeDispatcherTrait;
use hello_sys_call::IENSDispatcher;
use hello_sys_call::IENSDispatcherTrait;

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap();
    //deploy_syscall
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    contract_address
}

#[test]
fn test_increase_balance() {
    let contract_address = deploy_contract("ENS");

    // Create a Dispatcher object that will allow interacting with the deployed contract
    let dispatcher = IENSDispatcher { contract_address };

    let name_before = dispatcher.get_name("0xabc");
    assert(name_before == "0xabc", 'Invalid name');

    dispatcher.store_name("0xdef");

    let name_after = dispatcher.get_name("0xdef");
    assert(name_after == "0xdef", 'Invalid name');
}
