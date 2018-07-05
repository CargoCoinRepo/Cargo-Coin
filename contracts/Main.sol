pragma solidity ^0.4.24;

/**
 * The CargoCoin Smart Contract
 */
contract CargoContract
{
	address private importer;
	address private exporter;
	address public CargoCoinAuthority;
	bool importerAccepted;
	bool exsporterAccepted;
	uint startTime;
	uint waitingTime;
	uint balance = 0;

	function CargoContract(address _exporter, address _importer, address _CargoCoinAuthority, uint _waitingTime)
	{
		importer = _importer;
		exporter = _exporter;
		CargoCoinAuthority = _CargoCoinAuthority;
		startTime = now;
		waitingTime = _waitingTime;
	}

	function accept() public
	{
		if(msg.sender == importer)
		{
			importerAccepted = true;
		}
		else if(msg.sender == exporter)
		{
			exporterAccepted = true;
		}

		if(importerAccepted && exporterAccepted)
		{
			payBalance();
		}
		else if(importerAccepted && !exporterAccepted && now > startTime + waitingTime)
		{
			selfdestruct(importer);
		}
	}

	function payBalance() private
	{
		if(exporter.send(this.balance))
		{
			balance = 0;
		}
		else
		{
			revert();
		}
	}
	
	function deposit() public payable
	{
		if(msg.sender == importer)
		{
			balance += msg.value;
		}
	}
	
	function cancel() public
	{
		if(msg.sender == importer)
		{
			importerAccepted = false;
		}
		else if(msg.sender == exporter)
		{
			exporterAccepted = false;
		}

		if(importerAccepted && !exporterAccepted)
		{
			selfdestruct(importer);
		}
	}

	function kill() public constant
	{
		if (msg.sender == CargoCoinAuthority)
		{
			selfdestruct(importer);
		}
	}
	
	function () payable
	{
		revert();
	}
}