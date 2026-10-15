# Salesforce SAML SSO
## Configure Salesforce as a SAML 2.0 Service Provider in Okta. Map the FederationIdentifier so SAML assertions can match Salesforce users. Demonstrate both IdP-initiated and SP-initiated SSO flows. Capture and decode a SAML assertion to verify correctness.
---
### Configuration Steps

**Step 1: Enable SAML in Salesforce**

1. Log in to Salesforce with the administrator account.
2. Navigate to **Setup → Identity → Single Sign-On Settings**.
3. Click **Edit**, check **SAML Enabled**, and click **Save**.
4. Click **New** to create a new SAML SSO configuration.

**Step 2: Map FederationIdentifier in Okta**

1. In Okta, go to the Salesforce app → **General** tab → **SAML Settings → Edit → Next** (Configure SAML section).
2. Under **Attribute Statements**, add/confirm an attribute mapped to `FederationIdentifier`, with the value sourced from `user.email` (or whichever field matches what's stored on the Salesforce user record).
3. Save. This is what lets Salesforce match an incoming assertion to an actual user — without it, authentication will fail even with a perfectly valid, correctly signed assertion.

**Step 3: Populate SAML Settings from Okta**

1. In Okta, open the **SAML Setup Instructions** link (Applications → Salesforce App).
	![SAML Setup Instructions](./Attachments/Pasted%20image%2020261007131251.png)
2. Use the values from that page to fill in the Salesforce SAML config:
    - Issuer
    - Identity Provider Certificate
    - Identity Provider Login URL
    - Custom Logout URL
    - API Name
    - Entity ID
3. Save the **Login URL** and **Logout URL** for later use.
4. Download the Okta **metadata** file.

**Step 4: Configure Custom Domain in Okta**

1. In Okta, go to the **General** tab of the Salesforce app.
2. Add your **custom domain**.
    - ⚠️ Do **not** include `my.salesforce.com` in this field.

**Step 5: Configure Advanced Sign-On Settings (Okta)**

1. In Okta, go to the **Sign-On** tab of the Salesforce app → **Advanced Sign-On Settings**.
2. Enter the **Login URL** and **Logout URL** saved from Step 3.
3. Check **Enable Single Logout** if SP-initiated single logout is desired.

**Step 6: Configure the Signing Certificate**

1. Copy the `ds:X509` certificate value from Okta's metadata/setup page.
2. Create a `.cert` file formatted as:

```
   -----BEGIN CERTIFICATE-----
   [CERTIFICATE VALUE]
   -----END CERTIFICATE-----
```

3. Upload this `.cert` file into the **Signature Certificate** field (Salesforce SAML config).

**Step 7: Configure Single Logout**

1. Copy the **SingleLogoutService URL** from the Okta metadata file.
2. Paste it into **Identity Provider Single Logout** in the Salesforce SAML setup.
3. Check **Single Logout Enabled** in both Salesforce and Okta.
4. Click **Save** in Salesforce.

**Step 8: Enable SP-Initiated SAML**

1. In Salesforce, set up a **custom domain** (if not already done).
2. In Salesforce **Single Sign-On Settings**, add the custom domain into the **Entity ID** field.
3. In Okta, return to the **General** tab for the Salesforce app, add the same custom domain (without `my.salesforce.com`), and **Save**.
4. Recheck the **Login URL** in Salesforce's Single Sign-On Settings page and **Save**.

**Step 9: Set Okta as the Default Authentication Service**

1. In Salesforce, go to **My Domain**.
2. Under **Authentication Configuration**, check the box next to the Okta instance configured in Single Sign-On Settings.
3. Click **Save**.
---
### Deliverables

**Sequence Diagram of the SAML SP-Initiated flow built**
![SP-Initiated Flow|617](./SP-Initiated_Flow_Seq_Diagram.dark.svg)


**Screenshot of IdP-initiated SSO landing on Salesforce**
Okta Dashboard for Stephen Curry:
![](Attachments/Pasted%20image%2020261008214054.png)

Salesforce Page for Stephen Curry:
![](Attachments/Pasted%20image%2020261008214130.png)

**SAML Tracer screenshot showing decoded assertion with FederationIdentifier (NameID) highlighted**
![](Attachments/Pasted%20image%2020261008214313.png)

**Okta Salesforce app configuration screenshot (Sign On tab)**

![](Attachments/Pasted%20image%2020261008215221.png)

![](Attachments/Pasted%20image%2020261008215257.png)

**Salesforce SSO configuration screenshot**

![](Attachments/Pasted%20image%2020261008215456.png)

---
### Key Concepts Recap

#### 1. The SAML actors and the Assertion

Three parties are involved in every SAML login:

- **User**: the person trying to get into an app (e.g. LeBron opening Salesforce).
- **Service Provider (SP)**: the app being accessed. Here, Salesforce.
- **Identity Provider (IdP)**: the system that authenticates the user and vouches for them. Here, Okta.

Salesforce never sees LeBron's Okta password. Instead, Okta verifies him and sends Salesforce an **Assertion**: a signed XML document that says, in effect, "I am Okta, I authenticated this person just now, here is who they are, and this message is intended for Salesforce." Salesforce accepts it because it was configured in advance to trust Okta's certificate.

_Analogy:_ a passport. The border officer (Salesforce) doesn't know you personally, but trusts the issuing government (Okta) and checks the document's security features (signature).

#### 2. IdP-initiated vs SP-initiated flow

The difference is **where the user starts**, and that changes the sequence of messages.

- **IdP-initiated:** the user is already in Okta and clicks the Salesforce tile. Okta builds the assertion and the browser posts it straight to Salesforce. Two hops.
- **SP-initiated:** the user types the Salesforce URL directly. Salesforce has no session for them, so it sends an **AuthnRequest** redirecting the browser to Okta ("please authenticate this person, and send them back here afterwards"). Okta authenticates, then returns the assertion to Salesforce. This needs the extra round trip because Okta wouldn't otherwise know which app the user was heading to or where to send the response.

_Why both matter:_ IdP-initiated is common for dashboard-style access. SP-initiated is what happens when users click bookmarks or email links to Salesforce, which in practice is most of the time.

#### 3. X.509 certificates and signature validation

Okta signs each assertion with its **private key**. Salesforce holds Okta's **public certificate** (the one you pasted into the Signature Certificate field) and uses it to check the signature. If the signature checks out, Salesforce knows two things: the assertion really came from Okta, and nobody altered it in transit.

_Failure scenario:_ if Okta rotates its signing certificate and Salesforce still has the old public cert, every login fails with a signature validation error even though nothing else changed. This is why certificate expiry tracking is a standard operational task in SSO programmes.

#### 4. FederationIdentifier (the matching problem)

A valid, signed assertion isn't enough. Salesforce still has to decide _which Salesforce user_ the assertion refers to. It does this by comparing a value in the assertion against the **Federation ID** field on user records.

_Example:_ Okta sends `FederationIdentifier = lebron.james@mambaairlines.com`. Salesforce searches its users for that exact Federation ID. If the Salesforce record has `lebron.james@mamba-airlines.com` instead (one character different), no match is found and login fails, despite everything else being correct.

This is the most common real-world SAML failure: the cryptography is fine, the _identity data_ doesn't line up.

#### 5. My Domain

My Domain gives your Salesforce org its own unique login URL (e.g. `yourcompany.my.salesforce.com`) instead of the shared generic one.

- **SP-initiated SSO needs it:** Salesforce has to know which org, and therefore which IdP configuration, the user is trying to reach before it can redirect them to Okta. A shared generic URL can't answer that.
- **IdP-initiated SSO doesn't strictly need it at the protocol level**, because the assertion carries what Salesforce needs to validate it.
- **In practice it's effectively mandatory today:** Salesforce enforces My Domain for all orgs, and Okta's app config uses your domain values for the ACS URL and Entity ID.

#### 6. Audience restriction

Every assertion states which SP it is meant for (the Audience, which matches Salesforce's Entity ID). Salesforce rejects any assertion addressed to a different audience.

_Why this exists:_ without it, an assertion issued for a low-security app could be captured and replayed against Salesforce. Audience restriction ties each assertion to one intended recipient.

This is also why the Entity ID in your Salesforce config and the Audience value in Okta must match exactly, which is why the custom domain step appears on both sides.

#### 7. Clock skew and assertion validity

Assertions carry timestamps (`NotBefore` and `NotOnOrAfter`) that define a short validity window, usually a few minutes. If Okta's clock and Salesforce's clock disagree by more than the tolerance, a perfectly good assertion looks either "not yet valid" or "expired" and gets rejected.

_Why the window is short:_ a stolen assertion is only usable for a very brief period, which limits replay attacks.

#### 8. Single Logout (SLO)

Normal SSO logs you _in_ everywhere from one place. Without SLO, logging out of Okta leaves your Salesforce session alive. With SLO configured (the logout URLs and checkboxes in your steps), signing out of one side tells the other to end its session too.