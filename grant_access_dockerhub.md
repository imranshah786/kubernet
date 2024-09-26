# Grant our lab access to your private repository on DockerHub.
> if your docker image is stored in a public repository on DockerHub, you do not need to do anything.

To grant our lab account **ebdbcb** access to your private repository on DockerHub so that we can pull your docker images, you need to follow these steps:

- create an *Organization* (if you don't already have one):
    - log into DockerHub. In the top-right corner, click your profile icon and select *Organizations*.
    - click *Create Organization*, fill out the required information, and create your organization.


- create a *Team*:
    - in your organization's settings, go to the *Teams* tab.
    - click *Create Team* and give it a name.


- add the *ebdbcb* user to the *Team*:
    - select your newly created team.
    - click *Invite Members* and add the user *ebdbcb*.
    - select the permissions for the *ebdbcb* user (only *read* access).


- share the repository:
    - go to your private repository. In the repository settings, assign the repository to the team.
    - choose the level of access the team should have (read).

Now, our lab account *ebdbcb* can access your private repository and kubernetes will be able to pull the docker images you want to use in your workflow.
