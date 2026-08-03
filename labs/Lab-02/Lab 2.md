# Steps Performed for the setup
---
## Phase 1: Set Up AD Domain, OUs, and Users (`DC01`)

### Step 1: Install AD DS & Promote Domain

1. Open Server Manager on DC01 > Add Roles and Features > Select Active Directory Domain Services (AD DS).
2. Complete the setup and click Promote this server to a domain controller.
3. Select Add a new forest, enter lab.local as the domain name, set the DSRM password, and finish the installation.   

### Step 2: Create OUs, Users, and Groups

1. Open Active Directory Users and Computers (ADUC) .
2. Right-click lab.local > New > Organizational Unit to create the 5 OUs:
    - FlightOps
    - Finance
    - IT
    - Contractors
    - Management
3. Create NBA test personas inside their target OUs.
4. Fill out user properties: First Name, Last Name, Email, Department, Job Title.
## Phase 2: Install Okta AD Agent & Delegate Permissions
### Step 1: Download Agent from Okta
1. Open the Okta Admin Console as Super Admin.
2. Go to Directory > Directory Integrations > Add Directory > Add Active Directory.
3. Download the Okta AD Agent setup file onto DC01.
### Step 2: Run Installer with Auto-Created Service Account
1. Run the Agent installer.
2. Choose your domain `lab.local`.
3. When prompted for the service account, select Create or use the OktaService account to let the installer auto-create `OktaService`.
4. Enter the Okta tenant URL (`[https://mamba-airlines.okta.com](https://mamba-airlines.okta.com)`) and complete the OAuth authorization window in the browser.

### Step 3: Run Delegation of Control Wizard in ADUC

1. Open ADUC, right-click the root domain `lab.local`, and select Delegate Control.(`For making sure that the agent can make changes in the domain - for eg: Create/Delete users, read users`)
2. Click Add, type `OktaService` (or the service account name created by the installer), and click OK.
3. Select Delegate the following common tasks:
    - Create, delete, and manage all user accounts.
    - Reset user passwords and force password change at next logon (if handling password resets).
    - Read all user information.
    - Modify the membership of a group.
## Phase 3: Map OUs & Configure Import Settings

1. In the Okta Admin Console, go to Directory Integrations > Active Directory > Provisioning > Integration.
2. Under User OUs connected to Okta, select FlightOps, Finance, IT, Contractors, and Management.
3. Choose your Okta Username format (I used email address).
4. Go to Security > Delegated Authentication and confirm Enable delegated authentication to Active Directory is checked.
5. Under Provisioning > To Okta, verify the attribute mappings for department, jobTitle, and manager.

## Phase 4: Import Users & Test Authentication

1. Go to Directory > Directory Integrations > Active Directory > Import.
2. Click Import Now > Full Import, then confirm/assign the imported users.
3. Verify Profile: Open LeBron James in Okta Universal Directory and ensure his profile lists department=FlightOps as AD-sourced.
4. Test DelAuth: Open an Incognito window and log into Okta using LeBron's AD password.
5. Test Real-Time Sync: Reset LeBron's password on DC01 in ADUC and immediately sign into Okta with the new password to prove delegated authentication works instantly.


---
# Architecture diagram: DC01 -> Okta AD Agent -> Okta Cloud
![Architecture Diagram](./AD_Okta%20Architecture.dark.svg)


---
# Outputs
---
## Okta AD Agent shows status "Connected" in Okta Admin Console
![](Attachments/Pasted%20image%2020260727135608.png)

---
## AD users from your OUs (FlightOps, Finance, IT, Contractors, Management) imported into Okta
![](Attachments/Pasted%20image%2020260730092324.png)

---
## Okta user profiles show AD-sourced attributes: department, jobTitle, manager DN
![](Attachments/Pasted%20image%2020260730092855.png)

---
## Successful delegated authentication test
![](Attachments/Pasted%20image%2020260731115021.png)
![](Attachments/Lab2excalidraw.excalidraw)
![](Attachments/Pasted%20image%2020260731115134.png)

---
