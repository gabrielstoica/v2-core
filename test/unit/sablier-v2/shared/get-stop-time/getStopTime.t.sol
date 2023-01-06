// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { SharedTest } from "../SharedTest.t.sol";

abstract contract GetStopTime__Test is SharedTest {
    /// @dev it should return zero.
    function testGetStopTime__StreamNonExistent() external {
        uint256 nonStreamId = 1729;
        uint40 actualStopTime = sablierV2.getStopTime(nonStreamId);
        uint40 expectedStopTime = 0;
        assertEq(actualStopTime, expectedStopTime);
    }

    modifier StreamExistent() {
        _;
    }

    /// @dev it should return the correct stop time.
    function testGetStopTime() external StreamExistent {
        uint256 streamId = createDefaultStream();
        uint40 actualStopTime = sablierV2.getStopTime(streamId);
        uint40 expectedStopTime = DEFAULT_STOP_TIME;
        assertEq(actualStopTime, expectedStopTime);
    }
}