use starknet::ContractAddress;

#[starknet::interface]
trait IVerificationHelper<TContractState> {
  fn calculation_proof(ref self: TContractState, proof: u256) -> u256;
}

#[starknet::contract]
mod VerificationHelper {
  
  #[storage]
  struct Storage {
    }


  #[abi(embed_v0)]
  impl IVerificationHelperImpl of super::IVerificationHelper<ContractState> {
    fn calculation_proof(ref self: ContractState, proof: u256) -> u256 {
      let generator: u256 = 3;
      let generator_inverse: u256 = 105;
      let x: u256 = TryInto::try_into(proof).unwrap();
      let y = x*x*x + generator*x + generator_inverse;
      y
    }
  }
}
