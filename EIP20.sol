// 实现了 EIP20 令牌标准：https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md
// SPDX-License-Identifier: MIT

// Solidity版本需大于0.8.0
pragma solidity > 0.8.0;

// 引入EIP20Interface.sol文件
import "./EIP20Interface.sol";

// EIP20合约实现了EIP20Interface接口
contract EIP20 is EIP20Interface {

    // 最大无符号整数，用于初始化MAX_UINT256
    uint256 constant private MAX_UINT256 = 2**256 - 1;
    // 用户余额映射表
    mapping (address => uint256) public balances;
    // 授权转账映射表
    mapping (address => mapping (address => uint256)) public allowed;
    /*
    注意:
    以下变量是可选项。不必包含它们。
    它们允许自定义令牌合约，但并不影响核心功能。
    有些钱包/接口甚至可能不会查看此信息。
    */
    // 令牌名称
    string public name;                   
    // 令牌小数位数
    uint8 public decimals;                
    // 令牌符号
    string public symbol;                 

    // 构造函数，初始化合约
    constructor(
        uint256 initialSupply,  // 初始供应量
        string memory tokenName,      // 令牌名称
        uint8 decimalUnits,     // 小数位数
        string memory tokenSymbol     // 令牌符号
    ) {
        // 为创建者分配所有初始令牌
        balances[msg.sender] = initialSupply;               
        // 更新总供应量
        totalSupply = initialSupply;                        
        // 设置令牌名称
        name = tokenName;                                   
        // 设置小数位数
        decimals = decimalUnits;                            
        // 设置令牌符号
        symbol = tokenSymbol;                               
    }

    // 转账函数
    function transfer(address recipient, uint256 amount) override public returns (bool success) {
        // 确保发送者余额足够
        require(balances[msg.sender] >= amount, "Insufficient balance");
        // 减少发送者余额
        balances[msg.sender] -= amount;
        // 增加接收者余额
        balances[recipient] += amount;
        // 发送转账事件
        emit Transfer(msg.sender, recipient, amount); 
        return true;
    }

    // 授权转账函数
    function transferFrom(address sender, address recipient, uint256 amount) override public returns (bool success) {
        // 获取授权额度
        uint256 allowance1 = allowed[sender][msg.sender];
        // 确保发送者余额足够且授权额度足够
        require(balances[sender] >= amount && allowance1 >= amount, "Insufficient balance or allowance");
        // 增加接收者余额
        balances[recipient] += amount;
        // 减少发送者余额
        balances[sender] -= amount;
        // 如果授权额度小于最大值，则减少授权额度
        if (allowance1 < MAX_UINT256) {
            allowed[sender][msg.sender] -= amount;
        }
        // 发送授权转账事件
        emit Transfer(sender, recipient, amount); 
        return true;
    }

    // 查询用户余额函数
    function balanceOf(address account) override public view returns (uint256 balance) {
        return balances[account];
    }

    // 授权函数
    function approve(address spender, uint256 amount) override public returns (bool success) {
        // 授权额度
        allowed[msg.sender][spender] = amount;
        // 发送授权事件
        emit Approval(msg.sender, spender, amount); 
        return true;
    }

    // 查询授权额度函数
    function allowance(address owner, address spender) override public view returns (uint256 remaining) {
        return allowed[owner][spender];
    }
    
    // 将字节数组转换为字符串
    function bytes32ToString(bytes32 _bytes32) internal pure returns (string memory) {
        uint8 i = 0;
        while(i < 32 && _bytes32[i] != 0) {
            i++;
        }
        bytes memory bytesArray = new bytes(i);
        for (uint8 j = 0; j < i; j++) {
            bytesArray[j] = _bytes32[j];
        }
        return string(bytesArray);
    }
}
