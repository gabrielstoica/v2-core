// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.19;

import { ISablierV2Lockup } from "../ISablierV2Lockup.sol";

/// @title ISablierV2LockupRecipient
/// @notice Interface for recipient contracts capable of reacting to cancellations, renouncements, and withdrawals.
/// @dev Implementation of this interface is optional. If a recipient contract doesn't implement this
/// interface or implements it partially, function execution will not revert.
interface ISablierV2LockupRecipient {
    /// @notice Responds to sender-triggered cancellations.
    ///
    /// @dev Notes:
    /// - This function may revert, but the Sablier contract will ignore the revert.
    ///
    /// @param streamId The id of the canceled stream.
    /// @param sender The stream's sender, who canceled the stream.
    /// @param senderAmount The amount of assets refunded to the stream's sender, denoted in units of the asset's
    /// decimals.
    /// @param recipientAmount The amount of assets left for the stream's recipient to withdraw, denoted in units of
    /// the asset's decimals.
    function onStreamCanceled(
        uint256 streamId,
        address sender,
        uint128 senderAmount,
        uint128 recipientAmount
    )
        external;

    /// @notice Responds to renouncements.
    ///
    /// @dev Notes:
    /// - This function may revert, but the Sablier contract will ignore the revert.
    ///
    /// @param streamId The id of the renounced stream.
    function onStreamRenounced(uint256 streamId) external;

    /// @notice Responds to withdrawals triggered by either the stream's sender or an approved third party.
    ///
    /// @dev Notes:
    /// - This function may revert, but the Sablier contract will ignore the revert.
    ///
    /// @param streamId The id of the stream being withdrawn from.
    /// @param caller The original `msg.sender` address that triggered the withdrawal.
    /// @param to The address receiving the withdrawn assets.
    /// @param amount The amount of assets withdrawn, denoted in units of the asset's decimals.
    function onStreamWithdrawn(uint256 streamId, address caller, address to, uint128 amount) external;
}
