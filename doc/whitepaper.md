# ADA User Management Server

## Overview

### Purpose

The *ADA User Management Server* (short: *UMS*) encapsulates services relating to the registration, authentication and authorisation of users within the Australian Data Archive.  It provides a central authority for any information regarding registered ADA users and their privileges.

### Services

#### Authentication

The OpenID protocol (<http://openid.net/>) is used to authenticate users and provide a single-sign-on mechanism, with the UMS acting as an OpenID provider, and client ADA services (CMS, Adapt, etc.) acting as consumers.

#### Registration and account management

On sign-on, the UMS offers options for users to register or edit their personal details via a web interface with standardised URLs.

#### Authorisation

Selected ADA services may request information regarding user privileges and access rights via a RESTful API.

#### User details

Selected ADA services may request personal information on specific users via a RESTful API similar to the one used for authorisation.

#### User management

A web interface for managing user information, privileges and access rights is provided.

#### Implementation

The UMS is implemented as a standalone Rails application with a MySQL database for persistent storage. This database is private to the UMS and not to be accessed directly by other services.

#### Legacy considerations

Since the Nesstar software requires specific mechanisms for authentication and authorisation, a second MySQL database will hold partial duplicates of user records in a Nesstar-compliant format.

A number of other services which currently access the existing user database directly will be modified or rewritten to request information from the UMS instead. In order to ease the transition phase, the UMS will initially keep this legacy database updated to reflect any changes made to user records.

#### Potential extensions

In a first stage, the UMS will provide identities exclusively for users registered with ADA. We will however investigate the potential for establishing the UMS as a gateway to other identity providers such as the AAF.
