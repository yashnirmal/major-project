// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract Main {
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
        uint256 farmid;
        uint256[] complaintsRaised;
        uint256[] contributions;
        bool isRegistered;
    }

    struct Campaign {
        uint256 farmId;
        uint256 deadline;
        uint256 currentAmount;
        uint256 targetAmount;
        string description;
        address receiver;
        address[] contributors;
        mapping(address => uint256) investments;
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
        uint256 securityAmount;
        uint256 fundRaised;
        string[] documents;
        uint[] campaigns;
        address[] contributors;
        mapping(address => uint256) investments;
    }

    // --------------------Mappings-----------------------------------------------------
    mapping(address => User) users;
    mapping(address => Officer) officers;
    mapping(uint256 => Complaint) complaints;
    mapping(uint256 => Farm) farms;
    mapping(uint256 => Campaign) campaigns;

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

    function getComplaintDetails(
        uint id
    ) public view returns (Complaint memory) {
        return complaints[id];
    }

    function getCampaignInvestmentDetails(
        uint id
    ) public view returns (uint256) {
        return campaigns[id].investments[msg.sender];
    }

    function getCampaignCurrentAmount(uint id) public view returns (uint256) {
        return campaigns[id].currentAmount;
    }

    function getFarmFundRaisedDetials(
        uint256 id
    ) public view returns (uint256) {
        return farms[id].fundRaised;
    }

    // -------------------functions-----------------------------------------------------
    function registerUser(
        string memory name,
        string memory description
    ) public {
        User memory user = User(
            name,
            description,
            0,
            new uint256[](0),
            new uint256[](0),
            true
        );
        users[address(msg.sender)] = user;
        totalUsers += 1;
    }

    function loginUser() public view returns (bool) {
        if (bytes(users[msg.sender].description).length > 0) return true;
        else return false;
    }

    function createFarm(
        string memory cropType,
        string memory location,
        string memory description,
        string[] memory documents
    ) public payable {
        totalFarms += 1;
        farms[totalFarms].cropType = cropType;
        farms[totalFarms].location = location;
        farms[totalFarms].description = description;
        farms[totalFarms].documents = documents;
        farms[totalFarms].securityAmount = msg.value;
        users[address(msg.sender)].farmid = totalFarms;
    }

    function createComplaint(
        uint256 farmId,
        string memory description,
        string memory proof,
        string memory comments,
        uint256 deadline
    ) public payable {
        require(msg.value == farms[farmId].securityAmount / 10);
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
        complaints[totalComplaints] = complaint;
        users[address(msg.sender)].complaintsRaised.push(totalComplaints);
    }

    function createCampaign(
        uint256 farmId,
        uint256 deadline,
        uint256 targetAmount,
        string memory description,
        address receiver
    ) public {
        totalCampaigns += 1;
        campaigns[totalCampaigns].farmId = farmId;
        campaigns[totalCampaigns].deadline = deadline;
        campaigns[totalCampaigns].targetAmount = targetAmount;
        campaigns[totalCampaigns].description = description;
        campaigns[totalCampaigns].receiver = receiver;
        campaigns[totalCampaigns].status = Status.PENDING;
        farms[farmId].campaigns.push(totalCampaigns);
    }

    function registerOfficer(string memory description) public {
        Officer memory officer = Officer(description, new uint256[](0));
        totalOfficers += 1;
        officers[address(msg.sender)] = officer;
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

    function fundToCampaign(uint id) public payable {
        campaigns[id].currentAmount += msg.value;
        //check
        campaigns[id].contributors.push(address(msg.sender));
        campaigns[id].investments[address(msg.sender)] += msg.value;
    }

    // cehckIfCampaingEndedAndcampaignInvestment
    function acceptCampaignInvestment(uint id) public {
        payable(campaigns[id].receiver).transfer(campaigns[id].currentAmount);
        campaigns[id].status = Status.ACCEPTED;
        address[] memory contributor = campaigns[id].contributors;
        uint256 farmId = campaigns[id].farmId;

        for (uint256 i = 0; i < contributor.length; i++) {
            if (farms[farmId].investments[contributor[i]] == 0) {
                farms[farmId].contributors.push(contributor[i]);
            }
            farms[farmId].investments[contributor[i]] += campaigns[id]
                .investments[contributor[i]];
        }

        farms[farmId].fundRaised += campaigns[id].targetAmount;
        campaigns[id].currentAmount = 0;
    }

    function rejectCampaignInvestment(uint id) public {
        campaigns[id].status = Status.REJECTED;
        address[] memory contributor = campaigns[id].contributors;
        for (uint256 i = 0; i < contributor.length; i++) {
            payable(contributor[i]).transfer(
                campaigns[id].investments[contributor[i]]
            );
            campaigns[id].investments[contributor[i]] = 0;
        }
    }

    function updateComplaintStatus(uint id, bool isAccepted) public {
        // check only if officer is making the request
        if (isAccepted) {
            payable(complaints[id].creater).transfer(
                farms[complaints[id].farmId].securityAmount / 5
            );
            complaints[id].status = Status.ACCEPTED;
        } else {
            complaints[id].status = Status.REJECTED;
        }
    }

    function distributeRewardsToInvesters(
        uint256 campaignId
    ) external returns (bool) {
        for (
            uint256 i = 0;
            i < campaigns[campaignId].contributors.length;
            i += 1
        ) {
            uint256 total = campaigns[campaignId].currentAmount;
            uint256 precentage = campaigns[campaignId].investments[
                campaigns[campaignId].contributors[i]
            ] / total;
            uint256 amt = precentage * campaigns[campaignId].currentAmount;
            payable(campaigns[campaignId].contributors[i]).transfer(amt);
        }
        return true;
    }
}
