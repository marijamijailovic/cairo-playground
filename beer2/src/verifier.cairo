use starknet::ContractAddress;

#[starknet::interface]
trait IVerificationHelper<TContractState> {
  fn calculation_proof(ref self: TContractState, proof: u256) -> u256;
}

#[starknet::interface]
trait IVerifier<TContractState> {
  fn verify(ref self: TContractState, proof: felt252) -> bool;
}

#[starknet::contract]
mod Verifier {
  use super::IVerificationHelperDispatcherTrait;
  use super::IVerificationHelperDispatcher;
  use starknet::ContractAddress;
  use beer2::utils::fib;

  #[storage]
  struct Storage {
     verification_helper: ContractAddress,
     result: felt252, 
    }

  #[constructor]
  fn constructor(
      ref self: ContractState,
      verification_helper: ContractAddress,
  ) {
      self.verification_helper.write(verification_helper);
  }

  #[abi(embed_v0)]
  impl IVerifierImpl of super::IVerifier<ContractState> {
    fn verify(ref self: ContractState, proof: felt252) -> bool {
      let generator: u256 = 3;
      let generator_inverse: u256 = 15;
      let x: u256 = TryInto::try_into(proof).unwrap();
      /// The STARK Curve is defined by the equation `y^2 = x^3 + FIELD_GENERATOR*x + FIELD_GENERATOR_INVERSE`.
      let y: u256 = x*x*x + generator*x + generator_inverse;
      let calculation_result = IVerificationHelperDispatcher {contract_address: self.verification_helper.read() }.calculation_proof(y*2);
      if calculation_result > 0 {
        let new_result = fib(1, 1, 25);
        self.result.write(new_result);
        return true;
      }
      false
    }
  }
}
