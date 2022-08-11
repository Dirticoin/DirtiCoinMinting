// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
// import "@openzeppelin/contracts/utils/math/Math.sol";

contract ERC20TaxTokenU  is ERC20Upgradeable, OwnableUpgradeable {
    using SafeMathUpgradeable for uint256;

    ////////////////////////////////////////////////////////////////////////
    // State variables
    ////////////////////////////////////////////////////////////////////////
    uint16 public basisFeePoint;
    uint16 public totalFeeRate;
    struct TaxFee {
        string name;
        address wallet;
        uint16 rate;
    }

    TaxFee[] public taxFees;
    bool public isTaxRunning;
    mapping (address => bool) public isTaxAddress;

    ////////////////////////////////////////////////////////////////////////
    // Events & Modifiers
    ////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////
    // Initialization functions
    ////////////////////////////////////////////////////////////////////////
    function __TaxToken_init(TaxFee[] memory _taxFees) internal virtual initializer {
        __Ownable_init();

        basisFeePoint = 10000;
        totalFeeRate = 0;

        updateTaxFees(_taxFees);
    }

    ////////////////////////////////////////////////////////////////////////
    // External functions
    ////////////////////////////////////////////////////////////////////////
    function updateTaxFees(TaxFee[] memory _taxFees) public onlyOwner {
        delete taxFees;
        for (uint i=0; i<_taxFees.length; i++) {
            taxFees.push(_taxFees[i]);
        }
        calcTotalFeeRate();
    }

    function updateTaxFeeById(uint8 index, string memory name, address wallet, uint16 rate) public onlyOwner {
        if (index == 255) {
            taxFees.push(TaxFee(name, wallet, rate));
        } else {
            taxFees[index] = TaxFee(name, wallet, rate);
        }
        calcTotalFeeRate();
    }

    function startTax(bool _status) external onlyOwner {
        isTaxRunning = _status;
    }
    
    function setTaxAddress(address _addr, bool bFlag) external onlyOwner {
        require(_addr != address(0x0), "zero address");
        isTaxAddress[_addr] = bFlag;
    }

    function calcTransFee(uint256 amount) public view virtual returns (uint256) {
        return amount * totalFeeRate / basisFeePoint;
    }

    function isTaxTransable(address from) public view virtual returns (bool) {
        return isTaxRunning && isTaxAddress[from];
    }

    ////////////////////////////////////////////////////////////////////////
    // Internal functions
    ////////////////////////////////////////////////////////////////////////
    function transFee(address from, uint256 amount) internal {
        if (!isTaxTransable(from)) {
            return;
        }

        for (uint i=0; i<taxFees.length; i++) {
            uint256 subFeeAmount = amount * taxFees[i].rate / totalFeeRate;
            super._transfer(from, taxFees[i].wallet, subFeeAmount);
        }
    }

    function calcTotalFeeRate() private {
        uint16 _totalFeeRate = 0;
        for (uint i=0; i<taxFees.length; i++) {
            _totalFeeRate = _totalFeeRate + taxFees[i].rate;
        }
        totalFeeRate = _totalFeeRate;
    }
}