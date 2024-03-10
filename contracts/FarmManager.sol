// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./UserManager.sol";

contract FarmManager is UserManager {
    
    uint256 totalFarms = 0;
    
    enum Status {
        PENDING,
        ACCEPTED,
        REJECTED
    }

    struct Farm {
        uint256 farmId;
        uint256 ownerId;
        string location;
        string description;
        string[] documents;
        Status status;
        address approvedByOfficer;
    }
    
    mapping(uint256 => Farm) public farms;
    
    constructor() {
        totalFarms = 0;
    }
    
    function createFarm(
        string memory location,
        string memory description,
        string[] memory documents
    ) external {
        farms[totalFarms].farmId = totalFarms;
        farms[totalFarms].ownerId = users[address(msg.sender)].userId;
        farms[totalFarms].location = location;
        farms[totalFarms].description = description;
        farms[totalFarms].documents = documents;
        totalFarms += 1;
    }
    
    function getAllFarms() external view returns (Farm[] memory) {
        Farm[] memory allFarms = new Farm[](totalFarms);
        for (uint256 i = 0; i < totalFarms; i++) {
            allFarms[i] = farms[i];
        }
        return allFarms;
    }
}