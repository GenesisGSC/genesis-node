// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

//address 0xFE51faF5B8c975cc48161fF9b234A54A3F6795bf
interface IGP {
	/**
	 * @dev Returns the amount of tokens in existence.
	 */
	function totalSupply() external view returns (uint256);

	/**
	 * @dev Returns the token decimals.
	 */
	function decimals() external view returns (uint8);

	/**
	 * @dev Returns the token symbol.
	 */
	function symbol() external view returns (string memory);

	/**
	 * @dev Returns the token name.
	 */
	function name() external view returns (string memory);

	/**
	 * @dev Returns the amount of tokens owned by `account`.
	 */
	function balanceOf(address account) external view returns (uint256);

	/**
	 * @dev Moves `amount` tokens from the caller's account to `recipient`.
	 *
	 * Returns a boolean value indicating whether the operation succeeded.
	 *
	 * Emits a {Transfer} event.
	 */
	function transfer(address recipient, uint256 amount) external returns (bool);

	/**
	 * @dev Returns the remaining number of tokens that `spender` will be
	 * allowed to spend on behalf of `owner` through {transferFrom}. This is
	 * zero by default.
	 *
	 * This value changes when {approve} or {transferFrom} are called.
	 */
	function allowance(address _owner, address spender) external view returns (uint256);

	/**
	 * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
	 *
	 * Returns a boolean value indicating whether the operation succeeded.
	 *
	 * IMPORTANT: Beware that changing an allowance with this method brings the risk
	 * that someone may use both the old and the new allowance by unfortunate
	 * transaction ordering. One possible solution to mitigate this race
	 * condition is to first reduce the spender's allowance to 0 and set the
	 * desired value afterwards:
	 * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
	 *
	 * Emits an {Approval} event.
	 */
	function approve(address spender, uint256 amount) external returns (bool);

	/**
	 * @dev Moves `amount` tokens from `sender` to `recipient` using the
	 * allowance mechanism. `amount` is then deducted from the caller's
	 * allowance.
	 *
	 * Returns a boolean value indicating whether the operation succeeded.
	 *
	 * Emits a {Transfer} event.
	 */
	function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

	/**
	 * @dev Emitted when `value` tokens are moved from one account (`from`) to
	 * another (`to`).
	 *
	 * Note that `value` may be zero.
	 */
	event Transfer(address indexed from, address indexed to, uint256 value);

	/**
	 * @dev Emitted when the allowance of a `spender` for an `owner` is set by
	 * a call to {approve}. `value` is the new allowance.
	 */
	event Approval(address indexed owner, address indexed spender, uint256 value);

	/**
	 * @dev Converts a certain amount of caller's GC token to GP token using the
	 * allowance mechanism. `amount` is then deducted from the caller's
	 * GC Token allowance.
	 *
	 * Returns a boolean value indicating whether the operation succeeded.
	 *
	 */
	function exchange(uint256 amount) external returns (bool);

	/**
	 * @dev Whether the `sender` account  can transfer  to the `recipient` account .
	 *
	 * Returns a boolean value indicating whether have transfer permission.
	 *
	 */
	function transferable(address sender, address recipient) external view returns (bool);

	/**
	 * @dev Burn `amount` tokens and decreasing the total supply.
	 */
	function burn(uint256 amount) external returns (bool);

	/** @dev get exchange rate
	 **/
	function exchangeRate() external view returns (uint128);

	/* @dev update the exchange rate by admin
	 */
	function setExchangeRate(uint128 rate) external returns (bool);

	/* @dev admin account of GP
	 */
	function admin() external view returns (address);

	/* @dev change admin by old admin
	 */
	function changeAdmin(address new_admin) external returns (bool);

	event UpdateAdmin(address new_admin);
	event ChangeExchangeRate(uint128 rate);
}
