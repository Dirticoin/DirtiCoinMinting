// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;

import "@openzeppelin/contracts-upgradeable/token/ERC20/utils/SafeERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/utils/math/SafeMathUpgradeable.sol";
import "./libraries/ERC20TaxTokenU.sol";

contract DIDToken is ERC20TaxTokenU {
    using SafeMathUpgradeable for uint256;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    ////////////////////////////////////////////////////////////////////////
    // State variables
    ////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////
    // Events & Modifiers
    ////////////////////////////////////////////////////////////////////////

    ////////////////////////////////////////////////////////////////////////
    // Initialization functions
    ////////////////////////////////////////////////////////////////////////

    function initialize(
        string memory name,
        string memory symbol,
        uint256 initialSupply,
        TaxFee[] memory _taxFees
    ) public virtual initializer {
        __ERC20_init(name, symbol);
        __TaxToken_init(_taxFees);

        _mint(_msgSender(), initialSupply);
    }

    ////////////////////////////////////////////////////////////////////////
    // External functions
    ////////////////////////////////////////////////////////////////////////
    function mint(address _to, uint256 _amount) external onlyOwner {
        require(_to != address(0x0), "zero address");
        _mint(_to, _amount);
    }

    function burn(address _from, uint256 _amount) external onlyOwner {
        require(_from != address(0x0), "zero address");
        _burn(_from, _amount);
    }

    ////////////////////////////////////////////////////////////////////////
    // Internal functions
    ////////////////////////////////////////////////////////////////////////
    function _transfer(address _from, address _to, uint256 _amount) internal virtual override {
        uint256 _transAmount = _amount;
        if (isTaxTransable(_from)) {
            uint256 taxAmount = super.calcTransFee(_amount);
            transFee(_from, taxAmount);
            _transAmount = _amount.sub(taxAmount);
        }
        super._transfer(_from, _to, _transAmount);
    }    
}