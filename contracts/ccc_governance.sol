//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;


import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract ccc_governance is ReentrancyGuard, Ownable {
  using Counters for Counters.Counter;
  Counters.Counter private _proposalIds;
  Counters.Counter private _projectIds;
    

// Initial variables 
  uint256 public minCost = 1500; //USD minimum cost for a project to be activated need to convert from ONE to USD, may need a setter function depending on how that will work
  uint256 public proposalFee = 50; //USD non-refundable fee that gets sent to the governance multisig wallet when a proposal is created - add getter and setter (Devon will do some research on how to do this without an oracle)
  address investorToken = address(0); // investor tokens will be distributed after a project is successfully completed. 
  address developerToken = address(0); // developer tokens will be airdropped upon approval from the Governance team 
  address artistToken = address(0); // artist tokens will be airdropped upon approval from the Governance team 
 address payable governanceWallet = payable(0); // Multisig wallet for funding creator grants  
uint256 public Delay = 43211; // number of blocks that equals 1 day (on EVM) need to figure out what this is for Harmony (ask Discord) and probably add getter and setter for this
  uint256 public votingPeriod = 302474;// number of blocks that equals 1 week (on EVM) need to figure out what this is for Harmony (ask Discord) and probably add getter and setter for this
  uint8 public quorum = 4; // amount of total token holders required to vote in support (i.e. a quorum value of 4 indicates one quarter of all token holders must vote in favor for something to pass) add getter and setter
//32768 blocks (approx 18.2 hours)
  // Struct for listing proposals 
 struct Proposal {
    uint proposalId;
    address proposalOwner;
    string proposalDescription;
    uint256 votes;
    bool devNeeded;
    bool artNeeded;
    uint256 deadline;
    uint proposalStatus;
  }
  // Struct for listing projects 
 struct Project {
    uint projectId;
    address payable projectOwner;
    string projectDescription;
    bool devNeeded;
    bool artNeeded;
    address payable developer;
    address payable artist;
    uint256 devCost;
    uint256 artCost;
    uint256 votes;
    uint projectStatus;
  }

// Mapping to assign IDs to proposals 
  mapping(uint256 => Proposal) private idToProposal; // need to create a view function to view proposals or can we view these mappings from the front end using JSON?
// Mapping to assign IDs to projects 
  mapping(uint256 => Project) private idToProject; // need to create a view function to view projects or can we view these mappings from the front end using JSON?
// Mapping to track voters   
  mapping (address => mapping (uint => bool)) voteRegistry;
// Mapping for developer bids
  mapping (address => mapping (uint => uint256)) developerBids; // need to create a view function to view bids or can we view these mappings from the front end using JSON?
// Mapping for artist bids
  mapping (address => mapping (uint => uint256)) artistBids; // need to create a view function to view bids or can we view these mappings from the front end using JSON?
// Mapping to track project complete voters   
  mapping (address => mapping (uint => bool)) completeVoteRegistry;
// Mapping to track project cancel voters   
  mapping (address => mapping (uint => bool)) cancelVoteRegistry;  

// Event to emit for each proposal created
  event ProposalCreated (
    uint indexed proposalId,
    address indexed proposalOwner,
    string proposalDescription,
    uint256 votes,  
    bool devNeeded,
    bool artNeeded,
    uint256 deadline,
    uint proposalStatus // 1 is pending, 2 is approved, and 3 is denied
  );

// Event to emit for each project created
  event ProjectCreated (
    uint indexed projectId,
    address indexed projectOwner,
    string projectDescription,
    bool devNeeded,
    bool artNeeded,
    address developer,
    address artist,
    uint256 devCost,
    uint256 artCost,
    uint256 votes,
    uint projectStatus // 1 is pending, 2 is active, 3 is complete requested, 4 is complete, 5 is cancel requested, and 6 is canceled
  );  

// Event to emit when someone has voted
  event ProposalVote (
      uint indexed proposalId,
      address indexed voter,
      bool support
  );

// Event to emit when a developer has bid on a project
  event DevBid (
      uint indexed projectId,
      address indexed devAddress,
      uint256 devAmount
  );

// Event to emit when a artist has bid on a project
  event ArtBid (
      uint indexed projectId,
      address indexed artAddress,
      uint256 artAmount
  );

// Event to emit when project completion approval is requested
  event RequestComplete (
      uint indexed projectId,
      address indexed projectOwner,
      string justification
  );  

// Event to emit when someone has voted to complete a project
  event CompleteVote (
      uint indexed projectId,
      address indexed voter,
      bool support
  );

// Event to emit when a project has been completed
  event ProjectComplete (uint indexed projectId);

// Event to emit when project cancelation approval is requested
  event RequestCancel (
      uint indexed projectId,
      address indexed projectOwner,
      string justification
  );  

// Event to emit when someone has voted to cancel a project
  event CancelVote (
      uint indexed projectId,
      address indexed voter,
      bool support
  );

// Event to emit when a project has been canceled
  event ProjectCanceled (uint indexed projectId);

// Create a proposal, include a description and whether or not a developer and/or an artist is needed for the project
  function propose(string memory description, bool devNeeded, bool artNeeded) public payable {
        address proposalOwner = msg.sender;
        uint totalProposalCount = _proposalIds.current();
        uint totalProjectCount = _projectIds.current();
        for (uint i = 0; i < totalProposalCount; i++) {
          require (idToProposal[i].proposalOwner != msg.sender, "You already have a pending proposal");}
        for (uint i = 0; i < totalProjectCount; i++) {
          require (idToProject[i].projectOwner != msg.sender, "You already have an active or pending project");}
        require (msg.value == proposalFee, "Please submit the proposal fee");
        
        governanceWallet.transfer(proposalFee);
        _proposalIds.increment();
        uint256 proposalId = _proposalIds.current();
        // uint256 snapshot = block.number + votingDelay;
        uint256 deadline = block.number + votingPeriod;
        uint proposalStatus = 1;

        idToProposal[proposalId] =  Proposal(
            proposalId,
            msg.sender,
            description,
            0, // inital votes
            devNeeded,
            artNeeded,
            // snapshot,
            deadline,
            proposalStatus       
            );

        emit ProposalCreated(
            proposalId,
            proposalOwner,
            description,
            0, // initial votes
            devNeeded,
            artNeeded,
            // snapshot,
            deadline,
            proposalStatus            
        );
    }
 
    // Allow token holders to vote in support of a proposal
    function vote(uint proposalId) external {
        address voter = msg.sender;
        require (idToProposal[proposalId].proposalStatus == 1, "Not a pending proposal");
        require (idToProposal[proposalId].proposalOwner != voter, "you cannot vote your own posts");
        require (voteRegistry[voter][proposalId] == false, "Sender already voted in this post");
        require (ERC20(investorToken).balanceOf(msg.sender) > 0 || ERC20(developerToken).balanceOf(msg.sender) > 0 || ERC20(artistToken).balanceOf(msg.sender) > 0, "Must hold an investor, developer, or artist token to vote");
        idToProposal[proposalId].votes += 1;
        voteRegistry[voter][proposalId] = true;
        emit ProposalVote(proposalId, voter, true);
    }
    // Validate a pending proposal. If the voting threshold has been met a project will be created, otherwise the proposal will be marked as denied.
    // Anyone can validate a proposal once the deadline for voting has passed.
    function validateProposal(uint proposalId) external {
        require (idToProposal[proposalId].proposalStatus == 1, "Not a pending proposal");
        require (idToProposal[proposalId].deadline <= block.number, "Deadline for voting has not been met");
        if (idToProposal[proposalId].votes > (ERC20(investorToken).totalSupply() + ERC20(developerToken).totalSupply() + ERC20(artistToken).totalSupply() / quorum)) {
           
           _projectIds.increment();
            uint256 projectId = _projectIds.current();
          uint projectStatus = 1;

        idToProject[projectId] =  Project(
            projectId,
            payable(idToProposal[proposalId].proposalOwner),
            idToProposal[proposalId].proposalDescription,
            idToProposal[proposalId].devNeeded,
            idToProposal[proposalId].artNeeded,
            payable(address(0)), // dev address
            payable(address(0)), // artist address 
            0, // dev cost
            0, // artist cost
            0, // votes
            projectStatus
            );

           emit ProjectCreated(
            projectId,
            idToProposal[proposalId].proposalOwner,
            idToProposal[proposalId].proposalDescription,
            idToProposal[proposalId].devNeeded,
            idToProposal[proposalId].artNeeded,
            address(0), // dev address
            address(0), // artist address 
            0, // dev cost
            0, // artist cost
            0, // votes
            projectStatus 
            );

            idToProposal[proposalId].proposalStatus = 2;
            idToProposal[proposalId].proposalOwner = address(0);}
        else {idToProposal[proposalId].proposalStatus = 3;
              idToProposal[proposalId].proposalOwner = address(0);}
    }

    // Allow addresses holding developer tokens to bid on pending projects.
    // Show conversion between ONE and USD on front end?
    function developerBid(uint projectId, uint256 amount) external {
        uint totalProjectCount = _projectIds.current();
        require (idToProject[projectId].devNeeded = true, "No development needed for this project");
        require (idToProject[projectId].projectStatus == 1, "Not a pending project");
        require (ERC20(developerToken).balanceOf(msg.sender) > 0, "Must hold a developer token to bid");
        for (uint i = 0; i < totalProjectCount; i++) {
          require (idToProject[i].developer != msg.sender, "Cannot work on multiple projects at the same time");}
        developerBids[msg.sender][projectId] = amount;
        emit DevBid(projectId, msg.sender, amount);
    }
    // Allow addresses holding artist tokens to bid on pending projects.
    function artistBid(uint projectId, uint256 amount) external {
        uint totalProjectCount = _projectIds.current();
        require (idToProject[projectId].artNeeded = true, "No development needed for this project");
        require (idToProject[projectId].projectStatus == 1, "Not a pending project");
        require (ERC20(artistToken).balanceOf(msg.sender) > 0, "Must hold an artist token to bid");
        for (uint i = 0; i < totalProjectCount; i++) {
          require (idToProject[i].artist != msg.sender, "Cannot work on multiple projects at the same time");}
        artistBids[msg.sender][projectId] = amount;
        emit ArtBid(projectId, msg.sender, amount);
    }
    // Allow project owners to choose developer and/or artist bids and activate their project.
    // Project owner sends the total cost of the project to this contract.
    function activateProject(uint projectId, address devAddress, address artAddress) public payable {
        idToProject[projectId].devCost = developerBids[devAddress][projectId];
        idToProject[projectId].artCost = artistBids[artAddress][projectId];
        require (idToProject[projectId].projectOwner == msg.sender, "You are not the owner of this project");
        require (idToProject[projectId].projectStatus == 1, "Not a pending project");
        if (idToProject[projectId].devNeeded = true) {
          require (devAddress != address(0), "Must include a developer address");}
        if (idToProject[projectId].artNeeded = true) {
          require (artAddress != address(0), "Must include an artist address");}
        require (idToProject[projectId].devCost + idToProject[projectId].artCost > minCost, "Project does not meet minimum investment threshold");
        require (msg.value == idToProject[projectId].devCost + idToProject[projectId].artCost, "Please submit sufficient amount to fund project");

        idToProject[projectId].developer = payable(devAddress);
        idToProject[projectId].artist = payable(artAddress);
        idToProject[projectId].projectStatus = 2;
    }
    // Allow project owners or contributors activate a vote for the community to approve project completion.
    // Front end disclaimer to show evidence of project in justification?
    function requestComplete(uint projectId, string memory justification) external {
        require (idToProject[projectId].projectOwner == msg.sender || idToProject[projectId].developer == msg.sender || idToProject[projectId].artist == msg.sender, "Only the project owner, developer, or artist can request project completion");
        require (idToProject[projectId].projectStatus == 2, "Is not an active project");
                
        idToProject[projectId].projectStatus = 3;

        emit RequestComplete(
            projectId,
            idToProject[projectId].projectOwner,
            justification);
    }
    // Allow token holders to vote in support of marking a project complete.
    function completeProjectVote(uint projectId) external {
        address voter = msg.sender;
        require (idToProject[projectId].projectStatus == 3, "Completion has not been requested");
        require (idToProject[projectId].projectOwner != voter, "you cannot vote your own posts");
        require (completeVoteRegistry[voter][projectId] == false, "Sender already voted in this post");
        require (ERC20(investorToken).balanceOf(msg.sender) > 0 || ERC20(developerToken).balanceOf(msg.sender) > 0 || ERC20(artistToken).balanceOf(msg.sender) > 0, "Must hold an investor, developer, or artist token to vote");
        idToProject[projectId].votes += 1;
        completeVoteRegistry[voter][projectId] = true;
        emit CompleteVote(projectId, voter, true);
    }
    // Validate a pending project completion. If the voting threshold has been met costs will be released to artists and developers, an investor token will be transferred from this contract to the project owner, and the project marked complete.
    // If not, the project reverts to active status.
    // Only the project owner or contributors can validate a completion request.
    function validateProjectComplete(uint projectId) public payable {
        require (idToProject[projectId].projectStatus == 3, "Completion has not been requested");
        require (idToProject[projectId].projectOwner == msg.sender || idToProject[projectId].developer == msg.sender || idToProject[projectId].artist == msg.sender, "Only the project owner, developer, or artist can validate project completion");
        if (idToProject[projectId].votes > (ERC20(investorToken).totalSupply() + ERC20(developerToken).totalSupply() + ERC20(artistToken).totalSupply() / quorum)) {
                      
           idToProject[projectId].developer.transfer(idToProject[projectId].devCost);
           idToProject[projectId].artist.transfer(idToProject[projectId].artCost);
                    
           emit ProjectComplete(projectId);

            ERC20(investorToken).transfer(msg.sender, 1);
            idToProject[projectId].projectStatus = 4;
            idToProject[projectId].projectOwner = payable (0);
            idToProject[projectId].developer = payable (0);
            idToProject[projectId].artist = payable (0);
        }
        else {
            idToProject[projectId].votes = 0;
            idToProject[projectId].projectStatus = 2;
        }
    }

    // Allow project owners or contributors to activate a vote for the community to approve project cancellation.
    function requestCancel(uint projectId, string memory justification) external {
        require (idToProject[projectId].projectOwner == msg.sender || idToProject[projectId].developer == msg.sender || idToProject[projectId].artist == msg.sender, "Only the project owner, developer, or artist can request project completion");
        require (idToProject[projectId].projectStatus == 2, "Is not an active project");
                
        idToProject[projectId].projectStatus = 5;

        emit RequestCancel(
            projectId,
            idToProject[projectId].projectOwner,
            justification);
    }
    // Allow token holders to vote in support of cancelling a project.
    function cancelProjectVote(uint projectId) external {
        address voter = msg.sender;
        require (idToProject[projectId].projectStatus == 5, "Cancelation has not been requested");
        require (idToProject[projectId].projectOwner != voter, "you cannot vote your own posts");
        require (cancelVoteRegistry[voter][projectId] == false, "Sender already voted in this post");
        require (ERC20(investorToken).balanceOf(msg.sender) > 0 || ERC20(developerToken).balanceOf(msg.sender) > 0 || ERC20(artistToken).balanceOf(msg.sender) > 0, "Must hold an investor, developer, or artist token to vote");
        idToProject[projectId].votes += 1;
        cancelVoteRegistry[voter][projectId] = true;
        emit CancelVote(projectId, voter, true);
    }
    // Validate a pending project cancellation. If the voting threshold has been met, costs will be released back to the project owner and the project marked as cancelled. 
    // If not, the project reverts to active status.
    // Only the project owner or contributors can validate a cancellation request.
    function validateProjectCancel(uint projectId) public payable {
        require (idToProject[projectId].projectStatus == 5, "Cancelation has not been requested");
        require (idToProject[projectId].projectOwner == msg.sender || idToProject[projectId].developer == msg.sender || idToProject[projectId].artist == msg.sender, "Only the project owner, developer, or artist can validate project completion");
        if (idToProject[projectId].votes > (ERC20(investorToken).totalSupply() + ERC20(developerToken).totalSupply() + ERC20(artistToken).totalSupply() / quorum)) {
                      
           idToProject[projectId].projectOwner.transfer(idToProject[projectId].devCost + idToProject[projectId].artCost);
                    
           emit ProjectCanceled(projectId);

            idToProject[projectId].projectStatus = 6;
            idToProject[projectId].projectOwner = payable (0);
            idToProject[projectId].developer = payable (0);
            idToProject[projectId].artist = payable (0);
        }
         else {
            idToProject[projectId].votes = 0;
            idToProject[projectId].projectStatus = 2;
        }
    }


    // Update minimum investment for a project, only the governance multsig wallet can make this change
    function updateMinCost(uint256 _minCost) public onlyOwner {
      minCost = _minCost;
    }
    // Update propsal fee for making a proposal, only the governance multsig wallet can make this change
    function updatePropsalFee(uint256 _proposalFee) public onlyOwner {
      proposalFee = _proposalFee;
    }
    // Update period of time to allow for voting on a proposal, only the governance multsig wallet can make this change
    function updateVotingPeriod(uint256 _votingPeriod) public onlyOwner {
      votingPeriod = _votingPeriod;
    }
    // Update period of time before allowing voting on a proposal, only the governance multsig wallet can make this change
   /* function votingDelay(uint256 _votingDelay) public onlyOwner {
      // votingDelay = _votingDelay;
    } */
    
    // Update the fraction of token holders required to vote in favor of a proposal, project completion, or project cancellation before it is approved
    // Only the governance multsig wallet can make this change
    function updateQuorum(uint8 _quorum) public onlyOwner {
      quorum = _quorum;
    }

    }