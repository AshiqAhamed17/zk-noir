// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IVerifier} from "./Verifier.sol";


contract Panagram is ERC1155, Ownable {

    ////////// State Variables ///////////////
    IVerifier public s_verifier;
    bytes32 public s_answer;
    uint256 public constant MIN_DURATION = 10800; //3 hrs
    uint256 public s_roundStartTime;
    address public s_currentRoundWinner;
    uint256 public s_currentRound;
    mapping (address => uint256) public s_lastCorrectGuessRound;


    //////////// EVENTS ///////////////
    event Panagram_VerifierUpdate(IVerifier verifier);
    event Panagram_NewRoundStarted(bytes32 answer);
    event Panagram_WinnerCrowned(address indexed winner, uint256 round);
    event Panagram_RunnerUpCrowned(address indexed runnerup, uint256 indexed round);


    //////////// ERROR //////////////
    error Panagram_MinTimeNotPassed(uint256 minTime, uint256 passedTime);
    error Panagram_NoRoundWinner();
    error Panagram_FirstPanagramNotStarted();
    error Panagram_AlreadyGuessedCorrectly(uint256 round, address guesser);
    error Panagram_InvalidProof();
    
    constructor(IVerifier _verifier) ERC1155("ipfs://bafybeicqfc4ipkle34tgqv3gh7gccwhmr22qdg7p6k6oxon255mnwb6csi/{id}.json") Ownable(msg.sender){
        s_verifier = _verifier;
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
    function makeGuess(bytes memory proof) external returns (bool) {
        //Check weather the first round has been started
        if(s_currentRound == 0) {
            revert Panagram_FirstPanagramNotStarted();
        }
        //check if the user has already guessed correctly
        if(s_lastCorrectGuessRound[msg.sender] == s_currentRound) {
            revert Panagram_AlreadyGuessedCorrectly(s_currentRound, msg.sender);
        }
        //check the proof and verify it with the verifier contract
        bytes32[] memory publicInputs = new bytes32[](1);
        publicInputs[0] = s_answer;
        bool proofResult = s_verifier.verify(proof, publicInputs);
        if(!proofResult) {
            revert Panagram_InvalidProof();
        }
        s_lastCorrectGuessRound[msg.sender] = s_currentRound;

        //if correct check if they are first and mint them NFT with id 0
        //if correct and not first then mint them NFT with id 1
        if(s_currentRoundWinner == address(0)) {
            s_currentRoundWinner = msg.sender;
            _mint(msg.sender, 0, 1, "");
            emit Panagram_WinnerCrowned(msg.sender, s_currentRound);
        }
        else {
            _mint(msg.sender, 1, 1, "");
            emit Panagram_RunnerUpCrowned(msg.sender, s_currentRound);
        }

        return proofResult;
    }

    /// Sets a new Verifier
    function setVerifier(IVerifier _verifier) external onlyOwner {
        s_verifier = _verifier;
        emit Panagram_VerifierUpdate(_verifier);
    }



}  