//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.4;

import "hardhat/console.sol";

//HRC 20 token  3contracts with 3 airdrop functions - ownable

// for contract 1. Trusted Developers = non-transferable + burnable 

// Trusted Artists  non-transferable + burnable

    function airdrop(address[] memory receivers) external onlyOwner {
    //    require(totalSupply() + receivers.length <= MAX, "EXCEED_MAX");
        for (uint256 i = 0; i < receivers.length; i++) {
            _mint(receivers[i], totalSupply() + 1);
        }
    }

The Investors  HRC-20 Tokens will be minted after completion of the project  called “Alumni Tokens”; 

these tokens are non-transferable/burnable and accumulate every time a project is completed.
this may need to be in a seperate function in a seperate contract, minted when tokens projects are complete
tokens will also need to be issued to developers and artists because the manual portion done by governance should be removed.

//person purposing would be a variable in an array or struct -done 

// - The airdrop functions below should cover this step

//Governance will invite artists and developers to join prior to launching the platform. 

/* Phase 2 - operational */

//Submission to the DAO will trigger a vote - done

//Once the platform is launched, artists and developers will gain access via community vote. 

//Front-end If denied entry, artists and developers may submit an appeal and supporting documents to Governance for review, including resumes, references, and past work. Governance will review the appeal at no cost to the applying talent.

//require statement when a user applies to work on a project that checks if that address is working on another project - done
// addresses would go in array - done
//array would be checked to recieve with mappings between developer/invesetor and artist/investor addresses. - done


//Phase Two - Collaboration & Fundraising for the Future (Initial Operational Stage)

// Holding any number of the 3 HRC tokens provides an account with one vote - done

Precentage of funds reallocated to the community is weighted by the number of tokens an account holds (if the token supply is 100 and an account has 4 tokend they get 4% of the funds reallocated to the community)

// Submitting a Partnership or Investor project proposal will require a “Project Submission Fee” of USD $1,500 to pay artist and developers. A part of this fee ($50) will be non-refundable and will go into the Creator Grants Projects Pool. -done

// The community holding HERC-20 Tokens reviews and votes on each proposal over a one week voting period. - done

// An approved proposal will need to trigger an event for developers and artists may bid on a project after voting to approve it. The contract will allow investors to select the artist and/or developer of their choice. - done

// After project is approved totalCost will be decided and sent to a seperate contract.- done but is sent to the Governance contract, not a seperate contract

//Any member with an artist or developer token can bid to assist - Anyone can bid, if this is indicating we would like to allow other than the bid winners to assist then we will need to add that (seems complicated)

//The DAO transfers Investor funds to a separate contract upon project acceptance. - done but currently it goes to the governance contract

// The smart contract will hold funds reserved for paying developers upon project completion. When the smart contract’s balance increases, the contract will trigger a notice and open voting to the community to determine whether that project is complete. A successful project completion vote will result in the contract auto-deploying developer payments. -done but not triggered by a balance increase, must manually trigger a vote

//Front-end One percent (1%) of all project profits must return to the DAO, which will release the funds in the form of investor payment to the developers. This incentivizes the developers to properly build a payment splitter.

// Front end? The community votes to resolve disputes between investors and developers. This means that, should the investor not want to release funds to the developer, they must reach out to the contract holding the funds and request a review, triggering a community vote. Both the investor and the developer will present their cases to the community on a Notion page; the funds are released after the community finishes reviewing the case.

// The DAO releases revenues after a successful project completion. -done


Phase Three - Community Investments (Operational Stage)
(Begin upon contract earning USD $10K)

// The Project returns one percent (1%) of the profits made from approved project grants. The DAO then reinvests these funds into the community for Creator Grants. -done, creator grant contract will need to be set up seperately

Submitting a Creator Grant is free if the applicant follows proposal guidelines highlighting the project’s vision, budget, partners, collaborators, and creators involved.

The governance community holding HERC-20 tokens will review and vote on each proposal over a two week vetting period.

The DAO encourages those looking to fund their projects to hire developers and artists from within the community. This incentivizes good behaviors by encouraging developers and artists to stay within the DAO ecosystem.The contract will pay out developers and stakeholders upon project completion.

The developers ensure the payment splitter is reallocating the proper amount of funding to the smart contract.

A payment splitter from the invested project must reallocate funds back into the DAOs contract for future investments.

Token Holders will split five percent (5%) of profits earned by the contract quarterly.

The DAO will allocate four percent (4%) of the funds to a community-chosen non-profit NGO or 501(c)(3).

//divide by balanceOf and add list of all holders

One percent (1%) will be allocated by the Governance Team.
}
