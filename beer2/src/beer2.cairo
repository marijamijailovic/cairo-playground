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
trait IBeer2<TContractState> {
  fn get_beer(ref self: TContractState, age_proof: Beer2::AgeProof);
}

#[starknet::contract]
mod Beer2 {
  use super::IBeer2DispatcherTrait;
  use super::IVerifierDispatcherTrait;
  use super::IVerifierDispatcher;
  use super::IBeerTokenDispatcherTrait;
  use super::IBeerTokenDispatcher;
  use beer2::errors::Errors;
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
  impl IBeer2Impl of super::IBeer2<ContractState> {
    fn get_beer(ref self: ContractState, age_proof: AgeProof) {
      let age_verified = IVerifierDispatcher {contract_address: self.verifier.read() }.verify(age_proof.proof);
      assert(age_verified, Errors::NOT_VALID);

      let age = extract_age(age_proof);
      assert(age > 18, Errors::NOT_VALID);

      let caller: ContractAddress = get_caller_address();
      IBeerTokenDispatcher {contract_address: self.beer_token.read()}.send_token(caller);
      self.emit(FreeBeer {winner: caller} );
    }
  }

  fn extract_age(age_proof: AgeProof) -> u128 {
    return age_proof.age;
  }
}
