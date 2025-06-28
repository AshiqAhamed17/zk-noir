// SPDX-License-Identifier: MIT
pragma solidity >=0.8.21;

import {ERC1155} from "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import {IVerifier} from "./Verifier.sol";


contract Panagram is ERC1155 {
    IVerifier public immutable verifier;

    constructor(IVerifier _verifier) ERC1155("ipfs://bafybeicqfc4ipkle34tgqv3gh7gccwhmr22qdg7p6k6oxon255mnwb6csi/{id}.json") {
        verifier = _verifier;
    }

}