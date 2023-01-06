// SPDX-License-Identifier: LGPL-3.0
pragma solidity >=0.8.13;

/// @title ISablierV2Sender
/// @notice Interface for Sablier V2 sender contracts that can react to cancellations.
/// @dev Implementing this interface is entirely optional. If a sender contract does not implement this interface,
/// the function execution will not revert.
interface ISablierV2Sender {
    /// @notice Reacts to the cancellation of a stream. Sablier V2 invokes this function on the sender after a
    /// cancellation triggered by the recipient.
    ///
    /// @dev Notes:
    /// - This function may revert, but Sablier V2 will always ignore the revert.
    ///
    /// @param streamId The id of the stream that was canceled.
    /// @param caller The address of the original `msg.sender` address that triggered the cancellation.
    /// @param recipientAmount The amount of tokens withdrawn to the recipient, in units of the token's decimals.
    /// @param senderAmount The amount of tokens returned to the sender, in units of the token's decimals.
    function onStreamCanceled(uint256 streamId, address caller, uint128 recipientAmount, uint128 senderAmount) external;
}