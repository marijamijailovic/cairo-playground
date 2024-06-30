# initialize signer

- starkli signer keystore new /path/to/keystore

# initialize account

- starkli account oz/argent init path/to/account
- starkli account deploy path/to/account

# declare contract class

- starkli declare path/to/contract_class.json --network network_name --account path/to/account

# deploy contract

- starkli class_hash constructor_arg --network network_name --account path/to/account
