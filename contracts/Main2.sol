// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Main2 {
    // ------------------------variables--------------------------------------------------
    uint256 totalUsers = 0;
    uint256 totalCampaigns = 0;
    uint256 totalComplaints = 0;
    uint256 totalFarms = 0;
    uint256 totalOfficers = 0;

    // -------------------------structs----------------------------------------------------
    enum Status {
        PENDING,
        ACCEPTED,
        REJECTED
    }

    struct User {
        string name;
        string description;
        uint256[] complaintsRaised;
        uint256[] contributions;
        bool isRegistered;
    }

    struct Campaign {
        uint256 farmId;
        uint256 deadline;
        uint256 securityAmount;
        uint256 currentAmount;
        uint256 targetAmount;
        string description;
        address receiver;
        address[] contributors;
        // mapping(address => uint256) investments;
        Status status;
    }

    struct Complaint {
        uint256 farmId;
        address creater;
        address officerInCharge;
        string description;
        string proof;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 deadline;
        Status status;
        string comments;
    }

    struct Officer {
        string description;
        uint[] allocatedComplaints;
    }

    struct Farm {
        string cropType;
        string location;
        string description;
        address userAddress;
        uint256 fundRaised;
        string[] documents;
        uint[] campaigns;
        address[] contributors;
        // mapping(address => uint256) investments;
    }
    
    // --------------------Arrays-------------------------------------
    User[] public usersArray;
    Officer[] public officersArray;
    Complaint[] public complaintsArray;
    Farm[] public farmsArray;
    Campaign[] public campaignsArray;


    // ------------------constructor----------------------------------------------------
    constructor() {
        totalUsers = 0;
        totalCampaigns = 0;
        totalComplaints = 0;
        totalFarms = 0;
        totalOfficers = 0;
    }

    // ------------------getter--------------------------------------------------------
    function getAllUsers() public view returns (User[] memory) {
        return usersArray;
    }
    
    function getAllFarms() public view returns (Farm[] memory) {
        return farmsArray;
    }
    
    function getUserDetails() public view returns (address) {
        return address(msg.sender);
    }

    // function getComplaintDetails(
    //     uint id
    // ) public view returns (Complaint memory) {
    //     return complaints[id];
    // }

    // function getCampaignInvestmentDetails(
    //     uint id
    // ) public view returns (uint256) {
    //     return campaigns[id].investments[msg.sender];
    // }

    // function getCampaignCurrentAmount(uint id) public view returns (uint256) {
    //     return campaigns[id].currentAmount;
    // }

    // function getFarmFundRaisedDetials(
    //     uint256 id
    // ) public view returns (uint256) {
    //     return farms[id].fundRaised;
    // }
    
    function getTotalUsers() public view returns (uint256) {
        return totalUsers;
    }

    // -------------------functions-----------------------------------------------------
    function registerUser(
        string memory name,
        string memory description
    ) public {
        User memory user = User(
            name,
            description,
            new uint256[](0),
            new uint256[](0),
            true
        );
        usersArray.push(user);
        totalUsers += 1;
        // usersAddressToIdx[address(msg.sender)] = totalUsers;
    }

    // function loginUser() public view returns (bool) {
    //     if (bytes(usersArray[usersAddressToIdx[address(msg.sender)]].description).length > 0) return true;
    //     else return false;
    // }

    function createFarm(
        string memory cropType,
        string memory location,
        string memory description,
        string[] memory documents
    ) public {
        totalFarms += 1;
        Farm memory farm = Farm(
            cropType,
            location,
            description,
            address(msg.sender),
            0,
            documents,
            new uint256[](0),
            new address[](0)
        );
        farmsArray.push(farm);
    }

    function createComplaint(
        uint256 farmId,
        string memory description,
        string memory proof,
        string memory comments,
        uint256 deadline
    ) public payable {
        Complaint memory complaint = Complaint(
            farmId,
            address(msg.sender),
            address(0),
            description,
            proof,
            1,
            0,
            deadline,
            Status.PENDING,
            comments
        );
        totalComplaints += 1;
        complaintsArray.push(complaint);
        // usersArray[usersAddressToIdx[address(msg.sender)]].complaintsRaised.push(totalComplaints);
    }

    function createCampaign(
        uint256 farmId,
        uint256 deadline,
        uint256 targetAmount,
        string memory description
    ) public payable {
        totalCampaigns += 1;
        Campaign memory campaign = Campaign(
            farmId,
            deadline,
            msg.value,
            0,
            targetAmount,
            description,
            msg.sender,
            new address[](0),
            Status.PENDING
        );
        campaignsArray.push(campaign);
        // campaigns[totalCampaigns].farmId = farmId;
        // campaigns[totalCampaigns].deadline = deadline;
        // campaigns[totalCampaigns].targetAmount = targetAmount;
        // campaigns[totalCampaigns].description = description;
        // campaigns[totalCampaigns].receiver = receiver;
        // campaigns[totalCampaigns].status = Status.PENDING;
        // farms[farmId].campaigns.push(totalCampaigns);
    }

    // function registerOfficer(string memory description) public {
    //     Officer memory officer = Officer(description, new uint256[](0));
    //     totalOfficers += 1;
    //     officers[address(msg.sender)] = officer;
    // }

    // function loginOfficer() public view returns (bool) {
    //     if (bytes(officers[msg.sender].description).length > 0) return true;
    //     else return false;
    // }

    // function voteToComplaint(uint id, bool isYes) public {
    //     if (isYes) {
    //         complaints[id].yesVotes += 1;
    //     } else {
    //         complaints[id].noVotes += 1;
    //     }
    // }

    // function fundToCampaign(uint id) public payable {
    //     campaigns[id].currentAmount += msg.value;
    //     //check
    //     campaigns[id].contributors.push(address(msg.sender));
    //     campaigns[id].investments[address(msg.sender)] += msg.value;
    // }

    // // cehckIfCampaingEndedAndcampaignInvestment
    // function acceptCampaignInvestment(uint id) public {
    //     payable(campaigns[id].receiver).transfer(campaigns[id].currentAmount);
    //     campaigns[id].status = Status.ACCEPTED;
    //     address[] memory contributor = campaigns[id].contributors;
    //     uint256 farmId = campaigns[id].farmId;

    //     for (uint256 i = 0; i < contributor.length; i++) {
    //         if (farms[farmId].investments[contributor[i]] == 0) {
    //             farms[farmId].contributors.push(contributor[i]);
    //         }
    //         farms[farmId].investments[contributor[i]] += campaigns[id]
    //             .investments[contributor[i]];
    //     }

    //     farms[farmId].fundRaised += campaigns[id].targetAmount;
    //     campaigns[id].currentAmount = 0;
    // }

    // function rejectCampaignInvestment(uint id) public {
    //     campaigns[id].status = Status.REJECTED;
    //     address[] memory contributor = campaigns[id].contributors;
    //     for (uint256 i = 0; i < contributor.length; i++) {
    //         payable(contributor[i]).transfer(
    //             campaigns[id].investments[contributor[i]]
    //         );
    //         campaigns[id].investments[contributor[i]] = 0;
    //     }
    // }

    // function updateComplaintStatus(uint id, bool isAccepted) public {
    //     // check only if officer is making the request
    //     if (isAccepted) {
    //         payable(complaints[id].creater).transfer(
    //             farms[complaints[id].farmId].securityAmount / 5
    //         );
    //         complaints[id].status = Status.ACCEPTED;
    //     } else {
    //         complaints[id].status = Status.REJECTED;
    //     }
    // }

    // function distributeRewardsToInvesters(
    //     uint256 campaignId
    // ) external returns (bool) {
    //     for (
    //         uint256 i = 0;
    //         i < campaigns[campaignId].contributors.length;
    //         i += 1
    //     ) {
    //         uint256 total = campaigns[campaignId].currentAmount;
    //         uint256 precentage = campaigns[campaignId].investments[
    //             campaigns[campaignId].contributors[i]
    //         ] / total;
    //         uint256 amt = precentage * campaigns[campaignId].currentAmount;
    //         payable(campaigns[campaignId].contributors[i]).transfer(amt);
    //     }
    //     return true;
    // }
}
