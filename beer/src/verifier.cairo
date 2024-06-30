use starknet::ContractAddress;

#[starknet::interface]
trait IVerifier<TContractState> {
  fn verify(ref self: TContractState, proof: felt252) -> bool;
}

#[starknet::contract]
mod Verifier {
  #[storage]
  struct Storage {}

  #[abi(embed_v0)]
  impl IVerifierImpl of super::IVerifier<ContractState> {
    fn verify(ref self: ContractState, proof: felt252) -> bool {
      // Verify the proof
      true
    }
  }
}
