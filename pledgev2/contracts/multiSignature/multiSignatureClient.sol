// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IMultiSignature{
    function getValidSignature(bytes32 msghash,uint256 lastIndex) external view returns(uint256);
}

//基础合约
contract multiSignatureClient{
    uint256 private constant multiSignaturePositon = uint256(keccak256("org.multiSignature.storage"));
    uint256 private constant defaultIndex = 0;

    constructor(address multiSignature) public {
        require(multiSignature != address(0),"multiSignatureClient : Multiple signature contract address is zero!");
        saveValue(multiSignaturePositon,uint256(multiSignature));
    }

    function getMultiSignatureAddress()public view returns (address){
        return address(getValue(multiSignaturePositon));
    }
   // 第三步用户执行某个合约的交易时，需要验证签名是否有效
    modifier validCall(){
        checkMultiSignature();
        _;
    }

    function checkMultiSignature() internal view {
        uint256 value;
        assembly {
            value := callvalue()
        }
        bytes32 msgHash = keccak256(abi.encodePacked(msg.sender, address(this)));  //调用方和合约地址的hash值
        address multiSign = getMultiSignatureAddress();
//        uint256 index = getValue(uint256(msgHash));
        uint256 newIndex = IMultiSignature(multiSign).getValidSignature(msgHash,defaultIndex);  //获取有效签名数量
        require(newIndex > defaultIndex, "multiSignatureClient : This tx is not aprroved");
//        saveValue(uint256(msgHash),newIndex);
    }

    function saveValue(uint256 position,uint256 value) internal
    {
        assembly {
            sstore(position, value)
        }
    }

    function getValue(uint256 position) internal view returns (uint256 value) {
        assembly {
            value := sload(position)
        }
    }
}