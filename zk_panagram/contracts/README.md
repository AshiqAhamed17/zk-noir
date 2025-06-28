# ZK Panagram

- Each `answer` is a `round`
- The owner is the only person that can start the round
- The round needs to have a minimum duration
- There needs to be a `winner` to start the next round
- The contract needs to be an NFT contract 
    - ERC-1155 (token_id 0 for `winners` and token_id 1 for `runners up`)
    - `Mint ID 0` if the user is the first person to guess correctly in the round
    - `Mint ID 1` if they got it correct but not the first one in that round
- To check if the users guess is correct we will call the `Verifier` smart contract