// SPDX-License-Identifier: MIT
pragma solidity >=0.8.2 < 0.9.0;

contract Crowdfunding {
    struct Campaign {
        address creator;
        uint256 targetAmount;
        uint256 deadline;
        uint256 totalContributions;
        bool finalized;
        mapping(address => uint256) contributions;
    }

    mapping(uint256 => Campaign) public campaigns;
    uint256 public campaignCount;

    event CampaignCreated(uint256 campaignId, address creator, uint256 targetAmount, uint256 deadline);
    event ContributionMade(uint256 campaignId, address contributor, uint256 amount);
    event CampaignFinalized(uint256 campaignId, bool success);
    event RefundIssued(uint256 campaignId, address contributor, uint256 amount);

    function createCampaign(uint256 _targetAmount, uint256 _duration) external {
        require(_targetAmount > 0, "Target amount must be greater than zero");
        require(_duration > 0, "Duration must be greater than zero");

        campaignCount++;
        Campaign storage newCampaign = campaigns[campaignCount];
        newCampaign.creator = msg.sender;
        newCampaign.targetAmount = _targetAmount;
        newCampaign.deadline = block.timestamp + _duration;
        newCampaign.finalized = false;

        emit CampaignCreated(campaignCount, msg.sender, _targetAmount, newCampaign.deadline);
    }

    function contribute(uint256 _campaignId) external payable {
        Campaign storage campaign = campaigns[_campaignId];

        require(block.timestamp < campaign.deadline, "Campaign has ended");
        require(msg.value > 0, "Contribution must be greater than zero");
        require(!campaign.finalized, "Campaign is finalized");

        campaign.totalContributions += msg.value;
        campaign.contributions[msg.sender] += msg.value;

        emit ContributionMade(_campaignId, msg.sender, msg.value);
    }

    function finalizeCampaign(uint256 _campaignId) external {
        Campaign storage campaign = campaigns[_campaignId];

        require(msg.sender == campaign.creator, "Only the creator can finalize the campaign");
        require(block.timestamp >= campaign.deadline, "Campaign is still ongoing");
        require(!campaign.finalized, "Campaign is already finalized");

        campaign.finalized = true;

        if (campaign.totalContributions >= campaign.targetAmount) {
            // Target met, transfer funds to the creator
            payable(campaign.creator).transfer(campaign.totalContributions);
            emit CampaignFinalized(_campaignId, true);
        } else {
            // Target not met, no transfer to the creator
            emit CampaignFinalized(_campaignId, false);
        }
    }

    function withdrawFunds(uint256 _campaignId) external {
        Campaign storage campaign = campaigns[_campaignId];
        uint256 contribution = campaign.contributions[msg.sender];

        require(campaign.finalized, "Campaign is not finalized");
        require(contribution > 0, "No funds to withdraw");

        if (campaign.totalContributions < campaign.targetAmount) {
            // Target not met, contributors can withdraw
            campaign.contributions[msg.sender] = 0;
            payable(msg.sender).transfer(contribution);
            emit RefundIssued(_campaignId, msg.sender, contribution);
        }
    }

    // Function to get campaign details
    function getCampaign(uint256 _campaignId) external view returns (
        address creator,
        uint256 targetAmount,
        uint256 deadline,
        uint256 totalContributions,
        bool finalized
    ) {
        Campaign storage campaign = campaigns[_campaignId];
        return (
            campaign.creator,
            campaign.targetAmount,
            campaign.deadline,
            campaign.totalContributions,
            campaign.finalized
        );
    }
}

