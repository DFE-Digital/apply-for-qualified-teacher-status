# 10. Using email-based OTP for user sign in

Date: 2022-12-07

## Status

Accepted

## Context

Users need a secure way to sign into Apply for QTS. Initially we implemented
this using magic links, however we’ve discovered issues where the links are
being ”clicked“ by email clients and becoming invalid before the user clicks
on them.

The Refer serious misconduct by a teacher service uses an one-time password
(OTP) approach to authentication which we can use in Apply for QTS.

Email-based OTP ensures that a user has control of and has entered a valid
email as part of sign up, and doesn't require them to remember or write down a
password, like magic links.

Unlike magic links, OTP codes are easier to copy and paste between devices, to
allow users to sign in on one but read their email on another device. Also,
magic links can be "opened" inadvertently by some mail clients, which can cause
them to invalidate depending on how they are implemented.

## Decision

We will implement email-based OTP.

Later, we will consider using TOTP codes, which offer more advantages, but also
require more up-front setup.

## Consequences

- We rely on Notify to sign users in at any time.
