#[starknet::interface]
pub trait IMathUtils<T> {
    fn add(ref self: T, a: u32, b: u32) -> u32;
    fn main_entry_point(ref self: T, a: u32, b: u32) -> Span<felt252>;
}

// contract A
#[starknet::contract]
pub mod MathUtils {
    use starknet::get_contract_address;
    use core::array::ArrayTrait;

    #[storage]
    struct Storage {
        value: u32,
    }

    pub fn aliquot_sum(number: u32) -> u32 {
      if number == 0 || number == 1 {
          return 0;
      }

      let limit = (number / 2) + 1;
      let mut index = 2;
      let mut res = 1;
      while (index < limit) {
          if number % index == 0 {
              res = res + index;
          }
          index += 1;
      };
      res.into()
    }

    #[abi(embed_v0)]
    impl IMathUtilsImpl of super::IMathUtils<ContractState> {
        fn add(ref self: ContractState, a: u32, b: u32) -> u32 {
            assert(a > 0, 'Number must be greater then 0');
            aliquot_sum(a + b)
        }

        fn add(ref self: ContractState, a: u32, b: u32) -> Span<felt252> {
            assert(a > 0, 'Number a must be greater then 0');
            assert(b > 0, 'Number b must be greater then 0');
            let mut Calldata: Array<felt252> = ArrayTrait::new();
            Serde::serialize(@a, ref Calldata);
            Serde::serialize(@b, ref Calldata);
            let res = starknet::syscalls::call_contract_syscall(get_contract_address(),0x035a8bb8492337e79bdc674d6f31ac448f8017e26cc7bfe3144fb5d886fe5369, Calldata.span()).unwrap();
            res    
        }
    }
}
