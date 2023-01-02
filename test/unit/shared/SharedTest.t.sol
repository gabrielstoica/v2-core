// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.8.13;

import { ISablierV2 } from "src/interfaces/ISablierV2.sol";
import { SablierV2 } from "src/SablierV2.sol";

import { UnitTest } from "../UnitTest.t.sol";

abstract contract SharedTest is UnitTest {
    /// @dev A property that is meant to be overridden by the child test contract, which will be either the
    /// SablierV2Linear or the SablierV2Pro contract.
    ISablierV2 internal sablierV2;
}
