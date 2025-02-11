# Continuous Deployment Tutorial

## Intro

The goal of this tutorial is to practice contiuous deployment using GitHub Actions. This corresponds to Task 1 of this assignment.

At the end of these steps, you should be able to see the flask app deployed to a public IP you control (e.g., something like [http://4.172.209.91:6969](http://4.172.209.91:6969)), and any changes to your repo would get automatically deployed to this site.

## Create a VM on Azure

Please follow the instructions [here](https://azure.microsoft.com/en-us/free/students) to receive your \$100 free Azure credit. The rest of this tutorial assumes you already have free access to create Azure VMs.

1. Go to [https://portal.azure.com](https://portal.azure.com)
2. Click on `Create a resource`
3. Click on `Create` under `Virtual Machine`
4. Fill in the form as follows:

	- **Subscription:** Azure for Students 
	- **Resource group:** Leave as New Resource group
	- **Virtual machine name:** `cs3260` (you can choose whatever name you like but the rest of this tutorial will use this name)
	- **Region:** ?? (I believe it auto populates the closest one; if not, choose a region that makes sense)
	- **Availability zone:** leave as Zones 1
	- **Security type:** leave as Trusted launch virtual machines
	- **Image:** Ubuntu Server 22.04 LTS - x64 Gen2
	- **VM architecture:** x64
	- **Run with Azure Spot discount:** leave unchecked
	- **Size:** Standard_B1s - 1 vcpu, 1GiB memory
	- **Enable Hibernation**: leave unchecked
	- **Authentication** SSH public key
	- **Username:** `azureuser` (you can choose whatever username you want but the rest of this tutorial will use this name)
	- **SSH public key source:** Generate new key pair
	- **Key pair name:** leave default which will be machinename_key (i.e., `cs3260_key`)
	- **Public inbound ports:**  Allow selected ports
	- **Select inbound ports:** Click on the drop down and select `HTTP (80)`, `HTTPS (443)`, `SSH (22)`

![](Images/VM1.jpg)
![](Images/VM2.jpg)
![](Images/VM3.jpg)

	
5. Click `Review + create`
6. Review the settings and click `Create`
7. **IMPORTANT** you will get a popup as follows asking you if you want to download your private key. Cick on `Download private key and create resource` and save the `.pem` file. Move the downloaded `cs3260_key.pem` file to a location on your computer (e.g., `~/Teaching`). Do NOT share this with anyone and never commit your keys to a repository.

8. A private key should not be accessible by any user or group on the machine. Therefore, we need to properly set its permission

```
cd ~/Teaching
chmod 400 cs3260_key.pem
```


9. Now click on `Go to resource`. You should see a public IP address in the right column of the machine details. Copy that IP address. 

Now, let's test that your machine

This is the form of the command you will use from your terminal:

`ssh -i <path to pem file> <username>@<ip address>`

So for example for me, this would translate to:

`ssh -i ~/Teaching/cs3260_key.pem azureuser@4.172.209.91` 

Type `yes` to the prompt.

And voila! You should see the VM's terminal:

```
azureuser@cs3260:~$ 
```

## Installing docker and docker-compose

Once you're inside of the VM, you need to install docker, because we will be using it to run our web application.

To install docker on the VM, we have to follow the following steps from [the official Docker instructions](https://docs.docker.com/engine/install/ubuntu/#install-using-the-repository)

```
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
sudo chmod a+r /etc/apt/keyrings/docker.gpg

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update

sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

Now we need to make sure we don't need sudo to run the `docker` command. Execute the commands below one by one:

```
sudo addgroup --system docker
sudo adduser $USER docker
newgrp docker
```

## Allow connections to the target port

The flask app we will deploy uses port `6969` for its docker deployment. We need to tell the Azure VM to allow connections to that port. To do so:

1. In your browser, go to [portal.azure.com](portal.azure.com)
2. Click on the name of your VM in the list of resources in front of you (`cs3260` in this example)
3. On the left hand side, click on `Network settings`
4. Click on `Create port rule` --> `Inbound port rule`
5. Change the port number to `6969`
6. Click `Add`


## Preparing your Repo for Continuous Deployment

To deploy an app to the VM, we need a way for GitHub actions to connect to the VM. Similar to how you just ssh'd into the machine, we want GitHub actions to be able to ssh into the machine. This means that GitHub actions needs three pieces of info (1) the IP of the VM, (2) the private key to use to connect to the VM, and (3) the username it is connecting to. All these three pieces of info should not be publicly shared and should not be committed to your repository. 

GitHub offers [secrets](https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions) to allow storing such sensitive information that you can later use in your GitHub actions workflows.

To add a secret, go to the repository's Settings on Github, under Security menu click on `Secrets and Variables` and then `Actions`. On the opened page, click on `New Repository Secret` to add a new secret key value pair. You will need to add the following 4 secrets (the 4th one is the ssh port):

1. `HOST` is the reachable address of the machine (`4.172.209.91` in the above example)
2. `USERNAME` is the username of the OS that we created (`azureuser` by default)
3. `KEY` is the contents of the private key we generated (i.e., the `cs3260_key.pem` you downloaded above)
4. `PORT` is the SSH port which is 22.

Note that no one, including yourself, can view the values of secrets once created (but you can replace their values). Secrets are also **not** copied to any forks of your repository.

You will use the above secrets in your github workflow file.


## Adding a Deploy workflow file

We are now ready to create our GitHub actions workflow file to deploy the (flask) app.

In the repository that contains your web application, create a new file `.github/workflows/deploy.yml`.

Now you need to figure out what should go into your `deploy.yml` file and how to use the secrets you created above to tell github actions where to deploy to. Your goal with this deploy workflow is to copy the contents of the repo to the VM you are going to deploy to and then run docker compose to run the website on the VM.

Once you push any changes to your repo, you should be able to see your application at `http://<ipaddress>:6969` 

Here are some useful actions you may want to read about and use:

- [actions/checkout](https://github.com/actions/checkout)
- [apple-boy/scp-action](https://github.com/appleboy/scp-action)
- [apple-boy/ssh-action](https://github.com/appleboy/ssh-action)





