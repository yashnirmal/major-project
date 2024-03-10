
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
    // -----------------------Questions---------------------------------------------------
    string[] questions = [
        // farming and practicess
        "Is the farm located in a region certified for organic farming by a recognized body?",
        "Have there been any recent changes to the farm's size, crop types, or surrounding environment that might impact its organic practices?",
        "Can you provide detailed satellite imagery or maps of the farm and its surrounding area to verify its location and potential limitations?",
        "Are there any specific microclimates or unique ecological factors within the region that the farm claims support its organic practices?",
        "can you provide scientific research or data to substantiate these claims?"

        // Certification and Documentation
        // "Does the farm hold a valid organic certification from a recognized national or international body?",
        // "Have you investigated the issuing body's reputation and history of ensuring accurate certification?",
        // "Can you access and analyze the farm's specific audit reports or inspection  records related to its certification?",
        // "Can you provide copies of the verification reports or protocols and confirm their alignment with recognized organic standards?",
        
        // // Farming Practices
        // "Does the farm claim to use only natural pest control methods and organic soil amendments?",
        // "Can you obtain the exact brand names or compositions of the natural pest control materials used and verify their organic certification?",
        // "Is there readily available documentation of the farm's record-keeping for application rates, timing, and target pests for these methods?",
        // "Can you provide data or research supporting the effectiveness and minimal environmental impact of the non-organic methods used?",

        // // Marketing Claims
        // "Does the farm's marketing exclusively use terms like 'certified organic' or 'USDA Organic'?",
        // "Have you compared the farm's marketing claims to the specific wording allowed by the issuing certification body's guidelines?",
        // "Are there any inconsistencies between the marketing claims and the farm's documented practices on their website or other publicly available information? ",
        // "Can you identify any instances where the farm's marketing might be targeting specific consumer demographics with potentially misleading language?"
    ];

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
        Status status;
        address approvedByOfficer;
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
        uint256 earnedAmount;
        Status status;
        address receiver;
    }

    struct Complaint {
        uint256 complaintId;
        uint256 farmId;
        uint256 campaignId;
        address creater;
        address officerInCharge;
        string description;
        string[] proofs;
        uint256 yesVotes;
        uint256 noVotes;
        uint256 deadline;
        Status status;
        string comment;
    }

    struct Officer {
        uint256 officerId;
        string name;
        string description;
        uint[] allocatedComplaints;
    }
    
    struct Investment{
        uint256 investmentId;
        uint256 campaignId;
        uint256 farmId;
        uint256 amount;
        address investorAddress;
    }

    // --------------------Mappings-----------------------------------------------------
    mapping(address => User) public users;
    mapping(address => Officer) public officers;
    mapping(uint256 => Complaint) public complaints;
    mapping(uint256 => Farm) public farms;
    mapping(uint256 => Campaign) public campaigns;
    mapping(uint256 => Investment) public investments;
    mapping(uint256 => address) public OfficerIdToAddress;

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

    function getOfficerDetails() public view returns (Officer memory) {
        return officers[address(msg.sender)];
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

    function getAddressFromOfficerId(uint256 id) public view returns (address) {
        return OfficerIdToAddress[id];
    }
    function getComplaintDetails(
        uint id
    ) public view returns (Complaint memory) {
        return complaints[id];
    }

    function getQuestion(uint256 questionNumber) public view returns (string memory) {
        return questions[questionNumber];
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

    function getStats(uint256 farmId) public view returns (uint256[] memory) {
        uint256[] memory stats = new uint256[](4);
        uint256 numberOfCompaigns = 0;
        uint256 investmentAmount = 0;
        for (uint256 i = 0; i < totalCampaigns; i++) {
            if (campaigns[i].farmId == farmId) {
                numberOfCompaigns += 1;
                for (uint256 j = 0; j < totalInvestments; j++) {
                    if(investments[j].campaignId == campaigns[i].farmId) {
                        investmentAmount += investments[j].amount;
                    }
                }
            }
        }
        stats[0] = numberOfCompaigns;
        stats[1] = investmentAmount;
        stats[2] = 0;
        stats[3] = 0;
        return stats;
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
    
    function getAllInvestmentForInvestor() public view returns(Investment[] memory){
        Investment[] memory allInvestments = new Investment[](totalInvestments);
        uint256 j = 0;
        for (uint256 i = 0; i < totalInvestments; i++) {
            if (investments[i].investorAddress == address(msg.sender)) {
                allInvestments[j] = investments[i];
                j += 1;
            }
        }
        return allInvestments;
    }
    
    function getUserDetailsFromCampaignId(uint256 campaignId) public view returns (User memory) {
        return users[address(campaigns[campaignId].receiver)];
    }
    
    function getComplaintsForOfficer() public view returns (Complaint[] memory) {
        Complaint[] memory allocatedChallenges = new Complaint[](officers[address(msg.sender)].allocatedComplaints.length);
        for(uint i=0;i<officers[address(msg.sender)].allocatedComplaints.length;i++) {
            allocatedChallenges[i] = (complaints[ officers[address(msg.sender)].allocatedComplaints[i] ]);
        }
        return allocatedChallenges;
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
    
    function registerOfficer(string memory name, string memory description) public {
        Officer memory officer = Officer(totalOfficers, name, description, new uint[](0));
        officers[address(msg.sender)] = officer;
        OfficerIdToAddress[totalOfficers] = address(msg.sender);
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
    

    function createCampaign(
        uint256 farmId,
        string memory cropType,
        string memory deadline,
        uint256 targetAmount,
        string memory description
    ) public payable {
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
    
    
    function fundToCampaign(uint id) public payable {
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

    function createComplaint(
        uint256 farmId,
        uint256 campaignId,
        string memory description,
        string[] memory proof,
        uint256 deadline
    ) public payable {
        // require(msg.value == campaigns[campaignId].securityAmount / 3);
        Complaint memory complaint = Complaint(
            totalComplaints,
            farmId,
            campaignId,
            address(msg.sender),
            address(0),
            description,
            proof,
            1,
            0,
            deadline,
            Status.PENDING,
            ""
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
    
    function getPendingComplaints() public view returns (Complaint[] memory) {
        Complaint[] memory pendingComplaints = new Complaint[](totalComplaints);
        uint256 j = 0;
        for (uint256 i = 0; i < totalComplaints; i++) {
            if (complaints[i].status == Status.PENDING) {
                pendingComplaints[j] = complaints[i];
                j += 1;
            }
        }
        return pendingComplaints;
    }
    
    function getPendingCampaigns() public view returns (Campaign[] memory) {
        Campaign[] memory pendingCampaigns = new Campaign[](totalCampaigns);
        uint256 j = 0;
        for (uint256 i = 0; i < totalCampaigns; i++) {
            if (campaigns[i].status == Status.PENDING) {
                pendingCampaigns[j] = campaigns[i];
                j += 1;
            }
        }
        return pendingCampaigns;
    }
    
    function getPendingFarms() public view returns (Farm[] memory) {
        Farm[] memory pendingFarms = new Farm[](totalFarms);
        uint256 j = 0;
        for (uint256 i = 0; i < totalFarms; i++) {
            if (farms[i].status == Status.PENDING) {
                pendingFarms[j] = farms[i];
                j += 1;
            }
        }
        return pendingFarms;
    }
    
    function handleComplaint(uint256 id, bool isAccepted) public {
        if (isAccepted) {
            payable(complaints[id].creater).transfer(
                campaigns[complaints[id].campaignId].securityAmount / 2
            );
            for(uint i=0; i<totalInvestments; i++) {
                if(investments[i].campaignId==complaints[id].campaignId && investments[i].farmId == complaints[id].farmId) {
                    payable(investments[i].investorAddress).transfer(investments[i].amount);
                }
            }
            complaints[id].status = Status.ACCEPTED;
        } else {
            complaints[id].status = Status.REJECTED;
        }
        officers[address(msg.sender)].allocatedComplaints = new uint256[](0);
    }
    
    function handlePendingCampaign(uint256 id, bool isAccepted) public {
        if (isAccepted) {
            campaigns[id].status = Status.ACCEPTED;
        } else {
            campaigns[id].status = Status.REJECTED;
        }
    }
    
    function handlePendingFarms(uint256 id, bool isAccepted) public {
        if (isAccepted) {
            farms[id].status = Status.ACCEPTED;
        } else {
            farms[id].status = Status.REJECTED;
        }
    }
    
    function withdrawAmountForFarmer(uint256 campaignId) public {
        payable(campaigns[campaignId].receiver).transfer(campaigns[campaignId].currentAmount);
    }
    
    function enterProfitFromCampaign(uint256 campaignId) payable public {
        campaigns[campaignId].earnedAmount += msg.value;
    }
    
    function distributeRewardsToInvesters(uint256 campaignId) public {
        uint256 totalInvestorForCampaign = 0;
        for (uint256 i = 0; i < totalInvestments; i++) {
            if (investments[i].campaignId == campaignId) {
                totalInvestorForCampaign += 1;
            }
        }
        
        for (uint256 i = 0; i < totalInvestments; i++) {
            if (investments[i].campaignId == campaignId) {
                payable(investments[i].investorAddress).transfer(
                    (campaigns[campaignId].earnedAmount / totalInvestorForCampaign)
                );
                campaigns[campaignId].earnedAmount -= (campaigns[campaignId].earnedAmount / totalInvestorForCampaign);
            }
        }
        payable(campaigns[campaignId].receiver).transfer(campaigns[campaignId].currentAmount + campaigns[campaignId].securityAmount);
    }
}