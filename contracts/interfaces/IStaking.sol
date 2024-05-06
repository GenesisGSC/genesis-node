// SPDX-License-Identifier: MIT

/*
------------------------update logs-------------------------------------------------------------------------------------

2024-03-30
1.[delete] beValidater 规则更改，不能手动

2.
  [add] isValidator(node), @return true: the node is one of the validators to product blocks 等效于 nodeStatus = 3

2. unbond 条件
  if nodeStatus = 1 可以unbond 至剩余未0
  if nodeStatus = 2 or 3 unbond 后剩余至少是 getMinStakeAmount

  unbond 后两个Era周期 可以 withdraw

3. leave
   任何状态都能请求。请求后，不在参与竞选。
   if nodeStatus = 3, 将持续在队列中直至下一个Era周期, 而后 nodeStatus 将 = 1
   nodeStatus = 1, 请求 unbond 可提前剩余的所有质押
   if call `withdraw`
     if 剩余 getLocked.  withdrawable = 0 And locked = 0
     系统将清除该节点数据，已产生的待释放不受影响

-------------------------------------------------------------------------------------
*/

pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

struct NodeInfo {
	//node address
	address node;
	//Staking total amount
	uint128 total;
}
//address 0x25201e6ba6E025eF496eDFD9A5AFe501CDc308e3
interface IStaking {
	/* @dev apple to be a candidate
     '_contract'： node 's contract
     'amount'：Staking `amount` of GPs to the node
     'authorId': the result of run "author_rotateKeys" from node 128 bytes
     */
	function join(address _contract, uint256 amount, bytes calldata authorId) external returns (bool);

	/* @dev out of candidates by node ownner,
    after call this , the node will be not in the line for campaign (1024) elected any more
    the nodeStatus() will be always = 1 , if it unbond and withdraw all his GP, the nodeStatus() = 0
    */
	function leave() external returns (bool);

	/**
	 * @dev Get the current operating status of the chain .
	 *
	 * Returns a boolean value indicating whether it can be operated.
	 *
	 * Note: If it is in the last 20 blocks of the campaign, it will be inoperable .
	 * If the chain is inoperable, means can't deposit and withdraw GP, but still
	 * can withdraw the block reward GS.
	 */
	function chainOperateStatus() external view returns (bool);

	/* @dev  Returns electeds
    'node' node address
    'total' Staking total amount
    */
	function electeds() external view returns (NodeInfo[] memory nodes);

	/* @dev Returns candidates
    'node' node address
    'total' Staking total amount
    */
	function candidates() external view returns (NodeInfo[] memory nodes);

	/**
	 * @dev Get the node contract address
	 *
	 */
	function getNodeContract(address nodeAccount) external view returns (address);
	/**
	 * @dev Get the current status of the node .
	 *
	 * Returns :
	 *     0- not a node
	 *     1- Candidate status
	 *     2- Elected status
	 *     3- Elected status and selected as the current verification nodes
	 */
	function nodeStatus(address) external view returns (uint256);

	/*
    true: the node is one of the validators to product blocks
          same as nodeStatus() = 3
    */
	function isValidator(address) external view returns (bool);

	/**
	 * @dev Get the minimum pledge amount of GP for node .
	 *
	 */
	function getMinStakeAmount() external view returns (uint256);

	/**
	 * @dev Get the node account bound to the current contract .
	 *
	 */
	function getNodeAccount(address contractAddress) external view returns (address);

	/**
	 * @dev Returns the GP amount of tokens owned by `account` of node.
	 */
	function GPBalanceOf(address nodeAccount) external view returns (uint256);

	/**
	 * @dev Staking `amount` of GPs to the node using the allowance mechanism.
	 * `amount` is then deducted from the `account`'s GP Token allowance.
	 *
	 * Returns a boolean value indicating whether the operation succeeded.
	 *
	 * Note: If the chainOperateStatus=false or the nodeStatus=0 , returns false;
	 * otherwise returns true.
	 *
	 */
	function depositFrom(address account, uint256 amount) external returns (bool);

	/**
    get the withdrawable and locked amount by a node account
    */
	function getLocked(address nodeAccount) external view returns (uint256 withdrawable, uint256 locked);

	/**
    move `amount` of GPs to getLocked().locked, it will be withdrawable on next Era
    if nodeStatus() = 1, can unbond all of GP
    if nodeStatus() =2 /3, at lease remain getMinStakeAmount() of GP
    */
	function unbond(uint256 amount) external returns (bool);

	/**
    withdraw all withdrawable of GPs to `recipient`
    after call `withdraw`
      if nodeStatus() == 1 and remain GP = 0, locked = 0 chill his node info
    */
	function withdrawTo(address recipient) external returns (uint256);

	/* @dev update contract by node ownner
    '_contract':new contract address
     */
	function updateContract(address _contract) external returns (bool);

	/* @dev update AuthorId by node ownner
     'author_id':the key of running node
     */
	function updateAuthorId(bytes calldata author_id) external returns (bool);

	/*  @dev get the author_id status, false:not used, true: used
	 */
	function isUsedAuthorId(bytes calldata author_id) external view returns (bool);

	/*  @dev get the author_id of node
	 */
	function authorIdOf(address node) external view returns (bytes memory);

	event Join(address indexed who, address indexed contract_address, uint256 amount);
	event Leave();
	event Deposit(address indexed node, address indexed who, uint256 amount);
	event Unbond(address indexed node, uint256 amount);
	event Withdraw(address indexed node, address indexed who, uint256 amount);
	event UpdateContract(address);
}
