// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiSigWallet {
    address[] public owners;      // 多签持有人地址
    uint public threshold;         // 签名门槛（多少人确认才能执行提案）

    struct Proposal {
        address recipient;
        uint amount;
        bytes data;
        uint confirmations;
        bool executed;
    }

    Proposal[] public proposals;
    mapping(address => mapping(uint => bool)) public confirmations;  // 记录每个地址对提案的确认状态

    modifier onlyOwner() {
        bool isOwner = false;
        for (uint i = 0; i < owners.length; i++) {
            if (msg.sender == owners[i]) {
                isOwner = true;
                break;
            }
        }
        require(isOwner, "Not an owner");
        _;
    }

    modifier proposalExists(uint _proposalId) {
        require(_proposalId < proposals.length, "Proposal does not exist");
        _;
    }

    modifier notExecuted(uint _proposalId) {
        require(!proposals[_proposalId].executed, "Proposal already executed");
        _;
    }

    constructor(address[] memory _owners, uint _threshold) {
        require(_owners.length > 0, "At least one owner required");
        require(_threshold > 0 && _threshold <= _owners.length, "Invalid threshold");

        owners = _owners;
        threshold = _threshold;
    }

    // 提交提案
    function submitProposal(address _recipient, uint _amount, bytes memory _data) public onlyOwner {
        proposals.push(Proposal({
            recipient: _recipient,
            amount: _amount,
            data: _data,
            confirmations: 0,
            executed: false
        }));
    }

    // 确认提案
    function confirmProposal(uint _proposalId) public onlyOwner proposalExists(_proposalId) notExecuted(_proposalId) {
        require(!confirmations[msg.sender][_proposalId], "Proposal already confirmed by you");

        proposals[_proposalId].confirmations += 1;
        confirmations[msg.sender][_proposalId] = true;

        // 如果确认数达到门槛，执行交易
        if (proposals[_proposalId].confirmations >= threshold) {
            executeProposal(_proposalId);
        }
    }

    // 执行提案
    function executeProposal(uint _proposalId) internal proposalExists(_proposalId) notExecuted(_proposalId) {
        Proposal storage proposal = proposals[_proposalId];
        (bool success, ) = proposal.recipient.call{value: proposal.amount}(proposal.data);
        require(success, "Transaction failed");

        proposal.executed = true;
    }

    // 获取当前提案数量
    function getProposalCount() public view returns (uint) {
        return proposals.length;
    }

    // 获取合约余额
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // 向合约存款
    receive() external payable {}
}
