// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract UserManager {
    uint256 totalUsers = 0;
    uint256 totalOfficers = 0;

    struct User {
        uint256 userId;
        string name;
        string description;
        bool isRegistered;
        string userType; // farmer, officer, investor
    }

    struct Officer {
        uint256 officerId;
        string name;
        string description;
        uint[] allocatedComplaints;
    }

    mapping(address => User) public users;
    mapping(address => Officer) public officers;
    mapping(uint256 => address) public OfficerIdToAddress;

    constructor() {
        totalUsers = 0;
        totalOfficers = 0;
    }

    function registerUser(
        string memory name,
        string memory description,
        string memory userType
    ) external {
        User memory user = User(totalUsers, name, description, true, userType);
        users[address(msg.sender)] = user;
        totalUsers += 1;
    }

    function loginUser() external view returns (bool) {
        if (bytes(users[msg.sender].description).length > 0) return true;
        else return false;
    }
    
    function registerOfficer(string memory name, string memory description) external {
        Officer memory officer = Officer(totalOfficers, name, description, new uint[](0));
        officers[address(msg.sender)] = officer;
        OfficerIdToAddress[totalOfficers] = address(msg.sender);
        totalOfficers += 1;
    }


    function loginOfficer() external view returns (bool) {
        if (bytes(officers[msg.sender].description).length > 0) return true;
        else return false;
    }

    function getUserDetails() external view returns (User memory) {
        return users[msg.sender];
    }

    function getOfficerDetails() external view returns (Officer memory) {
        return officers[msg.sender];
    }

}
