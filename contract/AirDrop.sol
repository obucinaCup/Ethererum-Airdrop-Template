// SPDX-License-Identifier: MIT

pragma solidity >=0.8.10;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract AirDrop is ERC20 {
    mapping(address => bool) public processedAirdrop;

    address private owner;
    address[] public airdropAddressList;
    uint256 eachClaimAmount = 1000;
    uint256 public maxAirdropAmount;
    uint256 public currentAirdropAmount;
    uint256 TotolToken = 100000;

    constructor() ERC20("Air Token", "ATN") {
        _mint(msg.sender, TotolToken * 10**18);
        owner = msg.sender;
        maxAirdropAmount = (3 * totalSupply()) / 10; // Max amount for Air drop is allocatied to 30% of total supply.
    }

    event AirdropProcessed(address _recipient, uint256 _date);
    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner can perform this action");
        _;
    }

    function withdraw(uint256 _amount) public onlyOwner {
        _transfer(msg.sender, address(this), _amount);
        maxAirdropAmount += _amount;
    }

    function claimToken(address _recipient) external {
        uint256 index;
        uint8 flag = 1;
        require(
            processedAirdrop[_recipient] == false,
            "Airdrop already Processed for this address"
        );

        for (uint256 i = 0; i < airdropAddressList.length; i++) {
            if (airdropAddressList[i] == _recipient) {
                index = i;
                flag = 0;
                break;
            }
        }
        require(
            flag == 0 || airdropAddressList[index] == _recipient,
            "This address is not eligible for the airdrop"
        );
        require(
            currentAirdropAmount + eachClaimAmount <= maxAirdropAmount,
            "Airdropped 100% of the allocated amount"
        );
        processedAirdrop[_recipient] = true;
        currentAirdropAmount += eachClaimAmount;
        _transfer(owner, _recipient, eachClaimAmount);
        emit AirdropProcessed(_recipient, block.timestamp);
    }

    // This function will let the admin to add specific address for the Airdrop.
    function addAddressForAirDrop(address _address) public onlyOwner {
        airdropAddressList.push(_address);
    }

    function getMaxAirdropAmount() external view returns (uint256) {
        return maxAirdropAmount;
    }

    function getCurrentAirdropAmount() external view returns (uint256) {
        return currentAirdropAmount;
    }

    function getWhitelistedAddress() external view returns (address[] memory) {
        return airdropAddressList;
    }

    function getProcessedAirdrop(address _address)
        external
        view
        returns (bool)
    {
        return processedAirdrop[_address];
    }
}
