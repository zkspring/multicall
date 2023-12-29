use starknet::{account::Call, ContractAddress, SyscallResult};

#[starknet::interface]
trait IMulticall<T> {
    fn call(self: @T, targets: Array<Call>) -> Array<SyscallResult<Span<felt252>>>;
    fn send(ref self: T, targets: Array<Call>) -> Array<SyscallResult<Span<felt252>>>;
}

#[starknet::contract]
mod Multicall {
    use starknet::{account::Call, ContractAddress, SyscallResult};
    use super::{IMulticallDispatcher, IMulticallDispatcherTrait, call};

    #[storage]
    struct Storage {}

    #[external(v0)]
    impl Multicall of super::IMulticall<ContractState> {
        fn call(self: @ContractState, targets: Array<Call>) -> Array<SyscallResult<Span<felt252>>> {
            call(targets)
        }

        fn send(
            ref self: ContractState, targets: Array<Call>
        ) -> Array<SyscallResult<Span<felt252>>> {
            call(targets)
        }
    }
}

fn call(mut targets: Array<Call>) -> Array<SyscallResult<Span<felt252>>> {
    let mut results: Array<SyscallResult> = array![];
    loop {
        match targets.pop_front() {
            Option::Some(Call{to, selector, calldata }) => results
                .append(starknet::call_contract_syscall(to, selector, calldata.span())),
            Option::None => { break; }
        }
    };
    results
}
