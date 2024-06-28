#[starknet::contract]
mod ENS {
    use starknet::get_caller_address;
    use starknet::ContractAddress;

    #[storage]
    struct Storage {
        names: LegacyMap::<ContractAddress, felt252>
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    fn NameStored(address: ContractAddress, name: felt252) {}

    #[constructor]
    fn constructor(ref self: ContractState, _name: felt252) {
        let caller = get_caller_address();
        self.names.write(caller, _name);
    }

    #[external(v0)]
    fn store_name(ref self: ContractState, _name: felt252) {
        let caller = get_caller_address();
        self.names.write(caller, _name);
        NameStored(caller, _name);
    }

    fn get_name(ref self: ContractState, address: ContractAddress) -> felt252 {
        self.names.read(address)
    }
}
