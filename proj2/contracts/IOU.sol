// Please paste your contract's solidity code here
// Note that writing a contract here WILL NOT deploy it and allow you to access it from your client
// You should write and develop your contract in Remix and then, before submitting, copy and paste it here

pragma solidity >= 0.4 <0.9.0;
import "hardhat/console.sol";

contract IOU {

	// struct Dept{
	// 	address creditor;
	// 	uint32 dept;
	// }
	// mapping (address => uint32) CreditorsDept;
	// mapping (address => Dept[]) IOUs;
	mapping (address => mapping(address => uint32)) IOUs;

	// Returns the amount that the deptor owes the creditor
	function lookup (address deptor, address creditor) public view returns (uint32 ret){

		// Dept[] memory depts = IOUs[deptor];

		// for(uint i =0; i < depts.length; i++){

		// 	if(depts[i].)	
		// }
		return IOUs[deptor][creditor];

	}

	function add_IOU(address creditor, uint32 amount, address[] calldata cycle, uint32 minAmount) external {

		console.log(creditor);
		console.log(amount);
		console.log(cycle.length);
		console.log(minAmount);
		IOUs[msg.sender][creditor] += amount;


		for (uint i=0; i<cycle.length; i++) {
			console.log("---");

			IOUs[cycle[i]][cycle[i+1]] -= minAmount;

		}

	}

}