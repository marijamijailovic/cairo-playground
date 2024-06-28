use starknet::ContractAddress;

use snforge_std::{declare, ContractClassTrait};

use hello_sys_call::IENSSafeDispatcher;
use hello_sys_call::IENSSafeDispatcherTrait;
use hello_sys_call::IENSDispatcher;
use hello_sys_call::IENSDispatcherTrait;

fn deploy_contract(name: ByteArray) -> ContractAddress {
    let contract = declare(name).unwrap();
    let (contract_address, _) = contract.deploy(@ArrayTrait::new()).unwrap();
    contract_address
}

#[test]
fn test_increase_balance() {
    let contract_address = deploy_contract("ENS");

    let dispatcher = IENSDispatcher { contract_address };

    let balance_before = dispatcher.get_name();
    assert(balance_before == 0, 'Invalid balance');

    dispatcher.store_name(42);

    let balance_after = dispatcher.get_name();
    assert(balance_after == 42, 'Invalid balance');
}

#[test]
#[feature("safe_dispatcher")]
fn test_cannot_increase_balance_with_zero_value() {
    let contract_address = deploy_contract("ENS");

    let safe_dispatcher = IENSSafeDispatcher { contract_address };

    let balance_before = safe_dispatcher.get_name().unwrap();
    assert(balance_before == 0, 'Invalid balance');

    match safe_dispatcher.store_name(0) {
        Result::Ok(_) => core::panic_with_felt252('Should have panicked'),
        Result::Err(panic_data) => {
            assert(*panic_data.at(0) == 'Amount cannot be 0', *panic_data.at(0));
        }
    };
}
