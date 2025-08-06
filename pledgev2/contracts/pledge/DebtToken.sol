// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./AddressPrivileges.sol";

// 创建token 首先要创建多签钱包，由多签钱包来控制 这个地址的权限  这个地址申请调用token时由多签钱包签署,地址才有权限调用这个token
contract DebtToken is ERC20, AddressPrivileges {

    constructor(string memory _name, string memory _symbol, address multiSignature) public ERC20(_name, _symbol) AddressPrivileges(multiSignature) {
    }

    /**
      * @notice mint the token
      * @dev function to mint token for an asset
      * @param _to means receiving address
      * @param _amount means mint amount
      # @return true is success
      */
    function mint(address _to, uint256 _amount) public onlyMinter returns (bool) {
        _mint(_to, _amount);
        return true;
    }

    /**
      * @notice burn the token
      * @dev function to burn token for an asset
      * @param _from means destory address
      * @param _amount means destory amount
      # @return true is success
      */
    function burn(address _from,uint256 _amount) public onlyMinter returns (bool) {
        _burn(_from, _amount);
        return true;
    }

}
