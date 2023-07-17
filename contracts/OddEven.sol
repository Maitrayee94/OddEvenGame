// SPDX-License-Identifier: WTFPL
pragma solidity ^0.8.3;

contract Roulette {
  uint betAmount;
  uint necessaryBalance;
  uint nextRoundTimestamp;
  address payable creator;
  uint256 maxAmountAllowedInTheBank;
  mapping (address => uint256) winnings;
  uint8[] payouts;
  uint8[] numberRange;
  
  /*
    BetTypes are as follows:
      0: color
      1: column
      2: dozen
      3: eighteen
      4: modulus
      5: number
      
    Depending on the BetType, number will be:
      color: 0 for black, 1 for red
      column: 0 for left, 1 for middle, 2 for right
      dozen: 0 for first, 1 for second, 2 for third
      eighteen: 0 for low, 1 for high
      modulus: 0 for even, 1 for odd
      number: number
  */
  
  struct Bet {
    address player;
    uint8 betType;
    uint8 number;
  }

  Bet[] public bets;
  
  constructor() {
    creator = payable(msg.sender);
    necessaryBalance = 0;
    nextRoundTimestamp = block.timestamp;
    payouts = [2, 3, 3, 2, 2, 36];
    numberRange = [1, 2, 2, 1, 2, 36];
    betAmount = 10000000000000000; // 0.01 ether
    maxAmountAllowedInTheBank = 200000000000000000; // 2 ether
  }

  event RandomNumber(uint256 number);
  
  function getStatus() public view returns (uint, uint, uint, uint, uint) {
    return (
      bets.length,             // number of active bets
      bets.length * betAmount, // value of active bets
      nextRoundTimestamp,      // when can we play again
      address(this).balance,   // roulette balance
      winnings[msg.sender]     // winnings of player
    ); 
  }
    
  function addEther() payable public {}

  function bet(uint8 number, uint8 betType) payable public {
    /* 
       A bet is valid when:
       1 - the value of the bet is correct (=betAmount)
       2 - betType is known (between 0 and 5)
       3 - the option betted is valid (don't bet on 37!)
       4 - the bank has sufficient funds to pay the bet
    */
    require(msg.value == betAmount);                           // 1
    require(betType >= 0 && betType <= 5);                      // 2
    require(number >= 0 && number <= numberRange[betType]);    // 3
    uint payoutForThisBet = payouts[betType] * msg.value;
    uint provisionalBalance = necessaryBalance + payoutForThisBet;
    require(provisionalBalance < address(this).balance);       // 4
    /* we are good to go */
    necessaryBalance += payoutForThisBet;
    bets.push(Bet({
      player: msg.sender,
      betType: betType,
      number: number
    }));
  }

  function spinWheel() public {
    /* are there any bets? */
    require(bets.length > 0);
    /* are we allowed to spin the wheel? */
    require(block.timestamp > nextRoundTimestamp);
    /* next time we are allowed to spin the wheel again */
    nextRoundTimestamp = block.timestamp;
    /* calculate 'random' number */
    uint diff = block.difficulty;
    bytes32 hash = blockhash(block.number - 1);
    Bet memory lb = bets[bets.length - 1];
    uint number = uint(keccak256(abi.encodePacked(block.timestamp, diff, hash, lb.betType, lb.player, lb.number))) % 37;
    /* check every bet for this number */
    for (uint i = 0; i < bets.length; i++) {
      bool won = false;
      Bet memory b = bets[i];
      if (number == 0) {
        won = (b.betType == 5 && b.number == 0);           // bet on 0
      } else {
        if (b.betType == 4) {
          if (b.number == 0) won = (number % 2 == 0);      // bet on even
          if (b.number == 1) won = (number % 2 == 1);      // bet on odd
        }                
      }
      /* if winning bet, add to player's winnings balance */
      if (won) {
        winnings[b.player] += betAmount * payouts[b.betType];
      }
    }
    /* delete all bets */
    delete bets;
    /* reset necessaryBalance */
    necessaryBalance = 0;
    /* check if there is too much money in the bank */
    if (address(this).balance > maxAmountAllowedInTheBank) takeProfits();
    /* return 'random' number to UI */
    emit RandomNumber(number);
  }
  
  function cashOut() public {
    address payable player = payable(msg.sender);
    uint256 amount = winnings[player];
    require(amount > 0);
    require(amount <= address(this).balance);
    winnings[player] = 0;
    player.transfer(amount);
  }
  
  function takeProfits() internal {
    uint amount = address(this).balance - maxAmountAllowedInTheBank;
    if (amount > 0) creator.transfer(amount);
  }
  
  function creatorKill() public {
    require(msg.sender == creator);
    selfdestruct(creator);
  }
}
