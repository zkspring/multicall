#[starknet::interface]
trait IHelloWorld<TContractState> {
    fn increase_balance(ref self: TContractState, amount: felt252);
    fn get_balance(self: @TContractState) -> felt252;
}

#[starknet::contract]
mod HelloWorld {
    #[storage]
    struct Storage {
        balance: felt252,
    }

    #[abi(embed_v0)]
    impl HelloWorldImpl of super::IHelloWorld<ContractState> {
        // Increases the balance by the given amount.
        fn increase_balance(ref self: ContractState, amount: felt252) {
            self.balance.write(self.balance.read() + amount);
        }

        // Gets the balance.
        fn get_balance(self: @ContractState) -> felt252 {
            self.balance.read()
        }
    }
}

#[cfg(test)]
mod tests {
    use core::option::OptionTrait;
    use core::traits::TryInto;
    use helloworld::{IHelloWorldDispatcher, IHelloWorldDispatcherImpl, IHelloWorldDispatcherTrait};
    use multicall::{IMulticallDispatcherTrait, IMulticallDispatcher};

    use snforge_std::{declare, ContractClassTrait, start_prank, CheatTarget, ContractClass};


    #[test]
    fn test_multicall() {
        // test code

        // First declare and deploy a contract
        let contract = declare('HelloWorld');

        // Alternatively we could use `deploy_syscall` here
        let contract_address = contract.deploy(@ArrayTrait::new()).unwrap();

        // Create a Dispatcher object that will allow interacting with the deployed contract
        let dispatcher = IHelloWorldDispatcher { contract_address };

        // Call a view function of the contract
        let balance = dispatcher.get_balance();
        assert(balance == 0, 'balance == 0');

        // Call a function of the contract
        // Here we mutate the state of the storage
        dispatcher.increase_balance(100);

        // Check that transaction took effect
        let balance = dispatcher.get_balance();
        assert(balance == 100, 'balance == 100');

        let contract = declare('Multicall');
        let contract_address = contract.deploy(@ArrayTrait::new()).unwrap();
        let dispatcher = IMulticallDispatcher { contract_address };
        dispatcher.call(array![]);
    }
}
