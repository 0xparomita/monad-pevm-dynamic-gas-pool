// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title ParallelGasTank
 * @dev Manages corporate sponsorship allocations across isolated maps to bypass core OCC processing conflicts.
 */
contract ParallelGasTank is Ownable {

    struct AccountQuota {
        uint256 balanceRemaining;
        bool isWhitelisted;
    }

    // Maps accounts directly to split slots to ensure conflict-free parallel thread allocations
    mapping(address => AccountQuota) public userQuotaRegistry;
    address public gasStationOperator;

    event GasSponsored(address indexed user, address indexed operator, uint256 amount);

    constructor() Ownable(msg.sender) {
        gasStationOperator = msg.sender;
    }

    /**
     * @notice Deducts gas budgets concurrently on structurally separated customer accounts.
     */
    function sponsorTransactionConcurrently(address user, uint256 chargeAmount) external {
        require(msg.sender == gasStationOperator, "AuthError: Caller identity matches no whitelisted relay nodes");
        AccountQuota storage quota = userQuotaRegistry[user];
        
        require(quota.isWhitelisted, "GasError: Target account profile has no active gas sponsorship active");
        require(quota.balanceRemaining >= chargeAmount, "GasError: Inadequate user gas allocation budget remaining");

        quota.balanceRemaining -= chargeAmount;

        emit GasSponsored(user, msg.sender, chargeAmount);
    }
}
