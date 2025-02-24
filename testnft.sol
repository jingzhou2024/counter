// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract BaseERC721 {
    using Strings for uint256;
    using Address for address;

    // 代币名称
    string private _name;

    // 代币符号
    string private _symbol;

    // 代币基础URI
    string private _baseURI;

    // 从代币ID映射到拥有者地址
    mapping(uint256 => address) private _owners;

    // 从拥有者地址映射到代币数量
    mapping(address => uint256) private _balances;

    // 从代币ID映射到被授权的地址
    mapping(uint256 => address) private _tokenApprovals;

    // 从拥有者到操作者授权的映射
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    /**
     * @dev 当 `tokenId` 代币从 `from` 转移到 `to` 时触发的事件。
     */
    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );

    /**
     * @dev 当 `owner` 授权 `approved` 管理 `tokenId` 代币时触发的事件。
     */
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev 当 `owner` 启用或禁用（`approved`） `operator` 管理其所有资产时触发的事件。
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    /**
     * @dev 通过设置代币集合的 `name`、`symbol` 和 `baseURI` 来初始化合约。
     */
    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_
    ) {
        /**代码*/
        _name = name_;
        _symbol = symbol_;
        _baseURI = baseURI_;
    }

    /**
     * @dev 查看 {IERC165-supportsInterface}。
     */
    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return
            interfaceId == 0x01ffc9a7 || // ERC165的接口ID
            interfaceId == 0x80ac58cd || // ERC721的接口ID
            interfaceId == 0x5b5e139f;   // ERC721Metadata的接口ID
    }
    
    /**
     * @dev 查看 {IERC721Metadata-name}。
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev 查看 {IERC721Metadata-symbol}。
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev 查看 {IERC721Metadata-tokenURI}。
     */
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: 查询不存在的代币的URI");
        return string(abi.encodePacked(_baseURI, tokenId.toString()));
    }

    /**
     * @dev 铸造 `tokenId` 并将其转移到 `to`。
     *
     * 要求：
     *
     * - `to` 不能是零地址。
     * - `tokenId` 必须不存在。
     *
     * 触发 {Transfer} 事件。
     */
    function mint(address to, uint256 tokenId) public {
        require(to != address(0), "ERC721: 铸造到零地址");
        require(!_exists(tokenId), "ERC721: 代币已被铸造");

        _owners[tokenId] = to;
        _balances[to] += 1;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev 查看 {IERC721-balanceOf}。
     */
    function balanceOf(address owner) public view returns (uint256) {
        /**代码*/
        require(owner != address(0), "ERC721: 查询零地址的余额");
        return _balances[owner];
    }

    /**
     * @dev 查看 {IERC721-ownerOf}。
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        /**代码*/
        address owner = _owners[tokenId];
        require(owner != address(0), "ERC721: 查询不存在代币的拥有者");
        return owner;
    }

    /**
     * @dev 查看 {IERC721-approve}。
     */
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(to != owner, "ERC721: 授权给当前拥有者");

        require(
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: 调用者不是拥有者也不是被授权管理全部资产"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev 查看 {IERC721-getApproved}。
     */
    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "ERC721: 查询不存在代币的授权地址");
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev 查看 {IERC721-setApprovalForAll}。
     */
    function setApprovalForAll(address operator, bool approved) public {
        address sender = msg.sender;
        require(operator != sender, "ERC721: 授权给调用者");

        _operatorApprovals[sender][operator] = approved;
        emit ApprovalForAll(sender, operator, approved);
    }

    /**
     * @dev 查看 {IERC721-isApprovedForAll}。
     */
    function isApprovedForAll(
        address owner,
        address operator
    ) public view returns (bool) {
        /**代码*/
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev 查看 {IERC721-transferFrom}。
     */
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: 转移调用者不是拥有者也不是被授权"
        );

        _transfer(from, to, tokenId);
    }

    /**
     * @dev 查看 {IERC721-safeTransferFrom}。
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) public {
        safeTransferFrom(from, to, tokenId, "");
    }

    /**
     * @dev 查看 {IERC721-safeTransferFrom}。
     */
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) public {
        require(
            _isApprovedOrOwner(msg.sender, tokenId),
            "ERC721: 转移调用者不是拥有者也不是被授权"
        );
        _safeTransfer(from, to, tokenId, _data);
    }

    /**
     * @dev 安全地将 `tokenId` 代币从 `from` 转移到 `to`，首先检查合约接收者是否了解ERC721协议，以防止代币被永久锁定。
     *
     * `_data` 是附加数据，没有指定格式，会在调用 `to` 时发送。
     *
     * 此内部函数等同于 {safeTransferFrom}，可用于实现例如基于签名的代币转移等替代机制。
     *
     * 要求：
     *
     * - `from` 不能是零地址。
     * - `to` 不能是零地址。
     * - `tokenId` 代币必须存在并且由 `from` 拥有。
     * - 如果 `to` 是智能合约，必须实现 {IERC721Receiver-onERC721Received}，在安全转移时会被调用。
     *
     * 触发 {Transfer} 事件。
     */
    function _safeTransfer(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) internal {
        _transfer(from, to, tokenId);
        require(
            _checkOnERC721Received(from, to, tokenId, _data),
            "ERC721: 转移到未实现ERC721Receiver的地址"
        );
    }

    /**
     * @dev 返回 `tokenId` 是否存在。
     *
     * 代币可以由其拥有者或通过 {approve} 或 {setApprovalForAll} 授权的账户管理。
     *
     * 代币在被铸造（`_mint`）时开始存在，在被销毁（`_burn`）时停止存在。
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        /**代码*/
    }

    /**
     * @dev 返回 `spender` 是否被允许管理 `tokenId`。
     *
     * 要求：
     *
     * - `tokenId` 必须存在。
     */
    function _isApprovedOrOwner(
        address spender,
        uint256 tokenId
    ) internal view returns (bool) {
        require(_exists(tokenId), "ERC721: 查询不存在代币的操作者");
        address owner = ownerOf(tokenId);
        return (spender == owner || getApproved(tokenId) == spender || isApprovedForAll(owner, spender));
    }

    /**
     * @dev 将 `tokenId` 从 `from` 转移到 `to`。
     * 与 {transferFrom} 不同，此函数对 msg.sender 没有限制。
     *
     * 要求：
     *
     * - `to` 不能是零地址。
     * - `tokenId` 代币必须由 `from` 拥有。
     *
     * 触发 {Transfer} 事件。
     */
    function _transfer(address from, address to, uint256 tokenId) internal {
        require(ownerOf(tokenId) == from, "ERC721: 转移的代币拥有者不正确");
        require(to != address(0), "ERC721: 转移到零地址");

        _approve(address(0), tokenId);

        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    // 获取NFT的当前拥有者
    function ownerOf(uint256 tokenId) public view returns (address) {
        address currentOwner = nft.ownerOf(tokenId);
        return currentOwner;
    }
 
    /**
     * @dev 授权 `to` 操作 `tokenId`
     *
     * 触发 {Approval} 事件。
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        /**代码*/
        _tokenApprovals[tokenId] = to;
        emit Approval(ownerOf(tokenId), to, tokenId);
    }

    /**
     * @dev 内部函数，用于在目标地址上调用 {IERC721Receiver-onERC721Received}。
     * 如果目标地址不是合约，则不执行调用。
     *
     * @param from 表示给定代币ID的前拥有者的地址
     * @param to 将接收代币的目标地址
     * @param tokenId 将要转移的代币ID
     * @param _data 可选数据，与调用一起发送的字节数据
     * @return bool 调用是否正确返回预期魔法值
     */
    function _checkOnERC721Received(
        address from,
        address to,
        uint256 tokenId,
        bytes memory _data
    ) private returns (bool) {
        if (to.isContract()) {
            try
                IERC721Receiver(to).onERC721Received(
                    msg.sender,
                    from,
                    tokenId,
                    _data
                )
            returns (bytes4 retval) {
                return retval == IERC721Receiver.onERC721Received.selector;
            } catch (bytes memory reason) {
                if (reason.length == 0) {
                    revert(
                        "ERC721: 转移到未实现ERC721Receiver的地址"
                    );
                } else {
                    assembly {
                        revert(add(32, reason), mload(reason))
                    }
                }
            }
        } else {
            return true;
        }
    }
}

contract BaseERC721Receiver is IERC721Receiver {
    constructor() {}

    function onERC721Received(
        address,
        address,
        uint256,
        bytes calldata
    ) external pure returns (bytes4) {
        return this.onERC721Received.selector;
    }
}