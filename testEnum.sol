// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract E {
    enum Status{
        Pending,
        Shipped,
        Delivered,
        Canceled
    }
    Status public status;
    constructor() {
        status = Status.Pending;
    }
    function ship() public {
        status = Status.Shipped;
    }
    function deliver() public {
        status = Status.Delivered;
    }
    function canceled() public {
        status = Status.Canceled;
    }
}

contract AccessControl {
    enum Role {Admin, Moderator, User}
    mapping(address => Role) public roles;
    function grantAdmin(address user) public {
        roles[user] = Role.Admin;
    }
    function grantModerator(address user) public {
        roles[user] = Role.Moderator;
    }
    function isAdmin(address user) public view returns(bool) {
        return roles[user] == Role.Admin;
    }
}
contract Payment {
    enum PaymentMethod {Creditcard, Paypal, Crypto}
    PaymentMethod public method;

    function setPaymentMethod(PaymentMethod _met) public {
        method = _met;
    }

    function processPayment() public view returns (string memory) {
        if (method == PaymentMethod.Creditcard) {
            return "Creditcard";
        } else if (method == PaymentMethod.Paypal) {
            return "Paypal";
        } else if (method == PaymentMethod.Crypto) {
            return "Crypto";
        }
        return "Unknown";
    }
}