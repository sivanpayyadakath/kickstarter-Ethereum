// SPDX-License-Identifier: MIT
pragma solidity ^0.4.17;

contract CampaignFactory {
    address[] deployedCampaigns;

    function createCampaign(uint minimumContribution) public {
        // pass msg.sender to get original manager address.
        address newCampaign = new Campaign(minimumContribution, msg.sender);
        deployedCampaigns.push(newCampaign);
    }

    function getDeployedCampaigns() public view returns (address[])  {
        return deployedCampaigns;
    }
}

contract Campaign {
    struct Request {
        string description;
        uint value;
        address recipient;
        bool complete;
        uint approvalCount;
        mapping(address => bool) approvals;
    }

    address public manager;
    uint public minimumContribution;
    Request[] public requests;
    mapping(address => bool) public approvers;
    uint public approversCount;

    function Campaign(uint minContribution, address creatorAddress) public {
        manager = creatorAddress;
        minimumContribution = minContribution;
    }

    function contribute() public payable {
        require(msg.value > minimumContribution);

        approvers[msg.sender] = true;
        approversCount++;
    }

    function createRequest(string description, uint value, address recipient) public restrictedManager {
        Request memory newRequest = Request({
            description: description,
            value: value,
            recipient: recipient,
            complete: false,
            approvalCount: 0
        });

        requests.push(newRequest);
    }

    function approveRequest(uint requestIndex) public {
        // Check if person is a valid approver
        require(approvers[msg.sender]);

        Request storage request = requests[requestIndex];
        // Check if approver has already voted on request
        require(!request.approvals[msg.sender]);

        request.approvals[msg.sender] = true;
        request.approvalCount++;
    }

    function finalizeRequest(uint requestIndex) public restrictedManager {
        Request storage request = requests[requestIndex];

        require(!request.complete);

        require(request.approvalCount > (approversCount/2));

        request.recipient.transfer(request.value);

        request.complete = true;
    }

    modifier restrictedManager {
        require(msg.sender == manager);
        _;
    }
}
