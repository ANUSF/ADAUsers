# ADA User Management Server (Draft)

## Overview

### Purpose

The *ADA User Management Server* (short: *UMS*) encapsulates services relating to the registration, authentication and authorisation of users within the Australian Data Archive.  It provides a central authority for any information regarding registered ADA users and their privileges.

### Services

#### Authentication

The OpenID protocol (<http://openid.net/>) is used to authenticate users and provide a single-sign-on mechanism, with the UMS acting as an OpenID provider, and client ADA services (CMS, Adapt, etc.) acting as consumers.

#### Authorisation

Selected ADA services may request information regarding user privileges and access rights via a RESTful API.

#### User details

Selected ADA services may request personal information on specific users via a RESTful API similar to the one used for authorisation.

#### Registration, account management and access requests

On sign-on, the UMS offers options for users to register or edit their personal details a web interface with standardised URLs. Request forms to be submitted by users requesting specific access rights are also handled by the UMS.

#### Administrative interface

An interactive web interface for managing user information, privileges and access rights is provided.

### Implementation

The UMS is implemented as a standalone Rails application with a MySQL database for persistent storage. This database is private to the UMS and not to be accessed directly by other services.

### Legacy considerations

Since the Nesstar software requires specific mechanisms for authentication and authorisation, a second MySQL database will hold partial duplicates of user records in a Nesstar-compliant format.

A number of other services which currently access the existing user database directly will be modified or rewritten to request information from the UMS instead. In order to ease the transition phase, the UMS will initially keep this legacy database updated to reflect any changes made to user records.

### Potential extensions

In a first stage, the UMS will provide identities exclusively for users registered with ADA. We will however investigate the potential for establishing the UMS as a gateway to other identity providers such as the AAF.


## Protocols

### General

All communication with the UMS takes places via the HTTPS (HTTP over SSL) protocol in order to prevent third parties from intercepting any sensitive information that may be exchanged. There are two basic ways of communicating with the UMS:

1. Requests to services accessible via a web interface must be initiated by a user agent (web browser). If the service requires authorisation, an authorised user must have signed in successfully.

2. Requests to services with a machine-readable interface can be initiated as above, but also by a recognised ADA service running on a trusted host. (Details on whether and how ADA services identify themselves to be filled in.)

### Authentication (OpenID)

The UMS uses version 2 of the OpenID protocol (<http://openid.net/>) together with the Simple Registration extension (SREG), both of which are well documented.

Roughly speaking, OpenID works by redirecting the user agent (usually a web browser) from the OpenID consumer (the service that the user wants to sign in to) to an OpenID provider. The user then signs in at the provider which redirects back to the consumer. If the user was already signed in, the provider redirects back immediately, so that no additional user action is required.

The redirection can either go to the base URL of the UMS, in which case a user will need to enter both a login name and password, or else to a URL identifying a particular user directly, in which case only a password need to be entered. The format of these identity URLs is not defined by the standard. The UMS uses the form 

    https://<server>/user/<name>

where `<server>` is the qualified host name assigned to the UMS service (e.g. `openid.ada.edu.au`) and `<name>` is the user's login name.

For Rails-based clients, the OpenID consumer code necessary to implement the sign-in process will be provided as a Rails engine (plugin) for easy inclusion.

### Authorization and requesting user details

Selected ADA services may request a range of information about users via a RESTful API. There are three types of requests:

1. A user's role.
2. A user's personal details.
3. A user's access rights regarding a given resource.

The collection of data associated to a user within the UMS is understood as an online resource identified by the user's identity URL. Each of the request types mentioned above is therefore implemented as a HTTP GET request to a sub-resource. In particular:

1. `https://<server>/user/<name>/role` for the user's role.
2. `https://<server>/user/<name>/details` for personal details.
3. `https://<server>/user/<name>/access/<resource>` to enquire access rights, where `<resource>` identifies a particular data resource. The most important data resource specifiers are ADA dataset IDs of the form `au.edu.anu.assda.ddi.xxxxx` (or supposedly `au.edu.ada.ddi.xxxxx` in the future).

Logically, the response is a simple value for a role request and a list of key-value pairs for a personal details request. For an access rights enquiry, a special situation may occur when a dataset is composed of several files with diverging access conditions (details to be specified).

Available response formats are plain text and JSON (maybe DDI as well?).

### Registration, account management, access requests and administration

These services will be provided via traditional, human-accessible web interfaces. (Detailled workflows to be specified.)
