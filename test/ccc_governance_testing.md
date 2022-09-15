contract deployed at 0x4a795FFa3B5367642D21169DC23c26CdeDde1d16

updateProposalFee
- Correctly updates fee when called by the contract owner
- Throws an error when called by a non-owner of the contract but does attempt the txn first and charge gas fees. On EVM Metamask throws the error before attempting and using gas.

propose
- Throws an error when attempting to propose something. Root cause is unclear but may be that there is no governance address to transfer the fee to.
- This was the issue 

contract deployed locally with all three ERC20 tokens already deployed locally and entered into contract

propose
- Attempting to submit a proposal without sending the 50 fee throws the expected error
- submitting a proposal with the 50 fee logs the proposal and sends the 50 fee to the governance wallet
    - currently able to propose two proposals at a time, appears to have something to do with the iteration?
    - had to remove && from require statement because it was checking for either condition and not both
    - when a proposal or project is approved, denied, completed, or canceled the addresses revert to 0 so that it does not flag any require statements

vote
- attempting to vote on your own proposal throws the expected error
- attempting to vote without one of the three ERC20 tokens throws the expected error
- vote successfull when voting while holding a dev or artist token
- attempting to vote on a proposal that you have already voted on throws the expected error
    -currently able to vote on non-existing proposal ids
    -fixed by removing '0' from the states so that a pending proposal has a state of '1' not '0'
- 




