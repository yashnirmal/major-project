// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Main {
    // ------------------------variables--------------------------------------------------
    uint256 totalUsers = 0;
    uint256 totalCampaigns = 0;
    uint256 totalComplaints = 0;
    uint256 totalFarms = 0;
    uint256 totalOfficers = 0;
    uint256 totalInvestments = 0;

    // -------------------------structs----------------------------------------------------
    enum Status {
        PENDING,
        ACCEPTED,
        REJECTED
    }

    struct User {
        uint256 userId;
        string name;
        string description;
        bool isRegistered;
        string userType; // farmer, officer, investor
    }

    struct Farm {
        uint256 farmId;
        uint256 ownerId;
        string location;
        string description;
        string[] documents;
        // Status status;
        // address approvedByOfficer;
    }

    struct Campaign {
        uint256 campaignId;
        uint256 farmId;
        string cropType;
        string deadline;  // yyyy-mm-dd
        uint256 currentAmount;
        uint256 targetAmount;
        string description;
        uint256 securityAmount;
        Status status;
        address receiver;
    }

    struct Complaint {
        uint256 complaintId;
        uint256 farmId;
        address creater;
        address officerInCharge;
        string description;
        string[] proofs;
        uint256 yesVotes;
        uint256 noVotes;
        string deadline;
        Status status;
    }

    struct Officer {
        uint256 officerId;
        string description;
        uint[] allocatedComplaints;
    }
    
    struct Investment{
        uint256 investmentId;
        uint256 campaignId;
        uint256 amount;
        uint256 investorId;
    }

    // --------------------Mappings-----------------------------------------------------
    mapping(address => User) public users;
    mapping(address => Officer) public officers;
    mapping(uint256 => Complaint) public complaints;
    mapping(uint256 => Farm) public farms;
    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => Investment) public investments;

    // ------------------constructor----------------------------------------------------
    constructor() {
        totalUsers = 0;
        totalCampaigns = 0;
        totalComplaints = 0;
        totalFarms = 0;
        totalOfficers = 0;
    }

    // ------------------getter--------------------------------------------------------
    function getUserDetails() public view returns (User memory) {
        return users[address(msg.sender)];
    }

    function getUserFarmDetails() public view returns (Farm memory) {
        for (uint256 i = 0; i < totalFarms; i++) {
            if (farms[i].ownerId == users[address(msg.sender)].userId) {
                return farms[i];
            }
        }
    }

    function getAllFarms() public view returns (Farm[] memory) {
        Farm[] memory allFarms = new Farm[](totalFarms);
        for (uint256 i = 0; i < totalFarms; i++) {
            allFarms[i] = farms[i];
        }
        return allFarms;
    }
    
    function getAllComplaints() public view returns (Complaint[] memory){
        Complaint[] memory allComplaints = new Complaint[](totalComplaints);
        for (uint256 i = 0; i < totalComplaints; i++) {
            allComplaints[i] = complaints[i];
        }
        return allComplaints;
    }

    function getComplaintDetails(
        uint id
    ) public view returns (Complaint memory) {
        return complaints[id];
    }

    function getCampaignForFarm(uint256 farmId) public view returns (Campaign[] memory) {
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

    function getAllCampaign() public view returns (Campaign[] memory) {
        Campaign[] memory allCampaigns = new Campaign[](totalCampaigns+1);
        for (uint256 i = 1; i <= totalCampaigns; i++) {
            allCampaigns[i] = campaigns[i-1];
        }
        return allCampaigns;
    }

    function getCampaignInvestmentDetails(
        uint id
    ) public view returns (Investment[] memory) {
        Investment[] memory allInvestments = new Investment[](totalInvestments);
        uint256 j = 0;
        for (uint256 i = 0; i < totalInvestments; i++) {
            if (investments[i].campaignId == id) {
                allInvestments[j] = investments[i];
                j += 1;
            }
        }
        return allInvestments;
    }
    
    function getAllInvestmentForInvestor(uint256 investorId) public view returns(Investment[] memory){
        Investment[] memory allInvestments = new Investment[](totalInvestments);
        uint256 j = 0;
        for (uint256 i = 0; i < totalInvestments; i++) {
            if (investments[i].investorId == investorId) {
                allInvestments[j] = investments[i];
                j += 1;
            }
        }
    }
    
    function getUserDetailsFromCampaignId(uint256 campaignId) public view returns (User memory) {
        return users[address(campaigns[campaignId].receiver)];
    }
    
    


    // -------------------functions-----------------------------------------------------
    function registerUser(
        string memory name,
        string memory description,
        string memory userType
    ) public {
        User memory user = User(totalUsers, name, description, true, userType);
        users[address(msg.sender)] = user;
        totalUsers += 1;
    }

    function loginUser() public view returns (bool) {
        if (bytes(users[msg.sender].description).length > 0) return true;
        else return false;
    }
    
    function registerOfficer(string memory description) public {
        Officer memory officer = Officer(totalOfficers, description, new uint256[](0));
        officers[address(msg.sender)] = officer;
        totalOfficers += 1;
    }

    function createFarm(
        string memory location,
        string memory description,
        string[] memory documents
    ) public {
        farms[totalFarms].farmId = totalFarms;
        farms[totalFarms].ownerId = users[address(msg.sender)].userId;
        farms[totalFarms].location = location;
        farms[totalFarms].description = description;
        farms[totalFarms].documents = documents;
        totalFarms += 1;
    }
    
    // function updateFarmStatus(uint256 farmId, Status status) public {
    //     farms[farmId].status = status;
    // }

    function createCampaign(
        uint256 farmId,
        string memory cropType,
        string memory deadline,
        uint256 targetAmount,
        string memory description
    ) public payable {
        campaigns[totalCampaigns].campaignId = totalCampaigns;
        campaigns[totalCampaigns].farmId = farmId;
        campaigns[totalCampaigns].cropType = cropType;
        campaigns[totalCampaigns].deadline = deadline;
        campaigns[totalCampaigns].currentAmount = 0;
        campaigns[totalCampaigns].targetAmount = targetAmount;
        campaigns[totalCampaigns].description = description;
        campaigns[totalCampaigns].securityAmount = msg.value;
        campaigns[totalCampaigns].status = Status.PENDING;
        campaigns[totalCampaigns].receiver = address(msg.sender);
        totalCampaigns += 1;
    }
    
    
    function fundToCampaign(uint id) public payable {
        campaigns[id].currentAmount += msg.value;
        investments[totalInvestments].investmentId = totalInvestments;
        investments[totalInvestments].campaignId = id;
        investments[totalInvestments].amount = msg.value;
        investments[totalInvestments].investorId = users[address(msg.sender)].userId;
    }

    function createComplaint(
        uint256 farmId,
        string memory description,
        string[] memory proof,
        string memory deadline
    ) public payable {
        // require(msg.value == farms[farmId].securityAmount / 10);
        Complaint memory complaint = Complaint(
            totalComplaints,
            farmId,
            address(msg.sender),
            address(0),
            description,
            proof,
            1,
            0,
            deadline,
            Status.PENDING
        );
        complaints[totalComplaints] = complaint;
        totalComplaints += 1;
    }

    function loginOfficer() public view returns (bool) {
        if (bytes(officers[msg.sender].description).length > 0) return true;
        else return false;
    }

    function voteToComplaint(uint id, bool isYes) public {
        if (isYes) {
            complaints[id].yesVotes += 1;
        } else {
            complaints[id].noVotes += 1;
        }
    }


    // cehckIfCampaingEndedAndcampaignInvestment
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
    //         // payable(complaints[id].creater).transfer(
    //         //     farms[complaints[id].farmId].securityAmount / 5
    //         // );
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
