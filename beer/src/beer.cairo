use starknet::ContractAddress;

#[starknet::interface]
trait IVerifier<TContractState> {
  fn verify(ref self: TContractState, proof: felt252) -> bool;
}

#[starknet::interface]
trait IBeerToken<TContractState> {
  fn send_token(ref self: TContractState, to: ContractAddress);
}

#[starknet::interface]
trait IBeer<TContractState> {
  fn buy_beer(ref self: TContractState, age_proof: Beer::AgeProof);
}

#[starknet::contract]
mod Beer {
  use super::IBeerDispatcherTrait;
  use super::IVerifierDispatcherTrait;
  use super::IVerifierDispatcher;
  use super::IBeerTokenDispatcherTrait;
  use super::IBeerTokenDispatcher;
  use starknet::{get_caller_address, ContractAddress};

  #[storage]
  struct Storage{ 
    verifier: ContractAddress,
    beer_token: ContractAddress,
  }

  #[event]
  #[derive(Drop, starknet::Event)]
  enum Event {
    BeerBought: BeerBought
  }

  #[derive(Drop, starknet::Event)]
  struct BeerBought {
    #[key]
    buyer: ContractAddress,
  }

  #[derive(Drop, Serde)]
  pub struct AgeProof {
    proof: felt252,
    age: u128,
  }

  mod Errors {
    const NOT_VALID_PROOF: felt252 = 'Invalid proof';
    const ZERO_ADDRESS_CALLER: felt252 = 'Caller is the zero address';
    const TOO_YUNG: felt252 = 'You are too young to buy beer';
  }

   #[constructor]
    fn constructor(
        ref self: ContractState,
        verifier_address: ContractAddress,
        beer_token_address: ContractAddress
    ) {
        self.verifier.write(verifier_address);
        self.beer_token.write(beer_token_address);
    }

  #[abi(embed_v0)]
  impl IBeerImpl of super::IBeer<ContractState> {
    fn buy_beer(ref self: ContractState, age_proof: AgeProof) {
      // Check if the age proof is valid
      let verified = IVerifierDispatcher {contract_address: self.verifier.read() }.verify(age_proof.proof);
      assert(verified, 'Not valid proof');
      let age = extract_age(age_proof);
      assert(age > 18, 'Too young');
      let caller: ContractAddress = get_caller_address();
      let beer_token_dispathcer = IBeerTokenDispatcher {contract_address: self.beer_token.read()};
      beer_token_dispathcer.send_token(caller);
      self.emit(BeerBought { buyer: caller} );
    }
  }

  fn extract_age(age_proof: AgeProof) -> u128 {
    return age_proof.age;
  }
}
