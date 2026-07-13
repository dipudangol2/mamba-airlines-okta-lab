# Tenant Branding with custom logo and color scheme
For creating a new tenant with custom logo and color, in the admin dashboard go to customizations > Brands and create a new brand with the name *"Mamba Airlines"*. Once the Brand is created - click on the newly created brand and customize the tenant with the logo and color of you choice. 
- Go to `Admin console > Customizations > Brands > Create Brand` to create a new brand. 
- Choose the logo of your choice, Add color scheme you like, change favicon for the page for the brand and you can also customize the login and logout page or include the login/logout flow of your own.
- There are many other options such as custom pages, emails for different activities, custom domains setup and other settings like animation, privacy policy, etc.

![Pasted image 20260712223946](./Attachments/Pasted%20image%2020260712223946.png)

![Pasted image 20260712224005](./Attachments/Pasted%20image%2020260712224005.png)

---
# All seven NBA personas exist as Okta users with profile attributes populated
You can add users from `Admin Console > Directories > People` . When creating users you are able to only fill up Name, email and password if you want to set one up. If you need to populate other fields like department, title and many others you can do so after user creation and edit the user profile.

![Pasted image 20260712223706](./Attachments/Pasted%20image%2020260712223706.png)

---
# Ten Groups created per Section 6
You can add groups similar to the way you add users. Go to `Admin Console > Directories > Groups`. When creating groups you are only able to set name and description for the group.
![Pasted image 20260712223637](./Attachments/Pasted%20image%2020260712223637.png)

---
# Three admin roles assigned: Kobe Bryant as Super Admin, Kawhi Leonard as Read-Only Admin, Tim Duncan as Application Admin
You can assign administrator roles by going to `Admin Console > Security > Administrators > Admins` and clicking Add Administrator. Select a user and the type of admin you want to create.
![Pasted image 20260712223545](./Attachments/Pasted%20image%2020260712223545.png)

---
# MFA enrollment policy requires all users to enrol Okta Verify within 7 days 

![Pasted image 20260712223423](./Attachments/Pasted%20image%2020260712223423.png)

---
# Password policy: minimum 12 characters, complexity required, 90-day expiry

![Password Policy set](./Attachments/Pasted%20image%2020260712222305.png)

![Password Expiry](./Attachments/Pasted%20image%2020260712222824.png)

---
# Postman GET /api/v1/users returns all seven personas with a 200 response

![Postman API get all users](Attachments/Pasted%20image%2020260713110338.png)

---
