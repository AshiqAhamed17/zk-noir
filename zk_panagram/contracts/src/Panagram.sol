// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IVerifier} from "./Verifier.sol";


contract Panagram is ERC1155, Ownable {

    ////////// State Variables ///////////////
    IVerifier public  verifier;
    bytes32 public s_answer;
    uint256 public constant MIN_DURATION = 10800; //3 hrs
    uint256 public s_roundStartTime;
    address public s_currentRoundWinner;
    uint256 public s_currentRound;


    //////////// EVENTS ///////////////
    event Panagram_VerifierUpdate(IVerifier verifier);
    event Panagram_NewRoundStarted(bytes32 answer);


    //////////// ERROR //////////////
    error Panagram_MinTimeNotPassed(uint256 minTime, uint256 passedTime);
    error Panagram_NoRoundWinner();
    
    constructor(IVerifier _verifier) ERC1155("ipfs://bafybeicqfc4ipkle34tgqv3gh7gccwhmr22qdg7p6k6oxon255mnwb6csi/{id}.json") Ownable(msg.sender){
        verifier = _verifier;
    }

    ///function to create a new round
    function newRound(bytes32 _answer) external onlyOwner() {
        if(s_roundStartTime == 0) { // First Round
            s_roundStartTime = block.timestamp;
            s_answer = _answer;
        }
        else { // Subsequent Round
            if(block.timestamp < s_roundStartTime + MIN_DURATION) { 
                revert Panagram_MinTimeNotPassed(MIN_DURATION, block.timestamp - s_roundStartTime);
            }
            if(s_currentRoundWinner == address(0)) { // Previous round must have a winner to start a new one.
                revert Panagram_NoRoundWinner();
            }

            //Reset for next round
            s_roundStartTime = block.timestamp;
            s_currentRoundWinner = address(0);
            s_answer = _answer;

        }
        s_currentRound++;
        emit Panagram_NewRoundStarted(_answer);
    }

    /// Function to allow users to submit a guess

    /// Sets a new Verifier
    function setVerifier(IVerifier _verifier) external onlyOwner {
        verifier = _verifier;
        emit Panagram_VerifierUpdate(_verifier);
    }



}  