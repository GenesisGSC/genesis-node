// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IGenesisNodeFactory {
	event NodeCreated(address nodeAccount, address node, uint256);
	event ClaimedGSRewardsCount(uint256 userIndex);

	function allNodes(uint256) external view returns (address node);
	function allNodesLength() external view returns (uint256);
	function depositAddressListLength() external view returns (uint256);
	function userDepositListLength() external view returns (uint256);

	function applyNode(
		uint256 amount,
		bytes calldata authorID,
		uint256 _commissionRate,
		uint256 _commissionMaxRate,
		uint256 _commissionMaxChangeRate
	) external returns (address node);

	function joinFactory(
		uint256 _commissionRate,
		uint256 _commissionMaxRate,
		uint256 _commissionMaxChangeRate
	) external returns (address node);
	function abortNode() external returns (bool);
	function getUserDepositList(address account) external returns (address[] memory nodes);
	function getNodeAccount(address nodeContract) external view returns (address);
	function getNodeContract(address nodeAccount) external view returns (address);
	function inNodeList(address nodeContract) external view returns (bool);
	function addUserDepositList(address account) external;
	function removeUserDepositList(address account) external;

	function withdrawAllAbortNodeContracts() external returns (bool);
	function getWithdrawAllBalances(
		address account
	) external view returns (uint256 gpBalance, uint256 gsBalance, uint256 wBalance);
}
