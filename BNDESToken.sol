pragma solidity ^0.6.0;

contract BNDESToken {
    using SafeMath for uint256;
    
    mapping (address => uint256) public _bookedBalances;
    mapping (address => uint256) public _confirmedBalances;
    uint256 public _bookedTotalSupply;
    uint256 public _confirmedTotalSupply;
    
    event DonationBooked(address, uint256);
    event DonationConfirmed(address, uint256);
    event DonationAllocated(address, address, uint256);
    event RedemptionRequested(address, uint256);
    
    event Transfer(address, address, uint256);
    event Burned(address, uint256);
    event Redeemed(address, uint256);
    
    //Donor books a donation
    function bookDonation(uint256 amount) public whenNotPaused onlyDonor {
        address account = msg.sender;
        _bookedTotalSupply = _bookedTotalSupply.add(amount);
        _bookedBalances[account] = _bookedBalances[account].add(amount);
        emit DonationBooked(account, amount);
    }
    
    //BNDES confirms the donor's donation
    function confirmDonation(address account, uint256 amount) public whenNotPaused onlyBNDES {
        _bookedTotalSupply = _bookedTotalSupply.sub(amount);
        _confirmedTotalSupply = _confirmedTotalSupply.add(amount);
        
        _bookedBalances[account] = _bookedBalances[account].sub(amount);
        _confirmedBalances[account] = _confirmedBalances[account].add(amount);
        
        emit DonationConfirmed(account, amount);
    }
    
    //BNDES transfer donations to a client
    function allocateDonation(address donor, address client, uint256 amount) public whenNotPaused onlyBNDES {
        _transfer(donor, client, amount);
        emit DonationAllocated(donor, client, amount);
    }
    
    //BNDES transfer many donations to a client
    function allocateManyDonation(address[] memory donor, address client, uint256[] memory amount) public whenNotPaused onlyBNDES {
        for (uint i=0; i<donor.length; i++) {
            _transfer(donor[i], client, amount[i]);
            emit DonationAllocated(donor[i], client, amount[i]);    
        }
    }
    
    //Client request a redemption
    function requestRedemption(uint256 amount) public whenNotPaused onlyClient {
        emit RedemptionRequested(msg.sender, amount);
    }
    
    //BNDES redeems to the Client
    function redeem (address to, uint256 value) public whenNotPaused onlyBNDES returns (bool) {
        _burn(to, value);
        emit Redeemed(to, value);
        return true;
    }
    
    //BNDES burns confirmedBalances
    function _burn(address account, uint256 amount) internal onlyBNDES {
        require(account != address(0), "burn from the zero address");

        _confirmedBalances[account] = _confirmedBalances[account].sub(amount, "burn amount exceeds balance");
        _confirmedTotalSupply = _confirmedTotalSupply.sub(amount);
        emit Burned(account, amount);
    }
    
    //BNDES transfers confirmedBalances from a sender to a receiver
    function _transfer(address sender, address recipient, uint256 amount) internal onlyBNDES {
        require(sender != address(0), "transfer from the zero address");
        require(recipient != address(0), "transfer to the zero address");

        _confirmedBalances[sender] = _confirmedBalances[sender].sub(amount, "transfer amount exceeds balance");
        _confirmedBalances[recipient] = _confirmedBalances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }
    
    
    modifier whenNotPaused() {
        // TODO !!!
        _;
    }
    
    modifier onlyBNDES() {
        // TODO !!!
        //require(isBNDES());
        _;
    }
    
    modifier onlyDonor() {
        // TODO !!!
        _;
    }
    
    modifier onlyClient() {
        // TODO !!!
        //require(isClient());
        _;
    }    
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * _Available since v2.4.0._
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     *
     * _Available since v2.4.0._
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
