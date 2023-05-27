// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.19 <0.9.0;

import { Errors } from "src/libraries/Errors.sol";
import { LockupDynamic } from "src/types/DataTypes.sol";

import { Dynamic_Integration_Basic_Test } from "../Dynamic.t.sol";
import { StreamedAmountOf_Integration_Basic_Test } from "../../lockup/streamed-amount-of/streamedAmountOf.t.sol";

contract StreamedAmountOf_Dynamic_Integration_Basic_Test is
    Dynamic_Integration_Basic_Test,
    StreamedAmountOf_Integration_Basic_Test
{
    function setUp() public virtual override(Dynamic_Integration_Basic_Test, StreamedAmountOf_Integration_Basic_Test) {
        Dynamic_Integration_Basic_Test.setUp();
        StreamedAmountOf_Integration_Basic_Test.setUp();
    }

    function test_StreamedAmountOf_StartTimeInTheFuture()
        external
        whenNotNull
        whenStreamHasNotBeenCanceled
        whenStatusStreaming
    {
        vm.warp({ timestamp: 0 });
        uint128 actualStreamedAmount = dynamic.streamedAmountOf(defaultStreamId);
        uint128 expectedStreamedAmount = 0;
        assertEq(actualStreamedAmount, expectedStreamedAmount, "streamedAmount");
    }

    function test_StreamedAmountOf_StartTimeInThePresent()
        external
        whenNotNull
        whenStreamHasNotBeenCanceled
        whenStatusStreaming
    {
        vm.warp({ timestamp: defaults.START_TIME() });
        uint128 actualStreamedAmount = dynamic.streamedAmountOf(defaultStreamId);
        uint128 expectedStreamedAmount = 0;
        assertEq(actualStreamedAmount, expectedStreamedAmount, "streamedAmount");
    }

    function test_StreamedAmountOf_OneSegment()
        external
        whenNotNull
        whenStreamHasNotBeenCanceled
        whenStatusStreaming
        whenStartTimeInThePast
    {
        // Simulate the passage of time.
        vm.warp({ timestamp: defaults.START_TIME() + 2000 seconds });

        // Create an array with one segment.
        LockupDynamic.Segment[] memory segments = new LockupDynamic.Segment[](1);
        segments[0] = LockupDynamic.Segment({
            amount: defaults.DEPOSIT_AMOUNT(),
            exponent: defaults.segments()[1].exponent,
            milestone: defaults.END_TIME()
        });

        // Create the stream.
        uint256 streamId = createDefaultStreamWithSegments(segments);

        // Run the test.
        uint128 actualStreamedAmount = dynamic.streamedAmountOf(streamId);
        uint128 expectedStreamedAmount = 4472.13595499957941e18; // (0.2^0.5)*10,000
        assertEq(actualStreamedAmount, expectedStreamedAmount, "streamedAmount");
    }

    modifier whenMultipleSegments() {
        _;
    }

    function test_StreamedAmountOf_CurrentMilestone1st()
        external
        whenNotNull
        whenStreamHasNotBeenCanceled
        whenStatusStreaming
        whenMultipleSegments
        whenStartTimeInThePast
    {
        // Warp 1 second to the future.
        vm.warp({ timestamp: defaults.START_TIME() + 1 seconds });

        // Run the test.
        uint128 actualStreamedAmount = dynamic.streamedAmountOf(defaultStreamId);
        uint128 expectedStreamedAmount = 0.000000053506725e18;
        assertEq(actualStreamedAmount, expectedStreamedAmount, "streamedAmount");
    }

    modifier whenCurrentMilestoneNot1st() {
        _;
    }

    function test_StreamedAmountOf_CurrentMilestoneNot1st()
        external
        whenNotNull
        whenStreamHasNotBeenCanceled
        whenStatusStreaming
        whenStartTimeInThePast
        whenMultipleSegments
        whenCurrentMilestoneNot1st
    {
        // Simulate the passage of time. 750 seconds is ~10% of the way in the second segment.
        vm.warp({ timestamp: defaults.START_TIME() + defaults.CLIFF_DURATION() + 750 seconds });

        // Run the test.
        uint128 actualStreamedAmount = dynamic.streamedAmountOf(defaultStreamId);
        uint128 expectedStreamedAmount = defaults.segments()[0].amount + 2371.708245126284505e18; // ~7,500*0.1^{0.5}
        assertEq(actualStreamedAmount, expectedStreamedAmount, "streamedAmount");
    }
}