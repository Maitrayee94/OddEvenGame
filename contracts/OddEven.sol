// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

contract OddEvenGame {
    address payable public owner;
    uint256 public participationFee = 0.001 ether;
    uint256 public bettingLimit = 0.01 ether;
    uint256 public randomNumber;
    mapping(address => uint256) public playerBets;
    mapping(address => bool) public isPlayerParticipating;
    mapping(address => uint256) public playerWinnings;
    
    event GameResult(address indexed player, uint256 betAmount, uint256 winnings);
    
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the contract owner can call this function.");
        _;
    }
    
    function participate() external payable {
        require(!isPlayerParticipating[msg.sender], "You are already participating.");
        require(msg.value >= participationFee, "Insufficient participation fee.");
        
        isPlayerParticipating[msg.sender] = true;
    }
    
    function placeBet(uint256 bet) external {
        require(isPlayerParticipating[msg.sender], "You are not participating.");
        require(bet <= bettingLimit, "Bet amount exceeds the limit.");
        
        playerBets[msg.sender] = bet;
    }
    
    function generateRandomNumber() external onlyOwner {
        randomNumber = uint256(keccak256(abi.encodePacked(block.timestamp, blockhash(block.number - 1))));
    }
    
    function distributeWinnings() external onlyOwner {
    for (uint256 i = 0; i < address(this).balance; i += participationFee) {
        address payable player = payable(address(uint160(i)));

        if (playerBets[player] % 2 == randomNumber % 2) {
            uint256 winnings = playerBets[player] * 2;
            playerWinnings[player] = winnings;
            player.transfer(winnings);
            emit GameResult(player, playerBets[player], winnings);
        }
    }
}

    
    function withdrawWinnings() external {
        require(playerWinnings[msg.sender] > 0, "You have no winnings to withdraw.");
        
        uint256 winnings = playerWinnings[msg.sender];
        playerWinnings[msg.sender] = 0;
        payable(msg.sender).transfer(winnings);
        emit GameResult(msg.sender, 0, winnings);
    }
    
    function withdrawFunds() external onlyOwner {
        require(address(this).balance > 0, "No funds to withdraw.");
        
        owner.transfer(address(this).balance);
    }
}
