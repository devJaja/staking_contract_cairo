// #[cfg(test)]
// mod tests {
//     use super::*;
//     use starknet::test::{assert_events, setup_contract, set_caller};
//     use starknet::{ContractAddress, u256};

//     // Mock ERC20 Token implementation for testing
//     struct MockERC20 {
//         balances: LegacyMap<ContractAddress, u256>,
//     }

//     impl MockERC20 {
//         fn new() -> Self {
//             MockERC20 {
//                 balances: LegacyMap::new(),
//             }
//         }

//         fn mint(&mut self, to: ContractAddress, amount: u256) {
//             let current_balance = self.balances.read(to);
//             self.balances.write(to, current_balance + amount);
//         }

//         fn transfer_from(
//             &self,
//             from: ContractAddress,
//             to: ContractAddress,
//             amount: u256,
//         ) -> bool {
//             let current_balance = self.balances.read(from);
//             if current_balance >= amount {
//                 self.balances.write(from, current_balance - amount);
//                 let recipient_balance = self.balances.read(to);
//                 self.balances.write(to, recipient_balance + amount);
//                 return true;
//             }
//             false
//         }

//         fn transfer(&self, to: ContractAddress, amount: u256) -> bool {
//             self.transfer_from(to, starknet::get_contract_address(), amount)
//         }

//         fn balance_of(&self, account: ContractAddress) -> u256 {
//             self.balances.read(account)
//         }
//     }

//     // Helper to deploy Staking contract and mock ERC20 token
//     fn setup_staking_contract() -> (ContractAddress, MockERC20) {
//         let token = MockERC20::new();
//         let staking_contract_address = setup_contract::<Staking>(token);
//         (staking_contract_address, token)
//     }

//     #[test]
//     fn test_stake() {
//         let (staking_contract_address, mut mock_token) = setup_staking_contract();
//         let user = ContractAddress::default();
//         let amount_to_stake = 100;

//         // Mint tokens to the user to stake
//         mock_token.mint(user, amount_to_stake);

//         // Set the caller to be the user
//         set_caller(user);

//         // User stakes tokens
//         staking_contract_address.stake(amount_to_stake);

//         // Verify staking event is emitted
//         assert_events!(staking_contract_address, Staked);

//         // Verify user's staked balance
//         let staked_balance = staking_contract_address.get_staked_balance(user);
//         assert_eq!(staked_balance, amount_to_stake);

//         // Verify total staked
//         let total_staked = staking_contract_address.get_total_staked();
//         assert_eq!(total_staked, amount_to_stake);
//     }

//     #[test]
//     fn test_withdraw() {
//         let (staking_contract_address, mut mock_token) = setup_staking_contract();
//         let user = ContractAddress::default();
//         let amount_to_stake = 100;
//         let amount_to_withdraw = 50;

//         // Mint tokens to the user to stake
//         mock_token.mint(user, amount_to_stake);

//         // Set the caller to be the user
//         set_caller(user);

//         // User stakes tokens
//         staking_contract_address.stake(amount_to_stake);

//         // User withdraws part of the staked amount
//         staking_contract_address.withdraw(amount_to_withdraw);

//         // Verify withdrawn event is emitted
//         assert_events!(staking_contract_address, Withdrawn);

//         // Verify user's staked balance after withdrawal
//         let staked_balance = staking_contract_address.get_staked_balance(user);
//         assert_eq!(staked_balance, amount_to_stake - amount_to_withdraw);

//         // Verify total staked after withdrawal
//         let total_staked = staking_contract_address.get_total_staked();
//         assert_eq!(total_staked, amount_to_stake - amount_to_withdraw);

//         // Verify the user received the tokens back
//         let user_balance = mock_token.balance_of(user);
//         assert_eq!(user_balance, amount_to_withdraw);
//     }

//     #[test]
//     fn test_insufficient_balance_for_staking() {
//         let (staking_contract_address, mut mock_token) = setup_staking_contract();
//         let user = ContractAddress::default();
//         let amount_to_stake = 100;

//         // Mint fewer tokens than required for staking
//         mock_token.mint(user, 50);

//         // Set the caller to be the user
//         set_caller(user);

//         // Try to stake more tokens than the user has
//         let result = staking_contract_address.stake(amount_to_stake);
//         assert_eq!(result, false);  // The transaction should fail due to insufficient balance
//     }

//     #[test]
//     fn test_insufficient_balance_for_withdrawal() {
//         let (staking_contract_address, mut mock_token) = setup_staking_contract();
//         let user = ContractAddress::default();
//         let amount_to_stake = 100;
//         let amount_to_withdraw = 150;

//         // Mint tokens to the user to stake
//         mock_token.mint(user, amount_to_stake);

//         // Set the caller to be the user
//         set_caller(user);

//         // User stakes tokens
//         staking_contract_address.stake(amount_to_stake);

//         // Try to withdraw more than the staked balance
//         let result = staking_contract_address.withdraw(amount_to_withdraw);
//         assert_eq!(result, false);  // The transaction should fail due to insufficient staked balance
//     }
// }
