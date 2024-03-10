// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./FarmManager.sol";

contract CampaignManager is FarmManager {
    uint256 totalCampaigns = 0;
    uint256 totalInvestments = 0;
    
    struct Campaign {
        uint256 campaignId;
        uint256 farmId;
        string cropType;
        string deadline;  // yyyy-mm-dd
        uint256 currentAmount;
        uint256 targetAmount;
        string description;
        uint256 securityAmount;
        uint256 earnedAmount;
        Status status;
        address receiver;
    }
    
    struct Investment{
        uint256 investmentId;
        uint256 campaignId;
        uint256 farmId;
        uint256 amount;
        address investorAddress;
    }
    
    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => Investment) public investments;    
    
    constructor(){
        totalCampaigns = 0;
        totalInvestments = 0;
    }
    
    function getAllCampaign() external view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](totalCampaigns+1);
        for (uint256 i = 1; i <= totalCampaigns; i++) {
            allCampaigns[i] = campaigns[i-1];
        }
        return allCampaigns;
    }
    
    function getCampaignForFarm(uint256 farmId) external view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](totalCampaigns);
        uint256 j = 0;
        for (uint256 i = 0; i < totalCampaigns; i++) {
            if (campaigns[i].farmId == farmId) {
                allCampaigns[j] = campaigns[i];
                j += 1;
            }
        }
        return allCampaigns;
    }
    
    function createCampaign(
        uint256 farmId,
        string memory cropType,
        string memory deadline,
        uint256 targetAmount,
        string memory description
    ) external payable {
        // require(msg.value >= targetAmount / 10);
        // require(farms[farmId].status == Status.ACCEPTED);
        campaigns[totalCampaigns].campaignId = totalCampaigns;
        campaigns[totalCampaigns].farmId = farmId;
        campaigns[totalCampaigns].cropType = cropType;
        campaigns[totalCampaigns].deadline = deadline;
        campaigns[totalCampaigns].currentAmount = 0;
        campaigns[totalCampaigns].targetAmount = targetAmount;
        campaigns[totalCampaigns].description = description;
        campaigns[totalCampaigns].securityAmount = msg.value;
        campaigns[totalCampaigns].earnedAmount = 0;
        campaigns[totalCampaigns].status = Status.PENDING;
        campaigns[totalCampaigns].receiver = address(msg.sender);
        totalCampaigns += 1;
    }
    
    function fundToCampaign(uint id) external payable {
        // require(
        //     farms[campaigns[id].farmId].status == Status.ACCEPTED
        // && campaigns[id].status == Status.ACCEPTED
        // && campaigns[id].targetAmount > campaigns[id].currentAmount + msg.value
        // );
        campaigns[id].currentAmount += msg.value;
        investments[totalInvestments].investmentId = totalInvestments;
        investments[totalInvestments].campaignId = id;
        investments[totalInvestments].farmId = campaigns[id].farmId;
        investments[totalInvestments].amount = msg.value;
        investments[totalInvestments].investorAddress = address(msg.sender);
        totalInvestments += 1;
    }
}