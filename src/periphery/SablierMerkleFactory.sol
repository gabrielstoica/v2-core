// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity >=0.8.22;

import { uUNIT } from "@prb/math/src/UD2x18.sol";

import { ISablierLockupLinear } from "../core/interfaces/ISablierLockupLinear.sol";
import { ISablierLockupTranched } from "../core/interfaces/ISablierLockupTranched.sol";

import { ISablierMerkleFactory } from "./interfaces/ISablierMerkleFactory.sol";
import { ISablierMerkleInstant } from "./interfaces/ISablierMerkleInstant.sol";
import { ISablierMerkleLL } from "./interfaces/ISablierMerkleLL.sol";
import { ISablierMerkleLT } from "./interfaces/ISablierMerkleLT.sol";
import { SablierMerkleInstant } from "./SablierMerkleInstant.sol";
import { SablierMerkleLL } from "./SablierMerkleLL.sol";
import { SablierMerkleLT } from "./SablierMerkleLT.sol";
import { MerkleBase, MerkleLL, MerkleLT } from "./types/DataTypes.sol";

/// @title SablierMerkleFactory
/// @notice See the documentation in {ISablierMerkleFactory}.
contract SablierMerkleFactory is ISablierMerkleFactory {
    /*//////////////////////////////////////////////////////////////////////////
                           USER-FACING CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @inheritdoc ISablierMerkleFactory
    function isPercentagesSum100(MerkleLT.TrancheWithPercentage[] calldata tranches)
        external
        pure
        override
        returns (bool result)
    {
        uint64 totalPercentage;
        for (uint256 i = 0; i < tranches.length; ++i) {
            totalPercentage += tranches[i].unlockPercentage.unwrap();
        }
        return totalPercentage == uUNIT;
    }

    /*//////////////////////////////////////////////////////////////////////////
                         USER-FACING NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice inheritdoc ISablierMerkleFactory
    function createMerkleInstant(
        MerkleBase.ConstructorParams memory baseParams,
        uint256 aggregateAmount,
        uint256 recipientCount
    )
        external
        returns (ISablierMerkleInstant merkleInstant)
    {
        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(
            abi.encodePacked(
                msg.sender,
                baseParams.asset,
                baseParams.expiration,
                baseParams.initialAdmin,
                abi.encode(baseParams.ipfsCID),
                baseParams.merkleRoot,
                bytes32(abi.encodePacked(baseParams.name))
            )
        );

        // Deploy the MerkleInstant contract with CREATE2.
        merkleInstant = new SablierMerkleInstant{ salt: salt }(baseParams);

        // Log the creation of the MerkleInstant contract, including some metadata that is not stored on-chain.
        emit CreateMerkleInstant(merkleInstant, baseParams, aggregateAmount, recipientCount);
    }

    /// @notice inheritdoc ISablierMerkleFactory
    function createMerkleLL(
        MerkleBase.ConstructorParams memory baseParams,
        ISablierLockupLinear lockupLinear,
        bool cancelable,
        bool transferable,
        MerkleLL.Schedule memory schedule,
        uint256 aggregateAmount,
        uint256 recipientCount
    )
        external
        returns (ISablierMerkleLL merkleLL)
    {
        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(
            abi.encodePacked(
                msg.sender,
                baseParams.asset,
                baseParams.expiration,
                baseParams.initialAdmin,
                abi.encode(baseParams.ipfsCID),
                baseParams.merkleRoot,
                bytes32(abi.encodePacked(baseParams.name)),
                lockupLinear,
                cancelable,
                transferable,
                abi.encode(schedule)
            )
        );

        // Deploy the MerkleLL contract with CREATE2.
        merkleLL = new SablierMerkleLL{ salt: salt }(baseParams, lockupLinear, cancelable, transferable, schedule);

        // Log the creation of the MerkleLL contract, including some metadata that is not stored on-chain.
        emit CreateMerkleLL(
            merkleLL, baseParams, lockupLinear, cancelable, transferable, schedule, aggregateAmount, recipientCount
        );
    }

    /// @notice inheritdoc ISablierMerkleFactory
    function createMerkleLT(
        MerkleBase.ConstructorParams memory baseParams,
        ISablierLockupTranched lockupTranched,
        bool cancelable,
        bool transferable,
        uint40 streamStartTime,
        MerkleLT.TrancheWithPercentage[] memory tranchesWithPercentages,
        uint256 aggregateAmount,
        uint256 recipientCount
    )
        external
        returns (ISablierMerkleLT merkleLT)
    {
        // Calculate the sum of percentages and durations across all tranches.
        uint256 count = tranchesWithPercentages.length;
        uint256 totalDuration;
        for (uint256 i = 0; i < count; ++i) {
            unchecked {
                // Safe to use `unchecked` because its only used in the event.
                totalDuration += tranchesWithPercentages[i].duration;
            }
        }

        // Deploy the MerkleLT contract.
        merkleLT = _deployMerkleLT(
            baseParams, lockupTranched, cancelable, transferable, streamStartTime, tranchesWithPercentages
        );

        // Log the creation of the MerkleLT contract, including some metadata that is not stored on-chain.
        emit CreateMerkleLT(
            merkleLT,
            baseParams,
            lockupTranched,
            cancelable,
            transferable,
            streamStartTime,
            tranchesWithPercentages,
            totalDuration,
            aggregateAmount,
            recipientCount
        );
    }

    /*//////////////////////////////////////////////////////////////////////////
                           INTERNAL NON-CONSTANT FUNCTIONS
    //////////////////////////////////////////////////////////////////////////*/

    /// @notice Deploys a new MerkleLT contract with CREATE2.
    /// @dev We need a separate function to prevent the stack too deep error.
    function _deployMerkleLT(
        MerkleBase.ConstructorParams memory baseParams,
        ISablierLockupTranched lockupTranched,
        bool cancelable,
        bool transferable,
        uint40 streamStartTime,
        MerkleLT.TrancheWithPercentage[] memory tranchesWithPercentages
    )
        internal
        returns (ISablierMerkleLT merkleLT)
    {
        // Hash the parameters to generate a salt.
        bytes32 salt = keccak256(
            abi.encodePacked(
                msg.sender,
                baseParams.asset,
                baseParams.expiration,
                baseParams.initialAdmin,
                abi.encode(baseParams.ipfsCID),
                baseParams.merkleRoot,
                bytes32(abi.encodePacked(baseParams.name)),
                lockupTranched,
                cancelable,
                transferable,
                streamStartTime,
                abi.encode(tranchesWithPercentages)
            )
        );

        // Deploy the MerkleLT contract with CREATE2.
        merkleLT = new SablierMerkleLT{ salt: salt }(
            baseParams, lockupTranched, cancelable, transferable, streamStartTime, tranchesWithPercentages
        );
    }
}