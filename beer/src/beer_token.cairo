#[starknet::contract]
mod BeerToken {
    use openzeppelin::token::erc20::{ERC20Component, ERC20HooksEmptyImpl};
    use starknet::ContractAddress;

    component!(path: ERC20Component, storage: erc20, event: ERC20Event);

    // ERC20 Mixin
    #[abi(embed_v0)]
    impl ERC20MixinImpl = ERC20Component::ERC20MixinImpl<ContractState>;
    impl ERC20InternalImpl = ERC20Component::InternalImpl<ContractState>;

    #[storage]
    struct Storage {
      #[substorage(v0)]
      erc20: ERC20Component::Storage
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        #[flat]
        ERC20Event: ERC20Component::Event
    }

    #[constructor]
    fn constructor(ref self: ContractState) {
        let name = "BeerToken";
        let symbol = "BTK";
        self.erc20.initializer(name, symbol);
    }

    #[external(v0)]
    fn send_token(ref self: ContractState, recipient: ContractAddress) { 
        self.erc20.mint(recipient, 1000000000000000000);
    }
}
