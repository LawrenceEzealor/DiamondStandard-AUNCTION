// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "../contracts/interfaces/IDiamondCut.sol";
import "../contracts/facets/DiamondCutFacet.sol";
import "../contracts/facets/DiamondLoupeFacet.sol";
import "../contracts/facets/OwnershipFacet.sol";
import "forge-std/Test.sol";
import "../contracts/Diamond.sol";
import "../contracts/facets/Auctions.sol";
import "../contracts/facets/AUCFacet.sol";

contract DiamondDeployer is Test, IDiamondCut {
    //contract types of facets to be deployed
    Diamond diamond;
    DiamondCutFacet dCutFacet;
    DiamondLoupeFacet dLoupe;
    OwnershipFacet ownerF;
    AUCFacet auctionF;
    Auctions auction;
    // DNFT nft;


    Auctions _auction;
    address A = address(0xa);
    address B = address(0xb);


    function setUp() public {
        //deploy facets
        dCutFacet = new DiamondCutFacet();
        diamond = new Diamond(address(this), address(dCutFacet));
        dLoupe = new DiamondLoupeFacet();
        ownerF = new OwnershipFacet();
        auctionF = new AUCFacet();
        auction = new Auctions();
        // nft = new DANIELNFT(address(diamond));

  

        //upgrade diamond with facets

        //build cut struct
        FacetCut[] memory cut = new FacetCut[](4);

        cut[0] = (
            FacetCut({
                facetAddress: address(dLoupe),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("DiamondLoupeFacet")
            })
        );

        cut[1] = (
            FacetCut({
                facetAddress: address(ownerF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("OwnershipFacet")
            })
        );

         cut[2] = (
            FacetCut({
                facetAddress: address(auctionF),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("AUCFacet")
            })
        );

         cut[3] = (
            FacetCut({
                facetAddress: address(auction),
                action: FacetCutAction.Add,
                functionSelectors: generateSelectors("Auctions")
            })
        );

        //upgrade diamond
        IDiamondCut(address(diamond)).diamondCut(cut, address(0x0), "");

        //call a function
        DiamondLoupeFacet(address(diamond)).facetAddresses();
        
        
        AUCFacet(address(diamond)).mintTo(A);
        AUCFacet(address(diamond)).mintTo(B);

        _auction = Auctions(address(diamond));


        A = mkaddr("bidder a");
        B = mkaddr("bidder b");


               //call a function
        DiamondLoupeFacet(address(diamond)).facetAddresses();
        _auction.CreateAuction(address(this), 0, 100);
       _auction.startBidding();
       vm.stopPrank();
    }


    function testBid() public {
       
       switchSigner(A);
       _auction.bid(1, 100);
        vm.stopPrank();
        switchSigner(B);
       _auction.bid(1, 20);

        //    bytes32 value = vm.load(
        //     address(diamond),
        //     bytes32(abi.encodePacked(uint256(2)))
        // );
        // uint256 decodevalue = abi.decode(abi.encodePacked(value), (uint256));
        // console.log(decodevalue);
    }




    function generateSelectors(
        string memory _facetName
    ) internal returns (bytes4[] memory selectors) {
        string[] memory cmd = new string[](3);
        cmd[0] = "node";
        cmd[1] = "scripts/genSelectors.js";
        cmd[2] = _facetName;
        bytes memory res = vm.ffi(cmd);
        selectors = abi.decode(res, (bytes4[]));
    }

        function mkaddr(string memory name) public returns (address) {
        address addr = address(
            uint160(uint256(keccak256(abi.encodePacked(name))))
        );
        vm.label(addr, name);
        return addr;
    }

      function switchSigner(address _newSigner) public {
        address foundrySigner = 0x1804c8AB1F12E6bbf3894d4083f33e07309d1f38;
        if (msg.sender == foundrySigner) {
            vm.startPrank(_newSigner);
        } else {
            vm.stopPrank();
            vm.startPrank(_newSigner);
        }

    }

    function diamondCut(
        FacetCut[] calldata _diamondCut,
        address _init,
        bytes calldata _calldata
    ) external override {}
}
