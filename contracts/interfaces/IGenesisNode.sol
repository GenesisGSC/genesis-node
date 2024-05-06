// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

interface IGenesisNode {
	function totalSharePoint() external view returns (uint256);
	function GPBalanceOf(address account) external view returns (uint256);
	function GSBalanceOf(address account) external view returns (uint256, uint256);
	function deposit(uint256 amount) external returns (bool);
	function withdrawReward() external returns (bool);
	function claimGsRewards(address account) external returns (bool);
	function sendBack() external returns (bool);
	function redeemable() external returns (bool);
	function getSendBackAmount(
		address account
	) external view returns (uint256 gpAmount, uint256 gsAmount, uint256 wBalance);
	function initialize(
		address account,
		uint256 amount,
		uint256 _commissionRate,
		uint256 _commissionMaxRate,
		uint256 _commissionMaxChangeRate
	) external;
	function setCommission(uint256 newCommission) external;
	function getUserSharePoint(address account) external view returns (uint256 sharePoint);
	function sendBackByFactory(address account) external returns (bool);
	function getNodeData()
		external
		view
		returns (
			uint256 _commissionRate,
			uint256 _commissionMaxRate,
			uint256 _commissionMaxChangeRate,
			address _nodeAccount,
			address _contractAddress,
			uint256 _gpTotal,
			uint256 _rBalance,
			uint256 _wBalance,
			uint256 _lastDepositTime,
			uint256 _blocks
		);
}
