# minecraft-container
**Minecraft container project**
  based off of this blog article: http://www.blog.juliaferraioli.com/2015/06/running-minecraft-server-on-google.html
***

*Build and run a Dockerfile to run a stateless Minecraft server on own PC*
- Clone and pull Dockerfile
- Build Dockerfile with
```docker build -t {YOUR DOCKERHUB USERNAME}/ubuntu-minecraft-server:1.10.2 . ```
- Run minecraft server container with
```docker run -d -p 25565:25565 {YOUR DOCKERHUB USERNAME}/ubuntu-minecraft-server:1.10.2```
- Server should be accessible on local machine at ```127.0.0.1:25565```
- Terminate the server with
```docker kill {CONTAINER ID}```

*Add state using volume mounts*
- Run the minecraft server container with the following volume mount:
```docker run -d -p 25565:25565 -v ~/minecraft-server-data/:/data/ {YOUR DOCKERHUB USERNAME}/ubuntu-minecraft-server:1.10.2```
- Terminate the server with
```docker kill {CONTAINER ID}```

---

**Using AWS and REX-Ray to Host a Persistent Minecraft Server in the Cloud**

*Setup AWS VM*
- Navigate to the AWS EC2 Dashboard and click the blue "Launch Instance" button
 - You should be in Step 1, below select the "Ubuntu Server 14.04 LTS (HVM), SSD Volume Type" AMI
 - Step 2: choose the t2.micro
 - Step 3: the default under the subnet category will choose an availability zone for your vm automatically
                this is fine, however upon creating future VMs, make sure they are all in the same subnet
                if you would like them to share storage volumes.

 - Step 4: leave defaults
 - Step 5: give the virtual machine a unique, descriptive name. Under "Key" enter "Name" and under "Value" enter your desired name
 - Step 6: configure the security group, leave the SSH port, but underneath click "Add Rule" and add a Custom TCP Rule
                enter 25565 in the Port Range field and set Source to "Anywhere"
 - Step 7: review and hit the "Launch" button, configure your SSH keys and launch the instance
- Startup may take several minutes, navigate to the Instances menu and when the 2 status checks complete ssh into the machine

*Install REX-Ray and Docker*
At this point you should be ssh-ed into your AWS Ubuntu virtual machine, enter the following commands into the terminal:

``` sudo apt-get update ```

``` sudo apt-get upgrade -y ```

``` curl -sSL https://dl.bintray.com/emccode/rexray/install | sh -s -- stable 0.3.3 ```

Modify the /etc/rexray/config.yml file(requires sudo)
``` sudo vi /etc/rexray/config.yml ```
Enter the following, replacing the AWS keys appropriately:
```
rexray:
  storageDrivers:
  - ec2
  volume:
    mount:
      preempt: true
    unmount:
      ignoreUsedCount: true
aws:
  accessKey: {YOUR AWS ACCESS KEY}
  secretKey: {YOUR AWS SECRET KEY}
```

Then save and exit the config.yml file. Continue in the SSH terminal

Next we'll install Docker using this curl and Docker's install script

``` curl -sSL https://get.docker.com/ | sh ```

To use Docker without sudo, we’ll have to add our user to the “docker” group.  Our username in this case is “ubuntu”.  You might have to change your username based on your settings for the AWS instance.

``` sudo usermod -aG docker ubuntu ```

Then logout
 ``` exit ```

*Pulling and Running the Minecraft-Server Container* 
 
SSH back into your AWS VM
Check that docker and rexray are installed and working correctly

```rexray version```

```docker ps```

List available storage volumes with `rexray volume list`

Make sure the rexray daemon is running

``` sudo service rexray start ```

Let's create a storage volume for our Minecraft server

``` rexray volume create --size=16 --volumename=mc-server-volume ```

Now if you look under Volumes in your AWS webpage the mc-server-volume should show up

To run the minecraft server enter the following:

``` docker run -d -p 25565:25565 --volume-driver=rexray -v mc-server-volume:/data akiraw95/ubuntu-minecraft-server:1.10.2 ```

Wait for the image to pull from dockerhub or build it yourself from the github repo.

Once docker spits out a container ID, the server is accessible from anywhere at the same IP that you SSH-ed into at port 25565.

To terminate the server enter: `docker kill {CONTAINER ID}`
To bring it up again, enter the same command as before- the server state should be persistent.
