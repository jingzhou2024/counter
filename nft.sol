// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";

contract BaseERC721 {
    using Strings for uint256;
    using Address for address;
    // Token name
    string private _name;

    // Token symbol
    string private _symbol;

    // Token baseURI
    string private _baseURI;

    // Mapping from token ID to owner address
    mapping(uint256 => address) private _owners;

    // Mapping owner address to token count
    mapping(address => uint256) private _balances;

    // Mapping from token ID to approved address
    mapping(uint256 => address) private _tokenApprovals;

    // Mapping from owner to operator approvals
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    event Transfer(
        address indexed from,
        address indexed to,
        uint256 indexed tokenId
    );
    event Approval(
        address indexed owner,
        address indexed approved,
        uint256 indexed tokenId
    );

    /**
     * @dev Emitted when `owner` enables or disables (`approved`) `operator` to manage all of its assets.
     */
    event ApprovalForAll(
        address indexed owner,
        address indexed operator,
        bool approved
    );

    /**
     * @dev Initializes the contract by setting a `name`, a `symbol` and a `baseURI` to the token collection.
     */
    constructor(
        string memory name_,
        string memory symbol_,
        string memory baseURI_
    ) {
        /**code*/
        _name = name_;
        _symbol = symbol_;
        _baseURI = baseURI_;
    }

    /**
     * @dev See {IERC721Metadata-name}.
     */
    function name() public view returns (string memory) {
        /**code*/
        return _name;
    }

    /**
     * @dev See {IERC721Metadata-symbol}.
     */
    function symbol() public view returns (string memory) {
        /**code*/
        return _symbol;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(
            /**code*/
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        // should return baseURI
        /**code*/
        return string(abi.encodePacked(_baseURI, tokenId.toString()));
    }

    /**
     * @dev Mints `tokenId` and transfers it to `to`.
     */
    function mint(address to, uint256 tokenId) public {
        require(
            /**code*/
            to != address(0),
            "ERC721: mint to the zero address"
        );
        require(
            /**code*/
            !_exists(tokenId),
            "ERC721: token already minted"
        );

        /**code*/
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(address(0), to, tokenId);
    }

    /**
     * @dev See {IERC721-balanceOf}.
     */
    function balanceOf(address owner) public view returns (uint256) {
        /**code*/
        return _balances[owner];
    }

    /**
     * @dev See {IERC721-ownerOf}.
     */
    function ownerOf(uint256 tokenId) public view returns (address) {
        /**code*/
        require(_exists(tokenId), "ERC721: owner query for nonexistent token");
        return _owners[tokenId];
    }

    /**
     * @dev See {IERC721-approve}.
     */
    function approve(address to, uint256 tokenId) public {
        address owner = ownerOf(tokenId);
        require(
            /**code*/
            to != owner,
            "ERC721: approval to current owner"
        );

        require(
            /**code*/
            msg.sender == owner || isApprovedForAll(owner, msg.sender),
            "ERC721: approve caller is not owner nor approved for all"
        );

        _approve(to, tokenId);
    }

    /**
     * @dev See {IERC721-getApproved}.
     */
    function getApproved(uint256 tokenId) public view returns (address) {
        require(
            /**code*/
            _exists(tokenId),
            "ERC721: approved query for nonexistent token"
        );

        /**code*/
        return _tokenApprovals[tokenId];
    }

    /**
     * @dev See {IERC721-setApprovalForAll}.
     */
    function setApprovalForAll(address operator, bool approved) public {
        address sender = msg.sender;
        require(
            /**code*/
            operator != sender,
            "ERC721: approve to caller"
        );

        /**code*/
        _operatorApprovals[sender][operator] = approved;

        emit ApprovalForAll(sender, operator, approved);
    }

    /**
     * @dev See {IERC721-isApprovedForAll}.
     */
    function isApprovedForAll(address owner, address operator)
        public
        view
        returns (bool)
    {
        /**code*/
        return _operatorApprovals[owner][operator];
    }

    /**
     * @dev Returns whether `tokenId` exists.
     */
    function _exists(uint256 tokenId) internal view returns (bool) {
        /**code*/
        return _owners[tokenId] != address(0);
    }

    /**
     * @dev Returns whether `spender` is allowed to manage `tokenId`.
     */
    function _isApprovedOrOwner(address spender, uint256 tokenId)
        internal
        view
        returns (bool)
    {
        require(
            /**code*/
            _exists(tokenId),
            "ERC721: operator query for nonexistent token"
        );

        /**code*/
        address owner = ownerOf(tokenId);
        return (spender == owner ||
            getApproved(tokenId) == spender ||
            isApprovedForAll(owner, spender));
    }

    /**
     * @dev Transfers `tokenId` from `from` to `to`.
     */
    function _transfer(
        address from,
        address to,
        uint256 tokenId
    ) internal {
        require(
            /**code*/
            ownerOf(tokenId) == from,
            "ERC721: transfer from incorrect owner"
        );

        require(
            /**code*/
            to != address(0),
            "ERC721: transfer to the zero address"
        );

        /**code*/
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;
        delete _tokenApprovals[tokenId];

        emit Transfer(from, to, tokenId);
    }

    /**
     * @dev Approve `to` to operate on `tokenId`
     */
    function _approve(address to, uint256 tokenId) internal virtual {
        /**code*/
        _tokenApprovals[tokenId] = to;

        emit Approval(ownerOf(tokenId), to, tokenId);
    }
}
