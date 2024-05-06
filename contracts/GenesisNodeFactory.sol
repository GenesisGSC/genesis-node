// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "./interfaces/IGenesisNodeFactory.sol";
import "./interfaces/IStaking.sol";
import "./interfaces/IGenesisNode.sol";
import "./GenesisNode.sol";

contract GenesisNodeFactory is IGenesisNodeFactory {
	address public constant STAKING_ADDRESS = 0x25201e6ba6E025eF496eDFD9A5AFe501CDc308e3;
	address[] public override allNodes;
	address[] public depositAddressList;
	address public owner;
	uint256 public saltID;
	uint256 public gasLimit = 5000000;
	uint256 public claimCount = 3;
	uint256 public claimGsAmount = 10;

	mapping(address => bool) inNodes;
	mapping(address => address[]) public UserDepositList; //user:{nodeCA1, nodeCA2...}
	mapping(address => mapping(address => bool)) inUserDepositList;

	modifier onlyOwner() {
		require(owner == msg.sender, "GenesisNodeFactory: No permission");
		_;
	}

	constructor() {
		owner = msg.sender;
	}

	function applyNode(
		uint256 amount,
		bytes calldata authorID,
		uint256 _commissionRate,
		uint256 _commissionMaxRate,
		uint256 _commissionMaxChangeRate
	) public override returns (address node) {
		require(IStaking(STAKING_ADDRESS).chainOperateStatus(), "Genesis: the gesesis chain is not on work.");
		require(getNodeContract(msg.sender) == address(0), "Genesis: the caller have active node.");
		require(
			IStaking(STAKING_ADDRESS).getMinStakeAmount() <= amount,
			"Genesis: amount less than minimum stake amount"
		);
		require(_commissionRate >= 0 && _commissionRate <= 10000, "Genesis: parameter invalid.");
		require(
			_commissionMaxRate <= 10000 &&
				_commissionRate <= _commissionMaxRate &&
				_commissionMaxChangeRate <= _commissionMaxRate,
			"Genesis: parameter invalid."
		);

		bytes memory bytecode = type(GenesisNode).creationCode;
		bytes32 salt = keccak256(abi.encodePacked(saltID));
		assembly {
			node := create2(0, add(bytecode, 32), mload(bytecode), salt)
		}
		require(node != address(0), "Genesis: Failed on deploy");
		saltID++;
		allNodes.push(node);
		emit NodeCreated(msg.sender, node, allNodes.length);

		(bool succeeded, ) = STAKING_ADDRESS.delegatecall(
			abi.encodeWithSignature("join(address,uint256,bytes)", node, amount, authorID)
		);
		if (!succeeded) return address(0);

		inNodes[node] = true;

		IGenesisNode(node).initialize(
			msg.sender,
			amount,
			_commissionRate,
			_commissionMaxRate,
			_commissionMaxChangeRate
		);
	}

	function joinFactory(
		uint256 _commissionRate,
		uint256 _commissionMaxRate,
		uint256 _commissionMaxChangeRate
	) public override returns (address node) {
		require(IStaking(STAKING_ADDRESS).chainOperateStatus(), "Genesis: the gesesis chain is not on work.");
		require(_commissionRate >= 0 && _commissionRate <= 10000, "Genesis: parameter invalid.");
		require(
			_commissionMaxRate <= 10000 &&
				_commissionRate <= _commissionMaxRate &&
				_commissionMaxChangeRate <= _commissionMaxRate,
			"Genesis: parameter invalid."
		);
		require(IStaking(STAKING_ADDRESS).nodeStatus(msg.sender) != 0, "Genesis: the caller is not a node");
		require(!inNodeList(getNodeContract(msg.sender)), "Genesis: the caller's node contract has already in factory");
		uint256 amount = IStaking(STAKING_ADDRESS).GPBalanceOf(msg.sender);
		require(amount > 0, "Genesis: the caller has no any GP on the chain");

		bytes memory bytecode = type(GenesisNode).creationCode;
		bytes32 salt = keccak256(abi.encodePacked(saltID));
		assembly {
			node := create2(0, add(bytecode, 32), mload(bytecode), salt)
		}
		require(node != address(0), "Genesis: Failed on deploy");
		saltID++;
		allNodes.push(node);
		emit NodeCreated(msg.sender, node, allNodes.length);

		(bool succeeded, ) = STAKING_ADDRESS.delegatecall(abi.encodeWithSignature("updateContract(address)", node));
		if (!succeeded) return address(0);

		inNodes[node] = true;

		IGenesisNode(node).initialize(
			msg.sender,
			amount,
			_commissionRate,
			_commissionMaxRate,
			_commissionMaxChangeRate
		);
	}

	function setClaimGsParam(
		uint256 _gasLimit,
		uint256 _claimCount,
		uint256 _claimGsAmount
	) public onlyOwner returns (bool) {
		gasLimit = _gasLimit;
		claimCount = _claimCount;
		claimGsAmount = _claimGsAmount;
		return true;
	}

	function allNodesLength() external view override returns (uint256) {
		return allNodes.length;
	}

	function depositAddressListLength() external view override returns (uint256) {
		return depositAddressList.length;
	}

	function userDepositListLength() external view override returns (uint256) {
		return UserDepositList[msg.sender].length;
	}

	function getUserDepositList(address account) external view override returns (address[] memory nodes) {
		return UserDepositList[account];
	}

	function abortNode() public override returns (bool succeeded) {
		require(IStaking(STAKING_ADDRESS).chainOperateStatus(), "Genesis: the gesesis chain is not on work.");
		require(getNodeContract(msg.sender) != address(0), "Genesis: caller not join candidates.");

		(succeeded, ) = STAKING_ADDRESS.delegatecall(abi.encodeWithSignature("leave()"));

		return succeeded;
	}

	function getNodeAccount(address nodeContract) public view override returns (address) {
		return IStaking(STAKING_ADDRESS).getNodeAccount(nodeContract);
	}

	function getNodeContract(address nodeAccount) public view override returns (address) {
		return IStaking(STAKING_ADDRESS).getNodeContract(nodeAccount);
	}

	function inNodeList(address nodeContract) public view override returns (bool) {
		return inNodes[nodeContract];
	}

	function addUserDepositList(address account) external override {
		address nodeContract = msg.sender;
		require(inNodes[nodeContract], "Genesis: caller not nodeContract");
		if (!inUserDepositList[account][nodeContract]) {
			UserDepositList[account].push(nodeContract);
			inUserDepositList[account][nodeContract] = true;
			depositAddressList.push(account);
		}
	}

	function removeUserDepositList(address account) external override {
		address nodeContract = msg.sender;
		require(inNodes[nodeContract], "Genesis: caller not nodeContract");
		if (inUserDepositList[account][nodeContract]) {
			address[] storage tmp = UserDepositList[account];
			uint256 _length = tmp.length;
			for (uint256 i = 0; i < _length; i++) {
				if (tmp[i] == nodeContract) {
					tmp[i] = tmp[_length - 1];
					inUserDepositList[account][nodeContract] = false;
					tmp.pop();
					break;
				}
			}
		}
	}

	function withdrawAllAbortNodeContracts() public override returns (bool) {
		address[] memory _userDepositList = UserDepositList[msg.sender];
		for (uint256 i = 0; i < _userDepositList.length; i++) {
			if (IGenesisNode(_userDepositList[i]).getUserSharePoint(msg.sender) > 0) {
				address nodeAccount = IStaking(STAKING_ADDRESS).getNodeAccount(_userDepositList[i]);
				uint256 nodeStatus = IStaking(STAKING_ADDRESS).nodeStatus(nodeAccount);

				if (nodeStatus == 0 || nodeStatus == 1) {
					IGenesisNode(_userDepositList[i]).sendBackByFactory(msg.sender);
				}
			}
		}
		return true;
	}

	function userClaimGsRewards(address[] memory _address) external {
		require(_address.length > 10, "Genesis: too many address");
		for (uint256 i = 0; i < _address.length; i++) {
			IGenesisNode(_address[i]).claimGsRewards(msg.sender);
		}
	}

	function claimGsRewards(uint256 userIndex) external {
		uint256 userCount = depositAddressList.length;
		uint256 iterations = 0;
		if (userIndex != 0) {
			iterations = userIndex;
		}
		uint256 gasUsed = 0;
		uint256 gasLeft = gasleft();
		require(gasLeft > gasLimit, "Genesis: Not enough gas");

		while (gasUsed < gasLimit && iterations < userCount) {
			address _address = depositAddressList[iterations];
			address[] memory _userDepositList = UserDepositList[_address];
			for (uint256 j = 0; j < _userDepositList.length; j++) {
				if (j > claimCount) {
					break;
				}
				address nodeAddress = _userDepositList[j];
				(, uint256 wBalance) = IGenesisNode(nodeAddress).GSBalanceOf(_address);
				if (wBalance > claimGsAmount) {
					IGenesisNode(nodeAddress).claimGsRewards(_address);
				}
			}
			iterations += 1;
			gasUsed = gasUsed + (gasLeft - (gasleft()));
			gasLeft = gasleft();
		}
		emit ClaimedGSRewardsCount(iterations);
	}

	function getWithdrawAllBalances(
		address account
	) public view override returns (uint256 gpBalance, uint256 gsBalance, uint256 wBalance) {
		for (uint256 i = 0; i < UserDepositList[account].length; i++) {
			if (IGenesisNode(UserDepositList[account][i]).getUserSharePoint(account) > 0) {
				(uint256 gpa, uint256 gsa, uint256 wgs) = IGenesisNode(UserDepositList[account][i]).getSendBackAmount(
					account
				);
				gpBalance += gpa;
				gsBalance += gsa;
				wBalance += wgs;
			}
		}
	}
}
