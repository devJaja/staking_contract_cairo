use starknet::ContractAddress;

#[starknet::interface]
trait IERC20<TContractState> {
    fn transfer_from(ref self: TContractState, from: ContractAddress, to: ContractAddress, amount: u256) -> bool;
    fn transfer(ref self: TContractState, recipient: ContractAddress, amount: u256) -> bool;
    fn balance_of(self: @TContractState, account: ContractAddress) -> u256;
}

#[starknet::interface]
trait IStaking<TContractState> {
    fn stake(ref self: TContractState, amount: u256);
    fn withdraw(ref self: TContractState, amount: u256);
    fn get_staked_balance(self: @TContractState, account: ContractAddress) -> u256;
    fn get_total_staked(self: @TContractState) -> u256;
}

#[starknet::contract]
mod Staking {
    use super::{IERC20Dispatcher, IERC20DispatcherTrait};
    use starknet::{get_caller_address, ContractAddress};

    #[storage]
    struct Storage {
        staking_token: ContractAddress,
        staked_balances: LegacyMap::<ContractAddress, u256>,
        total_staked: u256,
    }

    #[event]
    #[derive(Drop, starknet::Event)]
    enum Event {
        Staked: Staked,
        Withdrawn: Withdrawn
    }

    #[derive(Drop, starknet::Event)]
    struct Staked {
        user: ContractAddress,
        amount: u256
    }

    #[derive(Drop, starknet::Event)]
    struct Withdrawn {
        user: ContractAddress,
        amount: u256
    }

    #[constructor]
    fn constructor(ref self: ContractState, staking_token: ContractAddress) {
        assert(!staking_token.is_zero(), 'Invalid token address');
        self.staking_token.write(staking_token);
        self.total_staked.write(0);
    }

    #[abi(embed_v0)]
    impl StakingImpl of super::IStaking<ContractState> {
        fn stake(ref self: ContractState, amount: u256) {
            assert(amount > 0, 'Cannot stake 0');
            let caller = get_caller_address();
            let token = IERC20Dispatcher { contract_address: self.staking_token.read() };

            // Transfer tokens from user to contract
            assert(
                token.transfer_from(caller, starknet::get_contract_address(), amount),
                'Transfer failed'
            );

            // Update staking balances
            let current_balance = self.staked_balances.read(caller);
            self.staked_balances.write(caller, current_balance + amount);
            
            // Update total staked
            let current_total = self.total_staked.read();
            self.total_staked.write(current_total + amount);

            // Emit event
            self.emit(Staked { user: caller, amount });
        }

        fn withdraw(ref self: ContractState, amount: u256) {
            assert(amount > 0, 'Cannot withdraw 0');
            let caller = get_caller_address();
            
            // Check user has enough staked
            let current_balance = self.staked_balances.read(caller);
            assert(current_balance >= amount, 'Insufficient balance');

            // Update staking balances
            self.staked_balances.write(caller, current_balance - amount);
            
            // Update total staked
            let current_total = self.total_staked.read();
            self.total_staked.write(current_total - amount);

            // Transfer tokens back to user
            let token = IERC20Dispatcher { contract_address: self.staking_token.read() };
            assert(
                token.transfer(caller, amount),
                'Transfer failed'
            );

            // Emit event
            self.emit(Withdrawn { user: caller, amount });
        }

        fn get_staked_balance(self: @ContractState, account: ContractAddress) -> u256 {
            self.staked_balances.read(account)
        }

        fn get_total_staked(self: @ContractState) -> u256 {
            self.total_staked.read()
        }
    }
}