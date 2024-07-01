use starknet::ContractAddress;

#[starknet::interface]
trait IVerifier<TContractState> {
  fn verify(ref self: TContractState, proof: felt252) -> bool;
}

#[starknet::interface]
trait IBeerToken<TContractState> {
  fn send_token(ref self: TContractState, to: ContractAddress);
  fn total_supply(ref self: TContractState) -> u128;
}

#[starknet::interface]
trait IBeer<TContractState> {
  fn get_beer(ref self: TContractState, age_proof: Beer::AgeProof);
}

#[starknet::contract]
mod Beer {
  use super::IBeerDispatcherTrait;
  use super::IVerifierDispatcherTrait;
  use super::IVerifierDispatcher;
  use super::IBeerTokenDispatcherTrait;
  use super::IBeerTokenDispatcher;
  use beer::errors::Errors;
  use starknet::{get_caller_address, ContractAddress};

  #[storage]
  struct Storage{ 
    verifier: ContractAddress,
    beer_token: ContractAddress,
  }

  #[event]
  #[derive(Drop, starknet::Event)]
  enum Event {
    FreeBeer: FreeBeer 
  }

  #[derive(Drop, starknet::Event)]
  struct FreeBeer {
    #[key]
    winner: ContractAddress,
  }

  #[derive(Drop, Serde)]
  pub struct AgeProof {
    proof: felt252,
    age: u128,
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
    fn get_beer(ref self: ContractState, age_proof: AgeProof) {
      let verified = IVerifierDispatcher {contract_address: self.verifier.read() }.verify(age_proof.proof);
      assert(verified,  Errors::NOT_VALID_PROOF);

      let age = extract_age(age_proof);
      assert(age > 18, Errors::TOO_YUNG);

      let beer_token_dispathcer = IBeerTokenDispatcher {contract_address: self.beer_token.read()};

      let beer_token_total_supply = beer_token_dispathcer.total_supply();
      assert(beer_token_total_supply <= 10 * 1000000000000000000, Errors::NO_MORE_BEER);

      let caller: ContractAddress = get_caller_address();
      beer_token_dispathcer.send_token(caller);
      self.emit(FreeBeer {winner: caller} );
    }
  }

  fn extract_age(age_proof: AgeProof) -> u128 {
    return age_proof.age;
  }
}
